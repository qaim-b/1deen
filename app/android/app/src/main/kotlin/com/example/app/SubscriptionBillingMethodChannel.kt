package com.example.app

import android.app.Activity
import com.android.billingclient.api.AcknowledgePurchaseParams
import com.android.billingclient.api.BillingClient
import com.android.billingclient.api.BillingClientStateListener
import com.android.billingclient.api.BillingFlowParams
import com.android.billingclient.api.BillingResult
import com.android.billingclient.api.ProductDetails
import com.android.billingclient.api.Purchase
import com.android.billingclient.api.PurchasesUpdatedListener
import com.android.billingclient.api.QueryProductDetailsParams
import com.android.billingclient.api.QueryPurchasesParams
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

object SubscriptionBillingMethodChannel : MethodChannel.MethodCallHandler, PurchasesUpdatedListener {
    private const val CHANNEL_NAME = "one_deen/subscription_billing"

    private lateinit var activity: Activity
    private lateinit var methodChannel: MethodChannel
    private lateinit var billingClient: BillingClient

    private var pendingPurchaseResult: MethodChannel.Result? = null
    private var pendingProductId: String? = null

    fun register(messenger: BinaryMessenger, activity: Activity) {
        this.activity = activity
        methodChannel = MethodChannel(messenger, CHANNEL_NAME)
        methodChannel.setMethodCallHandler(this)

        billingClient = BillingClient.newBuilder(activity)
            .setListener(this)
            .enablePendingPurchases()
            .build()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getSubscriptionCatalog" -> {
                val productId = call.argument<String>("productId")
                if (productId.isNullOrBlank()) {
                    result.error("invalid_args", "productId is required", null)
                    return
                }
                queryCatalog(productId, result)
            }

            "purchaseAnnualPlan" -> {
                val productId = call.argument<String>("productId")
                if (productId.isNullOrBlank()) {
                    result.error("invalid_args", "productId is required", null)
                    return
                }
                launchPurchase(productId, result)
            }

            "restorePurchases" -> restorePurchases(result)
            else -> result.notImplemented()
        }
    }

    override fun onPurchasesUpdated(billingResult: BillingResult, purchases: MutableList<Purchase>?) {
        val result = pendingPurchaseResult ?: return

        if (billingResult.responseCode != BillingClient.BillingResponseCode.OK || purchases.isNullOrEmpty()) {
            result.success(mapOf("status" to "failed", "code" to billingResult.responseCode))
            pendingPurchaseResult = null
            pendingProductId = null
            return
        }

        val purchase = purchases.first()
        if (purchase.purchaseState == Purchase.PurchaseState.PURCHASED) {
            acknowledgeIfNeeded(purchase)
            result.success(
                mapOf(
                    "status" to "purchased",
                    "provider" to "android",
                    "productId" to (pendingProductId ?: ""),
                    "receiptToken" to purchase.purchaseToken,
                    "orderId" to (purchase.orderId ?: ""),
                ),
            )
        } else {
            result.success(mapOf("status" to "pending"))
        }

        pendingPurchaseResult = null
        pendingProductId = null
    }

    private fun queryCatalog(productId: String, result: MethodChannel.Result) {
        connectIfNeeded { ok ->
            if (!ok) {
                result.success(mapOf("available" to false, "reason" to "billing_unavailable"))
                return@connectIfNeeded
            }

            val queryParams = QueryProductDetailsParams.newBuilder()
                .setProductList(
                    listOf(
                        QueryProductDetailsParams.Product.newBuilder()
                            .setProductId(productId)
                            .setProductType(BillingClient.ProductType.SUBS)
                            .build(),
                    ),
                )
                .build()

            billingClient.queryProductDetailsAsync(queryParams) { _, productDetailsList ->
                val details = productDetailsList.firstOrNull()
                if (details == null) {
                    result.success(mapOf("available" to false))
                    return@queryProductDetailsAsync
                }

                val offer = details.subscriptionOfferDetails?.firstOrNull()
                val pricing = offer?.pricingPhases?.pricingPhaseList?.firstOrNull()
                result.success(
                    mapOf(
                        "available" to true,
                        "title" to details.title,
                        "description" to details.description,
                        "price" to (pricing?.formattedPrice ?: ""),
                        "currencyCode" to (pricing?.priceCurrencyCode ?: ""),
                    ),
                )
            }
        }
    }

    private fun launchPurchase(productId: String, result: MethodChannel.Result) {
        connectIfNeeded { ok ->
            if (!ok) {
                result.success(mapOf("status" to "failed", "reason" to "billing_unavailable"))
                return@connectIfNeeded
            }

            val queryParams = QueryProductDetailsParams.newBuilder()
                .setProductList(
                    listOf(
                        QueryProductDetailsParams.Product.newBuilder()
                            .setProductId(productId)
                            .setProductType(BillingClient.ProductType.SUBS)
                            .build(),
                    ),
                )
                .build()

            billingClient.queryProductDetailsAsync(queryParams) { _, detailsList ->
                val details = detailsList.firstOrNull()
                val offerToken = details?.subscriptionOfferDetails?.firstOrNull()?.offerToken

                if (details == null || offerToken.isNullOrBlank()) {
                    result.success(mapOf("status" to "failed", "reason" to "product_not_found"))
                    return@queryProductDetailsAsync
                }

                pendingPurchaseResult = result
                pendingProductId = productId

                val params = BillingFlowParams.newBuilder()
                    .setProductDetailsParamsList(
                        listOf(
                            BillingFlowParams.ProductDetailsParams.newBuilder()
                                .setProductDetails(details)
                                .setOfferToken(offerToken)
                                .build(),
                        ),
                    )
                    .build()

                billingClient.launchBillingFlow(activity, params)
            }
        }
    }

    private fun restorePurchases(result: MethodChannel.Result) {
        connectIfNeeded { ok ->
            if (!ok) {
                result.success(emptyList<Map<String, String>>())
                return@connectIfNeeded
            }

            billingClient.queryPurchasesAsync(
                QueryPurchasesParams.newBuilder()
                    .setProductType(BillingClient.ProductType.SUBS)
                    .build(),
            ) { _, purchases ->
                val restored = purchases
                    .filter { it.purchaseState == Purchase.PurchaseState.PURCHASED }
                    .map {
                        acknowledgeIfNeeded(it)
                        mapOf(
                            "provider" to "android",
                            "productId" to (it.products.firstOrNull() ?: "premium_annual_jpy_10000"),
                            "receiptToken" to it.purchaseToken,
                            "orderId" to (it.orderId ?: ""),
                        )
                    }
                result.success(restored)
            }
        }
    }

    private fun acknowledgeIfNeeded(purchase: Purchase) {
        if (purchase.isAcknowledged) {
            return
        }

        val params = AcknowledgePurchaseParams.newBuilder()
            .setPurchaseToken(purchase.purchaseToken)
            .build()
        billingClient.acknowledgePurchase(params) {}
    }

    private fun connectIfNeeded(onReady: (Boolean) -> Unit) {
        if (billingClient.isReady) {
            onReady(true)
            return
        }

        billingClient.startConnection(object : BillingClientStateListener {
            override fun onBillingSetupFinished(billingResult: BillingResult) {
                onReady(billingResult.responseCode == BillingClient.BillingResponseCode.OK)
            }

            override fun onBillingServiceDisconnected() {
                onReady(false)
            }
        })
    }
}
