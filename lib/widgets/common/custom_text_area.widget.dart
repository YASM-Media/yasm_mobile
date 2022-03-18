import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

class CustomTextArea extends StatelessWidget {
  final String label;
  final String helperText;
  final TextEditingController textFieldController;
  final List<FieldValidator> validators;
  final TextInputType textInputType;
  final int minLines;
  final int? maxLines;

  CustomTextArea({
    Key? key,
    required this.textFieldController,
    this.label = '',
    this.helperText = '',
    required this.validators,
    required this.textInputType,
    this.minLines = 1,
    this.maxLines,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: 10.0,
        horizontal: 10.0,
      ),
      child: TextFormField(
        style: TextStyle(
          color: Colors.white,
        ),
        minLines: this.minLines,
        maxLines: this.maxLines,
        keyboardType: textInputType,
        decoration: InputDecoration(
          hintStyle: TextStyle(
            color: Colors.grey,
          ),
          hintText: this.helperText,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          labelText: label,
          border: OutlineInputBorder(),
        ),
        controller: this.textFieldController,
        validator: MultiValidator(validators),
      ),
    );
  }
}