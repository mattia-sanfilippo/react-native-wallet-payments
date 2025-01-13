
#import <PassKit/PassKit.h>
#import "generated/RNWalletPaymentsSpec/RNWalletPaymentsSpec.h"

@interface WalletPayments : NSObject <NativeWalletPaymentsSpec, PKPaymentAuthorizationControllerDelegate>

@property (nonatomic, copy) RCTPromiseResolveBlock _Nullable resolveBlock;
@property (nonatomic, copy) RCTPromiseRejectBlock _Nullable rejectBlock;

@property (nonatomic, strong) NSArray<PKPaymentSummaryItem *> *cachedSummaryItems;
@property (nonatomic, strong) NSArray<PKShippingMethod *> *cachedShippingMethods;

@property (nonatomic, copy) void (^pendingShippingContactCompletion)(PKPaymentRequestShippingContactUpdate *update);
@property (nonatomic, copy) void (^pendingShippingMethodCompletion)(PKPaymentRequestShippingMethodUpdate *update);
@property (nonatomic, copy) void (^pendingPaymentAuthorizationCompletion)(PKPaymentAuthorizationResult *update);

@end
