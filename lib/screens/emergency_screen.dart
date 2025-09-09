import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../theme.dart';
import '../widgets/toast.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final List<EmergencyContact> emergencyContacts = [
    EmergencyContact(
      title: 'HTU Campus Security',
      subtitle: 'Available 24/7 for campus emergencies',
      phone: '024 339 9246',
      icon: Icons.security,
      color: Colors.blue,
      priority: 1,
    ),
    EmergencyContact(
      title: 'HTU Counseling Center',
      subtitle: 'Professional mental health support',
      phone: '024 339 9246',
      icon: Icons.psychology,
      color: AppTheme.primaryGreen,
      priority: 1,
    ),
    // EmergencyContact(
    //   title: 'Jordan Crisis Helpline',
    //   subtitle: 'National 24/7 crisis support',
    //   phone: '110',
    //   icon: Icons.support_agent,
    //   color: Colors.orange,
    //   priority: 2,
    // ),
    EmergencyContact(
      title: 'National Emergency',
      subtitle: 'Police, Fire, Medical Emergency',
      phone: '191',
      icon: Icons.local_hospital,
      color: Colors.red,
      priority: 3,
    ),
    EmergencyContact(
      title: 'National Suicide Prevention',
      subtitle: 'Confidential support for mental health crises',
      phone: '024 339 9246',
      icon: Icons.favorite,
      color: Colors.purple,
      priority: 2,
    ),
  ];

  final List<CrisisResource> crisisResources = [
    CrisisResource(
      title: 'Immediate Safety',
      description: 'If you are in immediate danger, call emergency services immediately',
      actions: ['Call Campus Security, describe your issue', 'Find a safe location', 'Contact someone you trust'],
      icon: Icons.shield,
      color: Colors.red,
    ),
    CrisisResource(
      title: 'Feeling Overwhelmed?',
      description: 'Take these steps to ground yourself',
      actions: [
        'Take 5 deep breaths',
        'Name 5 things you can see',
        'Name 4 things you can touch',
        'Name 3 things you can hear',
        'Call a friend or counselor'
      ],
      icon: Icons.self_improvement,
      color: AppTheme.primaryGreen,
    ),
    CrisisResource(
      title: 'Suicidal Thoughts?',
      description: 'You are not alone. Help is available right now',
      actions: [
        'Call crisis helpline immediately',
        'Go to nearest emergency room',
        'Remove means of self-harm',
        'Stay with someone you trust'
      ],
      icon: Icons.healing,
      color: Colors.purple,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 120.0,
              floating: false,
              pinned: true,
              backgroundColor: Colors.red.shade600,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'Emergency Resources',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.red.shade600,
                        Colors.red.shade800,
                      ],
                    ),
                  ),
                  child: const Center(
                    // child: Icon(
                    //   Icons.emergency,
                    //   size: 40,
                    //   color: Colors.white,
                    // ),
                  ),
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),

            // Emergency Banner
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.red.shade100,
                      Colors.red.shade50,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.shade300),
                ),
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Icon(
                            Icons.emergency,
                            size: 40,
                            color: Colors.red.shade600,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '🚨 Crisis Support Available 24/7',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'HTU cares about your wellbeing. If you\'re experiencing a crisis, help is immediately available.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.red.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            // Emergency Contacts
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Emergency Contacts',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final contact = emergencyContacts[index];
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 600),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: _buildEmergencyContactCard(contact, theme),
                        ),
                      ),
                    );
                  },
                  childCount: emergencyContacts.length,
                ),
              ),
            ),

            // Crisis Resources
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      'Crisis Support Resources',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final resource = crisisResources[index];
                    return AnimationConfiguration.staggeredList(
                      position: index + emergencyContacts.length,
                      duration: const Duration(milliseconds: 600),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: _buildCrisisResourceCard(resource, theme),
                        ),
                      ),
                    );
                  },
                  childCount: crisisResources.length,
                ),
              ),
            ),

            // Additional Resources
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppTheme.primaryGreen,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Additional Resources',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildResourceItem('HTU Student Affairs Office', 'Building A, Room 101'),
                    _buildResourceItem('Health Center', 'Building B, Ground Floor'),
                    _buildResourceItem('Academic Advisors', 'Available during office hours'),
                    _buildResourceItem('Peer Support Groups', 'Check student portal for schedules'),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyContactCard(EmergencyContact contact, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: contact.color.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: contact.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  contact.icon,
                  color: contact.color,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      contact.subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.phone,
                          color: contact.color,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          contact.phone,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: contact.color,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    onPressed: () => _makePhoneCall(contact.phone),
                    icon: Icon(
                      Icons.phone,
                      color: contact.color,
                      size: 28,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: contact.color.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  IconButton(
                    onPressed: () => _copyPhoneNumber(contact.phone),
                    icon: const Icon(
                      Icons.copy,
                      color: Colors.grey,
                      size: 20,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey.withOpacity(0.1),
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
    );
  }

  Widget _buildCrisisResourceCard(CrisisResource resource, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: resource.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      resource.icon,
                      color: resource.color,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          resource.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: resource.color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          resource.description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...resource.actions.map((action) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: resource.color.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: resource.color.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: resource.color,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        action,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResourceItem(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        _showErrorMessage('Cannot make phone calls on this device');
      }
    } catch (e) {
      _showErrorMessage('Failed to make phone call');
    }
  }

  Future<void> _copyPhoneNumber(String phoneNumber) async {
    await Clipboard.setData(ClipboardData(text: phoneNumber));
    if (mounted) {
      ToastService.showSuccess(
        context: context,
        title: 'Copied!',
        description: 'Phone number copied to clipboard',
      );
    }
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ToastService.showError(
        context: context,
        title: 'Error',
        description: message,
      );
    }
  }
}

class EmergencyContact {
  final String title;
  final String subtitle;
  final String phone;
  final IconData icon;
  final Color color;
  final int priority; // 1 = highest priority

  EmergencyContact({
    required this.title,
    required this.subtitle,
    required this.phone,
    required this.icon,
    required this.color,
    required this.priority,
  });
}

class CrisisResource {
  final String title;
  final String description;
  final List<String> actions;
  final IconData icon;
  final Color color;

  CrisisResource({
    required this.title,
    required this.description,
    required this.actions,
    required this.icon,
    required this.color,
  });
}
