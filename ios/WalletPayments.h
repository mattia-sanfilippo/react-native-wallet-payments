#import <PassKit/PassKit.h>

#ifdef RCT_NEW_ARCH_ENABLED
#import "generated/RNWalletPaymentsSpec/RNWalletPaymentsSpec.h"

// New Architecture Interface
@interface WalletPayments : NSObject <NativeWalletPaymentsSpec, PKPaymentAuthorizationControllerDelegate>

#else

#import <React/RCTBridgeModule.h>

// Old Architecture Interface
@interface WalletPayments : NSObject <RCTBridgeModule, PKPaymentAuthorizationControllerDelegate>

#endif

@property (nonatomic, copy) RCTPromiseResolveBlock _Nullable resolveBlock;
@property (nonatomic, copy) RCTPromiseRejectBlock _Nullable rejectBlock;

@property (nonatomic, strong) NSArray<PKPaymentSummaryItem *> *cachedSummaryItems;
@property (nonatomic, strong) NSArray<PKShippingMethod *> *cachedShippingMethods;

@property (nonatomic, copy) void (^pendingShippingContactCompletion)(PKPaymentRequestShippingContactUpdate *update);
@property (nonatomic, copy) void (^pendingShippingMethodCompletion)(PKPaymentRequestShippingMethodUpdate *update);
@property (nonatomic, copy) void (^pendingPaymentAuthorizationCompletion)(PKPaymentAuthorizationResult *update);

@end
