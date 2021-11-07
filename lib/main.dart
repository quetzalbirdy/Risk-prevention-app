import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'src/di/bloc_injector.dart';
import 'src/di/bloc_module.dart';
import 'package:sentry/sentry.dart';

void main() async {
  final sentry = SentryClient(dsn: '#');
  /* SharedPreferences.setMockInitialValues({}); */
  var container = await BlocInjector.create(BlocModule());
  runZonedGuarded(
    () => runApp(container.app),
    (error, stackTrace) async {
      await sentry.captureException(
        exception: error,
        stackTrace: stackTrace
        
      );
    }
  );
}