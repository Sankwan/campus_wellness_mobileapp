import 'package:flutter/material.dart';
import 'dart:math';
import '../theme.dart';
import '../widgets/toast.dart';

class SupportiveMessagesService {
  // Messages specifically for Ho Technical University students
  static const List<String> _negativeMoodMessages = [
    "Hey HTU warrior! 🎓 Remember that tough days don't define you - your resilience does. Take a deep breath and know that this feeling will pass.",
    
    "Dear HTU student 📚, even the brightest engineers have cloudy days. Your potential is limitless, and this moment doesn't diminish your worth.",
    
    "Fellow HTU scholar 🌟, it's okay to feel down sometimes. Your technical mind is strong, and you have the tools to work through this challenge.",
    
    "HTU champion 💪, remember that every great innovation started with someone who felt uncertain. You're building something amazing - including yourself.",
    
    "Brilliant HTU mind 🧠, your feelings are valid and temporary. Just like debugging code, working through emotions takes patience and skill - you've got both!",
    
    "Future HTU graduate 🎯, setbacks are setups for comebacks. Your journey in tech is preparing you for greatness - including handling tough moments like these.",
    
    "HTU innovator 🚀, even rockets need fuel checks before launch. Take time to refuel your spirit - your dreams are waiting for you.",
    
    "Talented HTU student 🔧, you solve complex problems daily. This emotional challenge is just another puzzle you'll master with time and self-care.",
    
    "HTU trailblazer 🌈, storms make trees grow deeper roots. This difficult moment is helping you build inner strength for your bright future.",
    
    "Dear HTU family member 🏠, you're not alone in this journey. Your campus community believes in you, and tomorrow brings new possibilities.",
    
    "HTU change-maker 🌍, the world needs your unique talents. Rest today, but remember that your contributions matter more than you know.",
    
    "Aspiring HTU professional 💼, every expert was once a beginner who felt overwhelmed. You're exactly where you need to be in your growth journey.",
  ];

  static const List<String> _encouragingTips = [
    "💡 Try the 4-7-8 breathing technique: Breathe in for 4, hold for 7, exhale for 8.",
    "🌱 Consider journaling your thoughts - HTU students often find writing helps organize complex feelings.",
    "🎵 Listen to your favorite study playlist - familiar melodies can be comforting.",
    "🚶‍♂️ Take a short walk around the HTU campus - fresh air and movement can shift your perspective.",
    "📞 Reach out to a classmate or friend - connection is powerful medicine.",
    "🧘‍♀️ Try a 5-minute meditation using our guided sessions in the app.",
    "☕ Make yourself a warm drink and practice mindful sipping.",
    "📖 Read something inspiring - maybe a success story from an HTU alumnus.",
    "🎨 Engage in a creative activity - doodling, sketching, or coding something fun.",
    "💫 Practice gratitude by listing 3 things you appreciate about your HTU experience today.",
  ];

  static void showSupportiveMessage(BuildContext context, int moodRating) {
    // Only show supportive messages for negative moods (rating 1-2)
    if (moodRating > 2) return;

    final random = Random();
    final message = _negativeMoodMessages[random.nextInt(_negativeMoodMessages.length)];
    final tip = _encouragingTips[random.nextInt(_encouragingTips.length)];

    // Show initial supportive message
    ToastService.showCustom(
      context: context,
      child: _buildSupportiveToast(context, message, moodRating),
      duration: const Duration(seconds: 6),
    );

    // Show helpful tip after a delay
    Future.delayed(const Duration(seconds: 7), () {
      if (context.mounted) {
        ToastService.showCustom(
          context: context,
          child: _buildTipToast(context, tip),
          duration: const Duration(seconds: 5),
        );
      }
    });
  }

  static Widget _buildSupportiveToast(BuildContext context, String message, int moodRating) {
    Color backgroundColor;
    IconData icon;
    
    switch (moodRating) {
      case 1:
        backgroundColor = Colors.red.shade50;
        icon = Icons.favorite;
        break;
      case 2:
        backgroundColor = Colors.orange.shade50;
        icon = Icons.support_agent;
        break;
      default:
        backgroundColor = AppTheme.lightGreen.withOpacity(0.1);
        icon = Icons.psychology;
    }

    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryGreen.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryGreen,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HTU Wellness Support 💚',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildTipToast(BuildContext context, String tip) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryGreen.withOpacity(0.05),
            AppTheme.lightGreen.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightGreen.withOpacity(0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.lightGreen.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lightbulb_outline,
              color: AppTheme.primaryGreen,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Helpful Tip for HTU Students',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  tip,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.3,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Crisis support resources specifically for HTU
  static void showCrisisSupport(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.health_and_safety,
              color: Colors.red.shade600,
            ),
            const SizedBox(width: 8),
            const Text('HTU Support Resources'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'If you\'re in crisis or need immediate support:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildSupportResource(
              'HTU Counseling Center',
              'Available Mon-Fri, 8AM-5PM',
              Icons.psychology,
            ),
            const SizedBox(height: 8),
            _buildSupportResource(
              'National Suicide Prevention',
              'Call 988 - Available 24/7',
              Icons.phone,
            ),
            const SizedBox(height: 8),
            _buildSupportResource(
              'Crisis Text Line',
              'Text HOME to 741741',
              Icons.message,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Remember: Seeking help is a sign of strength, not weakness. Your HTU community cares about you.',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Thank you',
              style: TextStyle(color: AppTheme.primaryGreen),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildSupportResource(String title, String subtitle, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.red.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
