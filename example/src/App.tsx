import { useCallback } from 'react';
import { Alert, View, StyleSheet } from 'react-native';
import {
  ApplePayButton,
  confirmPayment,
  updateShippingMethods,
  updateSummaryItems,
  useApplePay,
  type Contact,
  type ShippingMethod,
} from 'react-native-wallet-payments';

const App = () => {
  const onShippingContactSelected = useCallback((contact: Contact) => {
    if (contact?.postalAddress?.isoCountryCode === 'PL') {
      updateShippingMethods([
        {
          label: 'Poland Standard Shipping',
          amount: '10.00',
          identifier: 'standard',
          detail: 'Delivers in 5-7 business days',
        },
        {
          label: 'Poland Express Shipping',
          amount: '20.00',
          identifier: 'express',
          detail: 'Delivers in 2-3 business days',
        },
      ]);
    }

    if (contact?.postalAddress?.isoCountryCode === 'IT') {
      updateShippingMethods([
        {
          label: 'Italy Standard Shipping',
          amount: '15.00',
          identifier: 'standard',
          detail: 'Delivers in 5-7 business days',
        },
        {
          label: 'Italy Express Shipping',
          amount: '25.00',
          identifier: 'express',
          detail: 'Delivers in 2-3 business days',
        },
      ]);
    }
  }, []);

  const onShippingMethodSelected = useCallback((method: ShippingMethod) => {
    updateSummaryItems([
      { label: 'Product 1', amount: '10.00' },
      { label: 'Product 2', amount: '5.00' },
      { label: 'Shipping', amount: method.amount },
      {
        label: 'Total',
        amount: (15 + parseFloat(method.amount)).toFixed(2),
      },
    ]);
  }, []);

  const { startPayment } = useApplePay(
    onShippingContactSelected,
    onShippingMethodSelected
  );

  const handleApplePay = async () => {
    try {
      const result = await startPayment({
        merchantId: 'merchant.example.wallet-payments',
        countryCode: 'IT',
        currencyCode: 'EUR',
        supportedNetworks: ['visa', 'masterCard'],
        merchantCapabilities: ['3DS'],
        items: [
          { label: 'Product 1', amount: '10.00' },
          { label: 'Product 2', amount: '5.00' },
          { label: 'Total', amount: '15.00' },
        ],
        billingContact: {
          name: {
            givenName: 'John',
            familyName: 'Doe',
          },
          postalAddress: {
            street: 'Via Roma 156',
            city: 'Rome',
            state: 'RM',
            postalCode: '00100',
            country: 'Italy',
            isoCountryCode: 'IT',
          },
          phoneNumber: '+39 333 1234567',
          emailAddress: 'test@johndoe.com',
        },
        shippingContact: {
          name: {
            givenName: 'John',
            familyName: 'Doe',
          },
          postalAddress: {
            street: 'Via Roma 145',
            city: 'Rome',
            state: 'RM',
            postalCode: '00100',
            country: 'Italy',
            isoCountryCode: 'IT',
          },
          phoneNumber: '+39 333 1234567',
          emailAddress: 'test@johndoe.com',
        },
        requiredShippingContactFields: [
          'name',
          'postalAddress',
          'emailAddress',
          'phoneNumber',
        ],
        requiredBillingContactFields: [
          'name',
          'emailAddress',
          'postalAddress',
          'phoneNumber',
        ],
        shippingMethods: [
          {
            label: 'Standard Shipping',
            amount: '5.00',
            identifier: 'standard',
            detail: 'Delivers in 5-7 business days',
          },
          {
            label: 'Express Shipping',
            amount: '10.00',
            identifier: 'express',
            detail: 'Delivers in 2-3 business days',
          },
        ],
      });

      console.log(result);

      await confirmPayment();

      Alert.alert('Payment Successful');
    } catch (error) {
      Alert.alert('Payment Failed');
    }
  };

  return (
    <View style={styles.container}>
      <ApplePayButton
        onPress={handleApplePay}
        style={styles.applePayButton}
        buttonType="buy"
        buttonStyle="automatic"
        cornerRadius={4}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#f5f5f5',
  },
  applePayButton: {
    width: 200,
    height: 50,
  },
});

export default App;
