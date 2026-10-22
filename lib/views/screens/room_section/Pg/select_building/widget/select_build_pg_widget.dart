import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/room_controller.dart';
import 'package:vlr/data/models/rooom/pg_floor_model.dart';
import 'package:vlr/data/models/rooom/pg_room_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/custom_image.dart';
import 'package:vlr/views/screens/room_section/Pg/select_building/widget/building_widget.dart';
import 'package:vlr/views/screens/room_section/Pg/select_room_bed/widget/dot_for_bed_widget.dart';

class AddFavWidget extends StatelessWidget {
  const AddFavWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 16,
      right: 16,
      child: GetBuilder<RoomController>(builder: (roomController) {
        return GestureDetector(
          onTap: () {
            roomController.isAddFavorite = !roomController.isAddFavorite;
            roomController.update();
          },
          child: CircleAvatar(
            radius: 20,
            backgroundColor: white,
            child: Icon(
              roomController.isAddFavorite
                  ? Icons.favorite
                  : Icons.favorite_border_outlined,
              size: 22,
              color: redDark,
            ),
          ),
        );
      }),
    );
  }
}

class RoomProfileTopSection extends StatelessWidget {
  const RoomProfileTopSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RoomController>(builder: (roomController) {
      final room = roomController.selectedRoomDetails;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        offset: const Offset(0, 1),
                        blurRadius: 2,
                        spreadRadius: 0,
                        color: black.withValues(alpha: 0.05),
                      )
                    ]),
                child: CustomImage(
                  path: (room?.images != null && room!.images!.isNotEmpty)
                      ? room.images![0].url ?? Assets.imagesHomeProfile
                      : Assets.imagesHomeProfile,
                  height: MediaQuery.of(context).size.height / 3,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const AddFavWidget(),
            ],
          ),
          sizedBoxHeight(height: 12),
          Text(
            room?.roomNumber != null ? "Room ${room!.roomNumber}" : "Urban Oasis Suite",
            style: Helper(context).textTheme.titleMedium?.copyWith(
                  fontSize: 24,
                  color: blackText3,
                ),
          ),
          sizedBoxHeight(height: 4),
          Row(
            children: [
               Icon(
                Icons.location_on_outlined,
                color: greyDart2,
                size: 16,
              ),
              sizedBoxWidth(width: 6),
              Expanded(
                child: Text(
                  "Koramangala, Bengaluru",
                  style: Helper(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        color: blackText3,
                      ),
                ),
              ),
            ],
          ),
          sizedBoxHeight(height: 6),
          Row(
            children: [
              const Icon(
                Icons.star,
                color: greenDark,
                size: 14,
              ),
              sizedBoxWidth(width: 6),
              Text(
                "4.9",
                style: Helper(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 12,
                      color: blackText1,
                    ),
              ),
              sizedBoxWidth(width: 6),
              Text(
                "(3,234 Rating)",
                style: Helper(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 12,
                      color: blackText1,
                    ),
              ),
            ],
          ),
          sizedBoxHeight(height: 12),
          RichText(
            text: TextSpan(
              text: room?.securityDeposit != null ? "₹${room!.securityDeposit}" : "₹16,500",
              style: Helper(context).textTheme.titleMedium?.copyWith(
                    fontSize: 24,
                    color: primaryColor,
                  ),
              children: [
                TextSpan(
                  text: " / security deposit",
                  style: Helper(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        color: greyDart2,
                      ),
                )
              ],
            ),
          ),
          sizedBoxHeight(height: 30),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: white,
              border: Border.all(
                width: 1,
                color: greyLight1.withValues(alpha: 0.30),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 20,
                      color: primaryColor,
                    ),
                    sizedBoxWidth(width: 6),
                    Text(
                      "About",
                      style: Helper(context).textTheme.titleMedium?.copyWith(
                            fontSize: 16,
                            color: blackText3,
                          ),
                    ),
                  ],
                ),
                sizedBoxHeight(height: 20),
                Text(
                  "Experience premium urban living in this thoughtfully designed suite. Located in the heart of Koramangala, this space offers a perfect blend of comfort, style, and convenience for working professionals and students alike. Enjoy high-speed connectivity, modern amenities, and a vibrant community atmosphere.",
                  style: Helper(context).textTheme.bodySmall?.copyWith(
                        fontSize: 14,
                        color: greyDart2,
                      ),
                ),
              ],
            ),
          )
        ],
      );
    });
  }
}

class RoomWidget extends StatelessWidget {
  final PgRoomModel pgRoomModel;
  const RoomWidget({
    super.key,
    required this.pgRoomModel,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: pgRoomModel.isSelect ? 1.02 : 1,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(16),
        width: MediaQuery.of(context).size.width / 3.2,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: pgRoomModel.isSelect ? primaryColor : white,
          border: Border.all(
            width: 1,
            color: pgRoomModel.isSelect ? blueLight3 : greyLight6,
          ),
          boxShadow: [
            BoxShadow(
              color: pgRoomModel.isSelect
                  ? primaryColor.withValues(alpha: 0.18)
                  : black.withValues(alpha: 0.04),
              blurRadius: pgRoomModel.isSelect ? 18 : 8,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              style: Helper(context).textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                    color: pgRoomModel.isSelect ? white : blackText3,
                  ) ??
                  const TextStyle(),
              child: Text(pgRoomModel.roomNo ?? ""),
            ),
            sizedBoxHeight(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              style: Helper(context).textTheme.labelLarge?.copyWith(
                    fontSize: 16,
                    color: pgRoomModel.isSelect ? blueLight6 : greyDart2,
                  ) ??
                  const TextStyle(),
              child: Text(
                pgRoomModel.bedLeftNo == 0
                    ? "Full"
                    : "${pgRoomModel.bedLeftNo} Bed Left",
              ),
            ),
            sizedBoxHeight(height: 16),
            DotOfBedWidget(
              shareTypeNo: pgRoomModel.shareType ?? 0,
              bedLeft: pgRoomModel.bedLeftNo ?? 0,
              isSelect: pgRoomModel.isSelect,
            )
          ],
        ),
      ),
    );
  }
}

class SelectPgFloor extends StatelessWidget {
  final PgFloorModel? pgFloorModel;
  const SelectPgFloor({
    super.key,
    required this.pgFloorModel,
  });

  @override
  Widget build(BuildContext context) {
    final String titleText = pgFloorModel?.floorNo ?? pgFloorModel?.displayName ?? "Floor";
    final String subTitleText = (pgFloorModel?.floorName != null &&
            pgFloorModel!.floorName!.isNotEmpty &&
            pgFloorModel!.floorName != titleText)
        ? pgFloorModel!.floorName!
        : (pgFloorModel?.availableBeds != null
            ? "${pgFloorModel!.availableBeds} Beds Available"
            : "${pgFloorModel?.totalRooms ?? 0} Rooms");

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: (pgFloorModel?.isSelect ?? false) ? primaryColor : pinLight,
        border: Border.all(
          width: 1,
          color: (pgFloorModel?.isSelect ?? false) ? blueLight3 : greyLight6,
        ),
        boxShadow: (pgFloorModel?.isSelect ?? false)
            ? [
                BoxShadow(
                  offset: const Offset(0, 4),
                  blurRadius: 6,
                  spreadRadius: -4,
                  color: black.withValues(alpha: 0.10),
                ),
                BoxShadow(
                  offset: const Offset(0, 10),
                  blurRadius: 15,
                  spreadRadius: -3,
                  color: black.withValues(alpha: 0.10),
                ),
              ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            titleText,
            style: Helper(context).textTheme.bodySmall?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: (pgFloorModel?.isSelect ?? false) ? white : blackText3,
                ),
          ),
          sizedBoxHeight(height: 4),
          Text(
            subTitleText,
            style: Helper(context).textTheme.titleMedium?.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: (pgFloorModel?.isSelect ?? false) ? white : blackText3,
                ),
          ),
        ],
      ),
    );
  }
}

class SelectBuildPgWidget extends StatelessWidget {
  const SelectBuildPgWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Select Building",
              style: Helper(context).textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                    color: blackText3,
                  ),
            ),
            Text(
              "2 Buildings available",
              style: Helper(context).textTheme.bodySmall?.copyWith(
                    fontSize: 16,
                    color: const Color(0xFF737686),
                  ),
            ),
          ],
        ),
        sizedBoxHeight(height: 16),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return const BuildingWidget(
                isSelect: true,
              );
            },
            separatorBuilder: (_, __) => sizedBoxWidth(width: 16),
            itemCount: 4,
            shrinkWrap: true,
          ),
        ),
        sizedBoxHeight(height: 32),
        Stack(
          children: [
            CustomImage(
              path: Assets.imagesPgBuilding,
              height: MediaQuery.of(context).size.height / 4,
              width: double.infinity,
              fit: BoxFit.cover,
              radius: 12,
            ),
            Positioned(
              bottom: 16,
              left: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(99),
                    color: black.withValues(alpha: 0.70)),
                child: Text(
                  "Emerald Residency - Block A",
                  style: Helper(context).textTheme.titleSmall?.copyWith(
                        fontSize: 16,
                        color: white,
                      ),
                ),
              ),
            )
          ],
        ),
        sizedBoxHeight(height: 32),
        Text(
          "Select Floor",
          style: Helper(context).textTheme.titleMedium?.copyWith(
                fontSize: 16,
                color: blackText3,
              ),
        ),
        sizedBoxHeight(height: 16),
        GetBuilder<RoomController>(builder: (roomController) {
          return SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final floorModel = roomController.pgFloorModelList[index];
                return GestureDetector(
                    onTap: () {
                      roomController.updateSelectPgFloor(floorModel);
                    },
                    child: SelectPgFloor(pgFloorModel: floorModel));
              },
              separatorBuilder: (_, __) => sizedBoxWidth(width: 16),
              itemCount: roomController.pgFloorModelList.length,
              shrinkWrap: true,
            ),
          );
        }),
      ],
    );
  }
}
