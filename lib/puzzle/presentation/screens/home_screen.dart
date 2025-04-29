import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:puzzlegame/core/providers/language_provider.dart';
import 'package:puzzlegame/core/theme/fun_app_theme.dart';
import 'package:puzzlegame/core/widgets/custom_button.dart';
import 'package:puzzlegame/puzzle/presentation/screens/puzzle_screen.dart';
import 'package:puzzlegame/puzzle/presentation/tutorial/puzzle_tutorial.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Puzzle Oyunu başlangıç ekranı
/// 
/// Kullanıcının oyunu başlatmasını, zorluk seviyesini seçmesini ve tutorial'ı görüntülemeyi sağlar.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  // Seçilen zorluk seviyesi
  int _selectedDifficulty = 3; // 3x3 grid (kolay)
  
  // Başlık animasyonu için controller
  late AnimationController _titleController;
  
  // Arka plan animasyonu için
  double _backgroundAnimValue = 0;

  // Tutorial ekranını görüntülemek için
  bool _showTutorial = false;
  
  @override
  void initState() {
    super.initState();
    
    // Başlık animasyonu için controller
    _titleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    // Sürekli artan değer için timer
    Future.delayed(Duration.zero, () {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _startBackgroundAnimation();
      });
    });
  }
  
  void _startBackgroundAnimation() {
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) {
        setState(() {
          _backgroundAnimValue += 0.01;
          if (_backgroundAnimValue > 2 * pi) {
            _backgroundAnimValue = 0;
          }
        });
        _startBackgroundAnimation();
      }
    });
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Çevirileri alalım
    final localizations = AppLocalizations.of(context)!;

    // Tutorial ekranını gösterme kontrolü
    if (_showTutorial) {
      return PuzzleTutorial(
        onTutorialCompleted: () {
          setState(() {
            _showTutorial = false;
          });
        },
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Animasyonlu arka plan
          _buildAnimatedBackground(),
          
          // Ana içerik
          SafeArea(
            child: Column(
              children: [
                // Dil değiştirme butonu için üst kısıma bir Row ekleyelim
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, right: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildLanguageButton(),
                    ],
                  ),
                ),
                
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildAppTitle(),
                          const SizedBox(height: 40),
                          _buildDifficultySelector(),
                          const SizedBox(height: 60),
                          _buildActionButtons(),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Footer bilgisi
                _buildFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Dil değiştirme butonu
  Widget _buildLanguageButton() {
    final languageProvider = Provider.of<LanguageProvider>(context);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () {
            // Alternatif dile geç
            languageProvider.changeLocale(languageProvider.alternativeLanguageCode);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  languageProvider.flagEmoji,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  languageProvider.getAlternativeLanguageName(context),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().scale(
      delay: const Duration(milliseconds: 300),
      duration: const Duration(milliseconds: 500),
      curve: Curves.elasticOut,
    );
  }

  // Animasyonlu arka plan
  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _titleController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(
                cos(_backgroundAnimValue) * 0.2, 
                sin(_backgroundAnimValue) * 0.2
              ),
              end: Alignment(
                cos(_backgroundAnimValue + pi) * 0.2, 
                sin(_backgroundAnimValue + pi) * 0.2
              ),
              colors: [
                FunAppTheme.primaryColor,
                FunAppTheme.primaryColor.withAlpha(160),
                Colors.blue.shade300,
                FunAppTheme.primaryColor.withAlpha(200),
              ],
              stops: const [0.0, 0.3, 0.7, 1.0],
            ),
          ),
          child: CustomPaint(
            size: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
            painter: BubblesPainter(animation: _backgroundAnimValue),
          ),
        );
      },
    );
  }

  // Uygulama başlığı
  Widget _buildAppTitle() {
    final localizations = AppLocalizations.of(context)!;
    
    return Column(
      children: [
        // İkon Animasyonu
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(50),
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(40),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            Icons.extension,
            color: Colors.white,
            size: 80,
          ).animate(
            onPlay: (controller) => controller.repeat(), // Animasyonu tekrarlamak için onPlay callback'i kullanıyoruz
          )
            .scale(duration: const Duration(milliseconds: 800), curve: Curves.elasticOut)
            .then()
            .rotate(duration: const Duration(milliseconds: 500), begin: 0.05, end: -0.05, curve: Curves.easeInOut)
            .then()
            .rotate(duration: const Duration(milliseconds: 500), begin: -0.05, end: 0.05, curve: Curves.easeInOut),
        ),
        
        const SizedBox(height: 30),
        
        // Oyun İsmi Animasyonu
        Text(
          "Puzzle Craft", // Doğrudan "Puzzle Craft" kullanarak localizations.appName yerine
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
        ).animate(
          onPlay: (controller) => controller.repeat(), // Sürekli tekrar et
        )
          .fadeIn(duration: const Duration(milliseconds: 600))
          .then()
          .slideY(begin: 0.1, end: -0.1, duration: const Duration(seconds: 2), curve: Curves.easeInOut)
          .then()
          .slideY(begin: -0.1, end: 0.1, duration: const Duration(seconds: 2), curve: Curves.easeInOut)
          ,
        
        const SizedBox(height: 10),
        
        // Altyazı Animasyonu
        Text(
          localizations.subtitle,
          style: TextStyle(
            fontSize: 18,
            color: Colors.white.withAlpha(220),
            fontWeight: FontWeight.w500,
          ),
        ).animate()
          .fadeIn(delay: const Duration(milliseconds: 300), duration: const Duration(milliseconds: 800))
          .slideY(begin: 0.5, end: 0, duration: const Duration(milliseconds: 500), curve: Curves.easeOut),
      ],
    );
  }

  // Zorluk seviyesi seçici
  Widget _buildDifficultySelector() {
    final localizations = AppLocalizations.of(context)!;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(30),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            localizations.difficultyLevel,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDifficultyOption(
                3, 
                localizations.easyLevel, 
                Icons.sentiment_satisfied, 
                Colors.green,
                "3x3"
              ),
              const SizedBox(width: 12),
              _buildDifficultyOption(
                4, 
                localizations.mediumLevel, 
                Icons.sentiment_neutral, 
                Colors.orange,
                "4x4"
              ),
              const SizedBox(width: 12),
              _buildDifficultyOption(
                5, 
                localizations.hardLevel, 
                Icons.sentiment_very_dissatisfied, 
                Colors.red,
                "5x5"
              ),
            ],
          ),
        ],
      ),
    ).animate().scale(
      delay: const Duration(milliseconds: 400),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
    );
  }

  // Zorluk seviyesi seçim butonu
  Widget _buildDifficultyOption(int difficulty, String label, IconData icon, Color color, String gridText) {
    final isSelected = _selectedDifficulty == difficulty;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDifficulty = difficulty;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white.withAlpha(100),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: color.withAlpha(100),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ] : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withAlpha(100) : color.withAlpha(50),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                gridText,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Aksiyon butonları
  Widget _buildActionButtons() {
    final localizations = AppLocalizations.of(context)!;
    
    return Column(
      children: [
        // Oyna Butonu
        SizedBox(
          width: 200,
          height: 60,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => PuzzleScreen(gridSize: _selectedDifficulty),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOutQuart;

                    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                    var offsetAnimation = animation.drive(tween);

                    return SlideTransition(position: offsetAnimation, child: child);
                  },
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 8,
              shadowColor: Colors.black.withAlpha(100),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.play_arrow, size: 28),
                const SizedBox(width: 8),
                Text(
                  localizations.startButton.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ).animate().scale(
          delay: const Duration(milliseconds: 600),
          duration: const Duration(milliseconds: 600),
          curve: Curves.elasticOut,
        ),
        
        const SizedBox(height: 20),
        
        // Tutorial Butonu
        TextButton.icon(
          onPressed: () {
            setState(() {
              _showTutorial = true;
            });
          },
          icon: const Icon(Icons.school, color: Colors.white),
          label: Text(
            localizations.howToPlay,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ).animate().fadeIn(
          delay: const Duration(milliseconds: 800),
          duration: const Duration(milliseconds: 600),
        ),
      ],
    );
  }

  // Footer bilgisi
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        '© Puzzle Craft 2025',
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 12,
        ),
      ),
    );
  }
}

class BubblesPainter extends CustomPainter {
  final double animation;
  
  BubblesPainter({required this.animation});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(40)
      ..style = PaintingStyle.fill;
    
    // Rastgele pozisyonlarda kabarcıklar çiz
    final rnd = Random(42); // Sabit seed ile rastgele değerler üret
    
    for (int i = 0; i < 25; i++) {
      final x = rnd.nextDouble() * size.width;
      final y = rnd.nextDouble() * size.height;
      final radius = rnd.nextDouble() * 30 + 10;
      
      // Kabarcık hareketi için offset
      final offsetX = sin(animation + i * 0.4) * 15;
      final offsetY = cos(animation + i * 0.4) * 15;
      
      // Renk ve opaklık değişimi
      final opacity = (sin(animation * 0.5 + i) * 0.3 + 0.2).clamp(0.1, 0.5);
      paint.color = Colors.white.withOpacity(opacity);
      
      canvas.drawCircle(
        Offset(x + offsetX, y + offsetY),
        radius,
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Her frame'de yeniden çiz
  }
}