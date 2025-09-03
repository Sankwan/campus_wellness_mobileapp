import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme.dart';
import '../models/journal_model.dart';
import 'journal_write_screen.dart';

class JournalReadScreen extends StatelessWidget {
  final JournalModel journal;

  const JournalReadScreen({
    super.key,
    required this.journal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => JournalWriteScreen(
                    existingJournal: journal,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                journal.title,
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Metadata
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: AppTheme.textLight,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat('EEEE, MMMM d, y').format(journal.createdAt),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textLight,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.schedule_outlined,
                    size: 16,
                    color: AppTheme.textLight,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${journal.readingTime.inMinutes} min read',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textLight,
                    ),
                  ),
                ],
              ),
              
              if (journal.updatedAt != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      size: 16,
                      color: AppTheme.textLight,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Updated ${DateFormat('MMM d, y').format(journal.updatedAt!)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textLight,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: 24),
              
              // Mood Rating
              Row(
                children: [
                  Text(
                    'Mood: ',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < journal.moodRating
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: index < journal.moodRating
                            ? AppTheme.primaryGreen
                            : AppTheme.textLight,
                        size: 20,
                      );
                    }),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getMoodLabel(journal.moodRating),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textLight,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Prompt (if any)
              if (journal.prompt != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryGreen.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: AppTheme.primaryGreen,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Writing Prompt',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: AppTheme.primaryGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        journal.prompt!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
              
              // Content
              Text(
                journal.content,
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                  fontSize: 16,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Emotions
              if (journal.emotions.isNotEmpty) ...[
                Text(
                  'Emotions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: journal.emotions.map((emotion) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.primaryGreen.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        emotion,
                        style: TextStyle(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
              ],
              
              // Tags
              if (journal.tags.isNotEmpty) ...[
                Text(
                  'Tags',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: journal.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.softPurple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.softPurple.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          color: AppTheme.softPurple,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
              ],
              
              // Word count
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.textLight.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.text_fields,
                      color: AppTheme.textLight,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${journal.wordCount} words',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${journal.readingTime.inMinutes} minute read',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JournalWriteScreen(
                existingJournal: journal,
              ),
            ),
          );
        },
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.edit),
        label: const Text(
          'Edit Entry',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  String _getMoodLabel(int rating) {
    switch (rating) {
      case 1:
        return 'Very Low';
      case 2:
        return 'Low';
      case 3:
        return 'Neutral';
      case 4:
        return 'Good';
      case 5:
        return 'Excellent';
      default:
        return 'Unknown';
    }
  }
}
