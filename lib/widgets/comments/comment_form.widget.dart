import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:yasm_mobile/widgets/common/custom_text_area.widget.dart';

class CommentForm extends StatefulWidget {
  const CommentForm({Key? key}) : super(key: key);

  @override
  _CommentFormState createState() => _CommentFormState();
}

class _CommentFormState extends State<CommentForm> {
  final TextEditingController _commentController = new TextEditingController();

  @override
  void dispose() {
    super.dispose();

    this._commentController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 10, 0, 20),
      child: Form(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.80,
              child: CustomTextArea(
                textFieldController: this._commentController,
                label: "Comment Here",
                validators: [
                  RequiredValidator(
                    errorText: 'Please enter some text',
                  ),
                ],
                textInputType: TextInputType.text,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text('SUBMIT'),
            ),
          ],
        ),
      ),
    );
  }
}
