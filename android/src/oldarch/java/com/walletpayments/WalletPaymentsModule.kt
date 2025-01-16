package com.walletpayments

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod

class WalletPaymentsModule(context: ReactApplicationContext) : ReactContextBaseJavaModule(context) {
    private var implementation = WalletPaymentsModuleImpl()
    
    override fun getName(): String {
        return NAME
    }

    @ReactMethod
    fun canMakePayments(promise: Promise) {
        implementation.canMakePayments(promise)
    }

    @ReactMethod
    fun showPaymentSheet(data: ReadableMap?, promise: Promise) {
        implementation.showPaymentSheet(data, promise)
    }

    @ReactMethod
    fun updateShippingMethods(shippingMethods: ReadableArray?) {
        implementation.updateShippingMethods(shippingMethods)
    }

    @ReactMethod
    fun updateSummaryItems(summaryItems: ReadableArray?) {
        implementation.updateSummaryItems(summaryItems)
    }

    @ReactMethod
    fun confirmPayment() {
        implementation.confirmPayment()
    }

    @ReactMethod
    fun rejectPayment() {
        implementation.rejectPayment()
    }

    companion object {
        const val NAME = "WalletPayments"
    }
}