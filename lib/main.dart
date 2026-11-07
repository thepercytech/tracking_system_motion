import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/app.dart';
import 'core/app_bloc_observer.dart';
import 'features/checklist/data/checklist_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  final checklistRepository = ChecklistRepository();
  await checklistRepository.init();

  if (kDebugMode) {
    Bloc.observer = AppBlocObserver();
  }
  runApp(App(checklistRepository: checklistRepository));
}
