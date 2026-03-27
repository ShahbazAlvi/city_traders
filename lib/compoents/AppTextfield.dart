// import 'package:flutter/material.dart';
//
// class AppTextField extends StatefulWidget {
//   final TextEditingController controller;
//   final String label;
//   final TextInputType? keyboardType;
//   final IconData? icon;
//   final IconData? icons;
//   final VoidCallback? onToggleVisibility;
//   const AppTextField({super.key,
//     required this.controller,
//     required this.label,
//     this.keyboardType,
//     this.icon, this.icons,
//     this.onToggleVisibility, required String? Function(dynamic value) validator});
//
//   @override
//   State<AppTextField> createState() => _AppTextFieldState();
// }
//
// class _AppTextFieldState extends State<AppTextField> {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(10)
//       ),
//       child: TextFormField(
//         controller: widget.controller,
//         keyboardType: widget.keyboardType,
//         decoration: InputDecoration(
//          // hintText: widget.label,
//           labelText: widget.label,
//           prefixIcon: widget.icon != null ? Icon(widget.icon, color: Color(0xFF5B86E5)) : null,
//           suffixIcon: widget.icons!=null?IconButton(onPressed: widget.onToggleVisibility, icon: Icon(widget.icons)):null,
//           border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(10),
//             borderSide: const BorderSide(color: Colors.white, width: 1.5),),
//
//         ),
//
//
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

class AppTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final IconData? icon;
  final IconData? icons;
  final VoidCallback? onToggleVisibility;
  final String? Function(dynamic value)? validator;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.keyboardType,
    this.icon,
    this.icons,
    this.onToggleVisibility,
    required this.validator,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  late AnimationController _animController;
  late Animation<double> _glowAnimation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
      if (_focusNode.hasFocus) {
        _animController.forward();
      } else {
        _animController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              // Subtle base shadow
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
              // Focus glow effect
              if (_isFocused)
                BoxShadow(
                  color: const Color(0xFF5B86E5)
                      .withOpacity(0.25 * _glowAnimation.value),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            keyboardType: widget.keyboardType,
            validator: widget.validator,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1A1D2E),
              letterSpacing: 0.2,
            ),
            decoration: InputDecoration(
              labelText: widget.label,
              labelStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _isFocused
                    ? const Color(0xFF5B86E5)
                    : const Color(0xFF9CA3AF),
                letterSpacing: 0.3,
              ),
              floatingLabelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF5B86E5),
                letterSpacing: 0.4,
              ),

              // Prefix icon with animated color
              prefixIcon: widget.icon != null
                  ? Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  widget.icon,
                  color: _isFocused
                      ? const Color(0xFF5B86E5)
                      : const Color(0xFFB0B8C8),
                  size: 20,
                ),
              )
                  : null,

              // Suffix icon button
              suffixIcon: widget.icons != null
                  ? IconButton(
                onPressed: widget.onToggleVisibility,
                icon: Icon(
                  widget.icons,
                  color: _isFocused
                      ? const Color(0xFF5B86E5)
                      : const Color(0xFFB0B8C8),
                  size: 20,
                ),
                splashRadius: 20,
              )
                  : null,

              // Fill
              filled: true,
              fillColor: _isFocused
                  ? Colors.white
                  : const Color(0xFFF8F9FC),

              // Content padding
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 18,
              ),

              // Borders
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFFE8ECF4),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFF5B86E5),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFFFF5C5C),
                  width: 1.5,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFFFF5C5C),
                  width: 2,
                ),
              ),

              // Error style
              errorStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFFFF5C5C),
                letterSpacing: 0.2,
              ),
            ),
          ),
        );
      },
    );
  }
}