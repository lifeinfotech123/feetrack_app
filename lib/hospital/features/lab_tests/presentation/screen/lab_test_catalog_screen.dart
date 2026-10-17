import 'package:flutter/material.dart';
import 'diagnostic_labs_screen.dart';

class LabTestCatalogScreen extends StatelessWidget {
  final String? userId;

  const LabTestCatalogScreen({
    Key? key,
    this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DiagnosticLabsScreen(userId: userId);
  }
}
