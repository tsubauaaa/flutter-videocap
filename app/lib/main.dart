import 'dart:async';
import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'pages/camera_preview_top_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  CameraDescription frontCamera;
  await availableCameras().then(
    (cameras) {
      frontCamera = cameras.firstWhere(
          (description) =>
              description.lensDirection == CameraLensDirection.front,
          orElse: () => null);
      if (frontCamera == null) {
        return;
      }
    },
  );

  print(frontCamera.toString());
  runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      home: CameraPreviewTopPage(
        camera: frontCamera,
      ),
    ),
  );
}
