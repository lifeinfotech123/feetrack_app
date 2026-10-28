import 'package:flutter/material.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/common_button.dart';
import 'package:vlr/views/base/custom_image.dart';
import 'package:vlr/views/screens/school/school_profile/galley/galley_single_image_screen.dart';
import 'package:vlr/views/screens/school/school_profile/galley/school_galley_screen.dart';

class SchoolGallerySection extends StatelessWidget {
  const SchoolGallerySection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: white,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "School Gallery",
                style: Helper(context).textTheme.titleMedium?.copyWith(
                      fontSize: 20,
                      color: blackText1,
                    ),
              ),
              CustomButton(
                onTap: () {
                  navigate(context: context, page: SchoolGalleyScreen());
                },
                type: ButtonType.tertiary,
                child: Text(
                  "See Photos",
                  style: Helper(context).textTheme.titleMedium?.copyWith(
                        fontSize: 14,
                        color: blueLight3,
                      ),
                ),
              ),
            ],
          ),
          sizedBoxHeight(height: 16),
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  childAspectRatio: 1),
              itemBuilder: (context, index) {
                final isLastImage =
                    index == (imageList.length > 6 ? 5 : imageList.length - 1);

                final image = imageList[index];
                if (isLastImage) {
                  return GestureDetector(
                    onTap: () {
                      navigate(context: context, page: SchoolGalleyScreen());
                    },
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CustomImage(
                          path: image,
                          fit: BoxFit.cover,
                        ),
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: blueLight6.withValues(alpha: 0.60),
                            ),
                            child: Center(
                              child: Text(
                                "+12",
                                style: Helper(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontSize: 18,
                                      color: blackText1,
                                    ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                }
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
                    path: image,
                    fit: BoxFit.cover,
                  ),
                );
              },
              itemCount: imageList.length > 6 ? 6 : imageList.length,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
            ),
          )
        ],
      ),
    );
  }
}

List<String> imageList = [
  Assets.imagesBanner,
  Assets.imagesBanner1,
  Assets.imagesGymBanner3,
  Assets.imagesGymBanner2,
  Assets.imagesBanner,
  Assets.imagesBanner1,
  Assets.imagesGymBanner3,
  Assets.imagesGymBanner2,
  Assets.imagesBanner,
  Assets.imagesBanner1,
  Assets.imagesGymBanner3,
  Assets.imagesGymBanner2,
];
