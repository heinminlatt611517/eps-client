import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PersonalDetailInputField extends StatelessWidget {
  const PersonalDetailInputField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.onChanged,
    this.keyboardType,
    this.readOnly = false,
    this.maxLines = 1,
    this.validator,
    this.suffix,
    this.onTap,
    this.focusNode,
    this.errorText,
    this.obscureText = false,
    this.textInputAction,
    this.inputFormatters,
    this.enabled = true,
    this.textCapitalization = TextCapitalization.none,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;

  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final bool readOnly;
  final int maxLines;
  final String? Function(String?)? validator;
  final Widget? suffix;
  final VoidCallback? onTap;

  // NEW
  final FocusNode? focusNode;
  final String? errorText;
  final bool obscureText;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final hasError = (errorText != null && errorText!.isNotEmpty);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: cs.surfaceVariant.withOpacity(.35),
        borderRadius: BorderRadius.circular(12),
        border: hasError
            ? Border.all(color: cs.error.withOpacity(.6))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: tt.labelLarge?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            focusNode: focusNode,
            enabled: enabled,
            readOnly: readOnly,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            textCapitalization: textCapitalization,
            maxLines: obscureText ? 1 : maxLines,
            obscureText: obscureText,
            inputFormatters: inputFormatters,
            onChanged: onChanged,
            onTap: onTap,
            validator: validator,
            style: tt.titleMedium?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: tt.titleMedium?.copyWith(
                color: Colors.grey,
                fontWeight: FontWeight.w400,
              ),
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              suffixIcon: suffix,
              // show error line if provided
              errorText: errorText,
              errorMaxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
