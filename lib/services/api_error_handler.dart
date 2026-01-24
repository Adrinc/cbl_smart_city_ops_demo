import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// Simple toast/snackbar helper for DemoCorp CRM Demo
/// No real API errors, just UI feedback
class DemoMessageHandler {
  static Future<void> showToast(
    String msg, {
    String color = "#10B981", // Verde success por defecto
  }) async {
    await Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      webBgColor: color,
      textColor: Colors.white,
      timeInSecForIosWeb: 3,
      webPosition: 'center',
    );
  }

  static void showSuccessToast(String msg) {
    showToast(msg, color: "#10B981"); // Verde
  }

  static void showErrorToast(String msg) {
    showToast(msg, color: "#EF4444"); // Rojo
  }

  static void showWarningToast(String msg) {
    showToast(msg, color: "#F59E0B"); // Ámbar
  }
}
