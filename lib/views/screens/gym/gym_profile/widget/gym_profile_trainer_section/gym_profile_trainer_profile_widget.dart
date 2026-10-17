import 'package:flutter/material.dart';
import 'package:vlr/data/models/category_model/staff_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/custom_image.dart';
import 'package:vlr/views/screens/gym/gym_trainer_profile_screen/gym_trainer_profile_screen.dart';
import 'package:vlr/views/screens/gym/widget/gym_book_trainer_bottom_sheet.dart';

class GYmProfileTrainerProfileWidget extends StatelessWidget {
  final StaffModel staffModel;
  const GYmProfileTrainerProfileWidget({
    super.key,
    required this.staffModel,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        navigate(
          context: context,
          page: GymTrainerProfileScreen(
            staffId: staffModel.id?.toString(),
          ),
        );
      },
      child: Container(
        width: 192,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: greyLight,
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CustomImage(
                path: staffModel.photoUrl ?? "",
                width: 168,
                height: 145,
                radius: 20,
                fit: BoxFit.cover,
              ),
            ),
            sizedBoxHeight(height: 10),
            Text(
              staffModel.name ?? "",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Helper(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: blackText1,
                  ),
            ),
            sizedBoxHeight(height: 3),
            Row(
              children: [
                Flexible(
                  child: Text(
                    "${staffModel.specialization ?? ""} ",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Helper(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: greyText2,
                        ),
                  ),
                ),
                if (staffModel.experienceYears != null &&
                    staffModel.experienceYears!.isNotEmpty) ...[
                  Icon(
                    Icons.circle,
                    size: 4,
                    color: greyText2,
                  ),
                  Flexible(
                    child: Text(
                      " ${staffModel.experienceYears}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Helper(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF059669),
                          ),
                    ),
                  ),
                ],
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 34,
              child: ElevatedButton.icon(
                onPressed: () {
                  GymBookTrainerBottomSheet.show(
                    context: context,
                    staffModel: staffModel,
                  );
                },
                icon: const Icon(
                  Icons.bookmark_add_rounded,
                  size: 14,
                  color: Colors.white,
                ),
                label: const Text(
                  "Book",
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF002060),
                  padding: EdgeInsets.zero,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
