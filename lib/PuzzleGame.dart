import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(PuzzleGame());
}

class PuzzleGame extends StatelessWidget {
  const PuzzleGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PuzzleScreen(),
    );
  }
}

class PuzzleScreen extends StatefulWidget {
  const PuzzleScreen({super.key});

  @override
  _PuzzleScreenState createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> {
  final List<String> imagePaths = [
    'assets/images/image1.jpg',
    'assets/images/image2.jpg',
    'assets/images/image3.jpg',
    'assets/images/image4.jpg',
    'assets/images/image5.jpg',
    'assets/images/image6.png',
    'assets/images/image7.jpg',
    'assets/images/image8.jpg',
    'assets/images/image9.jpg',
    'assets/images/image10.jpg',
  ];

  String selectedImage = '';
  ui.Image? image;
  bool isImageLoaded = false;
  List<int> shuffledIndices = List.generate(9, (index) => index)..shuffle();
  List<int> correctOrder = List.generate(9, (index) => index);
  int secondsElapsed = 0;
  Timer? timer;
  int? draggingIndex;

  @override
  void initState() {
    super.initState();
    selectedImage = (imagePaths..shuffle()).first;
    loadImage(selectedImage);
    startTimer();
  }

  Future<void> loadImage(String path) async {
    final ByteData data = await rootBundle.load(path);
    final Uint8List bytes = data.buffer.asUint8List();
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    setState(() {
      image = frameInfo.image;
      isImageLoaded = true;
    });
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          secondsElapsed++;
        });
      }
    });
  }

  bool isCompleted() {
    return List.generate(9, (index) => index).every((i) => shuffledIndices[i] == correctOrder[i]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 83, 149, 149),
        title: Text('Yapboz Oyunu'),
        actions: [
          Padding(
            padding: EdgeInsets.all(10),
            child: Center(child: Text('Süre: $secondsElapsed sn')),
          ),
        ],
      ),
      backgroundColor: const Color.fromARGB(141, 110, 211, 137),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: isImageLoaded
                ? Image.asset(selectedImage, width: 300, height: 300, fit: BoxFit.cover)
                : CircularProgressIndicator(),
          ),
          Expanded(
            child: isImageLoaded
                ? GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                    ),
                    itemCount: 9,
                    itemBuilder: (context, index) {
                      int imgIndex = shuffledIndices[index];
                      return Draggable<int>(
                        data: index,
                        feedback: SizedBox(
                          width: 100,
                          height: 100,
                          child: CustomPaint(
                            size: Size(100, 100),
                            painter: PuzzlePainter(image!, imgIndex),
                          ),
                        ),
                        childWhenDragging: Container(color: Colors.grey),
                        child: DragTarget<int>(
                          onAcceptWithDetails: (draggedIndex) {
                            setState(() {
                              int temp = shuffledIndices[draggedIndex.data];
                              shuffledIndices[draggedIndex.data] = shuffledIndices[index];
                              shuffledIndices[index] = temp;
                            });
                            if (isCompleted()) {
                              timer?.cancel();
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: Text('Tebrikler!'),
                                  content: Text('Yapbozu $secondsElapsed saniyede tamamladınız!'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('Tamam'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                          builder: (context, candidateData, rejectedData) {
                            return CustomPaint(
                              size: Size(100, 100),
                              painter: PuzzlePainter(image!, imgIndex),
                            );
                          },
                        ),
                      );
                    },
                  )
                : CircularProgressIndicator(),
          ),
        ],
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
    double pieceWidth = image.width / 3;
    double pieceHeight = image.height / 3;
    int x = pieceIndex % 3;
    int y = pieceIndex ~/ 3;

    Rect srcRect = Rect.fromLTWH(x * pieceWidth, y * pieceHeight, pieceWidth, pieceHeight);
    Rect dstRect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawImageRect(image, srcRect, dstRect, Paint());
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
