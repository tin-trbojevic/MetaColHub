import 'package:flutter/material.dart';

class MyTextfield extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const MyTextfield({
    super.key,
    required this.hintText,
    required this.obscureText,
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,

            // Normal (unfocused) border
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(12),
            ),

            // Focused border
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.inversePrimary,
                width: 2.5,
              ),
              borderRadius: BorderRadius.circular(12),
            ),

            // Error border
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.redAccent),
              borderRadius: BorderRadius.circular(12),
            ),

            // Focused error border
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.deepOrange, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),

            suffixIcon:
                controller.text.isNotEmpty
                    ? Material(
                      color: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          controller.clear();
                          setState(() {});
                          if (onChanged != null) onChanged!('');
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(5.0),
                          child: Icon(Icons.clear),
                        ),
                      ),
                    )
                    : null,
          ),
          obscureText: obscureText,
          onChanged: (value) {
            setState(() {});
            if (onChanged != null) onChanged!(value);
          },
        );
      },
    );
  }
}
