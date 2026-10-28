import 'package:flutter/material.dart';
import 'package:vlr/views/widget/text_box/app_text_box.dart';

class RoomHomeSearchBar extends StatefulWidget {
  final String hindText;
  final Function() onTap;
  const RoomHomeSearchBar(
      {super.key, required this.hindText, required this.onTap});

  @override
  State<RoomHomeSearchBar> createState() => _RoomHomeSearchBarState();
}

class _RoomHomeSearchBarState extends State<RoomHomeSearchBar> {
  final TextEditingController _searchRoomController = TextEditingController();

  @override
  void dispose() {
    // 1. Clean up your own resources first;
    _searchRoomController.clear();

    // 2. Call the superclass implementation last
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppTextFieldWithHeading(
      controller: _searchRoomController,
      hindText: widget.hindText,
      readOnly: true,
      preFixWidget: const Icon(Icons.search),
      onTap: widget.onTap,
    );
  }
}
