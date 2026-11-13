import 'package:flutter/material.dart';
import 'package:morph_expressive/morph_expressive.dart';

/// Compare the retained organic bloom and harmonic stretch with the original.
class MorphChipOrganicLab extends StatefulWidget {
  const MorphChipOrganicLab({super.key});

  @override
  State<MorphChipOrganicLab> createState() => _MorphChipOrganicLabState();
}

class _MorphChipOrganicLabState extends State<MorphChipOrganicLab> {
  static const _options = <MorphChipToggleOption<String>>[
    MorphChipToggleOption(value: 'Daily', label: 'Daily'),
    MorphChipToggleOption(value: 'Weekly', label: 'Weekly'),
    MorphChipToggleOption(value: 'Monthly', label: 'Monthly'),
  ];

  double _bloomIntensity = 0.25;
  double _stretchIntensity = 0.40;
  String _single = 'Daily';
  Set<String> _multi = <String>{};

  @override
  Widget build(BuildContext context) =>
      Material(type: MaterialType.transparency, child: _buildLab(context));

  Widget _buildLab(BuildContext context) {
    final theme = MorphTheme.of(context);
    final textColor = theme.colorScheme.onSurfaceVariant;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Organic ink · bloom and harmonic stretch',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'The first selection uses a subtle irregular bloom; subsequent '
          'selections retain the original delayed stretch, with a gentle '
          'central-height deformation. The rounded ends remain unchanged '
          'and every pill returns to its normal shape at rest.',
          style: TextStyle(color: textColor),
        ),
        const SizedBox(height: 10),
        _intensitySlider(
          label: 'First selection · bloom',
          key: 'chip_organic_bloom_slider',
          valueKey: 'chip_organic_bloom_value',
          intensity: _bloomIntensity,
          onChanged: (value) => setState(() => _bloomIntensity = value),
        ),
        _intensitySlider(
          label: 'Stretch · central height',
          key: 'chip_organic_stretch_slider',
          valueKey: 'chip_organic_stretch_value',
          intensity: _stretchIntensity,
          onChanged: (value) => setState(() => _stretchIntensity = value),
        ),
        const SizedBox(height: 16),
        Text('Single · harmonic stretch', style: theme.textTheme.labelLarge),
        const SizedBox(height: 8),
        MorphChipToggle<String>(
          key: const ValueKey('organic_single_chip'),
          options: _options,
          organicBloomIntensity: _bloomIntensity,
          organicStretchIntensity: _stretchIntensity,
          selected: _single,
          onChanged: (next) => setState(() => _single = next),
        ),
        const SizedBox(height: 18),
        Text('Multiple · harmonic stretch', style: theme.textTheme.labelLarge),
        const SizedBox(height: 8),
        MorphChipToggle<String>(
          key: const ValueKey('organic_multi_chip'),
          options: _options,
          organicBloomIntensity: _bloomIntensity,
          organicStretchIntensity: _stretchIntensity,
          multiSelection: true,
          selectedValues: _multi,
          onSelectionChanged: (next) => setState(() => _multi = next),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          key: const ValueKey('chip_organic_reset_multi'),
          onPressed: () => setState(() => _multi = <String>{}),
          icon: const Icon(Icons.restart_alt),
          label: const Text('Clear selection · repeat first bloom'),
        ),
        const SizedBox(height: 14),
        Text(
          'Reference · original (intensity 0)',
          style: theme.textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        MorphChipToggle<String>(
          options: _options,
          selected: _single,
          onChanged: (next) => setState(() => _single = next),
        ),
        const SizedBox(height: 10),
        MorphChipToggle<String>(
          options: _options,
          multiSelection: true,
          selectedValues: _multi,
          onSelectionChanged: (next) => setState(() => _multi = next),
        ),
      ],
    );
  }

  Widget _intensitySlider({
    required String label,
    required String key,
    required String valueKey,
    required double intensity,
    required ValueChanged<double> onChanged,
  }) => Row(
    children: [
      SizedBox(width: 102, child: Text(label)),
      const Text('0'),
      Expanded(
        child: Slider(
          key: ValueKey(key),
          min: 0,
          max: 1,
          divisions: 100,
          value: intensity,
          label: intensity.toStringAsFixed(2),
          onChanged: onChanged,
        ),
      ),
      const Text('1'),
      const SizedBox(width: 8),
      SizedBox(
        width: 44,
        child: Text(
          intensity.toStringAsFixed(2),
          key: ValueKey(valueKey),
          textAlign: TextAlign.end,
        ),
      ),
    ],
  );
}
