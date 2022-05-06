import 'package:flutter/material.dart';
import 'package:flutterfire_ui/i10n.dart';
import 'package:adoptandlove/analytics/analytics.dart';
import 'package:adoptandlove/localization/app_localization.dart';
import 'package:adoptandlove/localization/firebase_localization.dart';
import 'package:adoptandlove/repositories/pets_db_repository.dart';
import 'package:adoptandlove/routes.dart';
import 'package:adoptandlove/preferences/app_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AppComponent extends StatefulWidget {
  @override
  _AppComponentState createState() => _AppComponentState();
}

class _AppComponentState extends State<AppComponent> {
  @override
  Future deactivate() async {
    await PetsDBRepository().dispose();
    await AppPreferences().dispose();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (BuildContext context) =>
          AppLocalizations.of(context).appTitle,
      initialRoute: Routes.ROUTE_HOME,
      onGenerateRoute: Routes.onGenerateRoute,
      navigatorObservers: [Analytics.firebaseObserver],
      theme: ThemeData(
        primaryColor: Colors.lightBlue.shade200,
        primaryColorDark: Colors.lightBlue[200],
        accentColor: Colors.white,
        textTheme: TextTheme(
          bodyText2: TextStyle(
            fontSize: 14.0,
            color: Color.fromARGB(0xFF, 0x66, 0x66, 0x66),
          ),
        ),
      ),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        FlutterFireUILocalizations.withDefaultOverrides(
            FirebaseLabelOverrides()),
        AppLocalizations.delegate
      ],
      supportedLocales: [
        const Locale('hu', 'HU'),
        const Locale('en', 'US'),
      ],
    );
  }
}
