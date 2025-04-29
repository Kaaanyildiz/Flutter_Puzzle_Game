import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('tr');

  Locale get locale => _locale;
  
  // Ana kodda kullanılan getter
  Locale get currentLocale => _locale;

  String get languageCode => _locale.languageCode;
  
  // Alternatif dil kodu (değiştirmek için)
  String get alternativeLanguageCode => _locale.languageCode == 'tr' ? 'en' : 'tr';
  
  // Dil için bayrak emojisi
  String get flagEmoji => _locale.languageCode == 'tr' ? '🇬🇧' : '🇹🇷';
  
  // Alternatif dilin adını al
  String getAlternativeLanguageName(BuildContext context) {
    return _locale.languageCode == 'tr' ? 'English' : 'Türkçe';
  }

  void changeLocale(String languageCode) {
    if (languageCode == 'tr') {
      _locale = const Locale('tr');
    } else if (languageCode == 'en') {
      _locale = const Locale('en');
    }
    notifyListeners();
  }
}