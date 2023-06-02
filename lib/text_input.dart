import 'package:flutter/material.dart';

class TextInput extends StatefulWidget {
  final TextEditingController textEditingController;
  final String label;

  const TextInput(
      {required this.textEditingController, required this.label, super.key});

  @override
  State<TextInput> createState() => _TextInputState();
}

class _TextInputState extends State<TextInput> {
  @override
  Widget build(BuildContext context) {
    return TextField(
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
