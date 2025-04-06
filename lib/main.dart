// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:puzzlegame/features/puzzle/presentation/screens/puzzle.screen.dart';
import 'features/puzzle/logic/puzzle_provider.dart';

void main() {
  runApp(const PuzzleGame());
}

class PuzzleGame extends StatelessWidget {
  const PuzzleGame({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PuzzleProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const PuzzleScreen(),
      ),
    );
  }
}
