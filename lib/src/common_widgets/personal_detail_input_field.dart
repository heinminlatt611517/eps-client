import 'package:flutter/material.dart';

class PersonalDetailInputField extends StatelessWidget {
  const PersonalDetailInputField({
    super.key,
    required this.label,
    required this.controller,          // <-- use controller instead of value
    this.hint,
    this.onChanged,
    this.keyboardType,
    this.readOnly = false,
    this.maxLines = 1,
    this.validator,
    this.suffix,
    this.onTap
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: cs.surfaceVariant.withOpacity(.35),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: tt.labelLarge?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            readOnly: readOnly,
            keyboardType: keyboardType,
            maxLines: maxLines,
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
            ),
          ),
        ],
      ),
    );
  }
}
