import 'package:hooks_riverpod/hooks_riverpod.dart';

final indexProvider = StateNotifierProvider((ref) => IndexController());

class IndexController extends StateNotifier<int> {
  IndexController() : super(0);

  void change() => state == 0 ? state++ : state--;
}
