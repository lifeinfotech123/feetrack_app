import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

enum ToastType {
  info(ToastificationType.info),
  warning(ToastificationType.warning),
  error(ToastificationType.error),
  success(ToastificationType.success);

  const ToastType(this.value);
  final ToastificationType value;
}

showCustomToast({required String msg, String? description, ToastType? toastType, ToastificationStyle? toastificationStyle}) {
  return toastification.show(
      alignment: Alignment.bottomCenter,
      type: toastType?.value,
      title: Text(
        msg,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      description: description != null ? Text(description) : null,
      style: toastificationStyle ?? ToastificationStyle.fillColored,
      icon: toastType == null
          ? const Icon(Icons.check_circle_outline)
          : null,
      autoCloseDuration: const Duration(seconds: 3),
      showProgressBar: false
    // borderSide: const BorderSide(width: 0, style: BorderStyle.none),
  );
}