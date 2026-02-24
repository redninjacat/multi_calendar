import 'package:flutter/material.dart';

/// Static helper class providing reusable control widgets with consistent
/// Material 3 styling.
///
/// All methods accept localized string labels from the caller, ensuring
/// no hardcoded English strings in this file.
class ControlWidgets {
  ControlWidgets._(); // Private constructor to prevent instantiation

  /// Creates a labeled toggle switch (SwitchListTile).
  ///
  /// - [label]: Localized label text for the toggle
  /// - [value]: Current boolean value
  /// - [onChanged]: Callback when the toggle changes
  static Widget toggle({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(label),
      value: value,
      onChanged: onChanged,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  /// Creates a labeled slider with value display.
  ///
  /// - [label]: Localized label text for the slider
  /// - [value]: Current numeric value
  /// - [min]: Minimum value
  /// - [max]: Maximum value
  /// - [divisions]: Number of discrete divisions (null for continuous)
  /// - [onChanged]: Callback when the slider value changes
  /// - [valueLabel]: Optional custom value display text (if null, shows value)
  static Widget slider({
    required String label,
    required double value,
    required double min,
    required double max,
    int? divisions,
    required ValueChanged<double> onChanged,
    String? valueLabel,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              Text(
                valueLabel ?? value.toStringAsFixed(divisions != null ? 0 : 1),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  /// Creates a labeled range slider with two thumbs.
  ///
  /// - [label]: Localized label text for the slider
  /// - [values]: Current [RangeValues] (start, end)
  /// - [min], [max]: Value bounds
  /// - [divisions]: Number of discrete steps
  /// - [onChanged]: Callback when either thumb moves
  /// - [valueLabel]: Optional custom display text
  static Widget rangeSlider({
    required String label,
    required RangeValues values,
    required double min,
    required double max,
    int? divisions,
    required ValueChanged<RangeValues> onChanged,
    String? valueLabel,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              Text(
                valueLabel ??
                    '${values.start.toStringAsFixed(0)} – ${values.end.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          RangeSlider(
            values: values,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  /// Creates a labeled dropdown selector.
  ///
  /// - [label]: Localized label text for the dropdown
  /// - [value]: Currently selected value
  /// - [items]: List of dropdown items
  /// - [onChanged]: Callback when the selection changes
  static Widget dropdown<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(width: 16),
          DropdownButton<T>(
            value: value,
            items: items,
            onChanged: onChanged,
            underline: Container(
              height: 1,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.shade400,
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Creates a labeled color picker button.
  ///
  /// - [label]: Localized label text for the color picker
  /// - [value]: Current color value
  /// - [onChanged]: Callback when a color is selected
  /// - [cancelLabel]: Localized text for the cancel button (defaults to empty)
  static Widget colorPicker({
    required String label,
    required Color value,
    required ValueChanged<Color> onChanged,
    String cancelLabel = '',
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(width: 16),
          Builder(
            builder: (context) => InkWell(
              onTap: () {
                showDialog<Color>(
                  context: context,
                  builder: (context) => ColorPickerDialog(
                    label: label,
                    initialColor: value,
                    onColorSelected: onChanged,
                    cancelLabel: cancelLabel,
                  ),
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 48,
                height: 36,
                decoration: BoxDecoration(
                  color: value,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.grey.shade400,
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Creates a set of preset selection chips.
  ///
  /// - [label]: Localized label text for the preset chips
  /// - [selected]: Currently selected preset value
  /// - [presets]: List of available preset values
  /// - [labelBuilder]: Function to generate localized label for each preset
  /// - [onChanged]: Callback when a preset is selected
  static Widget presetChips<T>({
    required String label,
    required T selected,
    required List<T> presets,
    required String Function(T) labelBuilder,
    required ValueChanged<T> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: presets.map((preset) {
              final isSelected = preset == selected;
              return ChoiceChip(
                label: Text(labelBuilder(preset)),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    onChanged(preset);
                  }
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Creates a tri-state toggle for nullable boolean fields.
  ///
  /// Shows three states: true (enabled), false (disabled), null (default/unset).
  ///
  /// - [label]: Localized label text for the toggle
  /// - [value]: Current nullable boolean value
  /// - [onChanged]: Callback when the state changes
  static Widget triStateToggle({
    required String label,
    required bool? value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<bool?>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment<bool?>(
                  value: null,
                  icon: Opacity(
                    opacity: value == null ? 1.0 : 0.4,
                    child: const Icon(Icons.remove, size: 16),
                  ),
                ),
                ButtonSegment<bool?>(
                  value: false,
                  icon: Opacity(
                    opacity: value == false ? 1.0 : 0.4,
                    child: const Icon(Icons.close, size: 16),
                  ),
                ),
                ButtonSegment<bool?>(
                  value: true,
                  icon: Opacity(
                    opacity: value == true ? 1.0 : 0.4,
                    child: const Icon(Icons.check, size: 16),
                  ),
                ),
              ],
              selected: {value},
              onSelectionChanged: (Set<bool?> newSelection) {
                if (newSelection.isNotEmpty) {
                  onChanged(newSelection.first);
                }
              },
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ],
      ),
    );
  }

}

/// A simple color picker dialog widget.
///
/// This is a basic implementation showing Material colors.
/// For production use, consider using a dedicated color picker package.
class ColorPickerDialog extends StatelessWidget {
  final String label;
  final Color initialColor;
  final ValueChanged<Color> onColorSelected;
  final String cancelLabel;

  const ColorPickerDialog({
    super.key,
    required this.label,
    required this.initialColor,
    required this.onColorSelected,
    this.cancelLabel = '',
  });

  static final List<Color> _materialColors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
    Colors.black,
    Colors.white,
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(label),
      content: SizedBox(
        width: 300,
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _materialColors.length,
          itemBuilder: (context, index) {
            final color = _materialColors[index];
            final isSelected = color == initialColor;
            return InkWell(
              onTap: () {
                onColorSelected(color);
                Navigator.of(context).pop();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade400,
                    width: isSelected ? 3 : 1,
                  ),
                ),
              ),
            );
          },
        ),
      ),
      actions: cancelLabel.isNotEmpty
          ? [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(cancelLabel),
              ),
            ]
          : null,
    );
  }
}
