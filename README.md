# react-native-wallet-payments

![main workflow](https://github.com/mattia-sanfilippo/react-native-wallet-payments/actions/workflows/ci.yml/badge.svg)
[![npm version](https://badge.fury.io/js/react-native-wallet-payments.svg)](https://badge.fury.io/js)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A powerful React Native library that provides a **customizable Apple Pay button** and full **Apple Pay integration** on iOS. The goal is to offer a **unified library** for handling multiple wallet-based payment systems, including **Google Pay** and **Samsung Pay**, in future versions.

---

## **Features**

- **Full Apple Pay support** on iOS.
- **Customizable Apple Pay button** with support for all button types and styles.
- Dynamic shipping options and summary items update during the payment process.
- **Future Support** planned for **Google Pay** and **Samsung Pay** on Android.

---

## Installation

```bash
npm install react-native-wallet-payments
# or
yarn add react-native-wallet-payments
```

### Additional iOS Setup

```bash
cd ios
pod install
```

1. **Add the Apple Pay capability** to your app in Xcode. Open your project in Xcode, navigate to the **Signing & Capabilities** tab, and click the **+ Capability** button. Search for **Apple Pay** and add it to your project.
2. **Add the Merchant ID** to the Apple Pay capability. Press the **+** button below **Merchant IDs** and enter your **Merchant ID** that is registered with Apple Pay in the Apple Developer Portal.

See the [Apple Pay documentation](https://developer.apple.com/documentation/passkit/setting-up-apple-pay) for more information.


## Usage

### Apple Pay

```typescript

const { startPayment, confirmPayment, rejectPayment } = useApplePay();

const handleApplePay = async () => {
  try {
    const paymentRequest = {
      merchantIdentifier: 'merchant.com.example',
      supportedNetworks: ['visa', 'masterCard'],
      countryCode: 'US',
      currencyCode: 'USD',
      paymentSummaryItems: [
        {
          label: 'Item 1',
          amount: '1.00',
        },
        {
          label: 'Item 2',
          amount: '2.00',
        },
      ],
    };

    const paymentResponse = await startPayment(paymentRequest);

    // Do any additional processing before confirming the payment

    // Confirm the payment to complete the transaction and show a success message on the Payment Sheet
    confirmPayment(paymentResponse.paymentData);
  } catch (error) {
    // Handle errors by showing an error on the Payment Sheet and rejecting the payment
    rejectPayment();
  }
};

return (
    <ApplePayButton
        type="buy"
        style={{ width: 200, height: 50 }}
        cornerRadius={4}
        onPress={handleApplePay}
    />
);

```




## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
