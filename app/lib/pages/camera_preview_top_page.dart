import 'dart:io';

import 'package:app/components/blinking_text_animation.dart';
import 'package:app/utils/scanner_utils.dart';
import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:path/path.dart';

class CameraPreviewTopPage extends StatefulWidget {
  const CameraPreviewTopPage({
    Key key,
  }) : super(key: key);

  @override
  CameraPreviewTopPageState createState() => CameraPreviewTopPageState();
}

class CameraPreviewTopPageState extends State<CameraPreviewTopPage> {
  CameraController _camera;
  Future<void> _initializeControllerFuture;
  bool _isRecording = false;

  CameraLensDirection _direction = CameraLensDirection.front;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final CameraDescription description =
        await ScannerUtils.getCamera(_direction);
    _camera = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: false,
    );
    setState(() {
      _initializeControllerFuture = _camera.initialize();
    });
  }

  @override
  void dispose() async {
    _camera.dispose();
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
          if (_camera != null) {
            return Stack(
              fit: StackFit.expand,
              children: [
                CameraPreview(_camera),
                if (_isRecording)
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
      if (_camera.value.isRecordingVideo) {
        FlutterBeep.playSysSound(iOSSoundIDs.EndVideoRecording);
        XFile video = await _camera.stopVideoRecording();
        setState(() {
          _isRecording = _camera.value.isRecordingVideo;
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
        await _camera.startVideoRecording();
        print('Start video recording.');
        setState(() => _isRecording = _camera.value.isRecordingVideo);
      } on CameraException catch (e) {
        print(e);
      }
    } catch (e) {
      print(e);
    }
  }
}
