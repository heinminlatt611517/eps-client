import 'package:flutter/material.dart';
class PasswordInputField extends StatefulWidget {
  const PasswordInputField({
    super.key,
    required this.controller,
    this.hintText,
    this.isPassword = false,
    this.validator,
    this.onChanged,
    this.readOnly = false,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String? hintText;
  final bool isPassword;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final TextInputType? keyboardType;

  @override
  State<PasswordInputField> createState() => _PasswordInputFieldState();
}

class _PasswordInputFieldState extends State<PasswordInputField> {
  bool _obscured = true;

  @override
  void initState() {
    super.initState();
    _obscured = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      height: 54,
      alignment: Alignment.center,
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: widget.controller,
              readOnly: widget.readOnly,
              keyboardType: widget.keyboardType,
              obscureText: widget.isPassword ? _obscured : false,
              onChanged: widget.onChanged,
              validator: widget.validator,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: tt.bodyMedium?.copyWith(color: Colors.grey[600]),
                isDense: true,
                border: InputBorder.none,
              ),
            ),
          ),
          if (widget.isPassword)
            IconButton(
              tooltip: _obscured ? 'Show password' : 'Hide password',
              splashRadius: 18,
              icon: Icon(
                _obscured ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                color: Colors.grey[600],
              ),
              onPressed: () => setState(() => _obscured = !_obscured),
            ),
        ],
      ),
    );
  }
}
