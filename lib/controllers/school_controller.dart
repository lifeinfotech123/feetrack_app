import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:vlr/data/repositories/school_repo.dart';

class SchoolController extends GetxController implements GetxService {
  final SchoolRepo schoolRepo;

  SchoolController({required this.schoolRepo});

  final TextEditingController schoolSearchController = TextEditingController();
  final TextEditingController studentFullNameController =
      TextEditingController();
  final TextEditingController studentIDController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    schoolSearchController.dispose();
    studentFullNameController.dispose();
    studentIDController.dispose();
  }
}
