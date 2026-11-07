import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/services/ai_checklist_service.dart';
import '../core/theme/app_theme.dart';
import '../features/checklist/cubit/checklist_cubit.dart';
import '../features/checklist/data/checklist_repository.dart';
import '../features/checklist/view/checklist_list_page.dart';

class App extends StatelessWidget {
  const App({super.key, required this.checklistRepository});

  final ChecklistRepository checklistRepository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ChecklistCubit(checklistRepository, AiChecklistService()),
      child: MaterialApp(
        title: 'Tracking System',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        home: const ChecklistListPage(),
      ),
    );
  }
}
