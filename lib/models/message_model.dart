import 'package:flutter/cupertino.dart';
import 'package:keyboard_animate/testing_page.dart';

class MessageNotifier extends ChangeNotifier {
  List<MessageModel> messageList = [];
  MessageNotifier() {
    initMessage();
  }
  void updateLocalFilePath(id, filePath) {
    messageList[id].value = filePath;
    notifyListeners();
  }

  MessageModel getItem(id) =>
      messageList.firstWhere((element) => element.id == id);

  void initMessage() {
    List.generate(10, (index) {
      if (index != 2) {
        messageList.add(
            MessageModel(id: index, type: "text", value: "List title $index"));
      } else {
        messageList.add(MessageModel(
            id: index,
            type: "image",
            value: "$baseUrl/api/file/bird_girl.png"));
      }
    });
    notifyListeners();
  }

  void addConversation(MessageModel data) {
    messageList = [data, ...messageList];
    notifyListeners();
  }

  int getConversionCount() => messageList.length;
}

class MessageModel {
  int id;
  String type;
  String value;
  MessageModel({required this.id, required this.type, required this.value});
}
