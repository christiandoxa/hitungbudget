import 'package:flutter/material.dart';

class TextInput extends StatefulWidget {
  final TextEditingController textEditingController;
  final String label;
  final Function(String) onSubmitted;
  const TextInput({
    required this.textEditingController,
    required this.label,
    required this.onSubmitted,
    super.key,
  });

  @override
  State<TextInput> createState() => _TextInputState();
}

class _TextInputState extends State<TextInput> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      onSubmitted: widget.onSubmitted,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        label: Text(
          widget.label,
        ),
      ),
      controller: widget.textEditingController,
    );
  }
}
