import 'dart:io';
import 'package:flutter/cupertino.dart';

class SmallImageNotifier extends ChangeNotifier {
  final List _selectedList = [];
  static List plainImageList = [];

  SmallImageModel getById(int id) {
    var imageData = plainImageList[id];
    return SmallImageModel(
        id: id,
        file: File(imageData['file']),
        width: imageData['width'],
        height: imageData['height']);
  }

  List<SmallImageModel> get items =>
      _selectedList.map((id) => getById(id)).toList();

  int getItemById(int id) => _selectedList.indexWhere((itemId) => id == itemId);

  void addToSelectedList(SmallImageModel item) {
    _selectedList.add(item.id);
    notifyListeners();
  }

  void removeFromSelectedList(SmallImageModel item) {
    _selectedList.remove(item.id);
    notifyListeners();
  }
}

class SmallImageModel {
  final int id;
  final File file;
  final int width;
  final int height;
  SmallImageModel(
      {required this.id,
      required this.file,
      required this.width,
      required this.height});

  @override
  int get hashCode => id;

  @override
  bool operator ==(Object other) => other is SmallImageModel && other.id == id;

  SmallImageModel.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        file = File(json["file"]),
        width = json["width"],
        height = json["height"];
}
