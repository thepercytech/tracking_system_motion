import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app/app.dart';
import 'core/app_bloc_observer.dart';

void main() {
  if (kDebugMode) {
    Bloc.observer = AppBlocObserver();
  }
  runApp(const App());
}
