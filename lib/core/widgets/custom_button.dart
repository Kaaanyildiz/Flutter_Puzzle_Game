// lib/core/widgets/custom_button.dart
import 'package:flutter/material.dart';
import 'package:puzzlegame/core/theme/fun_app_theme.dart';

/// Buton tipleri enum
enum ButtonType {
  /// Standart birincil buton
  primary,
  
  /// Kenarlıklı buton
  outlined,
  
  /// Düz metin buton
  text
}

/// Özel buton widget'ı
class CustomButton extends StatelessWidget {
  /// Buton metni
  final String text;
  
  /// Buton tıklama olayı
  final VoidCallback onPressed;
  
  /// Buton ikonu (opsiyonel)
  final IconData? icon;
  
  /// Buton tipi
  final ButtonType type;
  
  /// Buton boyutu
  final Size? size;
  
  /// CustomButton yapıcısı
  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.type = ButtonType.primary,
    this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case ButtonType.outlined:
        return _buildOutlinedButton();
      case ButtonType.text:
        return _buildTextButton();
      case ButtonType.primary:
      default:
        return _buildElevatedButton();
    }
  }

  /// Yükseltilmiş buton oluşturan metod
  Widget _buildElevatedButton() {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: FunAppTheme.primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        minimumSize: size,
      ),
      child: _buildButtonContent(Colors.white),
    );
  }

  /// Kenarlıklı buton oluşturan metod
  Widget _buildOutlinedButton() {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: FunAppTheme.primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        side: BorderSide(color: FunAppTheme.primaryColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        minimumSize: size,
      ),
      child: _buildButtonContent(FunAppTheme.primaryColor),
    );
  }

  /// Düz metin buton oluşturan metod
  Widget _buildTextButton() {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: FunAppTheme.primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        minimumSize: size,
      ),
      child: _buildButtonContent(FunAppTheme.primaryColor),
    );
  }

  /// Buton içeriğini (ikon ve metin) oluşturan metod
  Widget _buildButtonContent(Color color) {
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(text),
        ],
      );
    } else {
      return Text(text);
    }
  }
}