// lib/puzzle/logic/puzzle_provider.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:puzzlegame/domain/models/puzzle_piece.dart';

class PuzzleProvider extends ChangeNotifier {
  late final int gridSize;
  
  // Yapıcı metod parametreye opsiyonel değer atadım
  PuzzleProvider([this.gridSize = 3]) {
    final totalPieces = gridSize * gridSize;
    shuffledIndices = List.generate(totalPieces, (index) => index)..shuffle();
    
    // Dinamik olarak puzzle parçalarını oluşturuyorum
    puzzlePieces = List.generate(totalPieces, (index) {
      // Resim dosyalarını 1-9 arası isimlendiriyoruz
      final imageIndex = (index % 9) + 1;
      return PuzzlePiece(index: index, imagePath: 'assets/images/piece$imageIndex.jpg');
    });
  }

  late final List<PuzzlePiece> puzzlePieces;
  late List<int> shuffledIndices;
  int secondsElapsed = 0;
  Timer? _timer;

  bool isCompleted() {
    return List.generate(gridSize * gridSize, (index) => index).every((i) => shuffledIndices[i] == i);
  }

  void swapPieces(int index1, int index2) {
    int temp = shuffledIndices[index1];
    shuffledIndices[index1] = shuffledIndices[index2];
    shuffledIndices[index2] = temp;
    notifyListeners();
  }

  void startTimer(Function(int) onTick) {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      secondsElapsed++;
      onTick(secondsElapsed);
      notifyListeners();
    });
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}