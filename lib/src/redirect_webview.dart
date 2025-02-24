import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class RedirectWebView extends StatelessWidget {
  const RedirectWebView({
    super.key,
    required this.initialUri,
    required this.redirectUri,
  });

  final Uri initialUri;
  final Uri redirectUri;

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialUrlRequest: URLRequest(url: WebUri.uri(initialUri)),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        useShouldOverrideUrlLoading: true,
      ),
      shouldOverrideUrlLoading: (controller, navigationAction) async {
        if (navigationAction.request.url.toString().startsWith(redirectUri.toString())) {
          final result = navigationAction.request.url;
          Navigator.of(context).pop(result);
          return NavigationActionPolicy.CANCEL;
        } else {
          return NavigationActionPolicy.ALLOW;
        }
      },
    );
  }
}
