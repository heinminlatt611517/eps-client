import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomAppBarView extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBarView({
    super.key,
    required this.title,
    this.backgroundColor,
    this.trailing,
    this.showBack,
    this.onBack,
    this.popResult = true,
    this.centerTitle = true,
  });

  final String? title;
  final Color? backgroundColor;
  final Widget? trailing;
  final bool? showBack;
  final VoidCallback? onBack;
  final Object? popResult;
  final bool centerTitle;

  @override
  Widget build(BuildContext context) {
    final canPop = ModalRoute.of(context)?.canPop ?? false;
    final shouldShowBack = showBack ?? canPop;

    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      centerTitle: centerTitle,
      systemOverlayStyle: isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      leadingWidth: shouldShowBack ? 48 : 0,
      leading: shouldShowBack
          ? IconButton(
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        onPressed: () {
          if (onBack != null) {
            onBack!();
          } else {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop(popResult);
            }
          }
        },
      )
          : null,
      title: Text(
        title ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
      actions: trailing == null
          ? null
          : [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Center(child: trailing),
        ),
      ],
      foregroundColor: cs.onSurface,
      surfaceTintColor: backgroundColor, // removes unwanted tint on Android 12+
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
