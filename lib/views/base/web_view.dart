import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CustomWebView extends StatefulWidget {
  final String url, title;
  const CustomWebView({super.key, required this.url, required this.title});

  @override
  State<CustomWebView> createState() => _CustomWebViewState();
}

class _CustomWebViewState extends State<CustomWebView> {
  final WebViewController controller = WebViewController();
  late String url;
  double progress = 0.0;

  @override
  void initState() {
    super.initState();
    url = widget.url.trim();
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    controller
      ..loadRequest(Uri.parse(url))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progressValue) {
            if (mounted) {
              setState(() {
                progress = progressValue / 100;
              });
            }
          },
          onPageFinished: (url) {
            if (mounted) {
              setState(() {
                progress = 0.0;
              });
            }
          },
          onNavigationRequest: (NavigationRequest request) async {
            final requestUrl = request.url.trim();
            log("WebView Navigation Request: $requestUrl");

            // Intercept non-HTTP/HTTPS URLs (UPI links, GPay, PhonePe, Paytm, CRED, etc.)
            if (!requestUrl.startsWith('http://') && !requestUrl.startsWith('https://')) {
              await _launchExternalApp(requestUrl);
              return NavigationDecision.prevent;
            }

            // Intercept Android intent:// scheme
            if (requestUrl.startsWith('intent://')) {
              await _launchExternalApp(requestUrl);
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
  }

  Future<void> _launchExternalApp(String requestUrl) async {
    try {
      final Uri uri = Uri.parse(requestUrl);

      // Direct launch
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }

      // Handle Android intent:// URLs
      if (requestUrl.startsWith('intent://')) {
        String upiUrl = requestUrl.replaceFirst('intent://', 'upi://');
        if (upiUrl.contains('#Intent;')) {
          upiUrl = upiUrl.split('#Intent;').first;
        }
        final Uri upiUri = Uri.parse(upiUrl);
        if (await canLaunchUrl(upiUri)) {
          await launchUrl(upiUri, mode: LaunchMode.externalApplication);
          return;
        }
      }

      // Fallback
      await launchUrl(uri, mode: LaunchMode.externalNonBrowserApplication);
    } catch (e) {
      log("Error launching UPI / external app deep link: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    log(url);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          if (progress > 0.0)
            LinearProgressIndicator(value: progress, minHeight: 4),

          Expanded(child: WebViewWidget(controller: controller)),
        ],
      ),
    );
  }
}
