import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:math';
import 'package:palette_generator/palette_generator.dart';
import 'package:confetti/confetti.dart';
import 'package:puzzlegame/core/theme/fun_app_theme.dart';
import 'package:puzzlegame/puzzle/presentation/widgets/puzzle_grid.dart';
import 'package:puzzlegame/core/constants/app_strings.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Puzzle oyun ekranı widget'ı
class PuzzleScreen extends StatefulWidget {
  /// Zorluk seviyesine göre grid boyutu
  final int gridSize;

  const PuzzleScreen({super.key, this.gridSize = 3});

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> with TickerProviderStateMixin {
  // Puzzle resimleri için 15 adet resim yolu (9 mevcut + 6 yeni)
  final List<String> imagePaths = [
    "assets/images/piece1.jpg",
    "assets/images/piece2.jpg",
    "assets/images/piece3.jpg",
    "assets/images/piece4.jpg",
    "assets/images/piece5.jpg",
    "assets/images/piece6.jpg",
    "assets/images/piece7.jpg",
    "assets/images/piece8.jpg",
    "assets/images/piece9.jpg",
    "assets/images/piece10.jpg",
    "assets/images/piece11.jpg",
    "assets/images/piece12.jpg",
    "assets/images/piece13.jpg",
    "assets/images/piece14.jpg",
    "assets/images/piece15.jpg",
  ];

  // Hangi resmin kaç kez kullanıldığını takip etmek için map
  final Map<String, int> _imageUsageCount = {};
  
  // Son kullanılan 3 resmi takip etmek için liste
  final List<String> _recentlyUsedImages = [];

  String selectedImage = '';
  ui.Image? image;
  bool isImageLoaded = false;
  late final List<int> shuffledIndices;
  late final List<int> correctOrder;
  late final int totalPieces;
  int secondsElapsed = 0;
  Timer? timer;
  int? draggingIndex;
  Color? dominantColor;
  
  // Animasyon kontrolcüleri
  late AnimationController _backgroundController;
  late Animation<double> _backgroundAnimation;
  
  // Konfeti kontrolcüsünü sınıf değişkeni olarak tutmak yerine, 
  // her ihtiyaç duyduğumuzda yeni bir tane oluşturacağız
  ConfettiController? _confettiController;
  
  // Parça hareketlerini takip değişkenleri
  int moveCount = 0;
  List<int> recentlySwapped = [];
  
  // Konfeti widget'ını tutacak değişken
  Widget _confettiWidget = const SizedBox.shrink();

  /// Seçilen resmin ana rengini tespit eden metod
  Future<void> extractDominantColor(String imagePath) async {
    final paletteGenerator = await PaletteGenerator.fromImageProvider(
      AssetImage(imagePath),
    );
    setState(() {
      dominantColor = paletteGenerator.dominantColor?.color ?? Colors.white;
    });
  }

  @override
  void initState() {
    super.initState();
    totalPieces = widget.gridSize * widget.gridSize;
    shuffledIndices = List.generate(totalPieces, (index) => index)..shuffle();
    correctOrder = List.generate(totalPieces, (index) => index);
    
    // Başlangıçta resim kullanım sayaçlarını sıfırla
    for (final path in imagePaths) {
      _imageUsageCount[path] = 0;
    }
    
    // İlk resmi seç ve kullanım sayısını artır
    selectedImage = _selectNewImage();
    loadImage(selectedImage);
    extractDominantColor(selectedImage);
    
    // Arkaplan animasyonu ayarları
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);
    
    _backgroundAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(
        parent: _backgroundController,
        curve: Curves.easeInOut,
      ),
    );
    
    startTimer();
  }
  
  @override
  void dispose() {
    _backgroundController.dispose();
    timer?.cancel();
    super.dispose();
  }

  /// Resmi yükleyen metod
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

  /// Oyun süresini başlatan metod
  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          secondsElapsed++;
        });
      }
    });
  }

  /// Puzzle'ın tamamlanıp tamamlanmadığını kontrol eden metod
  bool isCompleted() {
    return List.generate(totalPieces, (index) => index).every((i) => shuffledIndices[i] == correctOrder[i]);
  }
  
  /// Parçaları değiştiren metod
  void swapPieces(int index1, int index2) {
    setState(() {
      int temp = shuffledIndices[index1];
      shuffledIndices[index1] = shuffledIndices[index2];
      shuffledIndices[index2] = temp;
      moveCount++;
      
      // Son taşınan parçaları takip et (vurgu efekti için)
      recentlySwapped = [index1, index2];
      
      // Kısa bir süre sonra vurgu efektini kaldır
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            recentlySwapped = [];
          });
        }
      });
    });
    
    // Tamamlandı mı kontrol et
    if (isCompleted()) {
      timer?.cancel();
      _startNewConfetti();
      showCompletionDialog();
    }
  }
  
  /// Oyun tamamlandığında gösterilen dialog
  void showCompletionDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      transitionDuration: const Duration(milliseconds: 500),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.elasticOut,
            reverseCurve: Curves.easeOutCubic,
          ),
          child: child,
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white.withAlpha(230),  // withOpacity yerine withAlpha kullanımı
        elevation: 20,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8, // Dialog genişliği
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                dominantColor?.withAlpha(179) ?? Colors.blue.shade200,  // withOpacity(0.7) yerine withAlpha(179)
                Colors.white,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.congratulations,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                AppLocalizations.of(context)!.completedIn(secondsElapsed.toString() + " sn"),
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStatItem(Icons.timer, '$secondsElapsed ${AppLocalizations.of(context)!.timeElapsed("").split(":")[0].toLowerCase()}'),
                  const SizedBox(width: 20),
                  _buildStatItem(Icons.swap_horiz, '$moveCount ${AppLocalizations.of(context)!.moves(moveCount).split(":")[0].toLowerCase()}'),
                ],
              ),
              const SizedBox(height: 20),
              // Butonları alt alta düzenliyoruz
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: dominantColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50), // Buton yüksekliği
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () {
                  // Dialog'u kapat
                  Navigator.pop(context);
                  
                  // Yeni oyun başlat
                  _restartWithNewImage();
                },
                icon: const Icon(Icons.refresh),
                label: Text(
                  AppLocalizations.of(context)!.restart,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 10), // Butonlar arasında boşluk
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50), // Buton yüksekliği
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () {
                  // Önce dialog'u, sonra oyun ekranını kapat (ana menüye dön)
                  Navigator.pop(context); // Dialog'u kapat
                  Navigator.pop(context); // Oyun ekranını kapat (ana menüye dön)
                },
                icon: const Icon(Icons.home),
                label: Text(
                  AppLocalizations.of(context)!.mainMenu,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Yeni bir konfeti efekti başlat
  void _startNewConfetti() {
    // Eğer varsa eskisini temizle
    _confettiController?.dispose();
    
    // Yeni bir kontrolcü oluştur
    _confettiController = ConfettiController(duration: const Duration(seconds: 5));
    
    // Yeni konfeti widget'ını oluştur
    setState(() {
      _confettiWidget = ConfettiWidget(
        confettiController: _confettiController!,
        blastDirectionality: BlastDirectionality.explosive,
        particleDrag: 0.05,
        emissionFrequency: 0.05,
        numberOfParticles: 20,
        gravity: 0.1,
        shouldLoop: false,
        colors: [
          Colors.red,
          Colors.blue,
          Colors.green,
          Colors.yellow,
          Colors.orange,
          Colors.purple,
          dominantColor ?? Colors.pink,
        ],
      );
    });
    
    // Konfeti efektini başlat
    _confettiController!.play();
  }
  
  /// Oyun tamamlandığında yeni bir resimle yeniden başlatma
  void _restartWithNewImage() {
    // Süreyi sıfırla
    secondsElapsed = 0;
    
    // Akıllı resim seçim algoritmasını kullan
    String newImage = _selectNewImage();
    
    setState(() {
      // Yeni resmi ayarla
      selectedImage = newImage;
      isImageLoaded = false;
      
      // Yeni parça düzenini oluştur
      shuffledIndices.clear();
      shuffledIndices.addAll(List.generate(totalPieces, (index) => index)..shuffle());
      
      // Hareket sayısını sıfırla
      moveCount = 0;
      recentlySwapped = [];
    });
    
    // Yeni resmi yükle
    loadImage(selectedImage);
    extractDominantColor(selectedImage);
    
    // Timer'ı yeniden başlat
    timer?.cancel();
    startTimer();
  }
  
  /// İstatistik öğesini oluşturan yardımcı metod
  Widget _buildStatItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.black54),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ekran boyutlarını al
    final screenSize = MediaQuery.of(context).size;
    final referenceImageSize = screenSize.width > 600 
        ? 340.0  // Büyük ekranlarda boyutu 300'den 340'a çıkarıyorum
        : screenSize.width * 0.7;  // Küçük ekranlarda %60 yerine %70 kullanıyorum
    
    return Scaffold(
      // Geri butonunu ekleyen AppBar ekledim
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(153),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back,
              color: Colors.black87,
            ),
          ),
          onPressed: () {
            // Ana menüye dön
            Navigator.pop(context);
          },
        ),
      ),
      extendBodyBehindAppBar: true, // AppBar'ı arkaplan üzerine yerleştir
      body: Stack(
        children: [
          // Arkaplan
          AnimatedBuilder(
            animation: _backgroundAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      dominantColor?.withAlpha(204) ?? FunAppTheme.primaryColor.withAlpha(204), // withOpacity(0.8) yerine withAlpha(204)
                      Colors.white,
                    ],
                    begin: Alignment(_backgroundAnimation.value / 20, 0),
                    end: Alignment.bottomRight,
                  ),
                ),
              );
            },
          ),
          
          // Konfeti efekti
          Align(
            alignment: Alignment.topCenter,
            child: _confettiWidget,
          ),
          
          SafeArea(
            bottom: true, // Tüm kenarları safe area içinde tut
            child: Column(
              children: [
                // Üst bilgi paneli
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${AppLocalizations.of(context)!.appName} ${widget.gridSize}x${widget.gridSize}',
                        style: const TextStyle(
                          fontSize: 24, 
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black45,
                              offset: Offset(1, 1),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.access_time, color: Colors.white70, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '$secondsElapsed sn',
                            style: const TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                          const SizedBox(width: 12),
                          const Icon(Icons.swap_horiz, color: Colors.white70, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '$moveCount',
                            style: const TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Referans resim - Ekran boyutuna göre dinamik
                Container(
                  width: referenceImageSize,
                  height: referenceImageSize,
                  margin: EdgeInsets.symmetric(
                    vertical: screenSize.height < 700 ? 5.0 : 15.0, // Küçük ekranlarda margin'i azalt
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black38,
                        blurRadius: 15,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: Colors.white.withAlpha(128),  // withOpacity(0.5) yerine withAlpha(128)
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: isImageLoaded
                          ? Image.asset(
                              selectedImage,
                              fit: BoxFit.cover,
                            )
                          : const Center(child: CircularProgressIndicator()),
                    ),
                  ),
                ),
                
                // Ana oyun alanı
                Expanded(
                  child: Center(
                    child: isImageLoaded
                        ? LayoutBuilder(
                            builder: (context, constraints) {
                              // Kullanılabilir alan boyutlarına göre grid boyutunu hesapla
                              final gridSize = min(
                                constraints.maxWidth - 32, 
                                constraints.maxHeight - 16
                              );
                              
                              return Container(
                                width: gridSize,
                                height: gridSize,
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(51),  // withOpacity(0.2) yerine withAlpha(51)
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: GridView.builder(
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: widget.gridSize,
                                    childAspectRatio: 1,
                                    crossAxisSpacing: 0,
                                    mainAxisSpacing: 0,
                                  ),
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: totalPieces,
                                  itemBuilder: (context, index) {
                                    int imgIndex = shuffledIndices[index];
                                    bool isRecentlySwapped = recentlySwapped.contains(index);
                                    
                                    return Draggable<int>(
                                      data: index,
                                      feedback: _buildPieceFeedback(imgIndex, gridSize / widget.gridSize),
                                      childWhenDragging: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade300,
                                          borderRadius: BorderRadius.circular(2),
                                          border: Border.all(
                                            color: Colors.white.withAlpha(77),  // withOpacity(0.3) yerine withAlpha(77)
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                      child: DragTarget<int>(
                                        onAcceptWithDetails: (draggedIndex) {
                                          swapPieces(draggedIndex.data, index);
                                        },
                                        builder: (context, candidateData, rejectedData) {
                                          return AnimatedContainer(
                                            duration: const Duration(milliseconds: 300),
                                            margin: EdgeInsets.zero,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(2),
                                              border: Border.all(
                                                color: isRecentlySwapped
                                                    ? Colors.yellow
                                                    : candidateData.isNotEmpty
                                                        ? Colors.blue.withAlpha(204)  // withOpacity(0.8) yerine withAlpha(204)
                                                        : Colors.transparent,
                                                width: isRecentlySwapped ? 2 : 1,
                                              ),
                                              boxShadow: isRecentlySwapped
                                                  ? [
                                                      BoxShadow(
                                                        color: Colors.yellow.withAlpha(153),  // withOpacity(0.6) yerine withAlpha(153)
                                                        blurRadius: 8,
                                                        spreadRadius: 2,
                                                      )
                                                    ]
                                                  : null,
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(2),
                                              child: CustomPaint(
                                                size: Size(
                                                  gridSize / widget.gridSize,
                                                  gridSize / widget.gridSize,
                                                ),
                                                painter: PuzzlePainter(
                                                  image!, 
                                                  imgIndex, 
                                                  widget.gridSize,
                                                  isHovered: candidateData.isNotEmpty || isRecentlySwapped,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          )
                        : const CircularProgressIndicator(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// Sürükleme sırasında gösterilen puzzle parçası
  Widget _buildPieceFeedback(int imgIndex, double size) {
    return Material(
      elevation: 6,
      shadowColor: Colors.black.withAlpha(51),
      borderRadius: BorderRadius.circular(1), 
      child: Container(
        width: size - 2,
        height: size - 2,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(1),
          border: Border.all(color: Colors.white.withAlpha(179), width: 0.5), // withOpacity(0.7) yerine withAlpha(179)
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(0.5),
          child: CustomPaint(
            size: Size(
              size - 2,
              size - 2,
            ),
            painter: PuzzlePainter(image!, imgIndex, widget.gridSize, isHovered: true),
          ),
        ),
      ),
    );
  }
  
  /// Akıllı resim seçim algoritması
  /// Tüm resimlerin dengeli bir şekilde kullanılmasını sağlar
  String _selectNewImage() {
    // Loglama için resim kullanım sayılarını yazdırabiliriz (debug için)
    // print("Resim kullanım sayıları: $_imageUsageCount");
    // print("Son kullanılan resimler: $_recentlyUsedImages");
    
    // Tüm resimler en az bir kez kullanılmışsa ve kullanım sayıları maksimuma ulaşmışsa, sayaçları sıfırla
    bool allMaxUsage = true;
    int maxAllowedUse = (imagePaths.length / 3).ceil(); // Her resmin ortalama kullanım üst sınırı
    
    for (final path in imagePaths) {
      if ((_imageUsageCount[path] ?? 0) < maxAllowedUse) {
        allMaxUsage = false;
        break;
      }
    }
    
    if (allMaxUsage) {
      // Tüm resimlerin kullanım sayılarını sıfırla
      for (final path in imagePaths) {
        _imageUsageCount[path] = 0;
      }
      // Sadece son seçilen resmi tut, diğerlerini temizle
      if (_recentlyUsedImages.isNotEmpty) {
        final lastUsed = _recentlyUsedImages.first;
        _recentlyUsedImages.clear();
        _recentlyUsedImages.add(lastUsed);
      }
    }
    
    // Henç hiç kullanılmamış resim var mı kontrol et ve tercih et
    final unusedImages = imagePaths.where((path) => _imageUsageCount[path] == 0).toList();
    if (unusedImages.isNotEmpty) {
      // Kullanılmamış resimlerden rastgele seç
      final selectedImage = unusedImages[Random().nextInt(unusedImages.length)];
      _imageUsageCount[selectedImage] = 1;
      
      // Son kullanılan resimlere ekle
      _recentlyUsedImages.insert(0, selectedImage);
      if (_recentlyUsedImages.length > 3) {
        _recentlyUsedImages.removeLast();
      }
      
      return selectedImage;
    }
    
    // Son 3 oyunda kullanılmayan resimleri tercih et
    final availableImages = List<String>.from(imagePaths)
      ..removeWhere((image) => _recentlyUsedImages.contains(image));
    
    if (availableImages.isNotEmpty) {
      // Kullanılabilir resimler arasından en az kullanılanları bul
      availableImages.sort((a, b) => (_imageUsageCount[a] ?? 0).compareTo(_imageUsageCount[b] ?? 0));
      
      // En düşük kullanım sayısı nedir?
      final minUsageCount = _imageUsageCount[availableImages.first];
      
      // En az kullanılan resimleri bul
      final leastUsedImages = availableImages
          .where((img) => _imageUsageCount[img] == minUsageCount)
          .toList();
      
      // Bu resimler arasından rastgele seç
      final selectedImage = leastUsedImages[Random().nextInt(leastUsedImages.length)];
      
      // Kullanım sayısını artır
      _imageUsageCount[selectedImage] = (_imageUsageCount[selectedImage] ?? 0) + 1;
      
      // Son kullanılan resimlere ekle
      _recentlyUsedImages.insert(0, selectedImage);
      if (_recentlyUsedImages.length > 3) {
        _recentlyUsedImages.removeLast();
      }
      
      return selectedImage;
    }
    
    // Eğer tüm resimler son 3'te kullanıldıysa, en az kullanılanı seç
    final allImages = List<String>.from(imagePaths);
    allImages.sort((a, b) => (_imageUsageCount[a] ?? 0).compareTo(_imageUsageCount[b] ?? 0));
    
    // En az kullanılan resimlerden bir liste oluştur
    final minUsageCount = _imageUsageCount[allImages.first] ?? 0;
    final leastUsedOverall = allImages
        .where((img) => _imageUsageCount[img] == minUsageCount)
        .toList();
    
    // Bu resimler arasından rastgele seç
    final selectedImage = leastUsedOverall[Random().nextInt(leastUsedOverall.length)];
    
    // Kullanım sayısını artır
    _imageUsageCount[selectedImage] = (_imageUsageCount[selectedImage] ?? 0) + 1;
    
    // Son kullanılan resimlere ekle (en eski olanı çıkar)
    _recentlyUsedImages.insert(0, selectedImage);
    if (_recentlyUsedImages.length > 3) {
      _recentlyUsedImages.removeLast();
    }
    
    return selectedImage;
  }
}