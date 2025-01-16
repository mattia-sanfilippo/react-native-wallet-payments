package com.walletpayments

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.bridge.ReadableMap

class WalletPaymentsModule(reactContext: ReactApplicationContext) : NativeWalletPaymentsSpec(reactContext) {
    private var implementation: WalletPaymentsModuleImpl = WalletPaymentsModuleImpl()
    
    override fun getName(): String {
        return NAME
    }

    override fun canMakePayments(promise: Promise) {
        implementation.canMakePayments(promise)
    }

    override fun showPaymentSheet(data: ReadableMap?, promise: Promise) {
        implementation.showPaymentSheet(data, promise)
    }

    override fun updateShippingMethods(shippingMethods: ReadableArray?) {
        implementation.updateShippingMethods(shippingMethods)
    }

    override fun updateSummaryItems(summaryItems: ReadableArray?) {
        implementation.updateSummaryItems(summaryItems)
    }

    override fun confirmPayment(promise: Promise) {
        implementation.confirmPayment(promise)
    }

    override fun rejectPayment(promise: Promise) {
        implementation.rejectPayment(promise)
    }

    companion object {
        const val NAME = "WalletPayments"
    }
}
