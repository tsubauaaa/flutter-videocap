import 'dart:io';

import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:path/path.dart';

class CameraPreviewTopPage extends StatefulWidget {
  const CameraPreviewTopPage({
    Key key,
    @required this.camera,
  }) : super(key: key);
  final CameraDescription camera;

  @override
  CameraPreviewTopPageState createState() => CameraPreviewTopPageState();
}

class CameraPreviewTopPageState extends State<CameraPreviewTopPage> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Capture a video'),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: startAndStopVideoRecording,
        child: const Icon(Icons.camera_alt),
      ),
    );
  }

  void startAndStopVideoRecording() async {
    try {
      await _initializeControllerFuture;
      if (_controller.value.isRecordingVideo) {
        FlutterBeep.playSysSound(iOSSoundIDs.EndVideoRecording);
        XFile video = await _controller.stopVideoRecording();
        File videoFile = File(video.path);
        final String videoPath = "/videos/" + basename(video.path);
        Reference ref = FirebaseStorage.instance.ref().child(videoPath);
        TaskSnapshot storageTaskSnapshot = await ref.putFile(videoFile);
        if (storageTaskSnapshot.ref != null) {
          final downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
          print('Stop video recording and save video.');
          print(downloadUrl.toString());
        }
        return;
      }
      try {
        FlutterBeep.playSysSound(
          iOSSoundIDs.BeginVideoRecording,
        );
        await _controller.startVideoRecording();
        print('Start video recording.');
      } on CameraException catch (e) {
        print(e);
      }
    } catch (e) {
      print(e);
    }
  }
}
