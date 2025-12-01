import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

enum ButtonVariant { primary, secondary, ghost }

enum ButtonSize { small, medium, large }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final Widget? icon;
  final bool fullWidth;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.icon,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = _getButtonStyle();
    final textStyle = _getTextStyle();
    final padding = _getPadding();

    Widget buttonChild = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[icon!, const SizedBox(width: AppSpacing.xs)],
        Text(text, style: textStyle),
      ],
    );

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: TextButton(
        onPressed: onPressed,
        style: buttonStyle.copyWith(padding: WidgetStateProperty.all(padding)),
        child: buttonChild,
      ),
    );
  }

  ButtonStyle _getButtonStyle() {
    Color backgroundColor;
    Color foregroundColor;
    Color borderColor;
    Color hoverColor;

    switch (variant) {
      case ButtonVariant.primary:
        backgroundColor = AppColors.primaryBlack;
        foregroundColor = AppColors.pureWhite;
        borderColor = AppColors.primaryBlack;
        hoverColor = const Color(0xFF171717);
        break;
      case ButtonVariant.secondary:
        backgroundColor = AppColors.pureWhite;
        foregroundColor = AppColors.primaryBlack;
        borderColor = AppColors.primaryBlack;
        hoverColor = AppColors.gray50;
        break;
      case ButtonVariant.ghost:
        backgroundColor = Colors.transparent;
        foregroundColor = AppColors.primaryBlack;
        borderColor = Colors.transparent;
        hoverColor = AppColors.gray50;
        break;
    }

    return ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.hovered)) return hoverColor;
        return backgroundColor;
      }),
      foregroundColor: WidgetStateProperty.all(foregroundColor),
      side: WidgetStateProperty.all(BorderSide(color: borderColor, width: 1)),
      shape: WidgetStateProperty.all(
        const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero, // No rounded corners
        ),
      ),
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      elevation: WidgetStateProperty.all(0),
    );
  }

  TextStyle _getTextStyle() {
    double fontSize;

    switch (size) {
      case ButtonSize.small:
        fontSize = 14;
        break;
      case ButtonSize.medium:
        fontSize = 16;
        break;
      case ButtonSize.large:
        fontSize = 18;
        break;
    }

    return TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600);
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(vertical: 8, horizontal: 16);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(vertical: 12, horizontal: 24);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(vertical: 16, horizontal: 32);
    }
  }
}
