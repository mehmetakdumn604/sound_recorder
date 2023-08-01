import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/sound_controller.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    Provider.of<SoundController>(context, listen: false).initAudio();
  }

  @override
  Widget build(BuildContext context) {
    final SoundController soundController = context.watch();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sound Recorder App"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 300,
              height: 90,
              color: Colors.black.withOpacity(.7),
              child: Column(
                children: [
                  Text(
                    soundController.audioTime,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      PlayerIcon(
                        onPressed: soundController.recordAudio,
                        icon: Icons.mic,
                      ),
                      if (soundController.voiceState != VoiceState.none)
                        PlayerIcon(
                          onPressed: soundController.pauseResumeAudio,
                          icon: soundController.voiceState == VoiceState.recording
                              ? Icons.pause
                              : Icons.play_arrow,
                        ),
                      if (soundController.voiceState != VoiceState.none)
                        PlayerIcon(
                          onPressed: soundController.stopAudio,
                          icon: Icons.stop,
                        ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class PlayerIcon extends StatelessWidget {
  const PlayerIcon({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      color: Colors.white,
      iconSize: 32,
    );
  }
}
