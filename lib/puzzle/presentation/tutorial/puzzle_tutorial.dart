import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:puzzlegame/core/theme/fun_app_theme.dart';
import 'package:puzzlegame/core/widgets/custom_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Puzzle Oyunu öğretici ekranı
///
/// Oyunun nasıl oynanacağını gösteren kapsamlı öğretici ekran
class PuzzleTutorial extends StatefulWidget {
  /// Eğitim tamamlandığında çağrılacak fonksiyon
  final VoidCallback onTutorialCompleted;

  const PuzzleTutorial({
    super.key, // Key parametresini super.key olarak düzelttim
    required this.onTutorialCompleted,
  });

  @override
  State<PuzzleTutorial> createState() => _PuzzleTutorialState();
}

class _PuzzleTutorialState extends State<PuzzleTutorial> {
  /// Aktif sayfa indeksi
  int _currentPageIndex = 0;
  
  /// Toplam sayfa sayısı
  final int _totalPages = 4;
  
  /// Sayfa kontrolcüsü
  final PageController _pageController = PageController();
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPageIndex < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onTutorialCompleted();
    }
  }

  void _previousPage() {
    if (_currentPageIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // FunAppTheme.primaryColor'dan koyu renk üretmek için
    Color darkPrimaryColor = Color.fromARGB(
      FunAppTheme.primaryColor.alpha, // .a as int yerine direkt .alpha kullanıyoruz (zaten int)
      (FunAppTheme.primaryColor.red - 40).clamp(0, 255), // .r yerine .red (zaten int)
      (FunAppTheme.primaryColor.green - 40).clamp(0, 255), // .g yerine .green (zaten int)
      (FunAppTheme.primaryColor.blue - 40).clamp(0, 255), // .b yerine .blue (zaten int)
    );
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            FunAppTheme.primaryColor,
            darkPrimaryColor,
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.extension,
                    color: Colors.white,
                    size: 36,
                  ).animate().scale(duration: const Duration(milliseconds: 600), curve: Curves.elasticOut),
                  const SizedBox(width: 12),
                  Text(
                    AppLocalizations.of(context)!.appName, // AppStrings yerine AppLocalizations kullanımı
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() {
                    _currentPageIndex = page;
                  });
                },
                children: [
                  _buildIntroductionPage(context),
                  _buildHowToPlayPage(context),
                  _buildTipsPage(context),
                  _buildDifficultyLevelsPage(context),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPageIndex > 0)
                    CustomButton(
                      text: "Geri",
                      onPressed: _previousPage,
                      icon: Icons.arrow_back,
                      type: ButtonType.outlined,
                    )
                  else
                    const SizedBox(width: 100),
                    
                  // Sayfa göstergesi
                  Row(
                    children: List.generate(_totalPages, (index) {
                      return Container(
                        width: 10,
                        height: 10,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPageIndex == index
                            ? Colors.white
                            : Colors.white.withAlpha(77),
                        ),
                      );
                    }),
                  ),
                  
                  CustomButton(
                    text: _currentPageIndex == _totalPages - 1 ? AppLocalizations.of(context)!.getStarted : "İleri",
                    onPressed: _nextPage,
                    icon: _currentPageIndex == _totalPages - 1
                        ? Icons.play_arrow
                        : Icons.arrow_forward,
                    type: ButtonType.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Giriş sayfası
  Widget _buildIntroductionPage(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),  
            child: Icon(
              Icons.extension,
              size: 120,
              color: FunAppTheme.primaryColor,
            ),
          ).animate().scale(duration: const Duration(milliseconds: 600), curve: Curves.elasticOut),
          
          const SizedBox(height: 32),
          
          Text(
            AppLocalizations.of(context)!.tutorialTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 20),
          
          Text(
            AppLocalizations.of(context)!.tutorialStep1,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 32),
          
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(
                    Icons.psychology,
                    color: Colors.amber,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Bu oyun şu becerileri geliştirir:',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 16),
                  _buildBenefitItem(
                    context,
                    Icons.visibility,
                    'Görsel algı ve dikkat'
                  ),
                  const SizedBox(height: 8),
                  _buildBenefitItem(
                    context,
                    Icons.psychology,
                    'Problem çözme becerisi'
                  ),
                  const SizedBox(height: 8),
                  _buildBenefitItem(
                    context,
                    Icons.fact_check,
                    'Mantıksal düşünme'
                  ),
                  const SizedBox(height: 8),
                  _buildBenefitItem(
                    context,
                    Icons.timelapse,
                    'Sabır ve konsantrasyon'
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Nasıl oynanır sayfası
  Widget _buildHowToPlayPage(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context)!.howToPlay,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          // Karıştırılmış Puzzle
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(
                    Icons.grid_on,
                    color: FunAppTheme.primaryColor,
                    size: 48,
                  ).animate().scale(duration: const Duration(milliseconds: 600)),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    '1. Karıştırılmış Puzzle',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'Oyun başladığında, karışık durumdaki puzzle parçalarını görürsünüz.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Karışık puzzle örneği
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(8),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 1,
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 4,
                      ),
                      itemCount: 9,
                      itemBuilder: (context, index) {
                        // Karışık puzzle simülasyonu
                        List<int> mixedNumbers = [2, 5, 3, 1, 7, 8, 4, 6, 0]; // 0 boş alan
                        int displayNumber = mixedNumbers[index];
                        bool isEmpty = displayNumber == 0;
                        
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: isEmpty ? Colors.grey.shade200 : FunAppTheme.primaryColor.withAlpha(204),
                            border: isEmpty ? Border.all(color: Colors.grey.shade300) : null,
                          ),
                          child: isEmpty
                              ? null
                              : Center(
                                  child: Text(
                                    '$displayNumber',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                        ).animate().fade(duration: const Duration(milliseconds: 300), delay: Duration(milliseconds: 50 * index));
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Parçaları Taşıma
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(
                    Icons.touch_app,
                    color: Colors.blue,
                    size: 48,
                  ).animate().scale(delay: const Duration(milliseconds: 200), duration: const Duration(milliseconds: 600)),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    '2. Parçaları Taşıma',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'Boş alanın yanındaki parçalara dokunarak onları boş alana taşıyabilirsiniz. Sadece boş alanın komşusu olan parçaları hareket ettirebilirsiniz.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Taşıma örneği
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // İlk durum
                      Container(
                        width: 120,
                        height: 120,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: GridView.count(
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 3,
                          mainAxisSpacing: 2,
                          crossAxisSpacing: 2,
                          children: [
                            _buildTileExample('1'),
                            _buildTileExample('2'),
                            _buildTileExample('3'),
                            _buildTileExample('4'),
                            _buildTileExample('5', isHighlighted: true),
                            _buildTileExample('6'),
                            _buildTileExample('7'),
                            _buildTileExample('8'),
                            _buildEmptyTile(),
                          ],
                        ),
                      ),
                      
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Icon(Icons.arrow_forward, color: Colors.blue),
                      ),
                      
                      // Taşıma sonrası
                      Container(
                        width: 120,
                        height: 120,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: GridView.count(
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 3,
                          mainAxisSpacing: 2,
                          crossAxisSpacing: 2,
                          children: [
                            _buildTileExample('1'),
                            _buildTileExample('2'),
                            _buildTileExample('3'),
                            _buildTileExample('4'),
                            _buildEmptyTile(),
                            _buildTileExample('6'),
                            _buildTileExample('7'),
                            _buildTileExample('8'),
                            _buildTileExample('5', isHighlighted: true),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Oyunun Hedefi
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 48,
                  ).animate().scale(delay: const Duration(milliseconds: 400), duration: const Duration(milliseconds: 600)),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    '3. Oyunun Hedefi',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'Tüm parçaları doğru sırayla yerleştirmeye çalışın. Parçalar sıralı şekilde dizildiğinde oyunu tamamlamış olursunuz.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Tamamlanmış puzzle örneği
                  Container(
                    width: 180,
                    height: 180,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green),
                    ),
                    child: GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      mainAxisSpacing: 2,
                      crossAxisSpacing: 2,
                      children: List.generate(9, (index) {
                        if (index == 8) return _buildEmptyTile();
                        return _buildTileExample('${index + 1}', isOrdered: true);
                      }),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.emoji_events, color: Colors.amber),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Tüm parçalar doğru yerleştiğinde oyun tamamlanır!',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.green.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // İpuçları sayfası
  Widget _buildTipsPage(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Text(
            'İpuçları ve Stratejiler',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          // İpuçları
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(
                    Icons.tips_and_updates,
                    color: Colors.amber,
                    size: 48,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildTipItem(
                    context,
                    'Köşelerden başlayın',
                    'Öncelikle köşe parçalarını doğru yerlerine yerleştirin.',
                    Icons.crop_square,
                  ),
                  
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  
                  _buildTipItem(
                    context,
                    'Üst satırı tamamlayın',
                    'Köşeleri yerleştirdikten sonra, üst satırı tamamlayarak devam edin.',
                    Icons.keyboard_arrow_up,
                  ),
                  
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  
                  _buildTipItem(
                    context,
                    'Sol sütunu tamamlayın',
                    'Üst satırı tamamladıktan sonra, sol sütunu yerleştirerek ilerleyin.',
                    Icons.keyboard_arrow_left,
                  ),
                  
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  
                  _buildTipItem(
                    context,
                    'Sabırlı olun',
                    'Bazen bir parçayı yerleştirmek için diğer parçaları geçici olarak yerinden çıkarmanız gerekebilir.',
                    Icons.timelapse,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Hamle planlama
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(
                    Icons.lightbulb,
                    color: Colors.orange,
                    size: 48,
                  ).animate().scale(duration: const Duration(milliseconds: 600), curve: Curves.elasticOut),
                  
                  const SizedBox(height: 12),
                  
                  Text(
                    'Hamle Planlama',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Text(
                    'İyi bir puzzle çözücü, hamleleri önceden planlar. Bir parçayı yerine koymadan önce, bunun için gereken hamle dizisini düşünün.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.psychology, color: Colors.orange),
                            const SizedBox(width: 8),
                            Text(
                              'İleri Düşünme',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tek bir hamle değil, bir dizi hamle düşünerek karmaşık durumları çözebilirsiniz.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Yararlı teknikler
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Yararlı Teknikler',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Teknikler listesi
                  Table(
                    border: TableBorder.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                    children: [
                      _buildTableRow(context, 'Teknik', 'Açıklama', isHeader: true),
                      _buildTableRow(context, 'Parçayı taşıma', 'Boş alan etrafındaki parçalara dokunarak taşıma'),
                      _buildTableRow(context, 'Döngü hareketi', 'Parçaları döngüsel olarak hareket ettirerek düzenleme'),
                      _buildTableRow(context, 'Geçici yer değiştirme', 'Bir parçayı geçici olarak yanlış yere koyma'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info, color: Colors.amber),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Takıldığınızda bazen bir adım geri gitmek, ileriyi görmek için yardımcı olabilir.',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13.0, // Metin boyutunu küçültüyorum
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Zorluk seviyeleri sayfası
  Widget _buildDifficultyLevelsPage(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Text(
            'Zorluk Seviyeleri',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          _buildDifficultyCard(
            context,
            'Kolay',
            '3x3 puzzle düzeni (9 parça)',
            Colors.green,
            Icons.sentiment_satisfied,
            [
              'Daha az parça ile kolay çözüm',
              'Başlangıç seviyesi için idealdir',
              'Temel stratejileri öğrenmek için mükemmel',
              'Sınırsız hamle hakkı',
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildDifficultyCard(
            context,
            'Orta',
            '4x4 puzzle düzeni (16 parça)',
            Colors.orange,
            Icons.sentiment_neutral,
            [
              'Orta zorluk seviyesi',
              'Daha fazla düşünme gerektirir',
              'Bilişsel becerileri geliştirmek için ideal',
              'İyi strateji gerektirir',
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildDifficultyCard(
            context,
            'Zor',
            '5x5 puzzle düzeni (25 parça)',
            Colors.red,
            Icons.sentiment_very_dissatisfied,
            [
              'Yüksek zorluk seviyesi',
              'Daha karmaşık çözüm stratejileri gerektirir',
              'Deneyimli oyuncular için mükemmel bir meydan okuma',
              'Yoğun düşünme ve planlama gerektirir',
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Bitirme ipucu
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(
                    Icons.emoji_events,
                    color: Colors.amber,
                    size: 32,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'Puzzle oyunu, zihinsel becerilerinizi geliştirirken eğlenmek için mükemmel bir yoldur.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: FunAppTheme.primaryColor.withAlpha(26), // withOpacity(0.1) yerine withAlpha(26)
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Puzzle çözmeye hazır mısınız?",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: FunAppTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // İpucu öğesi widgeti
  Widget _buildTipItem(BuildContext context, String title, String description, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.amber.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.amber.shade700,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Tablo satırı
  TableRow _buildTableRow(BuildContext context, String label, String value, {bool isHeader = false}) {
    return TableRow(
      decoration: BoxDecoration(
        color: isHeader ? Colors.grey.shade100 : Colors.white,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            value,
            style: TextStyle(
              fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
  
  // Zorluk seviyesi kartı
  Widget _buildDifficultyCard(
    BuildContext context, 
    String title, 
    String subtitle, 
    Color color, 
    IconData icon,
    List<String> features,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withAlpha(77), width: 2), // withOpacity(0.3) yerine withAlpha(77)
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withAlpha(51), // withOpacity(0.2) yerine withAlpha(51)
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            ...features.map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Row(
                children: [
                  Icon(Icons.check_circle, size: 18, color: color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      feature,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }
  
  // Puzzle parçasını temsilen örnek kare
  Widget _buildTileExample(String number, {bool isHighlighted = false, bool isOrdered = false}) {
    return Container(
      decoration: BoxDecoration(
        color: isHighlighted ? Colors.blue.shade400 : 
               isOrdered ? FunAppTheme.primaryColor : FunAppTheme.primaryColor.withAlpha(204), // withOpacity(0.8) yerine withAlpha(204)
        borderRadius: BorderRadius.circular(4),
        border: isHighlighted ? Border.all(color: Colors.blue, width: 2) : null,
      ),
      child: Center(
        child: Text(
          number,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
  
  // Boş puzzle parçası
  Widget _buildEmptyTile() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade300),
      ),
    );
  }
  
  // Fayda öğesi
  Widget _buildBenefitItem(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          color: FunAppTheme.primaryColor,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}