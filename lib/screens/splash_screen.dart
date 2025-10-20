import 'package:flutter/material.dart';
import 'package:redef_ai_main/core/supabase_config.dart';
import 'package:redef_ai_main/screens/home_screen.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    await Future.delayed(const Duration(seconds: 2));

    final user = SupabaseConfig.client.auth.currentUser;

    if (user != null) {
      // User is logged in → go to HomeScreen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } else {
      // User not logged in → show OnboardingScreen or LoginScreen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF06462C),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Redef AI',
                        style: TextStyle(
                          fontSize: 64,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'SourceSerif4',
                          letterSpacing: -1.5,
                          height: 1
                        ),
                      ),
                      Text(
                        'Get more done with your day',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.85),
                          fontWeight: FontWeight.w300,
                          fontFamily: 'Inter',
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 48.0),
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
