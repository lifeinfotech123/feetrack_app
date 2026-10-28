import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vlr/data/models/gym_trainer_core_specialties_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';

class CoreSpecialtiesWidget extends StatelessWidget {
  final GymTrainerCoreSpecialtiesModel gymTrainerCoreSpecialtiesModel;
  const CoreSpecialtiesWidget({
    super.key,
    required this.gymTrainerCoreSpecialtiesModel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: primaryText1.withValues(alpha: 0.12),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Modern Background Decorative Element
            Positioned(
              right: -12,
              bottom: -12,
              child: Opacity(
                opacity: 0.07,
                child: SvgPicture.asset(
                  gymTrainerCoreSpecialtiesModel.icon ?? "",
                  height: 72,
                  width: 72,
                  colorFilter: ColorFilter.mode(primaryText1, BlendMode.srcIn),
                ),
              ),
            ),
            // Glassy gradient effect
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    white.withValues(alpha: 0.9),
                    white.withValues(alpha: 0.4),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryText1.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: primaryText1.withValues(alpha: 0.05),
                        width: 0.5,
                      ),
                    ),
                    child: SvgPicture.asset(
                      gymTrainerCoreSpecialtiesModel.icon ?? "",
                      height: 20,
                      width: 20,
                      colorFilter: ColorFilter.mode(primaryText1, BlendMode.srcIn),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    gymTrainerCoreSpecialtiesModel.title?.toUpperCase() ?? "",
                    style: Helper(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
                          color: blackText1,
                          letterSpacing: 0.8,
                          height: 1.3,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  sizedBoxHeight(height: 2),
                  Container(
                    height: 2,
                    width: 16,
                    decoration: BoxDecoration(
                      color: primaryText1.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
