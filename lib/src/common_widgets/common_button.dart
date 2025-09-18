import 'package:eps_client/src/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CommonButton extends StatelessWidget {
  const CommonButton(
      {super.key,
      required this.text,
      required this.onTap,
      this.fontSize = 16,
      this.containerVPadding,
      this.containerHPadding,
      this.isLoading = false,
        this.isShowBorderColor = false,
      this.bgColor,
      this.buttonTextColor,
      this.fontFamily});
  final String text;
  final Function() onTap;
  final double? fontSize;
  final Color? bgColor;
  final double? containerVPadding;
  final double? containerHPadding;
  final bool isLoading;
  final bool? isShowBorderColor;
  final Color? buttonTextColor;
  final String? fontFamily;

  @override
  Widget build(BuildContext context) {
    return Bounceable(
      onTap: () {
        onTap();
      },
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: containerHPadding ?? 24,
            vertical: containerVPadding ?? 6),
        decoration: BoxDecoration(
          color: bgColor ?? Colors.blue,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color:isShowBorderColor==true ? context.primary : Colors.transparent,width: 1)
        ),
        child: isLoading
            ? IntrinsicWidth(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('processing',
                        style: const TextStyle(color: Colors.white)),
                    const SpinKitThreeBounce(size: 25, color: Colors.white),
                  ],
                ),
            )
            : Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: fontSize,
                  color:buttonTextColor,
                ),
              ),
      ),
    );
  }
}
