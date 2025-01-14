package com.walletpayments

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.module.ReactContextBaseJavaModule

abstract class WalletPaymentsSpec(context: ReactApplicationContext) : ReactContextBaseJavaModule(context) {
    abstract fun canMakePayments(promise: Promise)
    abstract fun showPaymentSheet(data: ReadableMap?, promise: Promise)
    abstract fun updateShippingMethods(shippingMethods: ReadableArray?)
    abstract fun updateSummaryItems(summaryItems: ReadableArray?)
    abstract fun confirmPayment()
    abstract fun rejectPayment()
}