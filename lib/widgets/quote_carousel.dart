import 'dart:async';
import 'package:flutter/material.dart';
import 'package:redef_ai_main/Theme.dart';

class QuoteCarousel extends StatefulWidget {
  const QuoteCarousel({super.key});

  @override
  State<QuoteCarousel> createState() => _QuoteCarouselState();
}

class _QuoteCarouselState extends State<QuoteCarousel> {
  int _currentIndex = 0;
  Timer? _timer;

  final List<String> _quotes = [
    '“If your dreams don\'t scare you, they\'re too small.”',
    '“The only way to do great work is to love what you do.”',
    '“Success is not final, failure is not fatal: it is the courage to continue that counts.”',
    '“Don\'t watch the clock; do what it does. Keep going.”',
    '“The future belongs to those who believe in the beauty of their dreams.”',
    '“Believe you can and you\'re halfway there.”',
  ];


  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % _quotes.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        color: AppColors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          child: Text(
            _quotes[_currentIndex],
            key: ValueKey<int>(_currentIndex),
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w400,
              fontFamily: 'SourceSerif4',
              letterSpacing: -1.2,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
