// lib/domain/models/puzzle_piece.dart

/// Puzzle oyunundaki bir parçayı temsil eden sınıf
class PuzzlePiece {
  /// Parçanın indeksi
  final int index;
  
  /// Parçanın resim dosyası yolu
  final String imagePath;
  
  /// PuzzlePiece yapıcısı
  /// [index] Parçanın indeksi
  /// [imagePath] Parçanın resim dosyası yolu
  const PuzzlePiece({
    required this.index, 
    required this.imagePath
  });
}