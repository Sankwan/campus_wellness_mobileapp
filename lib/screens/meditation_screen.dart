import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme.dart';
import '../models/meditation_model.dart';
import '../widgets/main_navigation.dart';
import 'meditation_player_screen.dart';
import '../services/ambient_sound_service.dart';

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String selectedCategory = 'All';
  bool isLoading = false;
  
  final List<String> categories = [
    'All', 'Breathing', 'Mindfulness', 'Sleep', 'Stress', 'Focus', 'Anxiety'
  ];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Guided meditation sessions (for built-in player with ambient sounds)
  final List<MeditationContent> guidedSessions = [
    MeditationContent(
      id: 'g1',
      title: 'Breathing Focus',
      description: 'Simple breathing meditation with countdown timer',
      category: 'Breathing',
      duration: 5,
      type: MeditationType.guided,
      instructor: 'Campus Wellness',
      difficulty: 'Beginner',
      rating: 4.8,
    ),
    MeditationContent(
      id: 'g2',
      title: 'Mindful Moments',
      description: 'Quick mindfulness session with ambient sounds',
      category: 'Mindfulness',
      duration: 10,
      type: MeditationType.guided,
      instructor: 'Campus Wellness',
      difficulty: 'Beginner',
      rating: 4.9,
    ),
    MeditationContent(
      id: 'g3',
      title: 'Stress Release',
      description: 'Gentle meditation to release daily stress',
      category: 'Stress',
      duration: 15,
      type: MeditationType.guided,
      instructor: 'Campus Wellness',
      difficulty: 'Beginner',
      rating: 4.7,
    ),
    MeditationContent(
      id: 'g4',
      title: 'Deep Focus',
      description: 'Extended meditation for concentration',
      category: 'Focus',
      duration: 20,
      type: MeditationType.guided,
      instructor: 'Campus Wellness',
      difficulty: 'Intermediate',
      rating: 4.6,
    ),
    MeditationContent(
      id: 'g5',
      title: 'Sleep Preparation',
      description: 'Wind down meditation for better sleep',
      category: 'Sleep',
      duration: 30,
      type: MeditationType.sleep,
      instructor: 'Campus Wellness',
      difficulty: 'Beginner',
      rating: 4.8,
    ),
  ];

  // YouTube video meditations
  final List<MeditationContent> youtubeVideos = [
    MeditationContent(
      id: 'y1',
      title: '4-7-8 Breathing Technique',
      description: 'A simple but powerful breathing exercise for anxiety and sleep',
      category: 'Breathing',
      duration: 5,
      type: MeditationType.guided,
      instructor: 'Dr. Andrew Weil',
      youtubeId: 'YRPh_GaiL8s',
      thumbnailUrl: 'https://img.youtube.com/vi/YRPh_GaiL8s/maxresdefault.jpg',
      difficulty: 'Beginner',
      rating: 4.8,
    ),
    MeditationContent(
      id: 'y2',
      title: 'Box Breathing for Stress',
      description: 'Navy SEAL breathing technique for instant calm',
      category: 'Breathing',
      duration: 8,
      type: MeditationType.guided,
      instructor: 'Breathe with Me',
      youtubeId: 'tEmt1Znux58',
      thumbnailUrl: 'https://img.youtube.com/vi/tEmt1Znux58/maxresdefault.jpg',
      difficulty: 'Beginner',
      rating: 4.7,
    ),
    MeditationContent(
      id: 'y3',
      title: '10-Minute Mindfulness',
      description: 'Daily mindfulness practice for beginners',
      category: 'Mindfulness',
      duration: 10,
      type: MeditationType.guided,
      instructor: 'Headspace',
      youtubeId: 'ZToicYcHIOU',
      thumbnailUrl: 'https://img.youtube.com/vi/ZToicYcHIOU/maxresdefault.jpg',
      difficulty: 'Beginner',
      rating: 4.9,
    ),
    MeditationContent(
      id: 'y4',
      title: 'Body Scan Meditation',
      description: 'Full body awareness and relaxation practice',
      category: 'Mindfulness',
      duration: 20,
      type: MeditationType.guided,
      instructor: 'The Honest Guys',
      youtubeId: 'QS2yDmWk0vs',
      thumbnailUrl: 'https://img.youtube.com/vi/QS2yDmWk0vs/maxresdefault.jpg',
      difficulty: 'Intermediate',
      rating: 4.8,
    ),
    MeditationContent(
      id: 'y5',
      title: 'Sleep Meditation',
      description: 'Gentle guided meditation to help you fall asleep',
      category: 'Sleep',
      duration: 45,
      type: MeditationType.sleep,
      instructor: 'Jason Stephenson',
      youtubeId: 'aAVopGm-NH0',
      thumbnailUrl: 'https://img.youtube.com/vi/aAVopGm-NH0/maxresdefault.jpg',
      difficulty: 'Beginner',
      rating: 4.9,
    ),
    MeditationContent(
      id: 'y6',
      title: 'Anxiety Relief Meditation',
      description: 'Calm your anxious mind with this soothing practice',
      category: 'Anxiety',
      duration: 18,
      type: MeditationType.guided,
      instructor: 'Michelle\'s Sanctuary',
      youtubeId: 'O-6f5wQXSu8',
      thumbnailUrl: 'https://img.youtube.com/vi/O-6f5wQXSu8/maxresdefault.jpg',
      difficulty: 'Beginner',
      rating: 4.8,
    ),
  ];

  List<MeditationContent> get filteredGuidedSessions {
    if (selectedCategory == 'All') return guidedSessions;
    return guidedSessions.where((m) => 
      m.category.toLowerCase() == selectedCategory.toLowerCase()
    ).toList();
  }

  List<MeditationContent> get filteredYoutubeVideos {
    if (selectedCategory == 'All') return youtubeVideos;
    return youtubeVideos.where((m) => 
      m.category.toLowerCase() == selectedCategory.toLowerCase()
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar with gradient
            Container(
              height: 200,
              decoration: const BoxDecoration(
                gradient: AppTheme.meditationGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Meditate',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.self_improvement,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Find your inner peace',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      
                      // Tab Bar
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicator: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          labelColor: AppTheme.primaryGreen,
                          unselectedLabelColor: Colors.white,
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          unselectedLabelStyle: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                          tabs: const [
                            Tab(text: 'Guided Sessions'),
                            Tab(text: 'YouTube Videos'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Categories Filter
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = selectedCategory == category;
                  
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCategory = category;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primaryGreen
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.primaryGreen
                                : AppTheme.textLight,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          category,
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
                    ),
                  );
                },
              ),
            ),
            
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildGuidedSessionsTab(),
                  _buildYoutubeVideosTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: MainNavigation(
        currentIndex: 2,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushNamed(context, '/ai-chatbot');
              break;
            case 2:
              break;
            case 3:
              Navigator.pushNamed(context, '/journal');
              break;
            case 4:
              Navigator.pushNamed(context, '/profile');
              break;
          }
        },
      ),
    );
  }

  Widget _buildGuidedSessionsTab() {
    final sessions = filteredGuidedSessions;
    
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: sessions.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.timer,
                      color: AppTheme.primaryGreen,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Built-in Timer Sessions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Meditation sessions with countdown timer and ambient sounds. Works offline.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }
        
        final meditation = sessions[index - 1];
        return AnimationConfiguration.staggeredList(
          position: index - 1,
          duration: const Duration(milliseconds: 600),
          child: SlideAnimation(
            verticalOffset: 50.0,
            child: FadeInAnimation(
              child: _buildGuidedSessionCard(meditation, Theme.of(context)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildYoutubeVideosTab() {
    final videos = filteredYoutubeVideos;
    
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: videos.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.video_library,
                      color: Colors.red,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'YouTube Video Sessions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Professional guided meditations from YouTube. Requires internet connection.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }
        
        final meditation = videos[index - 1];
        return AnimationConfiguration.staggeredList(
          position: index - 1,
          duration: const Duration(milliseconds: 600),
          child: SlideAnimation(
            verticalOffset: 50.0,
            child: FadeInAnimation(
              child: _buildYoutubeVideoCard(meditation, Theme.of(context)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGuidedSessionCard(MeditationContent meditation, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () => _startGuidedSession(meditation),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon instead of thumbnail for guided sessions
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: _getCategoryGradient(meditation.category),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getCategoryIcon(meditation.category),
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meditation.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        meditation.description,
                        style: theme.textTheme.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.timer,
                            size: 16,
                            color: AppTheme.primaryGreen,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${meditation.duration}m',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.primaryGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.offline_bolt,
                            size: 16,
                            color: AppTheme.primaryGreen,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Offline',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.primaryGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Play button and difficulty
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.play_arrow,
                        color: AppTheme.primaryGreen,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      meditation.difficulty,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textLight,
                        fontWeight: FontWeight.w500,
                      ),
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

  Widget _buildYoutubeVideoCard(MeditationContent meditation, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () {
            _playMeditation(meditation);
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Thumbnail
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(meditation.thumbnailUrl ?? ''),
                      fit: BoxFit.cover,
                      onError: (exception, stackTrace) {
                        // Fallback to gradient background
                      },
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: _getCategoryGradient(meditation.category),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meditation.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        meditation.description,
                        style: theme.textTheme.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: AppTheme.textLight,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${meditation.duration}m',
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.person,
                            size: 16,
                            color: AppTheme.textLight,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            meditation.instructor,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Rating and difficulty
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        meditation.difficulty,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          meditation.rating.toStringAsFixed(1),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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

  void _playMeditation(MeditationContent meditation) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  meditation.title,
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'by ${meditation.instructor}',
                                  style: TextStyle(
                                    color: AppTheme.textLight,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Video player placeholder
                      Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.black,
                        ),
                        child: meditation.youtubeId != null
                            ? Stack(
                                children: [
                                  // Thumbnail
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.network(
                                      meditation.thumbnailUrl ?? '',
                                      width: double.infinity,
                                      height: 200,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            gradient: _getCategoryGradient(meditation.category),
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  // Play overlay
                                  Center(
                                    child: Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.9),
                                        shape: BoxShape.circle,
                                      ),
                                      child: IconButton(
                                        onPressed: () => _launchYouTube(meditation.youtubeUrl),
                                        icon: Icon(
                                          Icons.play_arrow,
                                          size: 32,
                                          color: AppTheme.primaryGreen,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.self_improvement,
                                      size: 48,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Guided Audio Meditation',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Description and details
                      Text(
                        meditation.description,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Details row
                      Row(
                        children: [
                          _buildDetailChip(
                            icon: Icons.access_time,
                            label: '${meditation.duration} min',
                            color: AppTheme.primaryGreen,
                          ),
                          const SizedBox(width: 12),
                          _buildDetailChip(
                            icon: Icons.signal_cellular_alt,
                            label: meditation.difficulty,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 12),
                          _buildDetailChip(
                            icon: Icons.star,
                            label: meditation.rating.toString(),
                            color: Colors.amber,
                          ),
                        ],
                      ),
                      
                      const Spacer(),
                      
                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                if (meditation.youtubeId != null) {
                                  _launchYouTube(meditation.youtubeUrl);
                                } else {
                                  // Launch guided meditation player
                                  _launchGuidedMeditation(meditation);
                                }
                              },
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Start Session'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryGreen,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            onPressed: () {
                              // TODO: Add to favorites
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Added "${meditation.title}" to favorites'),
                                  backgroundColor: AppTheme.primaryGreen,
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.favorite_outline,
                              color: AppTheme.primaryGreen,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchYouTube(String? url) async {
    if (url == null) return;
    
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Could not launch YouTube video'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening video: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _launchGuidedMeditation(MeditationContent meditation) {
    // Navigate to custom meditation player for guided sessions
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GuidedMeditationPlayerScreen(
          meditation: meditation,
        ),
      ),
    );
  }

  void _startGuidedSession(MeditationContent meditation) {
    // Create a MeditationModel from MeditationContent for the player
    final meditationModel = MeditationModel(
      id: meditation.id,
      title: meditation.title,
      duration: meditation.duration,
      category: meditation.category,
      description: meditation.description,
      audioUrl: '', // No audio URL for timer-based sessions
      instructor: meditation.instructor,
      script: 'Focus on your breathing and let your mind relax.',
      createdAt: DateTime.now(),
    );
    
    // Navigate to the enhanced meditation player
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MeditationPlayerScreen(
          meditation: meditationModel,
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'breathing':
        return Icons.air;
      case 'mindfulness':
        return Icons.psychology;
      case 'sleep':
        return Icons.nightlight_round;
      case 'stress':
        return Icons.spa;
      case 'focus':
        return Icons.center_focus_strong;
      case 'anxiety':
        return Icons.healing;
      default:
        return Icons.self_improvement;
    }
  }

  LinearGradient _getCategoryGradient(String category) {
    switch (category.toLowerCase()) {
      case 'breathing':
        return AppTheme.calmingGradient;
      case 'sleep':
        return AppTheme.sleepGradient;
      case 'stress':
        return const LinearGradient(
          colors: [Colors.orange, Colors.deepOrange],
        );
      default:
        return AppTheme.meditationGradient;
    }
  }
}

// Simple guided meditation player for non-YouTube content
class GuidedMeditationPlayerScreen extends StatelessWidget {
  final MeditationContent meditation;
  
  const GuidedMeditationPlayerScreen({super.key, required this.meditation});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          meditation.title,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Guided Meditation',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                meditation.description,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Text(
                '${meditation.duration} minutes',
                style: TextStyle(
                  color: AppTheme.primaryGreen,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 40),
              // TODO: Add timer and guided instructions
              ElevatedButton(
                onPressed: () {
                  // TODO: Start guided session
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Guided meditation feature coming soon!'),
                      backgroundColor: AppTheme.primaryGreen,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('Start Meditation'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
