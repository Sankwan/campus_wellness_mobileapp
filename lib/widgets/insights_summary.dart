import 'package:flutter/material.dart';
import '../theme.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/firebase_service.dart';

class InsightsSummary extends StatefulWidget {
  final List<double> weeklyMoodTrend;
  final int meditationStreak;
  final int journalEntries;
  final bool useRealData;

  const InsightsSummary({
    super.key,
    required this.weeklyMoodTrend,
    required this.meditationStreak,
    required this.journalEntries,
    this.useRealData = true,
  });
  
  @override
  State<InsightsSummary> createState() => _InsightsSummaryState();
}

class _InsightsSummaryState extends State<InsightsSummary> {
  List<double> realMoodTrend = [];
  int realJournalEntries = 0;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.useRealData) {
      _loadRealData();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadRealData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final user = FirebaseService.getCurrentUser();
      if (user != null) {
        // Get mood trend for last 7 days
        final moodTrend = await _getWeeklyMoodTrend(user.uid);
        
        // Get journal entries count
        final journals = await FirebaseService.getUserJournals(user.uid, limit: 1000);
        
        setState(() {
          realMoodTrend = moodTrend;
          realJournalEntries = journals.length;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load insights data';
      });
      print('Error loading insights data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<List<double>> _getWeeklyMoodTrend(String userId) async {
    try {
      final List<double> weekTrend = [];
      final now = DateTime.now();
      
      for (int i = 6; i >= 0; i--) {
        final day = now.subtract(Duration(days: i));
        final startOfDay = DateTime(day.year, day.month, day.day);
        final endOfDay = DateTime(day.year, day.month, day.day, 23, 59, 59);
        
        final moods = await FirebaseService.getMoodsByDateRange(userId, startOfDay, endOfDay);
        
        if (moods.isNotEmpty) {
          final dayAverage = moods.map((mood) => mood.moodValue).reduce((a, b) => a + b) / moods.length;
          weekTrend.add(dayAverage);
        } else {
          weekTrend.add(0.0); // No mood logged that day
        }
      }
      
      return weekTrend;
    } catch (e) {
      print('Error getting weekly mood trend: $e');
      return List.filled(7, 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Insights',
              style: theme.textTheme.headlineSmall,
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/ai-chatbot');
              },
              child: Text(
                'Ask AI Doctor',
                style: TextStyle(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Mood Trend Chart
                Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      color: AppTheme.primaryGreen,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '7-Day Mood Trend',
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 120,
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : errorMessage != null
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                    size: 24,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Failed to load trend',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : LineChart(
                              LineChartData(
                                minX: 0,
                                maxX: 6,
                                minY: 0,
                                maxY: 5,
                                gridData: FlGridData(show: false),
                                titlesData: FlTitlesData(
                                  show: true,
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  rightTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  topTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                                        if (value.toInt() < days.length) {
                                          return Text(
                                            days[value.toInt()],
                                            style: theme.textTheme.bodySmall,
                                          );
                                        }
                                        return const Text('');
                                      },
                                    ),
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: _getDisplayMoodTrend().asMap().entries.map(
                                      (e) => FlSpot(e.key.toDouble(), e.value),
                                    ).toList(),
                                    isCurved: true,
                                    color: AppTheme.primaryGreen,
                                    barWidth: 3,
                                    isStrokeCapRound: true,
                                    dotData: FlDotData(
                                      show: true,
                                      getDotPainter: (spot, percent, barData, index) {
                                        return FlDotCirclePainter(
                                          radius: 4,
                                          color: AppTheme.primaryGreen,
                                          strokeWidth: 2,
                                          strokeColor: Colors.white,
                                        );
                                      },
                                    ),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          AppTheme.primaryGreen.withOpacity(0.3),
                                          AppTheme.primaryGreen.withOpacity(0.1),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 20),
                // Statistics Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      icon: Icons.local_fire_department,
                      label: 'Streak',
                      value: '${widget.meditationStreak} days',
                      color: Colors.orange,
                      theme: theme,
                    ),
                    _buildStatItem(
                      icon: Icons.book,
                      label: 'Journal',
                      value: '${_getDisplayJournalEntries()} entries',
                      color: AppTheme.softPurple,
                      theme: theme,
                    ),
                    _buildStatItem(
                      icon: Icons.mood,
                      label: 'Avg Mood',
                      value: _getDisplayAverageMood(),
                      color: AppTheme.primaryGreen,
                      theme: theme,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required ThemeData theme,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  List<double> _getDisplayMoodTrend() {
    if (!widget.useRealData) return widget.weeklyMoodTrend;
    if (realMoodTrend.isEmpty) return List.filled(7, 0.0);
    return realMoodTrend.map((value) => value > 0 ? value : 0.1).toList(); // Ensure visible points
  }
  
  int _getDisplayJournalEntries() {
    return widget.useRealData ? realJournalEntries : widget.journalEntries;
  }
  
  String _getDisplayAverageMood() {
    if (isLoading) return '--';
    final moodTrend = _getDisplayMoodTrend();
    if (moodTrend.isEmpty || moodTrend.every((mood) => mood <= 0.1)) return '--';
    final average = moodTrend.where((mood) => mood > 0.1).fold(0.0, (a, b) => a + b) / moodTrend.where((mood) => mood > 0.1).length;
    return average.toStringAsFixed(1);
  }
}
