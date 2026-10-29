import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import 'skleton/skelton.dart';

class NetworkImageWithLoader extends StatelessWidget {
  final BoxFit fit;

  const NetworkImageWithLoader(
    this.src, {
    super.key,
    this.fit = BoxFit.cover,
    this.radius = defaultPadding,
  });

  final String src;
  final double radius;

  @override
  Widget build(BuildContext context) {
    if (src.isEmpty || !src.startsWith('http')) {
      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF252532)
              : const Color(0xFFF0F0F5),
          borderRadius: BorderRadius.all(Radius.circular(radius)),
        ),
        child: const Center(
          child: Icon(Icons.image_outlined, color: Colors.grey, size: 28),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(radius)),
      child: CachedNetworkImage(
        fit: fit,
        imageUrl: src,
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imageProvider,
              fit: fit,
            ),
          ),
        ),
        placeholder: (context, url) => const Skeleton(),
        errorWidget: (context, url, error) => Container(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF252532)
              : const Color(0xFFF0F0F5),
          child: const Center(
            child: Icon(Icons.broken_image_outlined, color: Colors.grey, size: 26),
          ),
        ),
      ),
    );
  }
}
