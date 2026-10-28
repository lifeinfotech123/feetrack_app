import 'dart:io';

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../views/base/custom_toast.dart';

export 'package:image_picker/image_picker.dart';

class ServiceController {
  final picker = ImagePicker();

  Future<File?> pickImage(ImageSource source, BuildContext context) async {
    XFile? pickedFile;
    try {
      pickedFile = await picker.pickImage(source: source, imageQuality: 25);
    } catch (e) {
      debugPrint("Error picking image: $e");
      if (source == ImageSource.camera) {
        showCustomToast(msg: "Camera access denied or error occurred.");
      } else {
        showCustomToast(msg: "Gallery access denied or error occurred.");
      }
    }

    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  Future<List<XFile>> getMultiImage() async {
    final pickedFile = await picker.pickMultiImage(imageQuality: 25);
    return pickedFile;
  }

  Future<DateTime> selectDate(context,
      {DateTime? startData, DateTime? endDate}) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      initialDate: startData ?? DateTime.now().add(const Duration(minutes: 1)),
      lastDate: endDate ??
          DateTime.now().add(
            const Duration(days: 60),
          ),
    );
    return pickedDate!;
  }

  // get
  Future<List<File>> getMultipleImages(BuildContext context) async {
    List<File> productImage = [];
    try {
      final List<XFile> images = await picker.pickMultiImage(
        limit: 5,
        imageQuality: 25,
      );
      if (images.isNotEmpty) {
        for (var image in images) {
          productImage.add(File(image.path));
        }
      }
    } catch (e) {
      debugPrint("Error picking multiple images: $e");
      showCustomToast(msg: "Gallery access denied or error occurred.");
    }

    return productImage;
  }

  Future<String?> selectTime(BuildContext context) async {
    final TimeOfDay? timeOfDay = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.dial,
    );
    if (timeOfDay == null) {
      return null;
    } else {
      return DateFormat('HH:mm')
          // ignore: use_build_context_synchronously
          .format(DateFormat("h:mm a").parse(timeOfDay.format(context)));
    }
  }
}
