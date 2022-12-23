import 'package:flutter/cupertino.dart';

class ImageLoadingNotifier extends ChangeNotifier {
  List<ImageLoadingModel> loadingItems = <ImageLoadingModel>[];
  ImageLoadingModel getItem(id) =>
      loadingItems.firstWhere((element) => element.id == id,
          orElse: () =>
              ImageLoadingModel(id: -1, filePath: "finished!", progress: "-1"));

  void addItem(id, file) {
    loadingItems = [
      ...loadingItems,
      ImageLoadingModel(id: id, filePath: file, progress: "0")
    ];
    notifyListeners();
  }

  void updateProgress(id, progress) {
    loadingItems[_getItemIndex(id)].progress = progress;
    notifyListeners();
  }

  void removeLoadingItem(id) {
    loadingItems.removeAt(_getItemIndex(id));
    notifyListeners();
  }

  int _getItemIndex(id) =>
      loadingItems.indexWhere((element) => element.id == id);
}

class ImageLoadingModel {
  final int id;
  String filePath;
  String progress;
  ImageLoadingModel(
      {required this.id, required this.filePath, required this.progress});

  @override
  bool operator ==(Object other) =>
      other is ImageLoadingModel &&
      other.id == id &&
      other.filePath == filePath &&
      other.progress == progress;

  @override
  int get hashCode => id;
}
