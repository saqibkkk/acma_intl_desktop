import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
class Utils{
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

  Widget customTextFormField(String hint, TextEditingController controller,
      {TextInputType? keyboardType, String? errorText, void Function(String)? onChanged}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        errorText: errorText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      onChanged: onChanged,
    );
  }
}

