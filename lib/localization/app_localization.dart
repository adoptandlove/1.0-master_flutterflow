import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show SynchronousFuture;

class AppLocalizations {
  static const LocalizationsDelegate<AppLocalizations> delegate =
      const AppLocalizationDelegate();

  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    print("App locale ${Localizations.localeOf(context)}");
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  String get appTitle => "Menhely adatok";

  // Onboarding
  String get onboarding1Title => "Szia!";

  String get onboarding1Text =>
      "Szeretnél a barátunk lenni?\nIsmerd meg az alkalmazást!";

  String get onboarding2Title => "Kedveled?";

  String get onboarding2Text =>
      "Húzd jobbra a profilt,ha kedveled!\nÍgy a kedvéléseid között\nbármikor megtalálod.";

  String get onboarding3Title => "Inkább máskor?";

  String get onboarding3Text => "Ha nem érzed a lehetséges kémiát,\nhúzz balra.";

  String get onboarding4Title => "Találkozzunk!";

  String get onboarding4Text =>
      "Kattints az állat képére\nés olvasd el a bemutatkozóját.";

  String get onboarding5Title => "Fogadd örökbe";

  String get onboarding5Text =>
      "Kattints a gombra,\nhogy belekezdj a kalandba.";

  String get onboardingFinish => "Kezdés";

  String get onboardingNext => "Következő";

  // Shelter pet
  String get callShelter => "Vedd fel a kapcsolatot a menhellyel";

  String get pushAndContact =>
      "Kattints és lépj kapcsolatba a menhely képviselőjével.\nEmlítsd meg,hogy az Adopt & Love appon találtál rájuk és kérj időpontot!\n";

  String get errorUnableToCallShelter =>
      "A telefon alkalmazást nem sikerült megnyitni. Engedélyezd a beállításokban vagy tárcsázd a számot.";

  String get errorUnableToEmailShelter =>
      "Ha nem sikerült megnyitni az e-mail appot, próbáld meg másképp";

  // Swipe pets
  String get noMorePetsToSwipe =>
      "A lista\nmég csak most bővül.\nTaláld meg a barátod!";

  String get errorLoadingPets => "Hiba a betöltésnél...";

  // Favorites list
  String get myGetPetRequests => "Kapcsolatba léptem";

  String get myFavoritePets => "Kedvelt";

  String get emptyFavoritesList =>
      "Üres \n Kezdj el keresni!";

  // Pet profile
  String get myStory => "Történetem";

  String get deletePet => "Törlés a listából";

  String get readyForDate => "Készen állsz a találkozásra?";

  // Pet remove dialog
  String get petRemoveDialogMessage =>
      "Biztos, hogy eltávolítod?";

  String get petRemove => "Eltávolítás";

  String get petRemoveDialogTitle => "Eltávolítás";

  String get petRemoveDialogCancel => "Mégsem";

  String get petRemoveDialogOk => "Igen";

  // User profile
  String get loginTitle => "Bejelentkezés";

  String get loginConditionsDescription =>
      "A belépéssel megerősíted,hogy elfogadod a(z)";

  String get fairUseRules => "Felhasználási szabályokat";

  String get logout => "Kijelentkezés";

  String get privacyPolicy => "Adatvédelmi irányelveket";

  String get and => "és";

  String get userGuide => "Használati útmutató";

  // Preferences
  String get preferences => "Mit keresel?";

  String get iAmInterested => "Mit keresel?";

  String get cats => "Cica";

  String get dogs => "Kutya";

  // General
  String get retryOnError => "Kérlek próbáld újra";
}

class AppLocalizationDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(AppLocalizationDelegate old) => false;
}
