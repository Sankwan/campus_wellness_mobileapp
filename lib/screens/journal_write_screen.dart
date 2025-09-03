import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../theme.dart';
import '../models/journal_model.dart';
import '../services/firebase_service.dart';

class JournalWriteScreen extends StatefulWidget {
  final JournalModel? existingJournal;

  const JournalWriteScreen({
    super.key,
    this.existingJournal,
  });

  @override
  State<JournalWriteScreen> createState() => _JournalWriteScreenState();
}

class _JournalWriteScreenState extends State<JournalWriteScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  
  String? selectedPrompt;
  List<String> selectedEmotions = [];
  List<String> selectedTags = [];
  int moodRating = 3;
  bool isLoading = false;
  bool showPrompts = false;

  final List<String> emotions = [
    'Happy', 'Grateful', 'Excited', 'Peaceful', 'Proud', 'Loved',
    'Anxious', 'Sad', 'Frustrated', 'Angry', 'Confused', 'Lonely',
    'Hopeful', 'Motivated', 'Creative', 'Nostalgic', 'Overwhelmed', 'Content'
  ];

  final List<String> tags = [
    'Reflection', 'Gratitude', 'Goals', 'Relationships', 'Work',
    'Health', 'Dreams', 'Memories', 'Growth', 'Challenges',
    'Success', 'Learning', 'Family', 'Friends', 'Travel'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingJournal != null) {
      titleController.text = widget.existingJournal!.title;
      contentController.text = widget.existingJournal!.content;
      selectedPrompt = widget.existingJournal!.prompt;
      selectedEmotions = List.from(widget.existingJournal!.emotions);
      selectedTags = List.from(widget.existingJournal!.tags);
      moodRating = widget.existingJournal!.moodRating;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _handleBack(),
        ),
        title: Text(
          widget.existingJournal == null ? 'New Entry' : 'Edit Entry',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _saveJournal,
            child: Text(
              'Save',
              style: TextStyle(
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: scrollController,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Input
              TextField(
                controller: titleController,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  hintText: 'Give your entry a title...',
                  hintStyle: theme.textTheme.headlineSmall?.copyWith(
                    color: AppTheme.textLight,
                  ),
                  border: InputBorder.none,
                ),
                maxLines: 2,
              ),
              
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),

              // Mood Rating
              Row(
                children: [
                  Text(
                    'How are you feeling? ',
                    style: theme.textTheme.titleMedium,
                  ),
                  const Spacer(),
                  Row(
                    children: List.generate(5, (index) {
                      final rating = index + 1;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            moodRating = rating;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Icon(
                            rating <= moodRating
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: rating <= moodRating
                                ? AppTheme.primaryGreen
                                : AppTheme.textLight,
                            size: 24,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),

              // Prompt Section
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      showPrompts = !showPrompts;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: AppTheme.primaryGreen,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Writing Prompts',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: AppTheme.primaryGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              showPrompts
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: AppTheme.primaryGreen,
                            ),
                          ],
                        ),
                        if (selectedPrompt != null && !showPrompts) ...[
                          const SizedBox(height: 8),
                          Text(
                            selectedPrompt!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                        if (showPrompts) ...[
                          const SizedBox(height: 16),
                          Column(
                            children: JournalPrompts.dailyPrompts.map((promptData) {
                              final prompt = promptData['prompt']!;
                              final category = promptData['category']!;
                              final isSelected = selectedPrompt == prompt;
                              
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      selectedPrompt = isSelected ? null : prompt;
                                      showPrompts = false;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppTheme.primaryGreen.withOpacity(0.1)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppTheme.primaryGreen
                                            : Colors.transparent,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppTheme.primaryGreen.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                category,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: AppTheme.primaryGreen,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            if (isSelected) ...[
                                              const Spacer(),
                                              Icon(
                                                Icons.check_circle,
                                                color: AppTheme.primaryGreen,
                                                size: 20,
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          prompt,
                                          style: theme.textTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),

              // Content Input
              TextField(
                controller: contentController,
                style: theme.textTheme.bodyLarge,
                maxLines: null,
                minLines: 10,
                decoration: InputDecoration(
                  hintText: selectedPrompt != null
                      ? 'Start writing about: $selectedPrompt'
                      : 'What\'s on your mind? Start writing...',
                  hintStyle: theme.textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textLight,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.textLight.withOpacity(0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.textLight.withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.primaryGreen,
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Emotions Section
              Text(
                'How are you feeling?',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: emotions.map((emotion) {
                  final isSelected = selectedEmotions.contains(emotion);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedEmotions.remove(emotion);
                        } else {
                          selectedEmotions.add(emotion);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryGreen
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primaryGreen
                              : AppTheme.textLight,
                        ),
                      ),
                      child: Text(
                        emotion,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : theme.textTheme.bodyMedium?.color,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Tags Section
              Text(
                'Add tags (optional)',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: tags.map((tag) {
                  final isSelected = selectedTags.contains(tag);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedTags.remove(tag);
                        } else {
                          selectedTags.add(tag);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.softPurple.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.softPurple
                              : AppTheme.textLight,
                        ),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          color: isSelected
                              ? AppTheme.softPurple
                              : theme.textTheme.bodyMedium?.color,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 40),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _saveJournal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : Text(
                          widget.existingJournal == null ? 'Save Entry' : 'Update Entry',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _handleBack() {
    if (titleController.text.isNotEmpty || contentController.text.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Discard Entry?'),
          content: const Text('Your changes will be lost if you go back.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text(
                'Discard',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _saveJournal() async {
    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please add a title for your entry'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please write some content for your entry'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final user = FirebaseService.getCurrentUser();
      if (user != null) {
        final journal = JournalModel(
          id: widget.existingJournal?.id ?? const Uuid().v4(),
          userId: user.uid,
          title: titleController.text.trim(),
          content: contentController.text.trim(),
          prompt: selectedPrompt,
          emotions: selectedEmotions,
          tags: selectedTags,
          createdAt: widget.existingJournal?.createdAt ?? DateTime.now(),
          updatedAt: widget.existingJournal != null ? DateTime.now() : null,
          moodRating: moodRating,
        );

        if (widget.existingJournal == null) {
          await FirebaseService.saveJournal(journal);
        } else {
          await FirebaseService.updateJournal(journal);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.existingJournal == null
                    ? 'Journal entry saved! 📝'
                    : 'Journal entry updated! ✏️',
              ),
              backgroundColor: AppTheme.primaryGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );

          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to save journal entry. Please try again.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    scrollController.dispose();
    super.dispose();
  }
}
