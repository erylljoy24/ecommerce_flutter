package com.hs.magri

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity

// Use this for finger/face scan
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugin.common.MethodChannel

import com.paymaya.sdk.android.checkout.PayMayaCheckout
import com.paymaya.sdk.android.checkout.PayMayaCheckoutResult
import com.paymaya.sdk.android.checkout.models.CheckoutRequest
import com.paymaya.sdk.android.checkout.models.Item
import com.paymaya.sdk.android.common.CheckPaymentStatusResult
import com.paymaya.sdk.android.common.LogLevel
import com.paymaya.sdk.android.common.PayMayaEnvironment
import com.paymaya.sdk.android.paywithpaymaya.PayWithPayMaya
import com.paymaya.sdk.android.paywithpaymaya.PayWithPayMayaResult
import com.paymaya.sdk.android.paywithpaymaya.models.CreateWalletLinkRequest
import com.paymaya.sdk.android.paywithpaymaya.models.SinglePaymentRequest
import com.paymaya.sdk.android.vault.PayMayaVaultResult
import com.paymaya.sdk.android.common.models.RedirectUrl
import com.paymaya.sdk.android.checkout.models.Buyer
import com.paymaya.sdk.android.common.models.TotalAmount
import com.paymaya.sdk.android.common.models.AmountDetails
import com.paymaya.sdk.android.checkout.models.ItemAmount
import java.math.BigDecimal
import android.util.Log
import android.content.Intent

//class MainActivity: FlutterActivity() {
class MainActivity: FlutterFragmentActivity() {

    // Added this
    private val items: MutableList<Item> = mutableListOf()
    fun getItems(): List<Item> =
        items.toList()
    private val CHANNEL = "paymaya.flutter.dev"

    private var checkOutIdResult: String? = null
    private val payMayaCheckoutClient = PayMayaCheckout.newBuilder()
                    .clientPublicKey("pk-eo4sL393CWU5KmveJUaW8V730TTei2zY8zE4dHJDxkF")
                    .environment(PayMayaEnvironment.SANDBOX)
                    .logLevel(LogLevel.ERROR)
                    .build()

    var methodResult: MethodChannel.Result? = null
    private lateinit var _result: MethodChannel.Result //  we can call from activity and update the result
    // End added

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);

        // Added this
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            // Note: this method is invoked on the main thread.
            call, result ->
            if (call.method == "payViaPayMaya") {

                _result = result
                
                val requestReferenceNumber = call.argument<String>("requestReferenceNumber").toString()
                val appointment_name = call.argument<String>("appointment_name").toString()
                val appointment_quantity = call.argument<Int>("appointment_quantity")
                val appointment_value = call.argument<Double>("appointment_value").toString().toDouble()
                
                val success = call.argument<String>("success").toString()
                val failure = call.argument<String>("failure").toString()
                val cancel = call.argument<String>("cancel").toString()
                
                val checkout = call.argument<String>("checkout").toString()

                val redirectUrl = RedirectUrl(
                    success = success,
                    failure = failure,
                    cancel = cancel
                )
                
                if (items.size != 0) {
                    items.clear()
                }
                //if (items.size == 0) {
                    items.add(Item(
                        amount = ItemAmount(
                                BigDecimal.valueOf(appointment_value)
                            ),
                        name = appointment_name,
                        totalAmount = TotalAmount(
                            BigDecimal.valueOf(appointment_value),
                            "PHP"
                        )
                    ))
                //}
                

                val request = CheckoutRequest(
                    TotalAmount(
                        BigDecimal.valueOf(appointment_value),
                        "PHP"
                    ),
                    Buyer(
                        firstName = "",
                        middleName = "",
                        lastName = "",
                        contact = null,
                        shippingAddress = null,
                        billingAddress = null,
                        ipAddress = null
                    ),
                    getItems(),
                    requestReferenceNumber,
                    redirectUrl
                    //metadata
                )

                payMayaCheckoutClient.startCheckoutActivityForResult(this, request)

                //result.error("UNAVAILABLE", "Battery level not available.", null)
                
            } else {
                result.notImplemented()
            }
        }

        // End added
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        // val result: PayMayaCheckoutResult = payMayaCheckoutClient.onActivityResult(requestCode, resultCode, data)?.let {
        //     //checkoutCompleted(data)
        //     Log.d("================Log", resultCode.toString())
        //     //Log.d("=========", data)
        //     return
        // }

        val result: PayMayaCheckoutResult? = payMayaCheckoutClient.onActivityResult(requestCode, resultCode, data)

        checkOutIdResult = result?.checkoutId

        var message = ""
        var status = ""

        when (result) {
            is PayMayaCheckoutResult.Success -> {
                message = "Success, checkoutId: ${result.checkoutId}"
                status = "success"
            }

            is PayMayaCheckoutResult.Cancel -> {
                message = "Canceled, checkoutId: ${result.checkoutId}"
                status = "cancel"
            }

            is PayMayaCheckoutResult.Failure -> {
                message = "Failure, checkoutId: ${result.checkoutId}, exception: ${result.exception}"
                status = "failure"
            }
        }

        if (checkOutIdResult != null) {
            _result.success(status + "===" + checkOutIdResult)
        }

        //Log.d("================Log", checkOutIdResult + message)
      

        // payWithPayMayaClient.onActivityResult(requestCode, resultCode, data)?.let {
        //     // presenter.payWithPayMayaCompleted(it)
        //     // return
        // }

        // payMayaVaultClient.onActivityResult(requestCode, resultCode, data)?.let {
        //     //presenter.vaultCompleted(it)
        // }
    }

    // https://github.com/PayMaya/PayMaya-Android-SDK-v2/blob/master/sdk-demo/src/main/java/com/paymaya/sdk/android/demo/ui/cart/CartContract.kt
}
