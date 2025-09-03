import 'package:flutter/material.dart';
import 'onboarding_page.dart';

class ReasonPage extends StatefulWidget {
  const ReasonPage({super.key});

  @override
  State<ReasonPage> createState() => _ReasonPageState();
}

class _ReasonPageState extends State<ReasonPage>
    with SingleTickerProviderStateMixin {
  final List<String> reasons = const [
    'Stress Management',
    'Mood Tracking',
    'Academic Pressure',
    'Social Anxiety',
    'Emotional Support',
  ];

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onReasonTap(int index) async {
    setState(() => _selectedIndex = index);
    await _animationController.forward();
    await _animationController.reverse();
    Navigator.of(context).push(_createRoute());
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const OnboardingPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeInOut;
        var fadeTween =
            Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve));
        var scaleTween =
            Tween(begin: 0.9, end: 1.0).chain(CurveTween(curve: curve));
        return FadeTransition(
          opacity: animation.drive(fadeTween),
          child: ScaleTransition(
            scale: animation.drive(scaleTween),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 500),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 4,
        centerTitle: true,
        title: const Text(
          'Select Your Reason',
          style: TextStyle(
            color: Color(0xFF56AB2F),
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 1,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView.builder(
          itemCount: reasons.length,
          itemBuilder: (context, index) {
            bool isSelected = _selectedIndex == index;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _onReasonTap(index),
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      double scale = isSelected ? _scaleAnimation.value : 1.0;
                      return Transform.scale(
                        scale: scale,
                        child: child,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            color: Color(0xFF56AB2F),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Text(
                              reasons[index],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: Color(0xFF56AB2F),
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
