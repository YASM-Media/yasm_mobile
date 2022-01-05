import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:yasm_mobile/widgets/common/custom_field.widget.dart';

class DraggableTextField extends StatefulWidget {
  const DraggableTextField({Key? key}) : super(key: key);

  @override
  _DraggableTextFieldState createState() => _DraggableTextFieldState();
}

class _DraggableTextFieldState extends State<DraggableTextField> {
  String _text = 'Enter Text';
  double _xPosition = 0;
  double _yPosition = 0;
  double _scale = 1;
  double _rotate = 0;
  double _currentScale = 0;
  double _currentRotate = 0;

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
    return Positioned(
      top: _yPosition,
      left: _xPosition,
      child: Transform.rotate(
        angle: this._rotate,
        child: Transform.scale(
          scale: this._scale,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onScaleStart: _handleGestureScaleStart,
            onScaleUpdate: _handleGestureScaleUpdate,
            onTap: this._handleGestureTap,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.3,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding: EdgeInsets.all(
                MediaQuery.of(context).size.height * 0.02,
              ),
              child: Text(
                this._text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleGestureScaleStart(ScaleStartDetails details) {
    setState(() {
      this._currentRotate = this._rotate;
      this._currentScale = this._scale;
    });
  }

  void _handleGestureScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      this._scale = details.scale * this._currentScale;
      this._rotate = this._currentRotate + details.rotation;
      this._xPosition =
          details.focalPoint.dx - MediaQuery.of(context).size.height * 0.02 * 2;
      this._yPosition =
          details.focalPoint.dy - MediaQuery.of(context).size.height * 0.02 * 2;
    });
  }

  void _handleGestureTap() {
    this._textEditingController.text = this._text;
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: Colors.transparent,
        content: Center(
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
    );
  }

  void _handleTextChange() {
    if (!this._formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      this._text = this._textEditingController.text;
    });

    Navigator.of(context).pop();
  }
}
