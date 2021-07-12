import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'pages/camera_preview_top_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      home: CameraPreviewTopPage(),
    ),
  );
}
