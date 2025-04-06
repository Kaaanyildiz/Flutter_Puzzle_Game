// lib/core/services/timer_service.dart

import 'dart:async';

class TimerService {
  Timer? _timer;
  int _seconds = 0;

  int get seconds => _seconds;

  void startTimer(Function(int) onTick) {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _seconds++;
      onTick(_seconds);
    });
  }

  void stopTimer() {
    _timer?.cancel();
  }
}
