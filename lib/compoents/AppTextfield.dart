import 'package:flutter/material.dart';

class AppTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final IconData? icon;
  final IconData? icons;
  final VoidCallback? onToggleVisibility;
  const AppTextField({super.key,
    required this.controller,
    required this.label,
    this.keyboardType,
    this.icon, this.icons,
    this.onToggleVisibility, required String? Function(dynamic value) validator});

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10)
      ),
      child: TextFormField(
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        decoration: InputDecoration(
         // hintText: widget.label,
          labelText: widget.label,
          prefixIcon: widget.icon != null ? Icon(widget.icon, color: Color(0xFF5B86E5)) : null,
          suffixIcon: widget.icons!=null?IconButton(onPressed: widget.onToggleVisibility, icon: Icon(widget.icons)):null,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.white, width: 1.5),),

        ),


      ),
    );
  }
}
