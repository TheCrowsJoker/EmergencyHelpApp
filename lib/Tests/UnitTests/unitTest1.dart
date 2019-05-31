import 'dart:async';
import 'package:test/test.dart';

void main() {
  test('Send location via message feature', () async {
    final testClass = MainTest();

//    Timer shouldnt have started yet
    expect(testClass._timerValue, 10);
    expect(testClass._timerRunning, false);

//    Message shouldnt be sent yet
    expect(testClass._messageSent, false);

    testClass._startTimer();

//    Make sure that the timer has time to become less than 10
    await Future.delayed(const Duration(seconds: 2), () {});

//    timer should be running
    expect(testClass._timerValue, lessThan(10));
    expect(testClass._timerRunning, true);

//    Wait for timer to finish
    await Future.delayed(const Duration(seconds: 10), () {});

//    Timer values should be reset
    expect(testClass._timerValue, 10);
    expect(testClass._timerRunning, false);

//    Message should be sent
    expect(testClass._messageSent, true);
  });
}

class MainTest {
//  Timer values
  Timer _timer;
  int _timerValue = 10;
  bool _timerRunning = false;

//  New Variable used to mock sending messages
  bool _messageSent = false;

  void _startTimer() {
    _timerRunning = true;

    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(oneSec, (Timer timer) {
      if (_timerValue < 0) {
        _stopTimer();
            _sendMessages();
      } else {
        _timerValue = _timerValue - 1;
      }
    });
  }

  void _stopTimer() {
    _timer.cancel();
    _timerRunning = false;
    _timerValue = 10;
  }

  void _sendMessages() async {
    _messageSent = true;
  }
}
