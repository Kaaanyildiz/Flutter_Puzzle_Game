// lib/features/puzzle/logic/puzzle_provider.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:puzzlegame/domain/models/puzzle_piece.dart';

class PuzzleProvider extends ChangeNotifier {
  final List<PuzzlePiece> puzzlePieces = List.generate(9, (index) {
    return PuzzlePiece(index: index, imagePath: 'assets/images/piece1.jpg'); // Örnek resim yolu
  });

  List<int> shuffledIndices = List.generate(9, (index) => index)..shuffle();
  int secondsElapsed = 0;

  bool isCompleted() {
    return List.generate(9, (index) => index).every((i) => shuffledIndices[i] == i);
  }

  void swapPieces(int index1, int index2) {
    int temp = shuffledIndices[index1];
    shuffledIndices[index1] = shuffledIndices[index2];
    shuffledIndices[index2] = temp;
    notifyListeners();
  }

  void startTimer(Function(int) onTick) {
    Timer.periodic(Duration(seconds: 1), (timer) {
      secondsElapsed++;
      onTick(secondsElapsed);
    });
  }
}
