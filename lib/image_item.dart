import 'package:flutter/material.dart';
import 'package:keyboard_animate/selected_layer.dart';
import 'package:provider/provider.dart';
import 'models/small_image_notifier.dart';

class ImageItem extends StatelessWidget {
  final int index;
  final GlobalKey myKey;
  const ImageItem({Key? key, required this.index, required this.myKey})
      : super(key: key);
  final minSize = 400;

  @override
  Widget build(BuildContext context) {
    SmallImageModel item = context.select<SmallImageNotifier, SmallImageModel>(
        (selectedImageNotifier) => selectedImageNotifier.getById(index));
    var resizeRatio = getAspectSize(item.width, item.height).toInt();
    return Stack(
      children: [
        Container(
          color: Colors.grey[300],
          width: double.infinity,
          height: double.infinity,
        ),
        Container(
          decoration: BoxDecoration(
              image: DecorationImage(
            fit: BoxFit.cover,
            scale: 5,
            image: ResizeImage(FileImage(item.file),
                width: item.width > minSize
                    ? item.width ~/ resizeRatio
                    : item.width,
                height: item.height > minSize
                    ? item.height ~/ resizeRatio
                    : item.height,
                allowUpscaling: false),
          )),
        ),
        SelectedLayer(item: item),
      ],
    );
  }

  int getAspectSize(width, height) {
    var ratio = 1;
    if (width > 400 || height > 400) {
      var halfWidth = width / 2;
      var halfHeight = height / 2;
      while (halfHeight / ratio >= minSize || halfWidth / ratio >= minSize) {
        ratio *= 2;
      }
    }
    return ratio;
  }
}
