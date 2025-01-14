package com.walletpayments

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.module.annotations.ReactModule

@ReactModule(name = WalletPaymentsModule.NAME)
class WalletPaymentsModule(reactContext: ReactApplicationContext) :
  NativeWalletPaymentsSpec(reactContext) {

  override fun getName(): String {
    return NAME
  }

  @ReactMethod
  override fun canMakePayments(promise: Promise) {
    promise.resolve(false)
  }

  @ReactMethod
  override fun showPaymentSheet(data: ReadableMap?, promise: Promise) {
    promise.reject("E_NOT_IMPLEMENTED", "Apple Pay is not available on Android")
  }

  @ReactMethod
  override fun updateShippingMethods(shippingMethods: ReadableArray?) {
    // No-op
  }

  @ReactMethod
  override fun updateSummaryItems(summaryItems: ReadableArray?) {
    // No-op
  }

  @ReactMethod
  override fun confirmPayment() {
    // No-op
  }

  @ReactMethod
  override fun rejectPayment() {
    // No-op
  }

  companion object {
    const val NAME = "WalletPayments"
  }
}
