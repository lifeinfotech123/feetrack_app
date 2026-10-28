import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/room_controller.dart';
import 'package:vlr/services/theme.dart';

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
