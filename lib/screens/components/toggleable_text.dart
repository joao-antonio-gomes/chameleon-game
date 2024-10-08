import 'package:flutter/material.dart';

class ToggleableText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final bool obscureInitially;

  const ToggleableText({
    super.key,
    required this.text,
    this.style,
    this.obscureInitially = false,
  });

  @override
  ToggleableTextState createState() => ToggleableTextState();
}

class ToggleableTextState extends State<ToggleableText> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureInitially;
  }

  void _toggleObscure() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    IconData iconData = _obscureText ? Icons.visibility_off : Icons.visibility;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _obscureText ? _obscure(widget.text) : widget.text,
          style: widget.style,
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: _toggleObscure,
          child: Icon(
            iconData,
            size: 20,
          ),
        ),
      ],
    );
  }

  String _obscure(String text) {
    return text.replaceAll(RegExp(r'.'), '•');
  }
}
