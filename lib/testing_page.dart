import 'dart:io';
import 'package:flutter/services.dart';
import 'package:keyboard_animate/image_grid.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_animate/models/image_loading.dart';
import 'package:keyboard_animate/models/message_model.dart';
import 'package:provider/provider.dart';

var isLayoutOpening = false;
var baseUrl = "http://192.168.100.95:3000";
var appImageDir = "/storage/emulated/0/DCIM/NearBy";
MethodChannel platform = const MethodChannel("ag.test.thumbnail");

GlobalKey myKey = GlobalKey();

class TestingPage extends StatefulWidget {
  const TestingPage({Key? key}) : super(key: key);

  @override
  State<TestingPage> createState() => _TestingPageState();
}

class _TestingPageState extends State<TestingPage> {
  var listController = ScrollController();

  @override
  Widget build(BuildContext context) {
    print("TestingPage build ********************");
    var bottomOffset = MediaQuery.of(context).viewInsets.bottom;
    var conversationList = context.watch<MessageNotifier>().messageList;
    return Scaffold(
      key: myKey,
      resizeToAvoidBottomInset: false,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 50),
        padding: EdgeInsets.only(bottom: !isLayoutOpening ? bottomOffset : 0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                  reverse: true,
                  controller: listController,
                  itemCount: conversationList.length,
                  itemBuilder: (context, index) {
                    var item = conversationList[index];
                    return item.type == "text"
                        ? ListTile(title: Text(item.value))
                        : Align(
                            alignment: Alignment.topRight,
                            child: ListViewImage(
                                filePath: item.value, id: item.id),
                          );
                  }),
            ),
            Divider(
              height: 1,
              color: Colors.grey[300],
            ),
            TextCompose(
                body: Container(
              height: 50,
              color: Colors.white70,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {
                        showBotSheet();
                      },
                      icon: const Icon(
                        Icons.emoji_emotions_outlined,
                        color: Colors.grey,
                      )),
                  const Expanded(
                      child: TextField(
                    decoration: InputDecoration.collapsed(
                        hintText: "Type a message...",
                        hintStyle: TextStyle(color: Colors.grey)),
                  )),
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.send,
                        color: Colors.lightBlue,
                      ))
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }

  void showBotSheet() {
    isLayoutOpening = true;
    showModalBottomSheet(
        barrierColor: Colors.grey.withOpacity(0.1),
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return DraggableScrollableSheet(
              initialChildSize: 0.6,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                    color: Colors.white,
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.drag_handle),
                      Builder(builder: (context) {
                        return Expanded(
                          child: ImageGrid(
                            scrollController: scrollController,
                            listController: listController,
                          ),
                        );
                      }),
                    ],
                  ),
                );
              });
        }).then((value) => isLayoutOpening = false);
  }
}

class ListViewImage extends StatelessWidget {
  final String filePath;
  final int id;
  const ListViewImage({Key? key, required this.filePath, required this.id})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var dataPath = context.select<MessageNotifier, String>(
        (notifier) => notifier.getItem(id).value);
    print("Progress is $dataPath");

    return Stack(alignment: Alignment.center, children: [
      filterImage(context, dataPath),
      LoadingProgress(filePath: filePath, id: id)
    ]);
  }

  Widget filterImage(BuildContext context, String filePath) {
    if (filePath.startsWith("http://")) {
      var filename = filePath.split("/").last;
      filePath = "$appImageDir/$filename";
      if (!File(filePath).existsSync()) {
        downloadImage(context, id, filename);
        filePath = "$appImageDir/default.webp";
      } else {}
    }
    return Container(
      margin: const EdgeInsets.all(8),
      width: 250,
      height: 250,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
              fit: BoxFit.cover,
              image: ResizeImage(FileImage(File(filePath)),
                  width: 400, height: 400))),
    );
  }

  void downloadImage(context, id, filename) async {
    print("Image Downloading!");
    final url = Uri.parse("$baseUrl/api/file");
    final client = HttpClient();
    final request = await client.getUrl(url);
    request.headers
        .add(HttpHeaders.contentTypeHeader, "application/octet-stream");
    var httpResponse = await request.close();
    int byteCount = 0;
    var totalBytes = httpResponse.contentLength;
    var file = File("$appImageDir/$filename");
    Provider.of<ImageLoadingNotifier>(context, listen: false)
        .addItem(id, file.path);
    var fileWriter = file.openSync(mode: FileMode.write);
    httpResponse.listen((data) {
      byteCount += data.length;
      fileWriter.writeFromSync(data);
      updateProgress(id, byteCount, totalBytes);
    }, onDone: () {
      fileWriter.closeSync();
      platform.invokeMethod("refreshGallery", file.path);
      Provider.of<MessageNotifier>(context, listen: false)
          .updateLocalFilePath(id, "$appImageDir/$filename");
      print("Download Done!");
    }, onError: () {
      fileWriter.closeSync();
      print("Download Error!");
    });
  }
}

class LoadingProgress extends StatelessWidget {
  final String filePath;
  final int id;
  const LoadingProgress({Key? key, required this.filePath, required this.id})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    var progress = context.select<ImageLoadingNotifier, String>(
        (notifier) => notifier.getItem(id).progress);
    var percent = 0.0;
    if (progress != "-1") {
      percent = double.parse(progress);
    } else {
      percent = 1;
    }
    print("$id is Loading $progress%");
    return progress == "-1" || progress == "1.00"
        ? const SizedBox(width: 60, height: 60)
        : SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              value: percent,
              color: Colors.amber,
            ),
          );
  }
}

class TextCompose extends StatelessWidget {
  final Widget body;
  const TextCompose({Key? key, required this.body}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return body;
  }
}
