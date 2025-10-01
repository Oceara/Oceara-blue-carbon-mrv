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
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
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
 
