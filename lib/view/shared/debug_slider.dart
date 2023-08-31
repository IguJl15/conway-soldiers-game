import 'package:flutter/material.dart';

class DebugSlider extends StatelessWidget {
  final String label;
  final double min;
  final double max;
  final double value;
  final ValueChanged<double> onChanged;

  const DebugSlider({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface.withOpacity(.4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              textAlign: TextAlign.end,
            ),
          ),
          Slider.adaptive(
            label: label,
            semanticFormatterCallback: (value) => "$value",
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          )
        ],
      ),
    );
  }
}
