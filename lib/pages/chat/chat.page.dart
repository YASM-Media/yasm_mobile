import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:provider/provider.dart';
import 'package:yasm_mobile/constants/logger.constant.dart';
import 'package:yasm_mobile/dto/chat/chat_arguments/chat_arguments.dto.dart';
import 'package:yasm_mobile/dto/chat/create_chat/create_chat.dto.dart';
import 'package:yasm_mobile/dto/chat/delete_chat/delete_chat.dto.dart';
import 'package:yasm_mobile/dto/chat/delete_thread/delete_thread.dto.dart';
import 'package:yasm_mobile/exceptions/common/server.exception.dart';
import 'package:yasm_mobile/models/chat/chat_message/chat_message.model.dart';
import 'package:yasm_mobile/models/chat/chat_thread/chat_thread.model.dart';
import 'package:yasm_mobile/models/user/user.model.dart';
import 'package:yasm_mobile/pages/user/user_profile.page.dart';
import 'package:yasm_mobile/services/chat.service.dart';
import 'package:yasm_mobile/utils/display_snackbar.util.dart';
import 'package:yasm_mobile/widgets/chat/chat_bubble.widget.dart';
import 'package:yasm_mobile/widgets/common/custom_field.widget.dart';
import 'package:yasm_mobile/widgets/common/profile_picture.widget.dart';

class Chat extends StatefulWidget {
  const Chat({Key? key}) : super(key: key);

  static const routeName = "/chat";

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  late final ChatService _chatService;
  ChatThread? _chatThread;
  User? _user;
  List<Chat> _chats = [];

  final TextEditingController _chatController = new TextEditingController();
  final GlobalKey<FormState> _formKey = new GlobalKey();

  @override
  void initState() {
    super.initState();

    // Injecting the required services.
    this._chatService = Provider.of<ChatService>(context, listen: false);
  }

  @override
  void dispose() {
    super.dispose();

    // Disposing off the text controllers.
    this._chatController.dispose();
  }

  /*
   * Method to handle chat message submission.
   */
  Future<void> onMessageSubmit() async {
    // Check the validity of the form.
    if (!this._formKey.currentState!.validate()) {
      return;
    }

    // Save the message in database in the given thread.
    try {
      await this._chatService.createChatMessage(
            new CreateChatDto(
              threadId: this._chatThread!.id,
              message: this._chatController.text,
              createdAt: DateTime.now(),
            ),
          );
    } on ServerException catch (error) {
      displaySnackBar(error.message, context);
    } catch (error, stackTrace) {
      log.e("Chat:onMessageSubmit", error, stackTrace);
      displaySnackBar(
        "Something went wrong, please try again later.",
        context,
      );
    }
  }

  /*
   * Method to handle deleting chat message.
   */
  Future<void> onMessageDelete(String id) async {
    try {
      // Delete the message from the thread.
      await this._chatService.deleteChatMessage(
            new DeleteChatDto(
              threadId: this._chatThread!.id,
              chatId: id,
            ),
          );
    } on ServerException catch (error) {
      displaySnackBar(error.message, context);
    } catch (error, stackTrace) {
      log.e("Chat:onMessageDelete", error, stackTrace);
      displaySnackBar(
        "Something went wrong, please try again later.",
        context,
      );
    }
  }

  /*
   * Method to handle closing a thread.
   */
  Future<void> onThreadClose() async {
    // Close the thread and pop off from the chat screen.
    await this._chatService.deleteChatThread(
          new DeleteThreadDto(
            threadId: this._chatThread!.id,
          ),
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (this._chatThread == null || this._user == null) {
      ChatArguments chatArguments =
          ModalRoute.of(context)!.settings.arguments as ChatArguments;

      this._chatThread = chatArguments.chatThread;
      this._user = chatArguments.user;
    }

    AppBar appBar = AppBar(
      title: ListTile(
        leading: ProfilePicture(
          imageUrl: this._user!.imageUrl,
          size: MediaQuery.of(context).size.width * 0.1,
        ),
        title: Text('${this._user!.firstName} ${this._user!.lastName}'),
        onTap: () {
          Navigator.of(context).pushNamed(
            UserProfile.routeName,
            arguments: this._user!.id,
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: this.onThreadClose,
          child: Text('Close Chat'),
        ),
      ],
    );

    return Scaffold(
      appBar: appBar,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: this._chatService.listenToThread(this._chatThread!.id),
            builder: (
              BuildContext context,
              AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot,
            ) {
              if (snapshot.hasError) {
                log.e("Chat Error", snapshot.error, snapshot.stackTrace);
                return Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text("Loading");
              }

              this._chats.clear();

              if (snapshot.data!.data() != null) {
                this._chatThread = ChatThread.fromJson(snapshot.data!.data()!);
                this._chatThread!.messages.sort(
                      (ChatMessage a, ChatMessage b) => a.createdAt.compareTo(
                        b.createdAt,
                      ),
                    );
              }

              ScrollController controller = ScrollController();

              SchedulerBinding.instance!.addPostFrameCallback((_) {
                controller.jumpTo(controller.position.maxScrollExtent);
              });

              return Expanded(
                child: ListView.builder(
                  controller: controller,
                  shrinkWrap: true,
                  itemCount: this._chatThread!.messages.length,
                  itemBuilder: (context, index) {
                    ChatMessage chatMessage = this._chatThread!.messages[index];
                    return ChatBubble(
                      chatMessage: chatMessage,
                      onDelete: this.onMessageDelete,
                    );
                  },
                ),
              );
            },
          ),
          Container(
            child: Form(
              key: this._formKey,
              child: Row(
                children: [
                  Expanded(
                    child: CustomField(
                      textFieldController: this._chatController,
                      label: "Your Message",
                      validators: [
                        RequiredValidator(
                            errorText: "Please type in your message")
                      ],
                      textInputType: TextInputType.text,
                    ),
                  ),
                  OfflineBuilder(
                    connectivityBuilder:
                        (BuildContext context, ConnectivityResult result, _) {
                      final bool connected = result != ConnectivityResult.none;

                      return IconButton(
                        icon: Icon(Icons.send),
                        onPressed: connected ? this.onMessageSubmit : null,
                      );
                    },
                    child: SizedBox(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
