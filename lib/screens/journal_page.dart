import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import '../models/journal_model.dart';
import '../services/firebase_service.dart';
import '../widgets/main_navigation.dart';
import '../widgets/retry_dialog.dart';
import 'journal_write_screen.dart';
import 'journal_read_screen.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  List<JournalModel> journals = [];
  bool isLoading = true;
  String? errorMessage;
  String selectedFilter = 'All';
  
  final List<String> filters = ['All', 'Today', 'This Week', 'This Month'];

  @override
  void initState() {
    super.initState();
    _loadJournals();
  }

  Future<void> _loadJournals() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    
    try {
      final user = FirebaseService.getCurrentUser();
      if (user != null) {
        final userJournals = await FirebaseService.getUserJournals(user.uid);
        setState(() {
          journals = userJournals;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading journals: $e');
      
      if (mounted) {
        final shouldRetry = await HoTechRetryDialog.show(
          context: context,
          title: 'Journal Loading Issue',
          message: 'Having trouble accessing your journal entries. Let\'s reload your thoughts and reflections!',
        );
        
        if (shouldRetry == true) {
          _loadJournals(); // Retry
        } else {
          setState(() {
            isLoading = false;
            errorMessage = 'Unable to load journal entries. Pull to refresh when ready.';
          });
        }
      }
    }
  }

  List<JournalModel> get filteredJournals {
    final now = DateTime.now();
    switch (selectedFilter) {
      case 'Today':
        return journals.where((j) {
          final today = DateTime(now.year, now.month, now.day);
          final journalDate = DateTime(j.createdAt.year, j.createdAt.month, j.createdAt.day);
          return journalDate == today;
        }).toList();
      case 'This Week':
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        return journals.where((j) => j.createdAt.isAfter(weekStart)).toList();
      case 'This Month':
        return journals.where((j) => 
          j.createdAt.year == now.year && j.createdAt.month == now.month
        ).toList();
      default:
        return journals;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryGreen.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  'HTU',
                                  style: TextStyle(
                                    color: AppTheme.primaryGreen,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Journal',
                              style: theme.textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Capture your campus thoughts and reflections 📝',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryGreen.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const JournalWriteScreen(),
                          ),
                        );
                        if (result == true) {
                          _loadJournals();
                        }
                      },
                      icon: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Quick Stats
            if (!isLoading && journals.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AnimationConfiguration.staggeredList(
                  position: 0,
                  duration: const Duration(milliseconds: 600),
                  child: SlideAnimation(
                    verticalOffset: 30.0,
                    child: FadeInAnimation(
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStat(
                                'Total Entries',
                                journals.length.toString(),
                                Icons.book,
                                theme,
                              ),
                              _buildStat(
                                'This Month',
                                filteredJournals.length.toString(),
                                Icons.calendar_today,
                                theme,
                              ),
                              _buildStat(
                                'Avg Words',
                                _getAverageWordCount().toString(),
                                Icons.text_fields,
                                theme,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            
            // Filters
            if (!isLoading && journals.isNotEmpty) ...[
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      'Filter:',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: filters.length,
                          itemBuilder: (context, index) {
                            final filter = filters[index];
                            final isSelected = selectedFilter == filter;
                            
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                selected: isSelected,
                                label: Text(filter),
                                onSelected: (selected) {
                                  setState(() {
                                    selectedFilter = filter;
                                  });
                                },
                                backgroundColor: Colors.transparent,
                                selectedColor: AppTheme.primaryGreen.withOpacity(0.2),
                                checkmarkColor: AppTheme.primaryGreen,
                                labelStyle: TextStyle(
                                  color: isSelected 
                                      ? AppTheme.primaryGreen 
                                      : theme.textTheme.bodyMedium?.color,
                                  fontWeight: isSelected 
                                      ? FontWeight.w600 
                                      : FontWeight.normal,
                                ),
                                side: BorderSide(
                                  color: isSelected 
                                      ? AppTheme.primaryGreen 
                                      : AppTheme.textLight,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 20),
            
            // Journal Entries List
            Expanded(
              child: _buildJournalList(theme),
            ),
          ],
        ),
      ),
      bottomNavigationBar: MainNavigation(
        currentIndex: 3,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushNamed(context, '/ai-chatbot'); // FIXED: was '/insights'
              break;
            case 2:
              Navigator.pushNamed(context, '/meditation');
              break;
            case 3:
              // Already on journal
              break;
            case 4:
              Navigator.pushNamed(context, '/profile');
              break;
          }
        },
      ),
    );
  }

  Widget _buildJournalList(ThemeData theme) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (journals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.book_outlined,
              size: 80,
              color: AppTheme.textLight,
            ),
            const SizedBox(height: 16),
            Text(
              'Start Your Journey',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: AppTheme.textLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Write your first journal entry',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textLight,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const JournalWriteScreen(),
                  ),
                );
                if (result == true) {
                  _loadJournals();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Start Writing'),
            ),
          ],
        ),
      );
    }

    final displayJournals = filteredJournals;
    
    if (displayJournals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppTheme.textLight,
            ),
            const SizedBox(height: 16),
            Text(
              'No entries found',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppTheme.textLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try changing your filter',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textLight,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: displayJournals.length,
      itemBuilder: (context, index) {
        final journal = displayJournals[index];
        return AnimationConfiguration.staggeredList(
          position: index,
          duration: const Duration(milliseconds: 600),
          child: SlideAnimation(
            verticalOffset: 30.0,
            child: FadeInAnimation(
              child: _buildJournalCard(journal, theme),
            ),
          ),
        );
      },
    );
  }

  Widget _buildJournalCard(JournalModel journal, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => JournalReadScreen(journal: journal),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        journal.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: _getMoodColor(journal.moodRating),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  journal.preview,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: AppTheme.textLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('MMM d, y').format(journal.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textLight,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.schedule_outlined,
                      size: 14,
                      color: AppTheme.textLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${journal.readingTime.inMinutes} min read',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textLight,
                      ),
                    ),
                    const Spacer(),
                    if (journal.emotions.isNotEmpty)
                      Wrap(
                        spacing: 4,
                        children: journal.emotions.take(2).map((emotion) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              emotion,
                              style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.primaryGreen,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon, ThemeData theme) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppTheme.primaryGreen,
          size: 20,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryGreen,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppTheme.textLight,
          ),
        ),
      ],
    );
  }

  Color _getMoodColor(int rating) {
    switch (rating) {
      case 1:
      case 2:
        return Colors.red.withOpacity(0.7);
      case 3:
        return Colors.orange.withOpacity(0.7);
      case 4:
      case 5:
        return AppTheme.primaryGreen.withOpacity(0.7);
      default:
        return AppTheme.textLight;
    }
  }

  int _getAverageWordCount() {
    if (journals.isEmpty) return 0;
    final totalWords = journals.fold<int>(0, (sum, journal) => sum + journal.wordCount);
    return (totalWords / journals.length).round();
  }
}
