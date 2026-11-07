import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/checklist_cubit.dart';
import '../models/checklist.dart';
import 'checklist_detail_page.dart';
import 'generate_checklist_page.dart';

class ChecklistListPage extends StatefulWidget {
  const ChecklistListPage({super.key});

  @override
  State<ChecklistListPage> createState() => _ChecklistListPageState();
}

class _ChecklistListPageState extends State<ChecklistListPage> {
  @override
  void initState() {
    super.initState();
    context.read<ChecklistCubit>().load();
  }

  Future<void> _createManualChecklist(BuildContext context) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('New checklist'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'e.g. Stage 1: Foundations',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    if (name == null || name.trim().isEmpty) return;
    if (!context.mounted) return;
    await context.read<ChecklistCubit>().createChecklist(name);
  }

  void _openGeneratePage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ChecklistCubit>(),
          child: const GenerateChecklistPage(),
        ),
      ),
    );
  }

  void _openChecklist(BuildContext context, Checklist checklist) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ChecklistCubit>(),
          child: ChecklistDetailPage(checklistId: checklist.id),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checklists')),
      body: BlocBuilder<ChecklistCubit, ChecklistState>(
        builder: (context, state) {
          if (state.checklists.isEmpty) {
            return const Center(
              child: Text('No checklists yet. Add one with the + button.'),
            );
          }
          return ListView.separated(
            itemCount: state.checklists.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final checklist = state.checklists[index];
              return Dismissible(
                key: ValueKey(checklist.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Theme.of(context).colorScheme.errorContainer,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete_outline),
                ),
                onDismissed: (_) => context
                    .read<ChecklistCubit>()
                    .deleteChecklist(checklist.id),
                child: ListTile(
                  title: Text(checklist.name),
                  subtitle: Text(
                    '${checklist.doneCount}/${checklist.totalCount} done',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _openChecklist(context, checklist),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'generate',
            onPressed: () => _openGeneratePage(context),
            icon: const Icon(Icons.auto_awesome),
            label: const Text('From text'),
          ),
          const SizedBox(width: 12),
          FloatingActionButton(
            heroTag: 'manual',
            onPressed: () => _createManualChecklist(context),
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
