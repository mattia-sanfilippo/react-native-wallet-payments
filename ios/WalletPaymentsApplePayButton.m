#import "WalletPaymentsApplePayButton.h"
#import <PassKit/PassKit.h>

@implementation WalletPaymentsApplePayButton {
    PKPaymentButton *applePayButton;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Default button type and style
        _buttonType = PKPaymentButtonTypeAddMoney;
        _buttonStyle = PKPaymentButtonStyleBlack;
        _cornerRadius = 4.0;
        [self createApplePayButton];
    }
    return self;
}

- (void)setButtonType:(PKPaymentButtonType)buttonType {
    if (_buttonType != buttonType) {
        _buttonType = buttonType;
        [self createApplePayButton];
    }
}

- (void)setButtonStyle:(PKPaymentButtonStyle)buttonStyle {
    if (_buttonStyle != buttonStyle) {
        _buttonStyle = buttonStyle;
        [self createApplePayButton];
    }
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    applePayButton.layer.cornerRadius = cornerRadius;
    applePayButton.clipsToBounds = YES; // Ensure corners are clipped
}

- (void)createApplePayButton {
    [applePayButton removeFromSuperview]; // Remove the old button if it exists

    applePayButton = [PKPaymentButton buttonWithType:_buttonType style:_buttonStyle];
    applePayButton.layer.cornerRadius = _cornerRadius;
    applePayButton.clipsToBounds = YES;
    [applePayButton addTarget:self action:@selector(handlePress) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:applePayButton];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    applePayButton.frame = self.bounds;
}

- (void)handlePress {
    if (self.onPress) {
        self.onPress(@{});
    }
}

@end
