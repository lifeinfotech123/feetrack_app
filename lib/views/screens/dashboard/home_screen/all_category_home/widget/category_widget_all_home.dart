import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:vlr/data/models/category_model/category_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/views/widget/bootstrap_Icon/bootstrap_icon.dart';

class CategoryWidgetHome extends StatelessWidget {
  final CategoryModel categoryModel;

  const CategoryWidgetHome({
    super.key,
    required this.categoryModel,
  });

  @override
  Widget build(BuildContext context) {
    final String? imgUrl = categoryModel.imageUrl;
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 56,
          height: 56,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: categoryModel.colorValue.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: (imgUrl != null && imgUrl.isNotEmpty)
              ? CachedNetworkImage(
                  imageUrl: imgUrl,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Center(
                    child: SizedBox(
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: categoryModel.colorValue,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Center(
                    child: Icon(
                      getBootstrapIcon(categoryModel.icon),
                      color: categoryModel.colorValue,
                      size: 28,
                    ),
                  ),
                )
              : Center(
                  child: Icon(
                    getBootstrapIcon(categoryModel.icon),
                    color: categoryModel.colorValue,
                    size: 28,
                  ),
                ),
        ),
        const SizedBox(height: 6),
        Text(
          categoryModel.name ?? "",
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Helper(context).textTheme.titleSmall?.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
        ),
      ],
    );
  }
}
