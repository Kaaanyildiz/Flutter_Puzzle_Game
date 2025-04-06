import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart' show rootBundle;

class PuzzleTile extends StatefulWidget {
  final String imagePath;  // Resim yolu
  final int index;         // İndeks
  final int pieceIndex;    // Parça indeks
  final Function(int, int) onPieceMoved; // Parça yer değiştirme callback fonksiyonu

  const PuzzleTile({
    Key? key,
    required this.imagePath,
    required this.index,
    required this.pieceIndex,
    required this.onPieceMoved,
  }) : super(key: key);

  @override
  _PuzzleTileState createState() => _PuzzleTileState();
}

class _PuzzleTileState extends State<PuzzleTile> {
  ui.Image? image;  // ui.Image nesnesi, resmi tutacak

  @override
  void initState() {
    super.initState();
    loadImage(widget.imagePath);  // Resmi yükle
  }

  Future<void> loadImage(String path) async {
    final ByteData data = await rootBundle.load(path);
    final Uint8List bytes = data.buffer.asUint8List();
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    setState(() {
      image = frameInfo.image;  // Resmi set et
    });
  }

  @override
  Widget build(BuildContext context) {
    return Draggable<int>(
      data: widget.index,
      feedback: SizedBox(
        width: 100,
        height: 100,
        child: image != null
            ? CustomPaint(
                size: Size(100, 100),
                painter: PuzzlePainter(image!, widget.pieceIndex),
              )
            : Container(color: Colors.grey),
      ),
      childWhenDragging: Container(color: Colors.grey),
      child: DragTarget<int>(
        onAcceptWithDetails: (draggedIndex) {
          widget.onPieceMoved(draggedIndex.data, widget.index); // Parçayı yer değiştirme
        },
        builder: (context, candidateData, rejectedData) {
          return image != null
              ? CustomPaint(
                  size: Size(100, 100),
                  painter: PuzzlePainter(image!, widget.pieceIndex),
                )
              : Container(color: Colors.grey);
        },
      ),
    );
  }
}

class PuzzlePainter extends CustomPainter {
  final ui.Image image;
  final int pieceIndex;

  PuzzlePainter(this.image, this.pieceIndex);

  @override
  void paint(Canvas canvas, Size size) {
    double pieceWidth = image.width / 3;  // Resmin 3'e bölünmesi
    double pieceHeight = image.height / 3; // Yükseklik ayarı
    int x = pieceIndex % 3;       // Parçanın yatay konumu
    int y = pieceIndex ~/ 3;      // Parçanın dikey konumu

    Rect srcRect = Rect.fromLTWH(x * pieceWidth, y * pieceHeight, pieceWidth, pieceHeight);
    Rect dstRect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawImageRect(image, srcRect, dstRect, Paint());
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
