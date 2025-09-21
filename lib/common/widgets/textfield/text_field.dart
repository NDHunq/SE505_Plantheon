import 'package:flutter/material.dart';
import 'package:se501_plantheon/core/configs/constants/constraints.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';

/// Custom TextField widget có thể tái sử dụng toàn app
class AppTextField extends StatelessWidget {
  final String? labelText;
  final String? hintText;
  final String? initialValue;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? Function(String?)? validator;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;
  final double? borderWidth;
  final double? focusedBorderWidth;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? textStyle;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final TextAlign? textAlign;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool isDense;
  final double? contentPaddingVertical;
  final InputDecoration? decoration;

  const AppTextField({
    super.key,
    this.labelText,
    this.hintText,
    this.initialValue,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.borderWidth = 1.0,
    this.focusedBorderWidth = 2.0,
    this.contentPadding,
    this.textStyle,
    this.labelStyle,
    this.contentPaddingVertical = 10,
    this.hintStyle,
    this.textAlign,
    this.focusNode,
    this.autofocus = false,
    this.isDense = true,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller:
          controller ??
          (initialValue != null
              ? TextEditingController(text: initialValue)
              : null),
      keyboardType: keyboardType,
      obscureText: obscureText,
      enabled: enabled,
      readOnly: readOnly,
      maxLines: maxLines,
      maxLength: maxLength,
      onTap: onTap,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textAlign: textAlign ?? TextAlign.start,
      focusNode: focusNode,
      autofocus: autofocus,
      style: textStyle,
      decoration: decoration ?? _buildDefaultDecoration(context),
    );
  }

  InputDecoration _buildDefaultDecoration(BuildContext context) {
    final defaultBorderColor = borderColor ?? AppConstraints.lightGray;
    final defaultFocusedBorderColor =
        focusedBorderColor ?? AppColors.primary_600;
    final defaultErrorBorderColor = errorBorderColor ?? Colors.red;

    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      isDense: isDense,
      contentPadding:
          contentPadding ??
          EdgeInsets.symmetric(
            horizontal: AppConstraints.smallPadding,
            vertical: contentPaddingVertical!,
          ),
      labelStyle: labelStyle,
      hintStyle: hintStyle,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: defaultBorderColor, width: borderWidth!),
        borderRadius: BorderRadius.circular(AppConstraints.mediumBorderRadius),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: defaultFocusedBorderColor,
          width: focusedBorderWidth!,
        ),
        borderRadius: BorderRadius.circular(AppConstraints.mediumBorderRadius),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: defaultErrorBorderColor,
          width: borderWidth!,
        ),
        borderRadius: BorderRadius.circular(AppConstraints.mediumBorderRadius),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: defaultErrorBorderColor,
          width: focusedBorderWidth!,
        ),
        borderRadius: BorderRadius.circular(AppConstraints.mediumBorderRadius),
      ),
      disabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: defaultBorderColor.withOpacity(0.5),
          width: borderWidth!,
        ),
        borderRadius: BorderRadius.circular(AppConstraints.mediumBorderRadius),
      ),
    );
  }
}

/// Custom TextFormField widget với validation
class AppTextFormField extends StatelessWidget {
  final String? labelText;
  final String? hintText;
  final String? initialValue;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? Function(String?)? validator;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;
  final double? borderWidth;
  final double? focusedBorderWidth;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? textStyle;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final TextAlign? textAlign;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool isDense;
  final InputDecoration? decoration;

  const AppTextFormField({
    super.key,
    this.labelText,
    this.hintText,
    this.initialValue,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.borderWidth = 1.0,
    this.focusedBorderWidth = 2.0,
    this.contentPadding,
    this.textStyle,
    this.labelStyle,
    this.hintStyle,
    this.textAlign,
    this.focusNode,
    this.autofocus = false,
    this.isDense = true,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      keyboardType: keyboardType,
      obscureText: obscureText,
      enabled: enabled,
      readOnly: readOnly,
      maxLines: maxLines,
      maxLength: maxLength,
      onTap: onTap,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      textAlign: textAlign ?? TextAlign.start,
      focusNode: focusNode,
      autofocus: autofocus,
      style: textStyle,
      decoration: decoration ?? _buildDefaultDecoration(context),
    );
  }

  InputDecoration _buildDefaultDecoration(BuildContext context) {
    final defaultBorderColor = borderColor ?? AppConstraints.lightGray;
    final defaultFocusedBorderColor =
        focusedBorderColor ?? AppColors.primary_600;
    final defaultErrorBorderColor = errorBorderColor ?? AppColors.red;

    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      isDense: isDense,
      contentPadding:
          contentPadding ??
          const EdgeInsets.symmetric(
            horizontal: AppConstraints.smallPadding,
            vertical: AppConstraints.largePadding,
          ),
      labelStyle: labelStyle,
      hintStyle: hintStyle,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: defaultBorderColor, width: borderWidth!),
        borderRadius: BorderRadius.circular(AppConstraints.mediumBorderRadius),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: defaultFocusedBorderColor,
          width: focusedBorderWidth!,
        ),
        borderRadius: BorderRadius.circular(AppConstraints.mediumBorderRadius),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: defaultErrorBorderColor,
          width: borderWidth!,
        ),
        borderRadius: BorderRadius.circular(AppConstraints.mediumBorderRadius),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: defaultErrorBorderColor,
          width: focusedBorderWidth!,
        ),
        borderRadius: BorderRadius.circular(AppConstraints.mediumBorderRadius),
      ),
      disabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: defaultBorderColor.withOpacity(0.5),
          width: borderWidth!,
        ),
        borderRadius: BorderRadius.circular(AppConstraints.mediumBorderRadius),
      ),
    );
  }
}
