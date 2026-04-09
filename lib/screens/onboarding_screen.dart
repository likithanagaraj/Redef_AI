import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants.dart';
import '../design_tokens.dart';
import '../services/isar_service.dart';
import 'main_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  final IsarService _isarService = IsarService();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage == 0) {
      _pageController.animateToPage(
        1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  Future<void> _finishOnboarding() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter your name"),
          backgroundColor: cta,
        ),
      );
      return;
    }

    try {
      await _isarService.createUser(name);
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint("Error during onboarding: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildFirstPage(),
            _buildSecondPage(),
          ],
        ),
      ),
    );
  }

  Widget _buildFirstPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
      child: Column(
        children: [
          Text(
            "PRODUCTIVITY · REIMAGINED",
            style: kBodyStyle.copyWith(
              fontSize: 10,
              letterSpacing: 2,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "REDEFINE HOW\nYOU WORK.",
            textAlign: TextAlign.center,
            style: kTitleStyle.copyWith(fontSize: 28, height: 1.1),
          ),
          const Spacer(),
          Hero(
            tag: 'onboarding_image',
            child: Image.asset(
              "assets/images/onboardingimage.png",
              width: MediaQuery.of(context).size.width * 0.8,
              fit: BoxFit.contain,
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              "Just speak. we’ll handle your tasks, habits, and focus.",
              textAlign: TextAlign.center,
              style: kBodyStyle.copyWith(
                fontSize: 18,
                height: 1.4,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ),
          const SizedBox(height: 32),
          _buildButton("Continue", _nextPage),
        ],
      ),
    );
  }

  Widget _buildSecondPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 28),
          Text(
            "WHAT SHOULD WE CALL YOU?",
            style: kTitleStyle.copyWith(fontSize: 24, height: 0),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _nameController,
            autofocus: true,
            style: kBodyStyle.copyWith(fontSize: 18),
            cursorColor: cta,
            decoration: InputDecoration(
              hintText: "Enter Your Name",
              hintStyle: kBodyStyle.copyWith(color: Colors.white30, fontSize: 18),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white10),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: cta),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            onSubmitted: (_) => _finishOnboarding(),
          ),
          const SizedBox(height: 24),
          _buildButton("Get Started", _finishOnboarding),
        ],
      ),
    );
  }



  Widget _buildButton(String text, VoidCallback onPressed, {String? icon}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: 56, // Same as app's creation buttons
        decoration: BoxDecoration(
          color: cta,
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: kButtonTextStyle.copyWith(fontSize: 14),
            ),
            if (icon != null) ...[
              const SizedBox(width: Spacing.sm),
              SvgPicture.asset(
                "assets/icons/$icon",
                width: 20,
                height: 20,
                colorFilter: const ColorFilter.mode(textColor, BlendMode.srcIn),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

