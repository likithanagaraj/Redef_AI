import 'package:flutter/material.dart';
import 'package:redef_ai_main/Theme.dart';
import 'package:redef_ai_main/screens/signup_screen.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentIndex = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': 'Redef.ai',
      'image': 'assets/images/clippath.png',
      'subtitle': 'Get more done in a day than your friends do in a week',
    },
    {
      'title': 'Time Management',
      'image': 'assets/images/surreal-hourglass.png',
      'subtitle': 'Track your days and get the right insights to improve',

    },
  ];

  void _nextPage() {
    if (_currentIndex < _pages.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SignupScreen()),
      );
    }
  }

  void _previousPage() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentIndex];
    final isLastPage = _currentIndex == _pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              // Header with back button and progress indicator
              _buildHeader(page),

              // Main content
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Image
                    Image.asset(
                      page['image']!,
                      height: 250,
                      fit: BoxFit.contain,
                    ),

                    const SizedBox(height: 32),

                    // Subtitle
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        page['subtitle']!,
                        style: const TextStyle(
                          fontSize: 20,
                          letterSpacing: -0.5,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    style: TextStyle(
                      color: AppColors.white,
                      height: 0,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    isLastPage ? 'Get Started' : 'Next',
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Map<String, String> page) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Back button (only show if not first page)
        SizedBox(
          width: 40,
          height: 40,
          child: _currentIndex > 0
              ? IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: _previousPage,
            padding: EdgeInsets.zero,
          )
              : const SizedBox.shrink(),
        ),

        // Progress indicator
        Expanded(
          child: Center(
            child: Text('Redef AI')
          ),
        ),

        // Spacer to balance the back button
        const SizedBox(width: 40),
      ],
    );
  }
}


// Image.asset(
// page['progress']!,
// height: 18,
// fit: BoxFit.contain,
// ),