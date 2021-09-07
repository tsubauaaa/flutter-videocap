import 'package:app/models/reognition_model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final recognitionsProvider =
    StateNotifierProvider<RecognitionController, dynamic>(
  (ref) => RecognitionController(
    RecognitionModel(false),
  ),
);

class RecognitionController extends StateNotifier<RecognitionModel> {
  RecognitionController(RecognitionModel recognitionState)
      : super(RecognitionModel(false));

  void update(recognition) => state = recognition;
}
