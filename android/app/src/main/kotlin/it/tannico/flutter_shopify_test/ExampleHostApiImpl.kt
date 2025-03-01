package it.tannico.flutter_shopify_test

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.webkit.GeolocationPermissions
import android.webkit.PermissionRequest
import android.webkit.ValueCallback
import android.webkit.WebChromeClient
import android.webkit.WebView
import androidx.activity.ComponentActivity
import com.shopify.checkoutsheetkit.CheckoutEventProcessor
import com.shopify.checkoutsheetkit.CheckoutException
import com.shopify.checkoutsheetkit.DefaultCheckoutEventProcessor
import com.shopify.checkoutsheetkit.ShopifyCheckoutSheetKit
import com.shopify.checkoutsheetkit.lifecycleevents.CheckoutCompletedEvent
import com.shopify.checkoutsheetkit.pixelevents.PixelEvent

class ExampleHostApiImpl(private val context: Context) : ExampleHostApi {
    
    override fun presentCheckout(url: String) {
        try {
            val activity = context as? ComponentActivity
            
            if (activity != null) {
                ShopifyCheckoutSheetKit.present(
                    checkoutUrl = url,
                    context = activity,
                    checkoutEventProcessor = createCheckoutEventProcessor(activity)
                )
            } else {
                throw FlutterError(
                    code = "ACTIVITY_NOT_FOUND",
                    message = "Could not get activity from context",
                    details = null
                )
            }
        } catch (e: Exception) {
            throw FlutterError(
                code = "CHECKOUT_ERROR",
                message = "Error presenting checkout: ${e.message}",
                details = e.toString()
            )
        }
    }
    
    private fun createCheckoutEventProcessor(context: Context): DefaultCheckoutEventProcessor {
        return object : DefaultCheckoutEventProcessor(context) {
            override fun onCheckoutCompleted(event: CheckoutCompletedEvent) {
                // Called when the checkout was completed successfully by the buyer.
                // Use this to update UI, reset cart state, etc.
            }
            
            override fun onCheckoutCanceled() {
                // Called when the checkout was canceled by the buyer.
            }
            
            override fun onCheckoutFailed(error: CheckoutException) {
                // Called when the checkout failed with an error.
                println("Checkout failed with error: $error")
            }

            override fun onCheckoutLinkClicked(uri: Uri) {
                // Handle when a link is clicked within the checkout
                // This can be used to open external links in a browser
                val intent = Intent(Intent.ACTION_VIEW, uri)
                context.startActivity(intent)
            }

            override fun onGeolocationPermissionsHidePrompt() {
                // No action needed when geolocation prompt is hidden
                println("Geolocation permissions prompt hidden")
            }

            override fun onGeolocationPermissionsShowPrompt(
                origin: String,
                callback: GeolocationPermissions.Callback
            ) {
                // Grant geolocation permissions for the checkout process
                // In a production app, you might want to request user permission first
                callback.invoke(origin, true, false)
                println("Geolocation permissions granted for: $origin")
            }

            override fun onPermissionRequest(permissionRequest: PermissionRequest) {
                // Grant permissions requested by the checkout webview
                // Common permissions include camera, microphone for payment verification
                val resources = permissionRequest.resources
                try {
                    permissionRequest.grant(resources)
                    println("Permissions granted: ${resources.joinToString()}")
                } catch (e: Exception) {
                    permissionRequest.deny()
                    println("Permission request denied due to: ${e.message}")
                }
            }

            override fun onShowFileChooser(
                webView: WebView,
                filePathCallback: ValueCallback<Array<Uri>>,
                fileChooserParams: WebChromeClient.FileChooserParams
            ): Boolean {
                // Handle file selection requests from the checkout webview
                // This is typically used when uploading files during checkout
                try {
                    val activity = context as? Activity
                    if (activity != null) {
                        val intent = fileChooserParams.createIntent()
                        activity.startActivity(intent)
                        // In a real implementation, you would handle the activity result
                        // and pass selected files to filePathCallback
                        println("File chooser opened")
                        return true
                    }
                } catch (e: Exception) {
                    println("Error showing file chooser: ${e.message}")
                    filePathCallback.onReceiveValue(null)
                }
                return false
            }

            override fun onWebPixelEvent(event: PixelEvent) {
                // Called when a web pixel event is emitted.
            }
        }
    }
} 