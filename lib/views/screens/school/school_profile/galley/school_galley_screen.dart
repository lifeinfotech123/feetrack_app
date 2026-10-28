import 'package:flutter/material.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/views/base/custom_image.dart';
import 'package:vlr/views/screens/dashboard/home_screen/service_appbar/service_appbar.dart';
import 'package:vlr/views/screens/school/school_profile/galley/galley_single_image_screen.dart';
import 'package:vlr/views/screens/school/school_profile/widget/school_gallery_section.dart';

class SchoolGalleyScreen extends StatelessWidget {
  const SchoolGalleyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ServiceAppbar(
        title: "School Gallery",
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            childAspectRatio: 1),
        itemBuilder: (context, index) {
          final _image = imageList[index];
          return GestureDetector(
            onTap: () {
              navigate(
                context: context,
                page: GallerySingleImageScreen(
                  imageList: imageList,
                  initialIndex: index,
                ),
              );
            },
            child: CustomImage(
              path: _image,
              fit: BoxFit.cover,
            ),
          );
        },
        itemCount: imageList.length > 6 ? 6 : imageList.length,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
      ),
    );
  }
}
