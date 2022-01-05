import 'package:flutter/material.dart';
import 'package:yasm_mobile/widgets/stories/draggable_text_field.widget.dart';

class CreateStory extends StatefulWidget {
  const CreateStory({Key? key}) : super(key: key);

  static const routeName = "/create-story";

  @override
  _CreateStoryState createState() => _CreateStoryState();
}

class _CreateStoryState extends State<CreateStory> {
  List<DraggableTextField> _textFields = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: _textFields,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            this._textFields.add(
                  new DraggableTextField(),
                );
          });
        },
      ),
    );
  }
}
