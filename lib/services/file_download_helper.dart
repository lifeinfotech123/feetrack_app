import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vlr/services/constants.dart';

class FileDownloadHelper {
  static Future<void> downloadAndShareFile(String url, String fileName, Map<String, String>? headers) async {
    try {
      showToast(message: "Preparing download...", toastType: ToastType.info);

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        // We use getTemporaryDirectory which does NOT require storage permission on modern Android
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        // Share the file so the user can save it using the system UI
        // Tapping 'Save to device' in the share sheet works without manual storage permission logic
        await Share.shareXFiles(
          [XFile(filePath)],
          text: 'Invoice: $fileName',
        );
        
        showToast(message: "File ready", toastType: ToastType.success);
      } else {
        showToast(message: "Failed to download (Error: ${response.statusCode})", toastType: ToastType.error);
      }
    } catch (e) {
      showToast(message: "Download error: $e", toastType: ToastType.error);
    }
  }
}
