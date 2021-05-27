import 'dart:io';

import 'package:app/components/blinking_text_animation.dart';
import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
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
  bool isRecording = false;

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
  void dispose() async {
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
            return Stack(
              fit: StackFit.expand,
              children: [
                CameraPreview(_controller),
                if (isRecording)
                  Align(
                    alignment: Alignment.topCenter,
                    child: BlinkingTextAnimation(),
                  ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: startAndStopVideoRecording,
        child: const Icon(
          CupertinoIcons.videocam_circle_fill,
        ),
      ),
    );
  }

  void startAndStopVideoRecording() async {
    try {
      await _initializeControllerFuture;
      if (_controller.value.isRecordingVideo) {
        FlutterBeep.playSysSound(iOSSoundIDs.EndVideoRecording);
        XFile video = await _controller.stopVideoRecording();
        setState(() {
          isRecording = _controller.value.isRecordingVideo;
        });

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
        setState(() => isRecording = _controller.value.isRecordingVideo);
      } on CameraException catch (e) {
        print(e);
      }
    } catch (e) {
      print(e);
    }
  }
}
