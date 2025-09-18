import 'package:flutter/material.dart';

class RatingView extends StatelessWidget {
  const RatingView({
    super.key,
    this.value,
    this.max = 5,
    this.size = 16,
    this.color,
    this.showValue = false,
    this.gap = 6,
    this.textStyle,
  });

  final double? value;
  final int max;
  final double size;
  final Color? color;
  final bool showValue;
  final double gap;
  final TextStyle? textStyle;

  /// Helper if your API gives rating as a String
  factory RatingView.fromString({
    Key? key,
    String? ratingStr,
    int max = 5,
    double size = 16,
    Color? color,
    bool showValue = false,
    double gap = 6,
    TextStyle? textStyle,
  }) {
    final v = double.tryParse((ratingStr ?? '').trim()) ?? 0.0;
    return RatingView(
      key: key,
      value: v,
      max: max,
      size: size,
      color: color,
      showValue: showValue,
      gap: gap,
      textStyle: textStyle,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;

    final raw = (value ?? 0).clamp(0, max).toDouble();
    final rounded = (raw * 2).round() / 2.0;

    final full = rounded.floor();
    final hasHalf = (rounded - full) == 0.5;
    final empty = max - full - (hasHalf ? 1 : 0);

    final stars = <Widget>[
      for (var i = 0; i < full; i++) Icon(Icons.star, size: size, color: c),
      if (hasHalf) Icon(Icons.star_half, size: size, color: c),
      for (var i = 0; i < empty; i++) Icon(Icons.star_border, size: size, color: c),
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...stars,
        if (showValue) SizedBox(width: gap),
      ],
    );
  }
}
