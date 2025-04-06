import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart' show rootBundle;
import 'package:puzzlegame/features/puzzle/presentation/widgets/puzzle_grid.dart';

class PuzzleScreen extends StatefulWidget {
  const PuzzleScreen({super.key});

  @override
  _PuzzleScreenState createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> {
  final List<String> imagePaths = [
    'assets/images/piece1.jpg',
    'assets/images/piece2.jpg',
    'assets/images/piece3.jpg',
    'assets/images/piece4.jpg',
    'assets/images/piece5.jpg',
    'assets/images/piece6.jpg',
    'assets/images/piece7.jpg',
    'assets/images/piece8.jpg',
    'assets/images/piece9.jpg',
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

  // Parçalar yer değiştirince çağrılacak fonksiyon
  void onPieceMoved(int draggedIndex, int targetIndex) {
    setState(() {
      // Parça yer değiştiriyor
      int temp = shuffledIndices[draggedIndex];
      shuffledIndices[draggedIndex] = shuffledIndices[targetIndex];
      shuffledIndices[targetIndex] = temp;
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
                      return PuzzleTile(
                        imagePath: selectedImage,
                        index: index,
                        pieceIndex: imgIndex,
                        onPieceMoved: onPieceMoved, // Yer değiştirme işlemi
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
