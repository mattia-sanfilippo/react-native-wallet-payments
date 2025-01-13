#import <UIKit/UIKit.h>
#import <React/RCTViewManager.h>
#import <PassKit/PassKit.h>

@interface WalletPaymentsApplePayButton : UIView

@property (nonatomic, assign) PKPaymentButtonType buttonType; // Button type
@property (nonatomic, assign) PKPaymentButtonStyle buttonStyle; // Button style
@property (nonatomic, assign) CGFloat cornerRadius; // Corner radius
@property (nonatomic, copy) RCTBubblingEventBlock onPress; // Callback for button press

@end
