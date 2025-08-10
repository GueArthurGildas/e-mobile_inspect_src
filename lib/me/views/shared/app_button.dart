import 'package:flutter/material.dart';

import 'base_button.dart';

class AppButton extends StatelessWidget {
  AppButton.outline({
    super.key,
    required this.onPressed,
    this.text,
    this.style,
    this.prefixIcon,
    this.suffixIcon,
    this.borderRadius,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.color = Colors.black,
    this.backgroundColor = Colors.transparent,
    this.borderColor = const Color(0xFFFF6A00),
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
    this.margin = const EdgeInsets.symmetric(horizontal: 16),
    this.space = 12,
    this.height = 48,
    this.width = double.infinity,
    this.enabled = true,
    this.mainAxisAlignment = MainAxisAlignment.spaceAround,
  });

  AppButton({
    super.key,
    required this.onPressed,
    this.text,
    this.style,
    this.prefixIcon,
    this.suffixIcon,
    this.borderRadius,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.color = Colors.white,
    this.backgroundColor = const Color(0xFFFF6A00),
    this.borderColor = const Color(0xFFFF6A00),
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
    this.margin = const EdgeInsets.symmetric(horizontal: 16),
    this.space = 12,
    this.height = 48,
    this.width = double.infinity,
    this.enabled = true,
    this.mainAxisAlignment = MainAxisAlignment.spaceAround,
  });

  final String? text;
  final VoidCallback? onPressed;
  final Color color;
  final Color backgroundColor;
  final Color borderColor;
  final TextStyle? style;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final double space;
  final double? height;
  final double? width;
  final BorderRadius? borderRadius;
  final bool enabled;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(48),
        child: BaseButton(
          onPressed: enabled ? onPressed : null,
          color: backgroundColor,
          child: Container(
            height: height,
            width: width,
            padding: padding,
            decoration: BoxDecoration(
              color: enabled
                  ? backgroundColor
                  : backgroundColor.withValues(alpha: 0.4),
              border: Border.all(
                color: enabled
                    ? borderColor
                    : borderColor.withValues(alpha: 0.4),
              ),
              borderRadius: borderRadius ?? BorderRadius.circular(48),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: mainAxisAlignment,
              crossAxisAlignment: crossAxisAlignment,
              children: [
                if (prefixIcon != null)
                  Padding(
                    padding: EdgeInsets.only(right: text == null ? 0 : space),
                    child: prefixIcon!,
                  ),
                if (text != null)
                  Text(
                    text ?? "",
                    style: style?.copyWith(
                      color: enabled ? color : color.withValues(alpha: 0.4),
                    ),
                  ),
                if (suffixIcon != null)
                  Padding(
                    padding: EdgeInsets.only(right: text == null ? 0 : space),
                    child: suffixIcon!,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
