import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../constants.dart';

class AutoUpdater {

  /// Get latest release info
  Future<Map<String, String>?> getLatestRelease() async {
    final url =
        "https://api.github.com/repos/$repoOwner/$repoName/releases/latest";

    final headers = {
      "Accept": "application/vnd.github+json",
      if (githubToken != null) "Authorization": "token $githubToken",
    };

    try {
      print("Fetching latest release info from: $url");

      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 15));

      print("GitHub API response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final tag = data['tag_name'];
        final assets = data['assets'] as List;
        String? fileUrl;

        for (var asset in assets) {
          print("Asset found: ${asset['name']}");
          if (asset['name'].toString().endsWith(".zip") ||
              asset['name'].toString().endsWith(".rar")) {
            fileUrl = asset['browser_download_url'];
            break;
          }
        }

        if (fileUrl == null) {
          print("No ZIP/RAR asset found in latest release.");
        }

        return {"version": tag, "url": fileUrl ?? ""};
      } else {
        print("GitHub API error: ${response.body}");
        return null;
      }
    } on SocketException catch (e) {
      print("Network error: $e");
      return null;
    } on TimeoutException {
      print("Request to GitHub timed out.");
      return null;
    } catch (e) {
      print("Unexpected error: $e");
      return null;
    }
  }

  bool isNewerVersion(String latest) {
    List<int> currentParts = currentVersion.split('.').map(int.parse).toList();
    List<int> latestParts =
        latest.replaceAll("v", "").split('.').map(int.parse).toList();

    for (int i = 0; i < latestParts.length; i++) {
      if (i >= currentParts.length || latestParts[i] > currentParts[i])
        return true;
      if (latestParts[i] < currentParts[i]) return false;
    }
    return false;
  }

  /// Download asset to Downloads folder with progress
  Future<String?> downloadUpdate(
      String url, Function(double) onProgress) async {
    if (url.isEmpty) return null;

    final downloadsDir = Directory(
      Platform.environment['USERPROFILE']! + '/Downloads',
    );
    if (!downloadsDir.existsSync()) downloadsDir.createSync(recursive: true);

    final fileName = url.split('/').last;
    final filePath = "${downloadsDir.path}/$fileName";
    final file = File(filePath);

    print("Starting download to: $filePath");

    try {
      final request = await HttpClient().getUrl(Uri.parse(url));
      if (githubToken != null) {
        request.headers.add("Authorization", "token $githubToken");
      }

      final response = await request.close();
      final total = response.contentLength ?? 0;
      int received = 0;

      final sink = file.openWrite();
      await for (var chunk in response) {
        received += chunk.length;
        sink.add(chunk);
        if (total > 0) onProgress(received / total);
      }
      await sink.close();

      print("Download complete: $filePath");
      return filePath;
    } catch (e) {
      print("Download failed: $e");
      return null;
    }
  }
}
