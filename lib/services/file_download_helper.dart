import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vlr/services/constants.dart';

class FileDownloadHelper {
  static Future<void> downloadAndShareFile(
    String primaryUrl,
    String fileName,
    Map<String, String>? headers, {
    List<String>? fallbackUrls,
  }) async {
    try {
      showToast(message: "Downloading file...", toastType: ToastType.info);

      final List<String> urlsToTry = [
        primaryUrl,
        if (fallbackUrls != null) ...fallbackUrls,
      ];

      http.Response? response;

      for (final url in urlsToTry) {
        try {
          final res = await http.get(Uri.parse(url), headers: headers);
          if (res.statusCode == 200 && res.bodyBytes.isNotEmpty) {
            response = res;
            break;
          }
        } catch (_) {}
      }

      if (response != null && response.statusCode == 200) {
        // 1. Save directly to public Downloads folder on Android if available
        bool savedToDownloads = false;
        String? savedFilePath;

        if (Platform.isAndroid) {
          try {
            final publicDownloadDir = Directory('/storage/emulated/0/Download');
            if (publicDownloadDir.existsSync()) {
              savedFilePath = '${publicDownloadDir.path}/$fileName';
              final downloadFile = File(savedFilePath);
              await downloadFile.writeAsBytes(response.bodyBytes);
              savedToDownloads = true;
            }
          } catch (_) {}
        }

        if (!savedToDownloads) {
          try {
            final docsDir = await getDownloadsDirectory() ??
                await getApplicationDocumentsDirectory();
            savedFilePath = '${docsDir.path}/$fileName';
            final downloadFile = File(savedFilePath);
            await downloadFile.writeAsBytes(response.bodyBytes);
            savedToDownloads = true;
          } catch (_) {}
        }

        // 2. Also write to temporary directory for share_plus sheet
        final tempDir = await getTemporaryDirectory();
        final tempFilePath = '${tempDir.path}/$fileName';
        final tempFile = File(tempFilePath);
        await tempFile.writeAsBytes(response.bodyBytes);

        if (savedToDownloads) {
          showToast(
            message: "✅ Saved to Downloads: $fileName",
            toastType: ToastType.success,
          );
        } else {
          showToast(
            message: "✅ File ready: $fileName",
            toastType: ToastType.success,
          );
        }

        // 3. Share/Open file using system sheet
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(tempFilePath)],
            text: 'PDF Document: $fileName',
          ),
        );
      } else {
        showToast(
          message: "Failed to download (Error 404: Invoice PDF not found)",
          toastType: ToastType.error,
        );
      }
    } catch (e) {
      showToast(message: "Download error: $e", toastType: ToastType.error);
    }
  }
}
