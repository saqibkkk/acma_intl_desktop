import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class Utils {
  Widget customPageHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.red, Colors.blue],
        ),
      ),
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(seconds: 1),
        builder: (context, double value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
                offset: Offset(0, (1 - value) * 20),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/appIcon.png',
                          width: 50,
                          height: 50,
                        ),
                        Text(
                          'ACMA INTERNATIONAL',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ))
                // const Text(
                //   "✨ ACMA INTERNATIONAL",
                //   style: TextStyle(
                //     color: Colors.white,
                //     fontSize: 28,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
                ),
          );
        },
      ),
    );
  }

  static Future<bool> isInternetAvailable() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  String generateRealtimeUid() {
    const String pushChars =
        '-0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz';
    int lastPushTime = DateTime.now().millisecondsSinceEpoch;
    Random random = Random();

    List<int> timeStampChars = List.filled(8, 0);
    int now = lastPushTime;
    for (int i = 7; i >= 0; i--) {
      timeStampChars[i] = now % 64;
      now = (now / 64).floor();
    }

    String id = timeStampChars.map((i) => pushChars[i]).join();

    for (int i = 0; i < 12; i++) {
      id += pushChars[random.nextInt(64)];
    }

    return id;
  }

  Widget customTextFormField(
    String hint,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    String? errorText,
    Function(String)? onChanged,
  }) {
    // Add inputFormatters automatically if number keyboard is used
    List<TextInputFormatter>? formatters;
    if (keyboardType == TextInputType.number) {
      formatters = [FilteringTextInputFormatter.digitsOnly];
    }

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: formatters,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        errorText: errorText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 12,
        ),
      ),
    );
  }

  Widget customElevatedFunctionButton(
      {required VoidCallback onPressed,
      required String btnName,
      required bgColor,
      required fgColor}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor, // Button color
        foregroundColor: fgColor,
        shadowColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Rounded corners
        ),
        elevation: 8, // Subtle shadow for depth
      ),
      onPressed: onPressed,
      child: Text(
        btnName,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 2,
        ),
      ), // ✅ directly assign callback
    );
  }

  Widget customTextCancelButton(
      {required VoidCallback onPressed,
      required String btnName,
      required textColor}) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        btnName,
        style: TextStyle(
            color: textColor, letterSpacing: 2, fontWeight: FontWeight.bold),
      ),
    );
  }

  SnackbarController customSnackBar(
      {required String title, required String message, required bgColor}) {
    return Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      borderRadius: 10,
      backgroundColor: bgColor,
    );
  }

  Widget customCircularProgressingIndicator() {
    return const CircularProgressIndicator(
      color: Colors.red,
      strokeAlign: 0,
      strokeWidth: 5,
    );
  }
}
