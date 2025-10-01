import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../models/role.dart';
import 'home_screen.dart';
import 'admin_dashboard_screen.dart';
import 'buyer_dashboard_screen.dart';
import '../widgets/step_progress.dart';

class OTPScreen extends StatefulWidget {
  static const String routeName = '/otp';
  const OTPScreen({super.key});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final TextEditingController _codeController = TextEditingController();
  Map<String, dynamic>? _args;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mode = _args?['mode'] as String?;
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if ((ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?)?['role'] != 'buyer')
              const StepProgress(currentStep: 2, totalSteps: 5, labels: ['Register', 'OTP', 'Map', 'Process', 'Result']),
            const SizedBox(height: 16),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '6-digit Code', hintText: 'कोड / Code'),
              maxLength: 6,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
              onPressed: () async {
                final code = _codeController.text.trim();
                if (code.length != 6) return;
                final auth = context.read<AuthProvider>();
                bool ok = false;
                if (mode == 'register') {
                  final name = _args?['name'] as String? ?? '';
                  final address = _args?['address'] as String? ?? '';
                  ok = await auth.verifyOtpAndCreateUser(code: code, name: name, address: address);
                } else if (mode == 'admin') {
                  final mobile = _args?['mobile'] as String? ?? '';
                  ok = await auth.loginAdminWithOtp(mobile: mobile, code: code);
                }
                if (!mounted) return;
                if (ok) {
                  final user = context.read<AuthProvider>().currentUser;
                  String routeName;
                  if (user?.role == UserRole.admin) {
                    routeName = AdminDashboardScreen.routeName;
                  } else if (user?.role == UserRole.buyer) {
                    routeName = BuyerDashboardScreen.routeName;
                  } else {
                    routeName = HomeScreen.routeName;
                  }
                  Navigator.of(context).pushNamedAndRemoveUntil(routeName, (_) => false);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid code')));
                }
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text('Verify / सत्यापित करें', style: TextStyle(fontSize: 16)),
              ),
            ),
            )
          ],
        ),
      ),
    );
  }
}


