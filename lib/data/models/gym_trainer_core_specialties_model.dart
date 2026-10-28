import 'package:vlr/views/base/custom_image.dart';

class GymTrainerCoreSpecialtiesModel {
  final String? title;
  final String? icon;

  GymTrainerCoreSpecialtiesModel({required this.title, required this.icon});
}

List<GymTrainerCoreSpecialtiesModel> gymTrainerCoreSpecialtiesModelList = [
  GymTrainerCoreSpecialtiesModel(
      title: "FUNCTIONAL STRENGTH", icon: Assets.svgsStrength),
  GymTrainerCoreSpecialtiesModel(
      title: "METABOLIC CONDITIONING", icon: Assets.svgsMetabolic),
  GymTrainerCoreSpecialtiesModel(
      title: "INJURY REHAB", icon: Assets.svgsInjuryRehed),
  GymTrainerCoreSpecialtiesModel(
      title: "SPORTS PERFORMANCE", icon: Assets.svgsSportStare),
];
