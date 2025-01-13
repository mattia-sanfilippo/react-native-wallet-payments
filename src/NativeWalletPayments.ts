import type { TurboModule } from 'react-native';
import { TurboModuleRegistry } from 'react-native';

export interface Spec extends TurboModule {
  canMakePayments(): Promise<boolean>;
  showPaymentSheet(data: Object): Promise<string>;
  updateShippingMethods(shippingMethods: Array<Object>): void;
  updateSummaryItems(summaryItems: Array<Object>): void;
  confirmPayment(): void;
  rejectPayment(): void;
}

export default TurboModuleRegistry.getEnforcing<Spec>('WalletPayments');
