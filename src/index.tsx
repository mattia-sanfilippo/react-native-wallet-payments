import WalletPayments from './NativeWalletPayments';

export { useApplePay } from './useApplePay';
export { default as ApplePayButton } from './ApplePayButton';

export type SummaryItem = {
  label: string;
  amount: string;
};

export type ContactField =
  | 'name'
  | 'postalAddress'
  | 'emailAddress'
  | 'phoneNumber'
  | 'phoneticName';

export type PaymentNetwork =
  | 'amex'
  | 'bancontact'
  | 'bankAxept'
  | 'barcode'
  | 'cartesBancaires'
  | 'chinaUnionPay'
  | 'dankort'
  | 'discover'
  | 'eftpos'
  | 'electron'
  | 'elo'
  | 'girocard'
  | 'idCredit'
  | 'interac'
  | 'jcb'
  | 'mada'
  | 'maestro'
  | 'masterCard'
  | 'meeza'
  | 'mir'
  | 'nanaco'
  | 'napas'
  | 'pagoBancomat'
  | 'postFinance'
  | 'quicPay'
  | 'suica'
  | 'tmoney'
  | 'visa'
  | 'vPay'
  | 'waon';

export type MerchantCapabilities =
  | '3DS' // 3D Secure
  | 'EMV' // EMV chip
  | 'credit' // Credit cards
  | 'debit'; // Debit cards

export type ShippingType =
  | 'shipping'
  | 'delivery'
  | 'storePickup'
  | 'servicePickup';

export type PaymentRequest = {
  merchantId: string;
  countryCode: string;
  currencyCode: string;
  supportedNetworks: Array<PaymentNetwork>;
  supportedCountries?: Array<string>;
  merchantCapabilities: Array<MerchantCapabilities>;
  items: Array<SummaryItem>;
  shippingMethods?: Array<{
    label: string;
    amount: string;
    identifier: string;
    detail: string;
  }>;
  shippingType?: ShippingType;
  requiredBillingContactFields?: Array<ContactField>;
  requiredShippingContactFields?: Array<ContactField>;
};

export type Contact = {
  postalAddress: {
    street: string;
    city: string;
    state: string;
    postalCode: string;
    subLocality: string;
    subAdministrativeArea: string;
    country: string;
    isoCountryCode: string;
  };
  emailAddress: string;
  phoneNumber: string;
  name: {
    familyName: string;
    middleName: string;
    givenName: string;
    namePrefix: string;
    nameSuffix: string;
    nickname: string;
    phoneticRepresentation: {
      familyName: string;
      middleName: string;
      givenName: string;
    };
  };
};

export type ShippingMethod = {
  label: string;
  amount: string;
  identifier: string;
  detail: string;
};

export type PaymentResult = {
  token: string;
  transactionIdentifier: string;
  paymentMethod: {
    displayName: string;
    network: string;
  };
  billingContact?: Partial<Contact>;
  shippingContact?: Partial<Contact>;
  shippingMethod?: ShippingMethod;
};

/**
 * canMakePayments
 * This function checks if the device supports Apple Pay and if the user has any cards added.
 * @returns {Promise<boolean>} - A promise that resolves with a boolean value.
 */
export function canMakePayments(): Promise<boolean> {
  return WalletPayments.canMakePayments();
}

/**
 * showPaymentSheet
 * This function invokes the native Apple Pay sheet with the provided payment data.
 * @param {PaymentData} data - The payment request details including merchant info, items, and optional fields.
 * @returns {Promise<PaymentResult>} - A promise that resolves with the payment result.
 */
export function showPaymentSheet(data: PaymentRequest): Promise<string> {
  return WalletPayments.showPaymentSheet(data);
}

/**
 * updateShippingMethods
 * This function updates the shipping methods in the Apple Pay sheet.
 * It can be called after the application receives the shipping contact details
 * from the event listener.
 */
export function updateShippingMethods(
  shippingMethods: Array<ShippingMethod>
): void {
  WalletPayments.updateShippingMethods(shippingMethods);
}

/**
 * updateSummaryItems
 * This function updates the summary items in the Apple Pay sheet.
 * It can be called after the application receives the shipping method details
 * from the event listener.
 */
export function updateSummaryItems(summaryItems: Array<SummaryItem>): void {
  WalletPayments.updateSummaryItems(summaryItems);
}

/**
 * confirmPayment
 * This function confirms the payment with the provided status and errors and closes the Apple Pay sheet.
 * if the function is not called, the Apple Pay sheet will remain open and it will go into a timeout state (handled by Apple's internal logic).
 */
export function confirmPayment(): void {
  WalletPayments.confirmPayment();
}

/**
 * rejectPayment
 * This function rejects the payment.
 */
export function rejectPayment(): void {
  WalletPayments.rejectPayment();
}
