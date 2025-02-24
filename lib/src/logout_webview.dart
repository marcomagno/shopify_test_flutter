import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class LogoutWebView extends StatelessWidget {
  const LogoutWebView({super.key, required this.uri});

  final Uri uri;

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialUrlRequest: URLRequest(url: WebUri.uri(uri)),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
      ),
      onLoadStop: (controller, url) {
        // Give a little suspension before popping the dialog
        Future.delayed(const Duration(milliseconds: 150), () {
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        });
      },
    );
  }
}
