import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart'; // keep library available per project features
import 'package:cached_network_image/cached_network_image.dart';
import '../models/challenge_model.dart';

class AddChallengeScreen extends StatefulWidget {
  final ChallengeModel? challengeToEdit;

  const AddChallengeScreen({Key? key, this.challengeToEdit}) : super(key: key);

  @override
  State<AddChallengeScreen> createState() => _AddChallengeScreenState();
}

class _AddChallengeScreenState extends State<AddChallengeScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _imageController;
  late final TextEditingController _goalController;
  late final TextEditingController _unitController;
  late final TextEditingController _exerciseTypeController;
  ChallengeDifficulty _difficulty = ChallengeDifficulty.medium;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final c = widget.challengeToEdit;
    _titleController = TextEditingController(text: c?.title ?? '');
    _descriptionController = TextEditingController(text: c?.description ?? '');
    _imageController = TextEditingController(text: c?.imageUrl ?? '');
    _goalController = TextEditingController(
      text: c != null ? c.goalValue.toString() : '0',
    );
    _unitController = TextEditingController(text: c?.unit ?? '');
    _exerciseTypeController = TextEditingController(
      text: c?.exerciseType ?? 'General',
    );
    _difficulty = c?.difficulty ?? ChallengeDifficulty.medium;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _imageController.dispose();
    _goalController.dispose();
    _unitController.dispose();
    _exerciseTypeController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);

    try {
      final title = _titleController.text.trim();
      final desc = _descriptionController.text.trim();
      final image = _imageController.text.trim();
      final goal = int.tryParse(_goalController.text) ?? 0;
      final unit = _unitController.text.trim();
      final exercise = _exerciseTypeController.text.trim();

      final now = DateTime.now();

      final docRef = widget.challengeToEdit == null
          ? FirebaseFirestore.instance.collection('challenges').doc()
          : FirebaseFirestore.instance
                .collection('challenges')
                .doc(widget.challengeToEdit!.id);

      final model = ChallengeModel(
        id: docRef.id,
        title: title,
        description: desc,
        imageUrl: image.isEmpty ? null : image,
        exerciseType: exercise.isEmpty ? 'General' : exercise,
        tags: widget.challengeToEdit?.tags ?? [],
        goalValue: goal,
        unit: unit,
        difficulty: _difficulty,
        participantIds: widget.challengeToEdit?.participantIds ?? [],
        startDate: widget.challengeToEdit?.startDate ?? now,
        createdAt: widget.challengeToEdit?.createdAt ?? now,
        lastModified: now,
      );

      await docRef.set(model.toMap());

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.challengeToEdit == null ? 'Add Challenge' : 'Edit Challenge',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // small share helper — keep share_plus available
              final preview =
                  '${_titleController.text}\n${_descriptionController.text}';
              if (preview.trim().isNotEmpty) Share.share(preview);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _imageController,
              decoration: const InputDecoration(labelText: 'Image URL'),
            ),
            const SizedBox(height: 8),
            if (_imageController.text.isNotEmpty)
              SizedBox(
                height: 150,
                width: double.infinity,
                child: CachedNetworkImage(
                  imageUrl: _imageController.text,
                  fit: BoxFit.cover,
                  placeholder: (c, u) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (c, u, e) => const Icon(Icons.broken_image),
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _goalController,
                    decoration: const InputDecoration(labelText: 'Goal Value'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _unitController,
                    decoration: const InputDecoration(labelText: 'Unit'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _exerciseTypeController,
              decoration: const InputDecoration(labelText: 'Exercise Type'),
            ),
            const SizedBox(height: 12),
            // Difficulty selector
            DropdownButtonFormField<ChallengeDifficulty>(
              value: _difficulty,
              items: ChallengeDifficulty.values
                  .map(
                    (d) => DropdownMenuItem(
                      value: d,
                      child: Text(d.name.capitalize()),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _difficulty = v);
              },
              decoration: const InputDecoration(labelText: 'Difficulty'),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const CircularProgressIndicator()
                    : const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension _StringExt on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
