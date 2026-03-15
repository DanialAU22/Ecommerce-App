import 'dart:async';

class Debouncer {
  Debouncer({this.duration = const Duration(milliseconds: 450)});

  final Duration duration;
  Timer? _timer;

  void run(void Function() callback) {
    _timer?.cancel();
    _timer = Timer(duration, callback);
  }

  void dispose() {
    _timer?.cancel();
  }
}
