import 'package:flutter/material.dart';

// ---------------- Colors ----------------
class AppColors {
  static const primary = Color(0xFF59B74F);
  static const secondary = Color(0xFF014E3C);
  static const white = Color(0xffFDFBF9); // TODO : change the variable name
  static const black = Colors.black;
  static const background = Color(0xFFF1EDE7);
}

// ---------------- Fonts ----------------
class AppFonts {
  static const primaryFont = 'SourceSerif4';
  static const seconderFont = 'Inter';

  static TextStyle heading1 = const TextStyle(
    fontFamily: primaryFont,
    fontSize: 40,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
  );

  static TextStyle heading2 = const TextStyle(
    fontFamily: seconderFont,
    fontSize: 26,
    fontWeight: FontWeight.w500,
    color: AppColors.black,
  );

  static TextStyle button = const TextStyle(
    fontFamily: seconderFont,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
  );

  static TextStyle body = const TextStyle(
    fontFamily: seconderFont,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
  );
}

// ---------------- Spacing ----------------
class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 40.0;
}












//
//
//
//
// import 'package:flutter/material.dart';
//
// // ============================================================================
// // COLOR SYSTEM - Semantic & Scalable
// // ============================================================================
// class AppColors {
//   // Brand Colors
//   static const primary = Color(0xFF59B74F);
//   static const primaryLight = Color(0xFF7BC96F);
//   static const primaryDark = Color(0xFF3A8A32);
//
//   static const secondary = Color(0xFF014E3C);
//   static const secondaryLight = Color(0xFF026B52);
//   static const secondaryDark = Color(0xFF003828);
//
//   // Neutral Colors (Better naming than "white/black")
//   static const background = Color(0xFFF1EDE7);
//   static const card = Color(0xFFFFFFFF);
//   static const cardVariant = Color(0xFFF5F5F5);
//
//   // Text Colors (Semantic naming)
//   static const textPrimary = Color(0xFF1A1A1A);
//   static const textSecondary = Color(0xFF666666);
//   static const textTertiary = Color(0xFF999999);
//   static const textInverse = Color(0xFFFFFFFF);
//
//   // State Colors
//   static const error = Color(0xFFDC2626);
//   static const success = Color(0xFF16A34A);
//   static const warning = Color(0xFFF59E0B);
//   static const info = Color(0xFF3B82F6);
//
//   // Border & Divider
//   static const border = Color(0xFFE5E5E5);
//   static const divider = Color(0xFFEEEEEE);
//
//   // Disabled States
//   static const disabled = Color(0xFFCCCCCC);
//   static const disabledBackground = Color(0xFFF5F5F5);
// }
//
// // ============================================================================
// // TYPOGRAPHY SYSTEM - Clear Hierarchy
// // ============================================================================
// class AppTypography {
//   // Font Families
//   static const String serif = 'SourceSerif4';
//   static const String sans = 'Inter';
//
//   // Display Styles (Large headings - Use SourceSerif4 for elegance)
//   static const displayLarge = TextStyle(
//     fontFamily: serif,
//     fontSize: 48,
//     fontWeight: FontWeight.w700,
//     height: 1.2,
//     letterSpacing: -0.5,
//   );
//
//   static const displayMedium = TextStyle(
//     fontFamily: serif,
//     fontSize: 40,
//     fontWeight: FontWeight.w600,
//     height: 1.2,
//     letterSpacing: -0.5,
//   );
//
//   static const displaySmall = TextStyle(
//     fontFamily: serif,
//     fontSize: 32,
//     fontWeight: FontWeight.w600,
//     height: 1.25,
//   );
//
//   // Headings (Use SourceSerif4 for content hierarchy)
//   static const headingLarge = TextStyle(
//     fontFamily: serif,
//     fontSize: 28,
//     fontWeight: FontWeight.w600,
//     height: 1.3,
//   );
//
//   static const headingMedium = TextStyle(
//     fontFamily: serif,
//     fontSize: 24,
//     fontWeight: FontWeight.w600,
//     height: 1.3,
//   );
//
//   static const headingSmall = TextStyle(
//     fontFamily: serif,
//     fontSize: 20,
//     fontWeight: FontWeight.w600,
//     height: 1.4,
//   );
//
//   // Body Text (Use Inter for readability)
//   static const bodyLarge = TextStyle(
//     fontFamily: sans,
//     fontSize: 18,
//     fontWeight: FontWeight.w400,
//     height: 1.6,
//     letterSpacing: 0.15,
//   );
//
//   static const bodyMedium = TextStyle(
//     fontFamily: sans,
//     fontSize: 16,
//     fontWeight: FontWeight.w400,
//     height: 1.5,
//     letterSpacing: 0.15,
//   );
//
//   static const bodySmall = TextStyle(
//     fontFamily: sans,
//     fontSize: 14,
//     fontWeight: FontWeight.w400,
//     height: 1.5,
//     letterSpacing: 0.1,
//   );
//
//   // Labels & UI Elements (Use Inter for UI clarity)
//   static const labelLarge = TextStyle(
//     fontFamily: sans,
//     fontSize: 16,
//     fontWeight: FontWeight.w400,
//     height: 1.4,
//     letterSpacing: 0.1,
//   );
//
//   static const labelMedium = TextStyle(
//     fontFamily: sans,
//     fontSize: 14,
//     fontWeight: FontWeight.w600,
//     height: 1.4,
//     letterSpacing: 0.1,
//   );
//
//   static const labelSmall = TextStyle(
//     fontFamily: sans,
//     fontSize: 12,
//     fontWeight: FontWeight.w600,
//     height: 1.4,
//     letterSpacing: 0.5,
//   );
//
//   // Button Text (Use Inter for interactive elements)
//   static const buttonLarge = TextStyle(
//     fontFamily: sans,
//     fontSize: 18,
//     fontWeight: FontWeight.w700,
//     height: 1.2,
//     letterSpacing: 0.5,
//   );
//
//   static const buttonMedium = TextStyle(
//     fontFamily: sans,
//     fontSize: 16,
//     fontWeight: FontWeight.w700,
//     height: 1.2,
//     letterSpacing: 0.5,
//   );
//
//   static const buttonSmall = TextStyle(
//     fontFamily: sans,
//     fontSize: 14,
//     fontWeight: FontWeight.w600,
//     height: 1.2,
//     letterSpacing: 0.5,
//   );
//
//   // Caption & Helper Text
//   static const caption = TextStyle(
//     fontFamily: sans,
//     fontSize: 12,
//     fontWeight: FontWeight.w400,
//     height: 1.4,
//     letterSpacing: 0.4,
//   );
//
//   static const overline = TextStyle(
//     fontFamily: sans,
//     fontSize: 10,
//     fontWeight: FontWeight.w600,
//     height: 1.4,
//     letterSpacing: 1.5,
//   );
// }
//
// // ============================================================================
// // SPACING SYSTEM - 8pt Grid
// // ============================================================================
// class AppSpacing {
//   static const double xxs = 2.0;
//   static const double xs = 4.0;
//   static const double sm = 8.0;
//   static const double md = 16.0;
//   static const double lg = 24.0;
//   static const double xl = 32.0;
//   static const double xxl = 40.0;
//   static const double xxxl = 48.0;
//
//   // Named Spacing for specific use cases
//   static const double buttonPaddingVertical = 16.0;
//   static const double buttonPaddingHorizontal = 24.0;
//   static const double cardPadding = 16.0;
//   static const double screenPadding = 20.0;
//   static const double sectionSpacing = 32.0;
// }
//
// // ============================================================================
// // BORDER RADIUS SYSTEM
// // ============================================================================
// class AppRadius {
//   static const double none = 0.0;
//   static const double xs = 4.0;
//   static const double sm = 8.0;
//   static const double md = 12.0;
//   static const double lg = 16.0;
//   static const double xl = 24.0;
//   static const double full = 9999.0;
//
//   // Named Radius
//   static const BorderRadius button = BorderRadius.all(Radius.circular(md));
//   static const BorderRadius card = BorderRadius.all(Radius.circular(lg));
//   static const BorderRadius input = BorderRadius.all(Radius.circular(sm));
//   static const BorderRadius dialog = BorderRadius.all(Radius.circular(xl));
// }
//
// // ============================================================================
// // ELEVATION/SHADOW SYSTEM
// // ============================================================================
// class AppShadows {
//   static const shadow1 = [
//     BoxShadow(
//       color: Color(0x0A000000),
//       offset: Offset(0, 1),
//       blurRadius: 2,
//     ),
//   ];
//
//   static const shadow2 = [
//     BoxShadow(
//       color: Color(0x0D000000),
//       offset: Offset(0, 2),
//       blurRadius: 4,
//     ),
//   ];
//
//   static const shadow3 = [
//     BoxShadow(
//       color: Color(0x14000000),
//       offset: Offset(0, 4),
//       blurRadius: 8,
//     ),
//   ];
//
//   static const shadow4 = [
//     BoxShadow(
//       color: Color(0x1F000000),
//       offset: Offset(0, 8),
//       blurRadius: 16,
//     ),
//   ];
// }
//
// // ============================================================================
// // THEME DATA - Apply to MaterialApp
// // ============================================================================
// class AppTheme {
//   static ThemeData get lightTheme {
//     return ThemeData(
//       useMaterial3: true,
//
//       // Color Scheme
//       colorScheme: const ColorScheme.light(
//         primary: AppColors.primary,
//         secondary: AppColors.secondary,
//         surface: AppColors.card,
//         error: AppColors.error,
//         onPrimary: AppColors.textInverse,
//         onSecondary: AppColors.textInverse,
//         onSurface: AppColors.textPrimary,
//       ),
//
//       scaffoldBackgroundColor: AppColors.background,
//
//       // Typography
//       textTheme: TextTheme(
//         displayLarge: AppTypography.displayLarge.copyWith(color: AppColors.textPrimary),
//         displayMedium: AppTypography.displayMedium.copyWith(color: AppColors.textPrimary),
//         displaySmall: AppTypography.displaySmall.copyWith(color: AppColors.textPrimary),
//         headlineLarge: AppTypography.headingLarge.copyWith(color: AppColors.textPrimary),
//         headlineMedium: AppTypography.headingMedium.copyWith(color: AppColors.textPrimary),
//         headlineSmall: AppTypography.headingSmall.copyWith(color: AppColors.textPrimary),
//         bodyLarge: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
//         bodyMedium: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
//         bodySmall: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
//         labelLarge: AppTypography.labelLarge.copyWith(color: AppColors.textPrimary),
//         labelMedium: AppTypography.labelMedium.copyWith(color: AppColors.textPrimary),
//         labelSmall: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
//       ),
//
//       // App Bar
//       appBarTheme: AppBarTheme(
//         backgroundColor: AppColors.card,
//         foregroundColor: AppColors.textPrimary,
//         elevation: 0,
//         centerTitle: false,
//         titleTextStyle: AppTypography.headingMedium.copyWith(color: AppColors.textPrimary),
//       ),
//
//       // Card
//       cardTheme: CardThemeData(
//         color: AppColors.card,
//         elevation: 0,
//         shape: RoundedRectangleBorder(
//           borderRadius: AppRadius.card,
//           side: const BorderSide(color: AppColors.border, width: 1),
//         ),
//       ),
//
//
//       // Elevated Button
//       elevatedButtonTheme: ElevatedButtonThemeData(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: AppColors.primary,
//           foregroundColor: AppColors.textInverse,
//           padding: const EdgeInsets.symmetric(
//             horizontal: AppSpacing.buttonPaddingHorizontal,
//             vertical: AppSpacing.buttonPaddingVertical,
//           ),
//           shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
//           textStyle: AppTypography.buttonMedium,
//           elevation: 0,
//         ),
//       ),
//
//       // Text Button
//       textButtonTheme: TextButtonThemeData(
//         style: TextButton.styleFrom(
//           foregroundColor: AppColors.primary,
//           textStyle: AppTypography.buttonMedium,
//         ),
//       ),
//
//       // Input Decoration
//       inputDecorationTheme: InputDecorationTheme(
//         filled: true,
//         fillColor: AppColors.card,
//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: AppSpacing.md,
//           vertical: AppSpacing.md,
//         ),
//         border: OutlineInputBorder(
//           borderRadius: AppRadius.input,
//           borderSide: const BorderSide(color: AppColors.border),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: AppRadius.input,
//           borderSide: const BorderSide(color: AppColors.border),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: AppRadius.input,
//           borderSide: const BorderSide(color: AppColors.primary, width: 2),
//         ),
//         errorBorder: OutlineInputBorder(
//           borderRadius: AppRadius.input,
//           borderSide: const BorderSide(color: AppColors.error),
//         ),
//         labelStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
//         hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary),
//       ),
//     );
//   }
// }