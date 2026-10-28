import 'package:flutter/material.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/services/input_decoration.dart';

class CustomDropDownList<T> extends StatelessWidget {
  final Widget? headingWidget;
  final String? heading;
  final bool isRequired;
  final List<Widget>? itemWidget;

  final List<T> items;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final TextStyle? hintStyle;

  final String? hintText;
  final Widget? preFixWidget;
  final String? prefixText;
  final TextStyle? prefixStyle;

  final FormFieldValidator<T>? validator;

  final Color? borderColor;
  final Color? bgColor;
  final double borderRadius;

  const CustomDropDownList({
    super.key,
    this.headingWidget,
    this.heading,
    this.isRequired = false,
    required this.items,
    this.itemWidget,
    this.value,
    this.onChanged,
    this.hintText,
    this.hintStyle,
    this.preFixWidget,
    this.prefixText,
    this.prefixStyle,
    this.validator,
    this.borderColor,
    this.bgColor,
    this.borderRadius = 12,
  });

  Color get borderColorLocal => borderColor ?? grey.withValues(alpha: 0.5);
  Color get bgColorLocal => bgColor ?? grey.withValues(alpha: 0.1);

  @override
  Widget build(BuildContext context) {
    final textStyle = Helper(context).textTheme.bodyMedium?.copyWith(
          fontSize: 14,
          color: black,
        );
    final hintStyleLocal = hintStyle ??
        Helper(context).textTheme.bodyMedium?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: greyText3,
            );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (heading != null || headingWidget != null) ...[
          Row(
            children: [
              Expanded(
                child: headingWidget ??
                    Text(
                      heading!,
                      overflow: TextOverflow.clip,
                      style: Helper(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: primaryText1,
                          ),
                    ),
              ),
              const SizedBox(width: 4),
              if (isRequired)
                const Text(
                  "*",
                  style: TextStyle(fontSize: 16, color: Colors.red),
                ),
            ],
          ),
          const SizedBox(height: 7),
        ],
        DropdownButtonFormField<T>(
          isExpanded: true,
          initialValue: value,
          style: textStyle,
          dropdownColor: white,
          elevation: 2,
          icon: const Icon(Icons.keyboard_arrow_down),
          validator: validator ??
              (v) {
                if (isRequired && v == null) return "This field is required";
                return null;
              },

          // --- Use SAME decoration as your TextField ---
          decoration: CustomDecoration.inputDecoration(
            hint: hintText ?? "Select",
            bgColor: bgColorLocal,
            hintStyle: hintStyleLocal,
            borderColor: borderColorLocal,
            icon: preFixWidget,
            prefixText: prefixText,
            prefixStyle: prefixStyle,
            borderRadius: borderRadius,
          ),

          items: itemWidget != null
              ? itemWidget?.asMap().entries.map((entry) {
                  int index = entry.key;
                  Widget w = entry.value;

                  return DropdownMenuItem<T>(
                    value: items[index], // ✅ ADD THIS LINE
                    child: w,
                  );
                }).toList()
              : items.map((e) {
                  return DropdownMenuItem<T>(
                    value: e,
                    child: Text(
                      e is String ? e : e.toString(),
                      style: textStyle,
                    ),
                  );
                }).toList(),

          onChanged: onChanged,
        ),
      ],
    );
  }
}
