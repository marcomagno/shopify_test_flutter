//
//  HostApi.swift
//  Runner
//
//  Created by Marco on 26/10/24.
//

import ShopifyCheckoutSheetKit

class ExampleHostApiImpl: ExampleHostApi {
    private weak var presentedViewController: CheckoutViewController?

    func presentCheckout(url: String) throws {
        if let resolvedURL = URL(string: url),
           let appDelegate = UIApplication.shared.delegate,
           let window = appDelegate.window,
           let controller = window?.rootViewController as? UIViewController
        {
            print(resolvedURL)
            presentedViewController = ShopifyCheckoutSheetKit.present(checkout: resolvedURL, from: controller, delegate: self)
        }
    }
}

extension ExampleHostApiImpl: CheckoutDelegate {
    func checkoutDidEmitWebPixelEvent(event: ShopifyCheckoutSheetKit.PixelEvent) {
        //
    }

    func checkoutDidComplete(event: CheckoutCompletedEvent) {
            // Called when the checkout was completed successfully by the buyer.
            // Use this to update UI, reset cart state, etc.
    }
    
    func checkoutDidCancel() {
        // Called when the checkout was canceled by the buyer.
        presentedViewController?.presentingViewController?.dismiss(animated: true)
    }
    
    func checkoutDidFail(error: CheckoutError) {
        print("Checkout failed with error: \(error)")
    }
    
        /// Tells the delegate that checkout has encountered an error and the return value will determine if it is handled with a fallback
    func shouldRecoverFromError(error: CheckoutError) -> Bool {
        print("shouldRecoverFromError: \(error)")
        return true
    }
    
    func checkoutDidClickLink(url: URL) {
            // Called when the buyer clicks a link within the checkout experience:
            //  - email address (`mailto:`),
            //  - telephone number (`tel:`),
            //  - web (`http:`)
            // and is being directed outside the application.
    }
}
