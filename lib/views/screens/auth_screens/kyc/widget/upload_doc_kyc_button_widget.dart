import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/common_button.dart';
import 'package:vlr/views/base/custom_image.dart';

class UploadDocKycButtonWidget extends StatelessWidget {
  final Function()? onTapGallyButton;
  final Function()? onTapCameraButton;
  final bool isProfile;
  const UploadDocKycButtonWidget({
    super.key,
    this.onTapGallyButton,
    this.onTapCameraButton,
    this.isProfile = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        !isProfile
            ? Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        height: 44,
                        color: white,
                        borderColor: greyLight2.withValues(alpha: 0.20),
                        radius: 999,
                        onTap: onTapGallyButton,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              Assets.svgsGallery,
                              height: 12,
                              width: 12,
                              fit: BoxFit.cover,
                            ),
                            sizedBoxWidth(width: 8),
                            Text(
                              "Gallery",
                              style: Helper(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    color: primaryText1,
                                  ),
                            )
                          ],
                        ),
                      ),
                    ),
                    sizedBoxWidth(width: 16),
                  ],
                ),
              )
            : SizedBox(),
        Expanded(
          child: CustomButton(
            height: 44,
            color: primaryText1,
            borderColor: greyLight2.withValues(alpha: 0.20),
            radius: 999,
            onTap: onTapCameraButton,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.camera_alt_rounded,
                  color: white,
                  size: 12,
                ),
                // SvgPicture.asset(
                //   Assets.,
                //   height: 12,
                //   width: 12,
                //   fit: BoxFit.cover,
                // ),
                sizedBoxWidth(width: 8),
                Text(
                  "Take Photo",
                  style: Helper(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: white,
                      ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
