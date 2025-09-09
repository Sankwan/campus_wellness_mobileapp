import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';
import '../widgets/toast.dart';

class DailyAffirmationsScreen extends StatefulWidget {
  const DailyAffirmationsScreen({super.key});

  @override
  State<DailyAffirmationsScreen> createState() => _DailyAffirmationsScreenState();
}

class _DailyAffirmationsScreenState extends State<DailyAffirmationsScreen>
    with TickerProviderStateMixin {
  
  late AnimationController _floatingController;
  late AnimationController _fadeController;
  late Animation<double> _floatingAnimation;
  late Animation<double> _fadeAnimation;
  
  List<Affirmation> affirmations = [];
  List<Affirmation> filteredAffirmations = [];
  List<String> favoriteAffirmations = [];
  String selectedCategory = 'All';
  int currentAffirmationIndex = 0;
  bool isLoading = true;

  final List<String> categories = [
    'All',
    'Self-Love',
    'Confidence',
    'Success',
    'Health',
    'Relationships',
    'Study',
    'Motivation',
    'Peace',
    'Gratitude',
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadAffirmations();
    _loadFavorites();
  }

  void _setupAnimations() {
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _floatingAnimation = Tween<double>(
      begin: -5.0,
      end: 5.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _floatingController.repeat(reverse: true);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadAffirmations() async {
    // Simulate loading time
    await Future.delayed(const Duration(milliseconds: 500));
    
    affirmations = _getAffirmationsData();
    _filterAffirmations();
    
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      favoriteAffirmations = prefs.getStringList('favorite_affirmations') ?? [];
    });
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorite_affirmations', favoriteAffirmations);
  }

  void _filterAffirmations() {
    if (selectedCategory == 'All') {
      filteredAffirmations = affirmations;
    } else {
      filteredAffirmations = affirmations
          .where((affirmation) => affirmation.category == selectedCategory)
          .toList();
    }
    currentAffirmationIndex = 0;
  }

  void _toggleFavorite(Affirmation affirmation) {
    setState(() {
      if (favoriteAffirmations.contains(affirmation.id)) {
        favoriteAffirmations.remove(affirmation.id);
        ToastService.showInfo(
          context: context,
          title: 'Removed from Favorites',
          description: 'Affirmation removed from your favorites',
        );
      } else {
        favoriteAffirmations.add(affirmation.id);
        HapticFeedback.lightImpact();
        ToastService.showSuccess(
          context: context,
          title: 'Added to Favorites! ❤️',
          description: 'You can find this affirmation in your favorites',
        );
      }
    });
    _saveFavorites();
  }

  void _nextAffirmation() {
    if (filteredAffirmations.isNotEmpty) {
      setState(() {
        currentAffirmationIndex = 
            (currentAffirmationIndex + 1) % filteredAffirmations.length;
      });
      
      // Restart fade animation
      _fadeController.reset();
      _fadeController.forward();
      
      HapticFeedback.selectionClick();
    }
  }

  void _previousAffirmation() {
    if (filteredAffirmations.isNotEmpty) {
      setState(() {
        currentAffirmationIndex = currentAffirmationIndex == 0 
            ? filteredAffirmations.length - 1 
            : currentAffirmationIndex - 1;
      });
      
      // Restart fade animation
      _fadeController.reset();
      _fadeController.forward();
      
      HapticFeedback.selectionClick();
    }
  }

  void _shareAffirmation(Affirmation affirmation) {
    Clipboard.setData(ClipboardData(
      text: '"${affirmation.text}"\n\n- From HTU Wellness App 🌱',
    ));
    
    ToastService.showSuccess(
      context: context,
      title: 'Copied to Clipboard! 📋',
      description: 'Share this positive message with others',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentAffirmation = filteredAffirmations.isNotEmpty 
        ? filteredAffirmations[currentAffirmationIndex] 
        : null;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: isLoading ? _buildLoadingState() : Column(
          children: [
            // Header
            _buildHeader(theme),
            
            // Category Filter
            _buildCategoryFilter(theme),
            
            // Main Affirmation Card
            Expanded(
              child: _buildMainAffirmationCard(currentAffirmation, theme),
            ),
            
            // Navigation Controls
            _buildNavigationControls(theme),
            
            // Bottom Actions
            _buildBottomActions(currentAffirmation, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
          ),
          const SizedBox(height: 20),
          Text(
            'Loading your daily dose of positivity...',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryGreen,
            AppTheme.lightGreen,
          ],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              Expanded(
                child: Text(
                  'Daily Affirmations ✨',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                onPressed: _showFavorites,
                icon: Icon(
                  Icons.favorite,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Nurture your mind with positive thoughts',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(ThemeData theme) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category;
          
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 400),
            child: SlideAnimation(
              horizontalOffset: 50.0,
              child: FadeInAnimation(
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = category;
                      });
                      _filterAffirmations();
                      HapticFeedback.selectionClick();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: isSelected ? LinearGradient(
                          colors: [AppTheme.primaryGreen, AppTheme.lightGreen],
                        ) : null,
                        color: isSelected ? null : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: isSelected ? [
                          BoxShadow(
                            color: AppTheme.primaryGreen.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ] : null,
                      ),
                      child: Center(
                        child: Text(
                          category,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey.shade700,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainAffirmationCard(Affirmation? affirmation, ThemeData theme) {
    if (affirmation == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sentiment_satisfied,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No affirmations found',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              'Try selecting a different category',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    final isFavorite = favoriteAffirmations.contains(affirmation.id);

    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatingAnimation.value),
          child: Container(
            margin: const EdgeInsets.all(20),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      affirmation.color.withOpacity(0.1),
                      Colors.white,
                      affirmation.color.withOpacity(0.05),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Category badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: affirmation.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        affirmation.category,
                        style: TextStyle(
                          color: affirmation.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Main affirmation text
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        '"${affirmation.text}"',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Action buttons row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Favorite button
                        IconButton(
                          onPressed: () => _toggleFavorite(affirmation),
                          icon: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.grey,
                              size: 28,
                              key: ValueKey(isFavorite),
                            ),
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: isFavorite 
                                ? Colors.red.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        
                        // Share button
                        IconButton(
                          onPressed: () => _shareAffirmation(affirmation),
                          icon: const Icon(
                            Icons.share,
                            color: Colors.blue,
                            size: 28,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.blue.withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        
                        // Random affirmation button
                        IconButton(
                          onPressed: _getRandomAffirmation,
                          icon: const Icon(
                            Icons.shuffle,
                            color: Colors.purple,
                            size: 28,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.purple.withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
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
      },
    );
  }

  Widget _buildNavigationControls(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous button
          ElevatedButton(
            onPressed: filteredAffirmations.length > 1 ? _previousAffirmation : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.arrow_back_ios, size: 16),
                const SizedBox(width: 4),
                const Text('Previous'),
              ],
            ),
          ),
          
          // Page indicator
          if (filteredAffirmations.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${currentAffirmationIndex + 1} of ${filteredAffirmations.length}',
                style: TextStyle(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          
          // Next button
          ElevatedButton(
            onPressed: filteredAffirmations.length > 1 ? _nextAffirmation : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Next'),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(Affirmation? affirmation, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Motivational message
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.lightGreen.withOpacity(0.1),
                  AppTheme.primaryGreen.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: AppTheme.primaryGreen,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Start your day with positive thoughts! 🌟',
                    style: TextStyle(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _getRandomAffirmation() {
    if (filteredAffirmations.isNotEmpty) {
      final random = DateTime.now().millisecondsSinceEpoch % filteredAffirmations.length;
      setState(() {
        currentAffirmationIndex = random;
      });
      
      // Restart fade animation
      _fadeController.reset();
      _fadeController.forward();
      
      HapticFeedback.lightImpact();
    }
  }

  void _showFavorites() {
    final favoriteAffirmationObjects = affirmations
        .where((affirmation) => favoriteAffirmations.contains(affirmation.id))
        .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(Icons.favorite, color: Colors.red),
                  const SizedBox(width: 12),
                  Text(
                    'My Favorites',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: favoriteAffirmationObjects.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.favorite_outline,
                            size: 60,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No favorites yet',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          Text(
                            'Tap the ♥️ to add affirmations',
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: favoriteAffirmationObjects.length,
                      itemBuilder: (context, index) {
                        final affirmation = favoriteAffirmationObjects[index];
                        return ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: affirmation.color.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.favorite,
                              color: affirmation.color,
                            ),
                          ),
                          title: Text(
                            affirmation.text,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(affirmation.category),
                          trailing: IconButton(
                            onPressed: () => _toggleFavorite(affirmation),
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            // Find and navigate to this affirmation
                            final index = filteredAffirmations.indexOf(affirmation);
                            if (index != -1) {
                              setState(() {
                                currentAffirmationIndex = index;
                              });
                              _fadeController.reset();
                              _fadeController.forward();
                            }
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<Affirmation> _getAffirmationsData() {
    return [
      // Self-Love Affirmations
      Affirmation(
        id: '1',
        text: 'I am worthy of love and belonging exactly as I am',
        category: 'Self-Love',
        color: Colors.pink,
      ),
      Affirmation(
        id: '2',
        text: 'I treat myself with kindness and compassion',
        category: 'Self-Love',
        color: Colors.pink,
      ),
      Affirmation(
        id: '3',
        text: 'I accept and embrace all parts of myself',
        category: 'Self-Love',
        color: Colors.pink,
      ),

      // Confidence Affirmations
      Affirmation(
        id: '4',
        text: 'I believe in my abilities and trust my decisions',
        category: 'Confidence',
        color: Colors.orange,
      ),
      Affirmation(
        id: '5',
        text: 'I am confident in expressing my authentic self',
        category: 'Confidence',
        color: Colors.orange,
      ),
      Affirmation(
        id: '6',
        text: 'I speak with confidence and my voice matters',
        category: 'Confidence',
        color: Colors.orange,
      ),

      // Success Affirmations
      Affirmation(
        id: '7',
        text: 'I am capable of achieving my goals and dreams',
        category: 'Success',
        color: Colors.purple,
      ),
      Affirmation(
        id: '8',
        text: 'Every challenge is an opportunity for growth',
        category: 'Success',
        color: Colors.purple,
      ),
      Affirmation(
        id: '9',
        text: 'I attract success through my positive actions',
        category: 'Success',
        color: Colors.purple,
      ),

      // Health Affirmations
      Affirmation(
        id: '10',
        text: 'My body is strong, healthy, and full of energy',
        category: 'Health',
        color: Colors.green,
      ),
      Affirmation(
        id: '11',
        text: 'I nourish my body with healthy choices',
        category: 'Health',
        color: Colors.green,
      ),
      Affirmation(
        id: '12',
        text: 'I prioritize my mental and physical wellbeing',
        category: 'Health',
        color: Colors.green,
      ),

      // Relationships Affirmations
      Affirmation(
        id: '13',
        text: 'I build meaningful connections with others',
        category: 'Relationships',
        color: Colors.red,
      ),
      Affirmation(
        id: '14',
        text: 'I communicate with love and understanding',
        category: 'Relationships',
        color: Colors.red,
      ),
      Affirmation(
        id: '15',
        text: 'I attract positive and supportive relationships',
        category: 'Relationships',
        color: Colors.red,
      ),

      // Study Affirmations
      Affirmation(
        id: '16',
        text: 'I am a capable and dedicated student',
        category: 'Study',
        color: Colors.blue,
      ),
      Affirmation(
        id: '17',
        text: 'I absorb knowledge easily and retain information well',
        category: 'Study',
        color: Colors.blue,
      ),
      Affirmation(
        id: '18',
        text: 'I approach my studies with curiosity and enthusiasm',
        category: 'Study',
        color: Colors.blue,
      ),

      // Motivation Affirmations
      Affirmation(
        id: '19',
        text: 'I am motivated and driven to reach my potential',
        category: 'Motivation',
        color: Colors.deepOrange,
      ),
      Affirmation(
        id: '20',
        text: 'I take action towards my goals every day',
        category: 'Motivation',
        color: Colors.deepOrange,
      ),
      Affirmation(
        id: '21',
        text: 'I persist through challenges with determination',
        category: 'Motivation',
        color: Colors.deepOrange,
      ),

      // Peace Affirmations
      Affirmation(
        id: '22',
        text: 'I am at peace with myself and my circumstances',
        category: 'Peace',
        color: Colors.teal,
      ),
      Affirmation(
        id: '23',
        text: 'I release what I cannot control and focus on what I can',
        category: 'Peace',
        color: Colors.teal,
      ),
      Affirmation(
        id: '24',
        text: 'I breathe deeply and find calm in the present moment',
        category: 'Peace',
        color: Colors.teal,
      ),

      // Gratitude Affirmations
      Affirmation(
        id: '25',
        text: 'I am grateful for all the blessings in my life',
        category: 'Gratitude',
        color: Colors.amber,
      ),
      Affirmation(
        id: '26',
        text: 'I appreciate the small joys that surround me daily',
        category: 'Gratitude',
        color: Colors.amber,
      ),
      Affirmation(
        id: '27',
        text: 'Gratitude fills my heart and attracts more abundance',
        category: 'Gratitude',
        color: Colors.amber,
      ),
    ];
  }
}

class Affirmation {
  final String id;
  final String text;
  final String category;
  final Color color;

  Affirmation({
    required this.id,
    required this.text,
    required this.category,
    required this.color,
  });
}
