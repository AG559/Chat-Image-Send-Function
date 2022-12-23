import 'package:flutter/material.dart';
import 'package:keyboard_animate/models/image_loading.dart';
import 'package:keyboard_animate/models/message_model.dart';
import 'package:keyboard_animate/models/small_image_notifier.dart';
import 'package:provider/provider.dart';
import 'testing_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<SmallImageNotifier>(
          create: (context) => SmallImageNotifier()),
      ChangeNotifierProvider<ImageLoadingNotifier>(
          create: (context) => ImageLoadingNotifier()),
      ChangeNotifierProvider<MessageNotifier>(
          create: (context) => MessageNotifier()),
    ],
    child: const MaterialApp(home: TestingPage()),
  ));
}

class MyImageCache extends ImageCache {
  MyImageCache() {
    liveImageCount;
    pendingImageCount;
  }
}
