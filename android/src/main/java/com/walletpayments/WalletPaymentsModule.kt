package com.walletpayments

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.module.annotations.ReactModule

@ReactModule(name = WalletPaymentsModule.NAME)
class WalletPaymentsModule(reactContext: ReactApplicationContext) :
  NativeWalletPaymentsSpec(reactContext) {

  override fun getName(): String {
    return NAME
  }

  override fun canMakePayments(promise: Promise) {
    promise.resolve(false)
  }

  override fun showPaymentSheet(data: ReadableMap?, promise: Promise) {
    promise.reject("E_NOT_IMPLEMENTED", "Apple Pay is not available on Android")
  }

  override fun updateShippingMethods(shippingMethods: ReadableArray?) {
    // No-op
  }

  override fun updateSummaryItems(summaryItems: ReadableArray?) {
    // No-op
  }

  override fun confirmPayment() {
    // No-op
  }

  override fun rejectPayment() {
    // No-op
  }

  companion object {
    const val NAME = "WalletPayments"
  }
}
