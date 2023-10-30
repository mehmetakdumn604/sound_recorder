import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_sound_lite/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';

class SoundController extends ChangeNotifier {
  static final SoundController _instance = SoundController._internal();
  static SoundController get instance => _instance;
  SoundController._internal();

  FlutterSoundRecorder? _audioRecorder;
  FlutterSoundPlayer? _audioPlayer;

  final player = AudioPlayer();
  Duration _recordDuration = Duration.zero;

  Timer? _timer;

  String get audioTime => _recordDuration.toString().split('.').first.padLeft(8, "0");

  VoiceState voiceState = VoiceState.none;
  String? audioFilePath;

  void initAudio() async {
    _audioRecorder = FlutterSoundRecorder();
    await _audioRecorder?.openAudioSession();
    await _audioPlayer?.openAudioSession();
  }

  void recordAudio() async {
    try {
      changeVoiceState(VoiceState.recording);
      final Directory audioDirectory = await getApplicationDocumentsDirectory();
      audioFilePath = "${audioDirectory.path}/${DateTime.now().millisecondsSinceEpoch.toString()}.wav";
      _startTimer();
      await _audioRecorder?.startRecorder(
        toFile: audioFilePath,
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
      changeVoiceState(VoiceState.done);
    } catch (e) {
      changeVoiceState(VoiceState.none);

      _stopTimer();

      log(e.toString());
    }
  }

  void pauseResumeAudio() {
    if (_audioRecorder == null) return;
    (_audioRecorder!.isPaused) ? _resumeAudio() : _pauseAudio();
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

  void playAudioFile() async {
    try {
      await _audioPlayer?.startPlayer(
        fromURI: audioFilePath,
        whenFinished: () {
          log("Finished playing audio");
        },
      );
    } catch (e) {
      log(e.toString());
    }
  }

  /// ------ upload audio file
  PlatformFile? _platformFile;

  PlatformFile? get platformFile => _platformFile;

  Future<void> uploadFile() async {
    try {
      FilePickerResult? filePickerResult = await FilePicker.platform.pickFiles(
        allowCompression: true,
        allowMultiple: false,
        allowedExtensions: ['mp3', 'wav'],
        type: FileType.custom,
      );
      if (filePickerResult == null) {
        log("FilePickerResult is null");
        return;
      }
      _platformFile = filePickerResult.files.first;
      notifyListeners();
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> playUploadedAudioFile() async {
    try {
      if (_platformFile?.path == null) {
        log("_platformFile is null");
        return;
      }
      await player.play(
        DeviceFileSource(_platformFile!.path!),
      );
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> pauseUploadedAudioFile() async {
    try {
      await player.pause();
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> stopUploadedAudioFile() async {
    try {
      await player.stop();
    } catch (e) {
      log(e.toString());
    }
  }
}

enum VoiceState {
  none,
  paused,
  recording,
  done,
}
