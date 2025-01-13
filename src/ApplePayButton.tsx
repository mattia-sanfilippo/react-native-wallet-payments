import {
  Platform,
  requireNativeComponent,
  type StyleProp,
  type ViewStyle,
} from 'react-native';

type ButtonTypes =
  | 'plain'
  | 'buy'
  | 'addMoney'
  | 'book'
  | 'checkout'
  | 'continue'
  | 'contribute'
  | 'donate'
  | 'inStore'
  | 'order'
  | 'reload'
  | 'rent'
  | 'setUp'
  | 'subscribe'
  | 'support'
  | 'tip'
  | 'topUp';

type ButtonStyles = 'black' | 'white' | 'whiteOutline' | 'automatic';

type ApplePayButtonProps = {
  buttonType?: ButtonTypes;
  buttonStyle?: ButtonStyles;
  cornerRadius?: number;
  onPress: () => void;
  style?: StyleProp<ViewStyle>;
};

const NativeApplePayButton = requireNativeComponent<
  Omit<ApplePayButtonProps, 'buttonType' | 'buttonStyle'> & {
    buttonType: number;
    buttonStyle: number;
    cornerRadius: number;
  }
>('WalletPaymentsApplePayButton');

const buttonTypeMap: Record<
  NonNullable<ApplePayButtonProps['buttonType']>,
  number
> = {
  plain: 0, // PKPaymentButtonTypePlain
  buy: 1, // PKPaymentButtonTypeBuy
  setUp: 2, // PKPaymentButtonTypeSetUp
  inStore: 3, // PKPaymentButtonTypeInStore
  donate: 4, // PKPaymentButtonTypeOrder
  checkout: 5, // PKPaymentButtonTypeCheckout
  book: 6, // PKPaymentButtonTypeBook
  subscribe: 7, // PKPaymentButtonTypeSubscribe
  reload: 8, // PKPaymentButtonTypeReload
  addMoney: 9, // PKPaymentButtonTypeAddMoney
  topUp: 10, // PKPaymentButtonTypeTopUp
  order: 11, // PKPaymentButtonTypeOrder
  rent: 12, // PKPaymentButtonTypeRent
  support: 13, // PKPaymentButtonTypeSupport
  contribute: 14, // PKPaymentButtonTypeContribute
  tip: 15, // PKPaymentButtonTypeTip
  continue: 16, // PKPaymentButtonTypeContinue
};

const buttonStyleMap: Record<
  NonNullable<ApplePayButtonProps['buttonStyle']>,
  number
> = {
  white: 0, // PKPaymentButtonStyleWhite
  whiteOutline: 1, // PKPaymentButtonStyleWhiteOutline
  black: 2, // PKPaymentButtonStyleBlack
  automatic: 3, // PKPaymentButtonStyleAutomatic
};

const ApplePayButton = ({
  buttonType = 'plain',
  buttonStyle = 'black',
  cornerRadius = 4,
  onPress,
  style,
}: ApplePayButtonProps) => {
  const isIos = Platform.OS === 'ios';

  return isIos ? (
    <NativeApplePayButton
      onPress={onPress}
      style={style}
      buttonStyle={buttonStyleMap[buttonStyle]}
      buttonType={buttonTypeMap[buttonType]}
      cornerRadius={cornerRadius}
    />
  ) : null;
};

export default ApplePayButton;
