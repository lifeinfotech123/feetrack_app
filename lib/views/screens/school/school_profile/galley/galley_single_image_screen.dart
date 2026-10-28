import 'package:flutter/material.dart';
import 'package:vlr/services/theme.dart';

class GallerySingleImageScreen extends StatefulWidget {
  final List<String> imageList;
  final int initialIndex;

  const GallerySingleImageScreen({
    super.key,
    required this.imageList,
    required this.initialIndex,
  });

  @override
  State<GallerySingleImageScreen> createState() =>
      _GallerySingleImageScreenState();
}

class _GallerySingleImageScreenState extends State<GallerySingleImageScreen> {
  late final PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController(
      initialPage: widget.initialIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: white,
      ),
      body: PageView.builder(
        controller: pageController,
        itemCount: widget.imageList.length,
        itemBuilder: (context, index) {
          return InteractiveViewer(
            minScale: 1,
            maxScale: 4,
            child: Center(
              child: Image.asset(
                widget.imageList[index],
                fit: BoxFit.contain,
              ),
            ),
          );
        },
      ),
    );
  }
}
