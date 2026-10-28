import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/extensions.dart';
import 'custom_image.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    Key? key,
    this.title,
    this.actions,
    this.leading,
    this.titleColor = Colors.black,
    this.fontWeight,
    this.isHome = false,
    this.automaticallyImplyLeading = true,
    this.centerTitle = false,
    this.toolbarHeight = kToolbarHeight,
    this.backgroundColor = Colors.transparent,
    this.systemOverlayStyle,
    this.iconColor,
    this.bottom,
    this.iconTheme,
  }) : super(key: key);

  final String? title;
  final List<Widget>? actions;
  final Widget? leading;
  final Color? titleColor;
  final FontWeight? fontWeight;
  final Color backgroundColor;
  final Color? iconColor;
  final bool isHome;
  final bool automaticallyImplyLeading;
  final bool centerTitle;
  final double toolbarHeight;
  final SystemUiOverlayStyle? systemOverlayStyle;
  final PreferredSizeWidget? bottom;
  final IconThemeData? iconTheme;

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      centerTitle: centerTitle,
      automaticallyImplyLeading: automaticallyImplyLeading,
      iconTheme: iconTheme,
      leading: leading,
      title: Builder(builder: (context) {
        if (isHome) {
          return const CustomImage(
            height: 35,
            path: Assets.imagesLogo,
          );
        } else {
          if (title != null) {
            return Text(
              title!,
              style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(fontSize: 18.0, color: titleColor, fontWeight: fontWeight),
            );
          } else {
            return const SizedBox.shrink();
          }
        }
      }),
      bottom: bottom,
      actions: actions,
      systemOverlayStyle: systemOverlayStyle ??
          context.theme.appBarTheme.systemOverlayStyle!.copyWith(
            statusBarIconBrightness: Brightness.dark,
          ),
    );
  }
}
