import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:adoptandlove/components/app/app_component.dart';
import 'package:adoptandlove/repositories/pets_db_repository.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

Future<Null> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  runZonedGuarded<Future<void>>(() async {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await PetsDBRepository().initDb();

    runApp(new AppComponent());
  }, (Object error, StackTrace stack) {
    FirebaseCrashlytics.instance.recordError(error, stack);
  });
}

