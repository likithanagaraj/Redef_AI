import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      home: SafeArea(child: Scaffold(body: RedefScreen())),
    ),
  );
}

class RedefScreen extends StatefulWidget {
  const RedefScreen({super.key});

  @override
  State<RedefScreen> createState() => _RedefScreenState();
}

class _RedefScreenState extends State<RedefScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/surreal-hourglass.png',
            height: 180,
            fit: BoxFit.contain,
          ),
          Text('Coming Soon',style: TextStyle(
            fontFamily: 'SourceSerif4',
            fontSize: 18,
            letterSpacing: -0.5,
            fontWeight: FontWeight.w500
          ),)
        ],
      ),
    );
  }
}
