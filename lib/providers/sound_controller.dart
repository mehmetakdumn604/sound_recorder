import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_sound_lite/flutter_sound.dart';

class SoundController extends ChangeNotifier {
  static final SoundController _instance = SoundController._internal();
  static SoundController get instance => _instance;
  SoundController._internal();

  FlutterSoundRecorder? _audioRecorder;

  Duration _recordDuration = Duration.zero;

  Timer? _timer;

  String get audioTime => _recordDuration.toString().split('.').first.padLeft(8, "0");

  VoiceState voiceState = VoiceState.none;

  void initAudio() async {
    _audioRecorder = FlutterSoundRecorder();
    await _audioRecorder?.openAudioSession();
  }

  void recordAudio() async {
    try {
      changeVoiceState(VoiceState.recording);
      _startTimer();
      await _audioRecorder?.startRecorder(
        toFile: "${DateTime.now().millisecondsSinceEpoch.toString()}.wav",
        codec: Codec.pcm16WAV,
      );
    } catch (e) {
      changeVoiceState(VoiceState.none);

      _stopTimer();
      log(e.toString());
    }
  }

  void stopAudio() async {
    try {
      changeVoiceState(VoiceState.none);

      _stopTimer();

      await _audioRecorder?.stopRecorder();
    } catch (e) {
      changeVoiceState(VoiceState.none);

      _stopTimer();

      log(e.toString());
    }
  }

  void pauseResumeAudio(){
    if(_audioRecorder == null) return;
   ( _audioRecorder!.isPaused )? _resumeAudio() : _pauseAudio();
  }

  void _pauseAudio() async {
    try {
      changeVoiceState(VoiceState.paused);

      _stopTimer(resetTime: false);

      await _audioRecorder?.pauseRecorder();
    } catch (e) {
      changeVoiceState(VoiceState.none);

      _stopTimer();

      log(e.toString());
    }
  }

  void _resumeAudio() async {
    try {
      changeVoiceState(VoiceState.recording);
      _startTimer();
      await _audioRecorder?.resumeRecorder();
    } catch (e) {
      changeVoiceState(VoiceState.none);
      _stopTimer();

      log(e.toString());
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _recordDuration += const Duration(seconds: 1);
      notifyListeners();
    });
  }

  void _stopTimer({bool resetTime = true}) {
    _timer?.cancel();
    _timer = null;

    if (resetTime) {
      _recordDuration = Duration.zero;
      notifyListeners();
    }
  }

  void changeVoiceState(VoiceState state) {
    voiceState = state;
    notifyListeners();
  }
}

enum VoiceState {
  none,
  paused,
  recording,
}
