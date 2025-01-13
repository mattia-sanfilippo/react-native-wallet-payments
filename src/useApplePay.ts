import { useCallback, useEffect, useRef } from 'react';
import { NativeEventEmitter, NativeModules } from 'react-native';
import {
  showPaymentSheet,
  confirmPayment as confirmPaymentNative,
  rejectPayment as rejectPaymentNative,
  type PaymentRequest,
  type PaymentResult,
  type Contact,
  type ShippingMethod,
} from 'react-native-wallet-payments';

const { WalletPaymentsApplePayEventEmitter } = NativeModules;
const applePayEmitter = new NativeEventEmitter(
  WalletPaymentsApplePayEventEmitter
);

export const useApplePay = (
  onShippingContactSelected: (contact: Contact) => void,
  onShippingMethodSelected: (method: ShippingMethod) => void
) => {
  const subscriptions = useRef<any[]>([]);

  useEffect(() => {
    const contactSubscription = applePayEmitter.addListener(
      'onShippingContactSelected',
      (contact) => {
        onShippingContactSelected(contact);
      }
    );

    const methodSubscription = applePayEmitter.addListener(
      'onShippingMethodSelected',
      (method) => {
        onShippingMethodSelected(method);
      }
    );

    subscriptions.current = [contactSubscription, methodSubscription];

    return () => {
      subscriptions.current.forEach((sub) => sub.remove());
    };
  }, [onShippingContactSelected, onShippingMethodSelected]);

  /**
   * startPayment
   * This function starts the Apple Pay payment process with the provided payment request options.
   * @param {PaymentRequest} options - The payment request details including merchant info, items, and optional fields.
   * @returns {Promise<PaymentResult>} - A promise that resolves with the payment result.
   * @throws {Error} - An error is thrown if the payment process fails.
   * @example
   * const result = await startPayment({
   *    merchantIdentifier: 'merchant.com.example',
   *    countryCode: 'US',
   *    currencyCode: 'USD',
   *    supportedNetworks: ['visa', 'masterCard', 'amex'],
   *    merchantCapabilities: ['3DS'],
   *    items: [
   *        { label: 'Product 1', amount: '10.00' },
   *        { label: 'Product 2', amount: '5.00' },
   *    ],
   * });
   */
  const startPayment = async (
    options: PaymentRequest
  ): Promise<PaymentResult> => {
    return new Promise((resolve, reject) => {
      const paymentAuthorizedSubscription = applePayEmitter.addListener(
        'onPaymentAuthorized',
        (paymentInfo) => {
          paymentAuthorizedSubscription.remove();
          resolve(paymentInfo);
        }
      );

      showPaymentSheet(options).catch((error) => {
        paymentAuthorizedSubscription.remove();
        reject(error);
      });
    });
  };

  const confirmPayment = useCallback(() => {
    confirmPaymentNative();
  }, []);

  const rejectPayment = useCallback(() => {
    rejectPaymentNative();
  }, []);

  return {
    startPayment,
    confirmPayment,
    rejectPayment,
  };
};
