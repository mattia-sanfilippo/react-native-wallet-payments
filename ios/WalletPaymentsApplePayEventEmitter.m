#import "WalletPaymentsApplePayEventEmitter.h"

static NSString* onShippingContactSelected = @"onShippingContactSelected";
static NSString* onShippingMethodSelected = @"onShippingMethodSelected";
static NSString* onPaymentAuthorized = @"onPaymentAuthorized";

static WalletPaymentsApplePayEventEmitter* eventEmitter = nil;

@implementation WalletPaymentsApplePayEventEmitter

RCT_EXPORT_MODULE(WalletPaymentsApplePayEventEmitter);

- (instancetype)init {
  if (self = [super init]) {
    eventEmitter = self;
  }
  return self;
}

+ (BOOL)requiresMainQueueSetup {
    return NO;
}

+ (instancetype)shared {
  return eventEmitter;
}

- (NSArray<NSString *> *)supportedEvents {
  return @[onShippingContactSelected, onShippingMethodSelected, onPaymentAuthorized];
}

@end
