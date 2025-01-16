package com.walletpayments

import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.bridge.ReadableMap

class WalletPaymentsModuleImpl {
    fun canMakePayments(promise: Promise) {
        promise.resolve(false)
    }

    fun showPaymentSheet(data: ReadableMap?, promise: Promise) {
        promise.reject("E_NOT_IMPLEMENTED", "Apple Pay is not available on Android")
    }

    fun updateShippingMethods(shippingMethods: ReadableArray?) {
        // No-op
    }

    fun updateSummaryItems(summaryItems: ReadableArray?) {
        // No-op
    }

    fun confirmPayment() {
        // No-op
    }

    fun rejectPayment() {
        // No-op
    }

    companion object {
        const val NAME = "WalletPayments"
    }
}