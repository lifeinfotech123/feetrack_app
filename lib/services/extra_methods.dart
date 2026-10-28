import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:vlr/views/base/custom_toast.dart';
import 'package:path_provider/path_provider.dart' show getTemporaryDirectory;
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ExtraMethods {
  String getWhatsAppUrl(String number, [String msg = '']) {
    return 'https://wa.me/91$number?text=$msg';
  }

  void makeCall(String number) async {
    final url = Uri(scheme: 'tel', path: number);
    launchUrl(url);
  }

  void shareMyApp(BuildContext context, String appLink) async {
    final box = context.findRenderObject() as RenderBox?;
    {
      await Share.share(
        appLink,
        subject: 'AnyProperty',
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      );
    }
  }

  Future<void> shareProperty(
      BuildContext context, String title, String imageUrl) async {
    log("Downloading Image: $imageUrl");

    try {
      final response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final filePath = '${tempDir.path}/shared_image.jpg';

        File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        if (!context.mounted) return;

        final box = context.findRenderObject() as RenderBox?;
        await Share.shareXFiles(
          [XFile(file.path)],
          text: title,
          subject: 'AnyProperty',
          sharePositionOrigin: box != null
              ? box.localToGlobal(Offset.zero) & box.size
              : Rect.zero, // Avoid errors if box is null
        );
      } else {
        log("Error: Failed to download image, status code: ${response.statusCode}");
      }
    } catch (e) {
      log("Error while sharing: $e");
    }
  }

  void makeMail(String email, [String subject = '']) {
    try {
      Uri emailLaunchUri = Uri(
          scheme: 'mailto', path: email, queryParameters: {'subject': subject});
      var url = emailLaunchUri.toString().replaceAll('+', ' ');
      launchInBrowser(url);
    } catch (e) {
      log(e.toString(), name: "Error at makeMail");
    }
  }

  static Future<void> launchInBrowser(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
        webViewConfiguration: const WebViewConfiguration(
          headers: <String, String>{'my_header_key': 'my_header_value'},
        ),
      );
    } else {
      showCustomToast(msg: 'Invalid url {$url}', toastType: ToastType.error);
      log('Could not launch $url');
    }
  }

  static Future<void> launchWebsite(String url) async {
    if (!(url.startsWith('http'))) {
      if (!(url.startsWith('https://'))) {
        url = 'https://$url';
      }
    }
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalNonBrowserApplication,
        // headers: <String, String>{'my_header_key': 'my_header_value'},
      );
    } else {
      log('Could not launch $url');
    }
  }
}

String formatIndianNumber(double number) {
  if (number >= 10000000) {
    return "${(number / 10000000).toStringAsFixed(2)} Cr";
  } else if (number >= 100000) {
    return "${(number / 100000).toStringAsFixed(2)} Lakh";
  } else {
    return number.toStringAsFixed(2);
  }
}
