import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/checklist_cubit.dart';

class GenerateChecklistPage extends StatefulWidget {
  const GenerateChecklistPage({super.key});

  @override
  State<GenerateChecklistPage> createState() => _GenerateChecklistPageState();
}

class _GenerateChecklistPageState extends State<GenerateChecklistPage> {
  final _nameController = TextEditingController();
  final _textController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final cubit = context.read<ChecklistCubit>();
    await cubit.generateChecklist(_nameController.text, _textController.text);
    if (!mounted) return;
    if (cubit.state.errorMessage == null) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChecklistCubit, ChecklistState>(
      listenWhen: (previous, current) =>
          current.errorMessage != null &&
          current.errorMessage != previous.errorMessage,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.errorMessage!)),
        );
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Generate from text')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Checklist name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: TextField(
                  controller: _textController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                    labelText: 'Paste text to turn into a checklist',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              BlocBuilder<ChecklistCubit, ChecklistState>(
                builder: (context, state) {
                  return FilledButton.icon(
                    onPressed: state.isGenerating ? null : _generate,
                    icon: state.isGenerating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_awesome),
                    label: Text(
                      state.isGenerating ? 'Generating...' : 'Generate',
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
