import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/small_image_notifier.dart';

class SelectedLayer extends StatelessWidget {
  final SmallImageModel item;
  const SelectedLayer({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isSelected = context.select<SmallImageNotifier, bool>(
        (smallImageNotifier) => smallImageNotifier.items.contains(item));
    var index = -1;
    if (isSelected) {
      index = context.select<SmallImageNotifier, int>(
          (smallImageNotifier) => smallImageNotifier.getItemById(item.id));
    }
    return GestureDetector(
      onTap: () {
        var smallImageNotifier = context.read<SmallImageNotifier>();
        if (isSelected) {
          smallImageNotifier.removeFromSelectedList(item);
        } else {
          smallImageNotifier.addToSelectedList(item);
        }
      },
      child: Visibility(
        visible: isSelected,
        maintainInteractivity: true,
        maintainSize: true,
        maintainAnimation: true,
        maintainState: true,
        child: Stack(
          children: [
            Container(color: Colors.white.withOpacity(0.5)),
            Align(
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.all(6),
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black,
                ),
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Text(
                    "${++index}",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
