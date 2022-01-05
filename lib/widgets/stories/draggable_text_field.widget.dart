import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:yasm_mobile/widgets/common/custom_field.widget.dart';

class DraggableTextField extends StatefulWidget {
  const DraggableTextField({Key? key}) : super(key: key);

  @override
  _DraggableTextFieldState createState() => _DraggableTextFieldState();
}

class _DraggableTextFieldState extends State<DraggableTextField> {
  String text = 'Enter Text';
  double xPosition = 0;
  double yPosition = 0;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _textEditingController =
      new TextEditingController(text: 'Enter Text');

  @override
  void dispose() {
    super.dispose();

    this._textEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Positioned(
        top: yPosition,
        left: xPosition,
        child: GestureDetector(
          onPanUpdate: this._handleGesturePanUpdate,
          onTap: this._handleGestureTap,
          child: Container(
            color: Colors.pink,
            padding: EdgeInsets.all(
              20.0,
            ),
            child: Text(
              this.text,
            ),
          ),
        ),
      ),
    );
  }

  void _handleGesturePanUpdate(tapData) {
    setState(() {
      this.xPosition += tapData.delta.dx;
      this.yPosition += tapData.delta.dy;
    });
  }

  void _handleGestureTap() {
    this._textEditingController.text = this.text;
    showDialog(
      context: context,
      builder: (BuildContext context) => Material(
        color: Colors.transparent,
        child: Container(
          child: Center(
            child: Form(
              key: this._formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomField(
                    textFieldController: this._textEditingController,
                    label: "Edit Text",
                    validators: [
                      RequiredValidator(errorText: "Text is required."),
                    ],
                    textInputType: TextInputType.text,
                  ),
                  TextButton(
                    onPressed: _handleTextChange,
                    child: Text('OK'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleTextChange() {
    if (!this._formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      this.text = this._textEditingController.text;
    });

    Navigator.of(context).pop();
  }
}
