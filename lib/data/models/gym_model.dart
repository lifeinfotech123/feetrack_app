import 'package:vlr/generated/assets.dart';

class GymModel {
  final String? image;
  final String? title;
  final String? distance;
  final String? price;
  final String? per;

  GymModel(
      {required this.image,
      required this.title,
      required this.distance,
      required this.price,
      required this.per});
}

List<GymModel> gymModelList = [
  GymModel(
      image: Assets.imagesGymBanner,
      title: "Gold's Gym",
      distance: "2.5 km",
      price: "₹999",
      per: "month"),
  GymModel(
      image: Assets.imagesGymBanner,
      title: "Anytime Fitness",
      distance: "3.0 km",
      price: "₹899",
      per: "month"),
  GymModel(
      image: Assets.imagesGymBanner,
      title: "Fitness First",
      distance: "1.8 km",
      price: "₹1099",
      per: "month"),
];
