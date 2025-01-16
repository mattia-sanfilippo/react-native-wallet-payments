#import "WalletPayments.h"
#import "WalletPaymentsApplePayEventEmitter.h"

@implementation WalletPayments

RCT_EXPORT_MODULE()

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

RCT_EXPORT_METHOD(canMakePayments:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    resolve(@([PKPaymentAuthorizationController canMakePayments]));
}

RCT_EXPORT_METHOD(showPaymentSheet:(NSDictionary *)data
                          resolve:(RCTPromiseResolveBlock)resolve
                          reject:(RCTPromiseRejectBlock)reject)
{


    // Check if Apple Pay is available
    if (![PKPaymentAuthorizationController canMakePayments]) {
        reject(@"E_UNAVAILABLE", @"This device cannot make Apple Pay payments", nil);
        return;
    }

    self.resolveBlock = resolve;
    self.rejectBlock = reject;

    // Extract payment request options
    NSString *merchantId = data[@"merchantId"];
    NSString *countryCode = data[@"countryCode"];
    NSString *currencyCode = data[@"currencyCode"];
    
    NSArray<NSString *> *supportedCountries = data[@"supportedCountries"];
  
    NSString *shippingType = data[@"shippingType"];

    NSArray<PKPaymentNetwork> *supportedNetworks = [self mapSupportedNetworks:data[@"supportedNetworks"]];
    PKMerchantCapability merchantCapabilities = [self mapMerchantCapabilities:data[@"merchantCapabilities"]];

    NSArray *items = data[@"items"];

    // Set up payment summary items
    NSMutableArray<PKPaymentSummaryItem *> *paymentSummaryItems = [NSMutableArray new];
    for (NSDictionary *item in items) {
        NSString *label = item[@"label"];
        NSDecimalNumber *amount = [NSDecimalNumber decimalNumberWithString:item[@"amount"]];
        [paymentSummaryItems addObject:[PKPaymentSummaryItem summaryItemWithLabel:label amount:amount]];
    }

    self.cachedSummaryItems = paymentSummaryItems;

    PKPaymentRequest *paymentRequest = [[PKPaymentRequest alloc] init];
    paymentRequest.merchantIdentifier = merchantId;
    paymentRequest.countryCode = countryCode;
    paymentRequest.currencyCode = currencyCode;
    paymentRequest.paymentSummaryItems = paymentSummaryItems;
    paymentRequest.supportedNetworks = supportedNetworks;
    paymentRequest.merchantCapabilities = merchantCapabilities;

    // Optional: Handle supported countries if provided. Default is all supported countries.
    if (supportedCountries) {
        paymentRequest.supportedCountries = [[NSSet alloc] initWithArray:supportedCountries];
    }
  
    // Optional: Prefill billing contact address if provided. Default is nil.
    if (data[@"billingContact"]) {
      PKContact *billingContact = [self mapContactFromData:data[@"billingContact"]];
      paymentRequest.billingContact = billingContact;
    }
  
    // Optional: Prefill shipping contact address if provided. Default is nil.
    if (data[@"shippingContact"]) {
      PKContact *shippingContact = [self mapContactFromData:data[@"shippingContact"]];
      paymentRequest.shippingContact = shippingContact;
    }
  
    // Optional: Handle shipping type if provided. Default is PKShippingTypeShipping.
    NSDictionary<NSString *, NSNumber *> *shippingTypeMap = @{
      @"delivery": @(PKShippingTypeDelivery),
      @"servicePickup": @(PKShippingTypeServicePickup),
      @"storePickup": @(PKShippingTypeStorePickup),
      @"shipping": @(PKShippingTypeShipping)
    };
  
    if (shippingType && shippingTypeMap[shippingType]) {
      paymentRequest.shippingType = (PKShippingType)[shippingTypeMap[shippingType] integerValue];
    }
      
    // Optional: Handle shipping methods if provided
    if (data[@"shippingMethods"]) {
        NSMutableArray<PKShippingMethod *> *shippingMethods = [NSMutableArray new];
        for (NSDictionary *method in data[@"shippingMethods"]) {
            PKShippingMethod *shippingMethod = [[PKShippingMethod alloc] init];
            shippingMethod.label = method[@"label"];
            shippingMethod.amount = [NSDecimalNumber decimalNumberWithString:method[@"amount"]];
            shippingMethod.identifier = method[@"identifier"];
            shippingMethod.detail = method[@"detail"];
            [shippingMethods addObject:shippingMethod];
        }
        paymentRequest.shippingMethods = shippingMethods;
    } else {
        paymentRequest.shippingMethods = nil;
    }

    self.cachedShippingMethods = paymentRequest.shippingMethods;

    NSDictionary<NSString *, PKContactField> *contactFieldMapping = @{
        @"name": PKContactFieldName,
        @"postalAddress": PKContactFieldPostalAddress,
        @"emailAddress": PKContactFieldEmailAddress,
        @"phoneNumber": PKContactFieldPhoneNumber,
        @"phoneticName": PKContactFieldPhoneticName
    };

    // Optional: Handle required billing contact fields if provided
    if (data[@"requiredBillingContactFields"]) {
        NSMutableSet<PKContactField> *requiredFields = [NSMutableSet new];
        for (NSString *field in data[@"requiredBillingContactFields"]) {
            PKContactField mappedField = contactFieldMapping[field];
            if (mappedField) {
                [requiredFields addObject:mappedField];
            } else {
                NSLog(@"Warning: Unsupported billing contact field '%@'", field);
            }
        }
        paymentRequest.requiredBillingContactFields = requiredFields;
    }

    // Optional: Handle required shipping contact fields if provided
    if (data[@"requiredShippingContactFields"]) {
        NSMutableSet<PKContactField> *requiredFields = [NSMutableSet new];
        for (NSString *field in data[@"requiredShippingContactFields"]) {
            PKContactField mappedField = contactFieldMapping[field];
            if (mappedField) {
                [requiredFields addObject:mappedField];
            } else {
                NSLog(@"Warning: Unsupported shipping contact field '%@'", field);
            }
        }
        paymentRequest.requiredShippingContactFields = requiredFields;
    }

    // Show the payment sheet
    PKPaymentAuthorizationController *paymentController = [[PKPaymentAuthorizationController alloc] initWithPaymentRequest:paymentRequest];
    paymentController.delegate = self;

    [paymentController presentWithCompletion:^(BOOL presented) {
        if (presented) {
            NSLog(@"Presented payment controller");
        } else {
            NSLog(@"Failed to present payment controller");
            self.rejectBlock(@"E_PRESENTATION_FAILED", @"Failed to present payment controller", nil);
        }
    }];
}

RCT_EXPORT_METHOD(updateShippingMethods:(NSArray *)shippingMethods)
{
    NSMutableArray<PKShippingMethod *> *updatedMethods = [NSMutableArray new];

    for (NSDictionary *methodData in shippingMethods) {
        PKShippingMethod *method = [[PKShippingMethod alloc] init];
        method.label = methodData[@"label"];
        method.amount = [NSDecimalNumber decimalNumberWithString:methodData[@"amount"]];
        method.identifier = methodData[@"identifier"];
        method.detail = methodData[@"detail"];
        [updatedMethods addObject:method];
    }

    self.cachedShippingMethods = updatedMethods;
  
  if (self.pendingShippingContactCompletion) {
    PKPaymentRequestShippingContactUpdate *update;
    
    NSLog(@"Updating shipping methods");
    
    if (updatedMethods.count == 0) {
      NSError *error = [PKPaymentRequest paymentShippingAddressUnserviceableErrorWithLocalizedDescription:@"Shipping is not available for the selected address."];
      update = [[PKPaymentRequestShippingContactUpdate alloc] initWithErrors:@[error] paymentSummaryItems:self.cachedSummaryItems shippingMethods:updatedMethods];
    } else {
      update = [[PKPaymentRequestShippingContactUpdate alloc] initWithErrors:nil
                                                         paymentSummaryItems:self.cachedSummaryItems shippingMethods:updatedMethods];
    }
    
    self.pendingShippingContactCompletion(update);
    self.pendingShippingContactCompletion = nil;
  }
}

RCT_EXPORT_METHOD(updateSummaryItems:(NSArray *)summaryItems)
{
    NSMutableArray<PKPaymentSummaryItem *> *updatedItems = [NSMutableArray new];

    for (NSDictionary *itemData in summaryItems) {
        NSString *label = itemData[@"label"];
        NSDecimalNumber *amount = [NSDecimalNumber decimalNumberWithString:itemData[@"amount"]];
        [updatedItems addObject:[PKPaymentSummaryItem summaryItemWithLabel:label amount:amount]];
    }

    self.cachedSummaryItems = updatedItems;

    if (self.pendingShippingMethodCompletion) {
        PKPaymentRequestShippingMethodUpdate *update = [[PKPaymentRequestShippingMethodUpdate alloc] initWithPaymentSummaryItems:self.cachedSummaryItems];
        self.pendingShippingMethodCompletion(update);
        self.pendingShippingMethodCompletion = nil;
    }
}

RCT_EXPORT_METHOD(confirmPayment)
{
  
  NSLog(@"Confirming payment");
  
  if (self.pendingPaymentAuthorizationCompletion) {
    PKPaymentAuthorizationStatus status = PKPaymentAuthorizationStatusSuccess;
    
    PKPaymentAuthorizationResult *result = [[PKPaymentAuthorizationResult alloc] initWithStatus:status errors:nil];
    self.pendingPaymentAuthorizationCompletion(result);
    
    // Clear the completion handlers
    self.pendingPaymentAuthorizationCompletion = nil;
    self.pendingShippingContactCompletion = nil;
    self.pendingShippingMethodCompletion = nil;
    self.cachedSummaryItems = nil;
    self.cachedShippingMethods = nil;
  } else {
    NSLog(@"No pending completion handler found for confirming payment");
  }
}

RCT_EXPORT_METHOD(rejectPayment)
{
  if (self.pendingPaymentAuthorizationCompletion) {
    NSLog(@"Rejecting payment");
    
    PKPaymentAuthorizationResult *result = [[PKPaymentAuthorizationResult alloc] initWithStatus:PKPaymentAuthorizationStatusFailure errors:nil];
    
    self.pendingPaymentAuthorizationCompletion(result);
    
    // Clear the completion handlers
    self.pendingPaymentAuthorizationCompletion = nil;
    self.pendingShippingContactCompletion = nil;
    self.pendingShippingMethodCompletion = nil;
    self.cachedSummaryItems = nil;
    self.cachedShippingMethods = nil;
    
  } else {
    NSLog(@"No pending completion handler found for rejecting payment");
  }
}

#pragma mark - PKPaymentAuthorizationControllerDelegate

- (void)paymentAuthorizationController:(PKPaymentAuthorizationController *)controller
                   didAuthorizePayment:(PKPayment *)payment
                                handler:(void (^)(PKPaymentAuthorizationResult *result))completion
{
    NSLog(@"Payment authorized");

    self.pendingPaymentAuthorizationCompletion = completion;

    NSString *token = [[NSString alloc] initWithData:payment.token.paymentData encoding:NSUTF8StringEncoding];
  
    NSDictionary *paymentMethod = @{
        @"displayName": payment.token.paymentMethod.displayName ?: @"",
        @"network": payment.token.paymentMethod.network ?: @"",
    };

    NSDictionary *billingContact = payment.billingContact ? @{
        @"name": @{
            @"givenName": payment.billingContact.name.givenName ?: @"",
            @"middleName": payment.billingContact.name.middleName ?: @"",
            @"familyName": payment.billingContact.name.familyName ?: @"",
            @"namePrefix": payment.billingContact.name.namePrefix ?: @"",
            @"nameSuffix": payment.billingContact.name.nameSuffix ?: @"",
            @"nickname": payment.billingContact.name.nickname ?: @"",
            @"phoneticRepresentation": @{
                @"familyName": payment.billingContact.name.phoneticRepresentation.familyName ?: @"",
                @"middleName": payment.billingContact.name.phoneticRepresentation.middleName ?: @"",
                @"givenName": payment.billingContact.name.phoneticRepresentation.givenName ?: @""
            }
        },
        @"postalAddress": @{
            @"street": payment.billingContact.postalAddress.street ?: @"",
            @"city": payment.billingContact.postalAddress.city ?: @"",
            @"state": payment.billingContact.postalAddress.state ?: @"",
            @"postalCode": payment.billingContact.postalAddress.postalCode ?: @"",
            @"country": payment.billingContact.postalAddress.country ?: @"",
            @"isoCountryCode": payment.billingContact.postalAddress.ISOCountryCode ?: @"",
            @"subAdministrativeArea": payment.billingContact.postalAddress.subAdministrativeArea ?: @"",
            @"subLocality": payment.billingContact.postalAddress.subLocality ?: @""
        },
        @"phoneNumber": payment.billingContact.phoneNumber ? payment.billingContact.phoneNumber.stringValue : @"",
        @"emailAddress": payment.billingContact.emailAddress ?: @""
    } : @{};

    NSDictionary *shippingContact = payment.shippingContact ? @{
        @"name": @{
            @"givenName": payment.shippingContact.name.givenName ?: @"",
            @"middleName": payment.shippingContact.name.middleName ?: @"",
            @"familyName": payment.shippingContact.name.familyName ?: @"",
            @"namePrefix": payment.shippingContact.name.namePrefix ?: @"",
            @"nameSuffix": payment.shippingContact.name.nameSuffix ?: @"",
            @"nickname": payment.shippingContact.name.nickname ?: @"",
            @"phoneticRepresentation": @{
                @"familyName": payment.shippingContact.name.phoneticRepresentation.familyName ?: @"",
                @"middleName": payment.shippingContact.name.phoneticRepresentation.middleName ?: @"",
                @"givenName": payment.shippingContact.name.phoneticRepresentation.givenName ?: @""
            }
        },
        @"postalAddress": @{
            @"street": payment.shippingContact.postalAddress.street ?: @"",
            @"city": payment.shippingContact.postalAddress.city ?: @"",
            @"state": payment.shippingContact.postalAddress.state ?: @"",
            @"postalCode": payment.shippingContact.postalAddress.postalCode ?: @"",
            @"country": payment.shippingContact.postalAddress.country ?: @"",
            @"isoCountryCode": payment.shippingContact.postalAddress.ISOCountryCode ?: @"",
            @"subAdministrativeArea": payment.shippingContact.postalAddress.subAdministrativeArea ?: @"",
            @"subLocality": payment.shippingContact.postalAddress.subLocality ?: @""
        },
        @"phoneNumber": payment.shippingContact.phoneNumber ? payment.shippingContact.phoneNumber.stringValue : @"",
        @"emailAddress": payment.shippingContact.emailAddress ?: @""
    } : @{};

    NSDictionary *shippingMethod = payment.shippingMethod ? @{
        @"label": payment.shippingMethod.label ?: @"",
        @"amount": [payment.shippingMethod.amount stringValue] ?: @"",
        @"identifier": payment.shippingMethod.identifier ?: @"",
        @"detail": payment.shippingMethod.detail ?: @""
    } : @{};

    NSDictionary *paymentInfo = @{
        @"token": token ?: @"",
        @"transactionIdentifier": payment.token.transactionIdentifier ?: @"",
        @"paymentMethod": paymentMethod,
        @"billingContact": billingContact,
        @"shippingContact": shippingContact,
        @"shippingMethod": shippingMethod
    };

    [WalletPaymentsApplePayEventEmitter.shared sendEventWithName:@"onPaymentAuthorized" body:paymentInfo];
}


- (void)paymentAuthorizationControllerDidFinish:(PKPaymentAuthorizationController *)controller
{
    NSLog(@"Payment controller finished");
    [controller dismissWithCompletion:nil];
  
    self.pendingPaymentAuthorizationCompletion = nil;
    self.pendingShippingContactCompletion = nil;
    self.cachedSummaryItems = nil;
    self.cachedShippingMethods = nil;

    // If the payment was not authorized, reject the promise
    if (self.resolveBlock) {
        self.rejectBlock(@"E_USER_CANCELLED", @"The user cancelled the payment", nil);
        self.resolveBlock = nil;
        self.rejectBlock = nil;
    }
}

- (void)paymentAuthorizationController:(PKPaymentAuthorizationController *)controller
               didSelectShippingContact:(PKContact *)contact
                                handler:(void (^)(PKPaymentRequestShippingContactUpdate *update))completion
{
    self.pendingShippingContactCompletion = completion;

    NSDictionary *contactDict = @{
        @"phoneNumber": contact.phoneNumber ? contact.phoneNumber.stringValue : @"",
        @"emailAddress": contact.emailAddress ?: @"",
        @"name": @{
            @"givenName": contact.name.givenName ?: @"",
            @"familyName": contact.name.familyName ?: @"",
        },
        @"postalAddress": @{
            @"city": contact.postalAddress.city ?: @"",
            @"state": contact.postalAddress.state ?: @"",
            @"street": contact.postalAddress.street ?: @"",
            @"subAdministrativeArea": contact.postalAddress.subAdministrativeArea ?: @"",
            @"subLocality": contact.postalAddress.subLocality ?: @"",
            @"postalCode": contact.postalAddress.postalCode ?: @"",
            @"country": contact.postalAddress.country ?: @"",
            @"isoCountryCode": contact.postalAddress.ISOCountryCode ?: @""
        }
    };

    [WalletPaymentsApplePayEventEmitter.shared sendEventWithName:@"onShippingContactSelected" body:contactDict];
}

- (void)paymentAuthorizationController:(PKPaymentAuthorizationController *)controller
               didSelectShippingMethod:(PKShippingMethod *)shippingMethod
                                handler:(void (^)(PKPaymentRequestShippingMethodUpdate *update))completion
{
    self.pendingShippingMethodCompletion = completion;

    NSDictionary *methodDict = @{
        @"label": shippingMethod.label ?: @"",
        @"amount": [shippingMethod.amount stringValue] ?: @"",
        @"identifier": shippingMethod.identifier ?: @"",
        @"detail": shippingMethod.detail ?: @""
    };

    [WalletPaymentsApplePayEventEmitter.shared sendEventWithName:@"onShippingMethodSelected" body:methodDict];
}

- (NSDictionary<NSString *, PKPaymentNetwork> *)availablePaymentNetworks {
    static NSMutableDictionary<NSString *, PKPaymentNetwork> *networkMap;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        networkMap = [NSMutableDictionary new];

        // Always available networks
        networkMap[@"amex"] = PKPaymentNetworkAmex;
        networkMap[@"cartesbancaires"] = PKPaymentNetworkCartesBancaires;
        networkMap[@"chinaunionpay"] = PKPaymentNetworkChinaUnionPay;
        networkMap[@"dankort"] = PKPaymentNetworkDankort;
        networkMap[@"discover"] = PKPaymentNetworkDiscover;
        networkMap[@"eftpos"] = PKPaymentNetworkEftpos;
        networkMap[@"electron"] = PKPaymentNetworkElectron;
        networkMap[@"elo"] = PKPaymentNetworkElo;
        networkMap[@"girocard"] = PKPaymentNetworkGirocard;
        networkMap[@"idcredit"] = PKPaymentNetworkIDCredit;
        networkMap[@"interac"] = PKPaymentNetworkInterac;
        networkMap[@"jcb"] = PKPaymentNetworkJCB;
        networkMap[@"mada"] = PKPaymentNetworkMada;
        networkMap[@"maestro"] = PKPaymentNetworkMaestro;
        networkMap[@"mastercard"] = PKPaymentNetworkMasterCard;
        networkMap[@"mir"] = PKPaymentNetworkMir;
        networkMap[@"nanaco"] = PKPaymentNetworkNanaco;
        networkMap[@"quicpay"] = PKPaymentNetworkQuicPay;
        networkMap[@"suica"] = PKPaymentNetworkSuica;
        networkMap[@"visa"] = PKPaymentNetworkVisa;
        networkMap[@"vpay"] = PKPaymentNetworkVPay;
        networkMap[@"waon"] = PKPaymentNetworkWaon;

        // Conditionally available networks based on iOS version
        if (@available(iOS 16.0, *)) {
            networkMap[@"bancontact"] = PKPaymentNetworkBancontact;
        }

        if (@available(iOS 16.4, *)) {
            networkMap[@"postfinance"] = PKPaymentNetworkPostFinance;
        }

        if (@available(iOS 17.0, *)) {
            networkMap[@"pagobancomat"] = PKPaymentNetworkPagoBancomat;
            networkMap[@"tmoney"] = PKPaymentNetworkTmoney;
        }

        if (@available(iOS 17.4, *)) {
            networkMap[@"meeza"] = PKPaymentNetworkMeeza;
        }

        if (@available(iOS 17.5, *)) {
            networkMap[@"bankaxept"] = PKPaymentNetworkBankAxept;
            networkMap[@"barcode"] = PKPaymentNetworkBarcode;
            networkMap[@"napas"] = PKPaymentNetworkNAPAS;
        }
    });
    return [networkMap copy];
}


- (NSArray<PKPaymentNetwork> *)mapSupportedNetworks:(NSArray<NSString *> *)networkStrings {
    NSDictionary<NSString *, PKPaymentNetwork> *networkMap = [self availablePaymentNetworks];
    NSMutableArray<PKPaymentNetwork> *networks = [NSMutableArray new];

    for (NSString *networkString in networkStrings) {
        PKPaymentNetwork network = networkMap[networkString.lowercaseString];
        if (network) {
            [networks addObject:network];
        } else {
            NSLog(@"Warning: Unsupported payment network %@", networkString);
        }
    }

    return networks;
}

- (PKMerchantCapability)mapMerchantCapabilities:(NSArray<NSString *> *)capabilities {
    PKMerchantCapability merchantCapabilities = 0;

    NSDictionary<NSString *, NSNumber *> *capabilityMap = @{
        @"3DS": @(PKMerchantCapability3DS),
        @"EMV": @(PKMerchantCapabilityEMV),
        @"credit": @(PKMerchantCapabilityCredit),
        @"debit": @(PKMerchantCapabilityDebit),
    };

    for (NSString *capability in capabilities) {
        NSNumber *nativeCapability = capabilityMap[capability];
        if (nativeCapability) {
            merchantCapabilities |= [nativeCapability unsignedIntegerValue];
        } else {
            NSLog(@"Warning: Unsupported merchant capability %@", capability);
        }
    }

    return merchantCapabilities;
}

- (PKContact *)mapContactFromData:(NSDictionary *)contactData {
    PKContact *contact = [[PKContact alloc] init];

    // Map name
    NSDictionary *nameData = contactData[@"name"];
    if (nameData) {
        NSPersonNameComponents *nameComponents = [[NSPersonNameComponents alloc] init];
        nameComponents.givenName = nameData[@"givenName"];
        nameComponents.familyName = nameData[@"familyName"];
        nameComponents.middleName = nameData[@"middleName"];
        nameComponents.namePrefix = nameData[@"namePrefix"];
        nameComponents.nameSuffix = nameData[@"nameSuffix"];
        nameComponents.nickname = nameData[@"nickname"];

        NSDictionary *phoneticRepresentation = nameData[@"phoneticRepresentation"];
        if (phoneticRepresentation) {
            NSPersonNameComponents *phoneticComponents = [[NSPersonNameComponents alloc] init];
            phoneticComponents.givenName = phoneticRepresentation[@"givenName"];
            phoneticComponents.familyName = phoneticRepresentation[@"familyName"];
            phoneticComponents.middleName = phoneticRepresentation[@"middleName"];
            nameComponents.phoneticRepresentation = phoneticComponents;
        }

        contact.name = nameComponents;
    }

    // Map postal address
    NSDictionary *postalAddressData = contactData[@"postalAddress"];
    if (postalAddressData) {
        CNMutablePostalAddress *postalAddress = [[CNMutablePostalAddress alloc] init];
        postalAddress.street = postalAddressData[@"street"];
        postalAddress.city = postalAddressData[@"city"];
        postalAddress.state = postalAddressData[@"state"];
        postalAddress.postalCode = postalAddressData[@"postalCode"];
        postalAddress.country = postalAddressData[@"country"];
        postalAddress.ISOCountryCode = postalAddressData[@"isoCountryCode"];
        postalAddress.subAdministrativeArea = postalAddressData[@"subAdministrativeArea"];
        postalAddress.subLocality = postalAddressData[@"subLocality"];
        contact.postalAddress = postalAddress;
    }

    // Map email address
    contact.emailAddress = contactData[@"emailAddress"];

    // Map phone number
    NSString *phoneNumber = contactData[@"phoneNumber"];
    if (phoneNumber) {
        contact.phoneNumber = [[CNPhoneNumber alloc] initWithStringValue:phoneNumber];
    }

    return contact;
}


#ifdef RCT_NEW_ARCH_ENABLED
- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
    return std::make_shared<facebook::react::NativeWalletPaymentsSpecJSI>(params);
}
#endif

@end
