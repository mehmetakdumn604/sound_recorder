import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sound_recorder/providers/sound_controller.dart';
import 'package:sound_recorder/view/home_view.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_)=> SoundController.instance),
    ],
    child: const MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeView(),
    );
  }
}
