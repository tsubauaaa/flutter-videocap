import 'dart:math';

import 'package:app/models/reognition_model.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
import 'package:image/image.dart';

class Classifier {
  Classifier(Interpreter interpreter) {
    loadModel(interpreter);
  }
  final modelFileName = 'mobilefacenet.tflite';
  Interpreter? _interpreter;

  Interpreter? get interpreter => _interpreter;

  final inputSize = 300;

  late ImageProcessor imageProcessor;

  late List<List<int>> _outputShapes;

  late List<TfLiteType> _outputTypes;

  Future<void> loadModel(Interpreter? interpreter) async {
    _interpreter = interpreter ??
        await Interpreter.fromAsset(
          modelFileName,
          options: InterpreterOptions()..threads = 4,
        );
    print('Interpreter loaded successfully');
    final outputTensors = _interpreter!.getOutputTensors();
    _outputShapes = [];
    _outputTypes = [];
    for (final tensor in outputTensors) {
      _outputShapes.add(tensor.shape);
      _outputTypes.add(tensor.type);
    }
  }

  TensorImage getProcessedImage(TensorImage inputImage) {
    final padSize = max(
      inputImage.height,
      inputImage.width,
    );

    imageProcessor = ImageProcessorBuilder()
        .add(
          ResizeWithCropOrPadOp(padSize, padSize),
        )
        .add(ResizeOp(
          inputSize,
          inputSize,
          ResizeMethod.BILINEAR,
        ))
        .build();
    return imageProcessor.process(inputImage);
  }

  RecognitionModel predict(Image image) {
    var inputImage = TensorImage.fromImage(image);
    inputImage = getProcessedImage(inputImage);

    final outputLocations = TensorBufferFloat(_outputShapes[0]);
    final outputClasses = TensorBufferFloat(_outputShapes[1]);
    final outputScores = TensorBufferFloat(_outputShapes[2]);
    final numLocations = TensorBufferFloat(_outputShapes[3]);

    final inputs = [inputImage.buffer];
    final outputs = {
      0: outputLocations.buffer,
      1: outputClasses.buffer,
      2: outputScores.buffer,
      3: numLocations.buffer,
    };

    _interpreter!.runForMultipleInputs(inputs, outputs);

    print('output: $outputs');

    final recognition = RecognitionModel(true);

    return recognition;
  }
}
