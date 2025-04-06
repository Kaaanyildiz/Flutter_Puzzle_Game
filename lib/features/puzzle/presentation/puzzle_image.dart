// lib/features/puzzle/presentation/widgets/puzzle_image.dart

import 'package:flutter/material.dart';

class PuzzleImage extends StatelessWidget {
  final String imagePath;

  const PuzzleImage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Image.asset(imagePath, width: 300, height: 300, fit: BoxFit.cover),
    );
  }
}
