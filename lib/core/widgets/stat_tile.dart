import 'package:flutter/material.dart';
import '../theme.dart';

class StatTile extends StatelessWidget {
  final String numeral;
  final String caption;

  const StatTile({super.key, required this.numeral, required this.caption});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          numeral,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontFamily: 'Michroma',
                fontSize: 48,
                height: 1.0,
                color: AppTheme.text,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          caption.toUpperCase(),
          style: AppTheme.labelStyle,
        ),
      ],
    );
  }
}
