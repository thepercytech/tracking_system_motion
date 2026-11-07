import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/checklist_cubit.dart';
import '../models/checklist.dart';
import '../models/checklist_item.dart';

class ChecklistDetailPage extends StatelessWidget {
  const ChecklistDetailPage({super.key, required this.checklistId});

  final String checklistId;

  Future<void> _addItem(BuildContext context, {String? parentId}) async {
    final controller = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(parentId == null ? 'New item' : 'New subtask'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (title == null || title.trim().isEmpty) return;
    if (!context.mounted) return;
    await context
        .read<ChecklistCubit>()
        .addItem(checklistId, title, parentId: parentId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChecklistCubit, ChecklistState>(
      builder: (context, state) {
        Checklist? checklist;
        for (final c in state.checklists) {
          if (c.id == checklistId) {
            checklist = c;
            break;
          }
        }
        if (checklist == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Checklist not found.')),
          );
        }
        return Scaffold(
          appBar: AppBar(title: Text(checklist.name)),
          body: checklist.items.isEmpty
              ? const Center(child: Text('No items yet.'))
              : ListView(
                  children: checklist.items
                      .map(
                        (item) => _ItemTile(
                          checklistId: checklistId,
                          item: item,
                          depth: 0,
                          onAddSubtask: (parentId) =>
                              _addItem(context, parentId: parentId),
                        ),
                      )
                      .toList(),
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _addItem(context),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({
    required this.checklistId,
    required this.item,
    required this.depth,
    required this.onAddSubtask,
  });

  final String checklistId;
  final ChecklistItem item;
  final int depth;
  final void Function(String parentId) onAddSubtask;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: depth * 24.0),
          child: ListTile(
            leading: Checkbox(
              value: item.done,
              onChanged: (_) => context.read<ChecklistCubit>().toggleItem(
                checklistId,
                item.id,
              ),
            ),
            title: Text(
              item.title,
              style: item.done
                  ? const TextStyle(decoration: TextDecoration.lineThrough)
                  : null,
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'subtask') {
                  onAddSubtask(item.id);
                } else if (value == 'delete') {
                  context.read<ChecklistCubit>().deleteItem(
                    checklistId,
                    item.id,
                  );
                }
              },
              itemBuilder: (_) => [
                if (depth == 0)
                  const PopupMenuItem(
                    value: 'subtask',
                    child: Text('Add subtask'),
                  ),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ),
        ),
        for (final subtask in item.subtasks)
          _ItemTile(
            checklistId: checklistId,
            item: subtask,
            depth: depth + 1,
            onAddSubtask: onAddSubtask,
          ),
      ],
    );
  }
}
