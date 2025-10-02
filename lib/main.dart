import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/map_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/register_screen.dart';
import 'screens/satellite_processing_screen.dart';
import 'screens/ai_results_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/buyer_dashboard_screen.dart';
import 'services/land_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LandService.instance),
      ],
      child: MaterialApp(
        title: 'Oceara',
      theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF87CEEB), // Light Sky Blue
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xFFF0F8FF), // Alice Blue
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF87CEEB), // Light Sky Blue
            foregroundColor: Colors.white,
            elevation: 2,
            centerTitle: true,
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 4,
            shadowColor: Colors.black26,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4682B4), // Steel Blue
              foregroundColor: Colors.white,
              elevation: 3,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          textTheme: const TextTheme(
            displayLarge: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50), // Dark Blue Gray
            ),
            displayMedium: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
            displaySmall: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
            headlineLarge: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Color(0xFF34495E), // Darker Blue Gray
            ),
            headlineMedium: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF34495E),
            ),
            headlineSmall: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF34495E),
            ),
            titleLarge: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
            titleMedium: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF34495E),
            ),
            titleSmall: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF34495E),
            ),
            bodyLarge: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: Color(0xFF2C3E50),
            ),
            bodyMedium: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: Color(0xFF34495E),
            ),
            bodySmall: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: Color(0xFF7F8C8D), // Light Gray
            ),
            labelLarge: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2C3E50),
            ),
            labelMedium: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF34495E),
            ),
            labelSmall: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Color(0xFF7F8C8D),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF87CEEB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF87CEEB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF4682B4), width: 2),
            ),
            labelStyle: const TextStyle(
              color: Color(0xFF34495E),
              fontSize: 14,
            ),
            hintStyle: const TextStyle(
              color: Color(0xFF7F8C8D),
              fontSize: 14,
            ),
          ),
        ),
        initialRoute: LoginScreen.routeName,
        routes: {
          LoginScreen.routeName: (_) => const LoginScreen(),
          RegisterScreen.routeName: (_) => const RegisterScreen(),
          OTPScreen.routeName: (_) => const OTPScreen(),
          HomeScreen.routeName: (_) => const HomeScreen(),
          MapScreen.routeName: (_) => const MapScreen(),
          SatelliteProcessingScreen.routeName: (_) => const SatelliteProcessingScreen(),
          AIResultsScreen.routeName: (_) => const AIResultsScreen(),
          AdminDashboardScreen.routeName: (_) => const AdminDashboardScreen(),
          BuyerDashboardScreen.routeName: (_) => const BuyerDashboardScreen(),
        },
      ),
    );
  }
}
 
