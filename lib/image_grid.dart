import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_animate/models/image_loading.dart';
import 'package:keyboard_animate/models/message_model.dart';
import 'package:keyboard_animate/models/small_image_notifier.dart';
import 'package:keyboard_animate/testing_page.dart';
import 'package:provider/provider.dart';
import 'image_item.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as file_util;

class ImageGrid extends StatefulWidget {
  final ScrollController scrollController;
  final ScrollController listController;
  const ImageGrid(
      {Key? key, required this.scrollController, required this.listController})
      : super(key: key);

  @override
  State<ImageGrid> createState() => _ImageGridState();
}

class _ImageGridState extends State<ImageGrid> {
  @override
  void initState() {
    listSyncFiles();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var bottomOffset = MediaQuery.of(context).viewInsets.bottom;
    return Stack(
      children: [
        SmallImageNotifier.plainImageList.isNotEmpty
            ? GridView.builder(
                controller: widget.scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: SmallImageNotifier.plainImageList.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {},
                    child: ImageItem(index: index, myKey: myKey),
                  );
                },
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, mainAxisSpacing: 2, crossAxisSpacing: 2),
              )
            : const Align(
                alignment: Alignment.center,
                child: CircularProgressIndicator(),
              ),
        Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedContainer(
            decoration: const BoxDecoration(color: Colors.white, boxShadow: [
              BoxShadow(
                  color: Colors.grey, offset: Offset(0, 1), blurRadius: 0.1)
            ]),
            duration: const Duration(milliseconds: 100),
            curve: bottomOffset > 0 ? Curves.easeOutExpo : Curves.elasticOut,
            padding: EdgeInsets.only(bottom: bottomOffset),
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: const BoxDecoration(color: Colors.white, boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(0, 1),
                  blurRadius: 0.05,
                )
              ]),
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.emoji_emotions_outlined,
                        color: Colors.grey,
                      )),
                  const Expanded(
                      child: TextField(
                          decoration: InputDecoration.collapsed(
                              hintText: "Add a caption...",
                              hintStyle: TextStyle(color: Colors.grey)))),
                  IconButton(
                      onPressed: () {
                        var selectedList = Provider.of<SmallImageNotifier>(
                                context,
                                listen: false)
                            .items;
                        for (var element in selectedList) {
                          uploadImage(element.file, widget.listController);
                        }
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.send,
                        color: Colors.lightBlue,
                      ))
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  void uploadImage(File file, ScrollController listController) async {
    print("uploadImage loading..!");
    var id = context.read<MessageNotifier>().getConversionCount();
    Provider.of<MessageNotifier>(context, listen: false)
        .addConversation(MessageModel(id: id, type: "image", value: file.path));
    Provider.of<ImageLoadingNotifier>(context, listen: false)
        .addItem(id, file.path);
    listController.jumpTo(0.0);
    int byteCount = 0;
    var httpClient = HttpClient();
    final request = await httpClient.postUrl(Uri.parse("$baseUrl/api/file"));
    var multipart = await http.MultipartFile.fromPath("photos", file.path,
        filename: file_util.basename(file.path));
    var requestMultipart =
        http.MultipartRequest("POST", Uri.parse("$baseUrl/api/file"));
    requestMultipart.files.add(multipart);
    var msStream = requestMultipart.finalize();
    var totalBytesLength = requestMultipart.contentLength;
    request.contentLength = totalBytesLength;
    request.headers.set(HttpHeaders.contentTypeHeader,
        requestMultipart.headers[HttpHeaders.contentTypeHeader]!);
    Stream<List<int>> streamUpload = msStream
        .transform(StreamTransformer.fromHandlers(handleData: (data, sink) {
      sink.add(data);
      byteCount += data.length;
      updateProgress(id, byteCount, totalBytesLength);
    }, handleError: (err, stack, sink) {
      print("stream Error $err");
      throw err;
    }, handleDone: (sink) {
      print("stream done!");
      sink.close();
    }));
    await request.addStream(streamUpload);
    var response = await request.close();
    if (response.statusCode == 200) {
      Provider.of<ImageLoadingNotifier>(myKey.currentContext!, listen: false)
          .removeLoadingItem(id);
      response
          .transform(utf8.decoder)
          .listen((value) {}, onDone: () => print("OnDone!"));
    }
  }

  void listSyncFiles() async {
    try {
      final result = await platform.invokeMethod("listSyncFiles");
      List decodedData = jsonDecode(result.toString());
      if (SmallImageNotifier.plainImageList != decodedData) {
        setState(() {
          SmallImageNotifier.plainImageList = decodedData;
        });
      }
    } catch (e) {
      print("Error is $e");
    }
  }
}

void updateProgress(int id, int sentBytes, int totalBytes) {
  var progress = (sentBytes / totalBytes * 100).toStringAsFixed(2);
  var result = (double.parse(progress) / 100).toStringAsFixed(2);
  Provider.of<ImageLoadingNotifier>(myKey.currentContext!, listen: false)
      .updateProgress(id, result);
}
