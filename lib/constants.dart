import 'package:flutter/material.dart';

const scaffoldBg = Color(0xff010101);
const cardColor = Color(0xff1A1A1A);
const textColor = Color(0xffFFFFFF);
const cta = Color(0xffC4342E);

// Typography Tokens
const TextStyle kTitleStyle = TextStyle(fontFamily: "ndot", fontSize: 32, color: textColor, height: 1.0);
const TextStyle kSubtitleStyle = TextStyle(fontFamily: "ndot", fontSize: 16, color: textColor);
const TextStyle kBodyStyle = TextStyle(fontFamily: "TTNormsPro", fontSize: 14, color: textColor);
const TextStyle kSmallBodyStyle = TextStyle(fontFamily: "TTNormsPro", fontSize: 12, color: textColor);
const TextStyle kCaptionStyle = TextStyle(fontFamily: "TTNormsPro", fontSize: 10, color: textColor);
const TextStyle kButtonTextStyle = TextStyle(fontFamily: "ndot", fontSize: 14, color: textColor);
const TextStyle kBottomSheetTitleStyle = TextStyle(fontFamily: "TTNormsPro", fontSize: 24, fontWeight: FontWeight.w600, color: scaffoldBg);
const TextStyle kBottomSheetLabelStyle = TextStyle(fontFamily: "TTNormsPro", fontSize: 14, color: scaffoldBg);
const TextStyle kBottomSheetInputStyle = TextStyle(fontFamily: "TTNormsPro", color: scaffoldBg);
const TextStyle kBottomSheetHintStyle = TextStyle(fontFamily: "TTNormsPro", color: Colors.white30);
// Supabase Config
const String kSupabaseUrl = 'https://lprinhfwtfsfrbnpbkme.supabase.co';
const String kSupabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxwcmluaGZ3dGZzZnJibnBia21lIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ3NzgwNTcsImV4cCI6MjA5MDM1NDA1N30.q6ShzVruzc2uKMEXuAutBL4WVsOngzhxehHnVmUahnw';