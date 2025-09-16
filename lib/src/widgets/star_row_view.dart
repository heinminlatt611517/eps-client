import 'package:flutter/material.dart';

/// Star row with halves and empties (0..5)
class StarRow extends StatelessWidget {
  const StarRow({super.key, required this.rating});
  final double rating;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    int full = rating.floor();
    double frac = rating - full;
    bool hasHalf = frac >= 0.25 && frac < 0.75;
    if (frac >= 0.75) { full += 1; hasHalf = false; }
    final empty = 5 - full - (hasHalf ? 1 : 0);

    final stars = <Widget>[
      for (int i = 0; i < full; i++)
        Icon(Icons.star, size: 16, color: cs.primary),
      if (hasHalf)
        Icon(Icons.star_half, size: 16, color: cs.primary),
      for (int i = 0; i < empty; i++)
        Icon(Icons.star_border, size: 16, color: cs.primary),
    ];

    return Row(children: stars);
  }
}