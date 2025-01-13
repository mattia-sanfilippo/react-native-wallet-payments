#import "WalletPaymentsApplePayButtonManager.h"
#import "WalletPaymentsApplePayButton.h"

@implementation WalletPaymentsApplePayButtonManager

RCT_EXPORT_MODULE(WalletPaymentsApplePayButton)

RCT_EXPORT_VIEW_PROPERTY(buttonType, NSInteger)
RCT_EXPORT_VIEW_PROPERTY(buttonStyle, NSInteger)
RCT_EXPORT_VIEW_PROPERTY(cornerRadius, CGFloat)
RCT_EXPORT_VIEW_PROPERTY(onPress, RCTBubblingEventBlock)

- (UIView *)view {
    return [[WalletPaymentsApplePayButton alloc] init];
}

@end
