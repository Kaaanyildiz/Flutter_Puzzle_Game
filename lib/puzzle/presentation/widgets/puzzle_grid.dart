import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart' show rootBundle;

/// Puzzle oyunu için parça widget'ı
class PuzzleTile extends StatefulWidget {
  /// Resim yolu
  final String imagePath;
  /// Parçanın grid içindeki indeksi
  final int index;
  /// Parçanın resimdeki orijinal indeksi
  final int pieceIndex;
  /// Parça yer değiştirme callback fonksiyonu
  final Function(int, int) onPieceMoved;

  const PuzzleTile({
    Key? key,
    required this.imagePath,
    required this.index,
    required this.pieceIndex,
    required this.onPieceMoved,
  }) : super(key: key);

  @override
  State<PuzzleTile> createState() => _PuzzleTileState();
}

class _PuzzleTileState extends State<PuzzleTile> with SingleTickerProviderStateMixin {
  ui.Image? image;  // ui.Image nesnesi, resmi tutacak
  bool isHovered = false; // Hover durumu
  late AnimationController _animationController;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    loadImage(widget.imagePath);  // Resmi yükle

    // Animasyon kontrolcüsü
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Elevation animasyonu
    _elevationAnimation = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Resmi yükleyen metod
  Future<void> loadImage(String path) async {
    final ByteData data = await rootBundle.load(path);
    final Uint8List bytes = data.buffer.asUint8List();
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    if (mounted) {
      setState(() {
        image = frameInfo.image;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => isHovered = true);
        _animationController.forward();
      },
      onExit: (_) {
        setState(() => isHovered = false);
        _animationController.reverse();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutQuint,
        transform: Matrix4.identity()
          ..translate(isHovered ? 0.0 : 0.0, isHovered ? -5.0 : 0.0, 0.0)
          ..scale(isHovered ? 1.05 : 1.0),
        child: Draggable<int>(
          data: widget.index,
          feedback: Material(
            elevation: 12,
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 100,
              height: 100,
              child: image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CustomPaint(
                        size: const Size(100, 100),
                        painter: PuzzlePainter(image!, widget.pieceIndex, 3, isHovered: true),
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
            ),
          ),
          childWhenDragging: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: 0.3,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withAlpha(128), width: 2), // withOpacity(0.5) -> withAlpha(128)
              ),
            ),
          ),
          child: DragTarget<int>(

            onAcceptWithDetails: (draggedIndex) {
              widget.onPieceMoved(draggedIndex.data, widget.index);
            },
            builder: (context, candidateData, rejectedData) {
              return AnimatedBuilder(
                animation: _elevationAnimation,
                builder: (context, child) {
                  return Material(
                    elevation: _elevationAnimation.value,
                    shadowColor: Colors.black45,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: candidateData.isNotEmpty
                              ? Colors.blue.withAlpha(179) // withOpacity(0.7) -> withAlpha(179)
                              : Colors.white.withAlpha(128), // withOpacity(0.5) -> withAlpha(128)
                          width: candidateData.isNotEmpty ? 3 : 2,
                        ),
                      ),
                      child: image != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Hero(
                                tag: 'puzzle_piece_${widget.pieceIndex}',
                                child: CustomPaint(
                                  size: const Size(100, 100),
                                  painter: PuzzlePainter(
                                    image!, 
                                    widget.pieceIndex, 
                                    3, 
                                    isHovered: isHovered || candidateData.isNotEmpty,
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class PuzzlePainter extends CustomPainter {
  /// Puzzle resmi
  final ui.Image image;
  /// Parçanın orijinal indeksi
  final int index;
  /// Grid boyutu (3x3, 4x4 vb.)
  final int gridSize;
  /// Hover durumu
  final bool isHovered;
  /// Kenar çizilsin mi
  final bool drawBorder;

  /// PuzzlePainter yapıcısı
  /// [image] Gösterilecek resim
  /// [index] Parçanın orijinal resimdeki indeksi
  /// [gridSize] Puzzle grid boyutu
  /// [isHovered] Parçanın hover durumu
  const PuzzlePainter(this.image, this.index, this.gridSize, {this.isHovered = false, this.drawBorder = true});

  @override
  void paint(Canvas canvas, Size size) {
    if (image == null) return;

    final imageWidth = image!.width;
    final imageHeight = image!.height;
    
    final pieceWidth = imageWidth / gridSize;
    final pieceHeight = imageHeight / gridSize;
    
    final row = index ~/ gridSize;
    final col = index % gridSize;
    
    final srcRect = Rect.fromLTWH(
      col * pieceWidth, 
      row * pieceHeight, 
      pieceWidth, 
      pieceHeight
    );
    
    final dstRect = Rect.fromLTWH(0, 0, size.width, size.height);
    
    final paint = Paint();
    if (isHovered) {
      paint.colorFilter = ColorFilter.mode(
        Colors.blue.withAlpha(77), // 0.3 -> 77
        BlendMode.srcATop
      );
    }
    
    canvas.drawImageRect(image!, srcRect, dstRect, paint);
    
    if (drawBorder) {
      final borderPaint = Paint()
        ..color = Colors.white.withAlpha(89) // 0.35 -> 89
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5;
      
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        borderPaint
      );
    }
  }

  @override
  bool shouldRepaint(covariant PuzzlePainter oldDelegate) {
    return oldDelegate.isHovered != isHovered || oldDelegate.image != image;
  }
}