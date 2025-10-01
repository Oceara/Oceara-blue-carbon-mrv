import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/role.dart';
import '../providers/auth_provider.dart';
import 'otp_screen.dart';
import '../widgets/step_progress.dart';

class RegisterScreen extends StatefulWidget {
  static const String routeName = '/register';
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  UserRole _role = UserRole.landOwner;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      final mobile = args['mobile'] as String?;
      final role = args['role'] as UserRole?;
      if (mobile != null) _mobileController.text = mobile;
      if (role != null) _role = role;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${_role.label} Registration')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_role != UserRole.buyer)
              const StepProgress(currentStep: 1, totalSteps: 5, labels: ['Register', 'OTP', 'Map', 'Process', 'Result']),
            const SizedBox(height: 16),
            
            // Role display
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(_getRoleIcon(_role), color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 12),
                    Text('Registering as: ${_role.label}', 
                         style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name', 
                hintText: 'पूरा नाम / Full Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _mobileController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: const InputDecoration(
                labelText: 'Mobile Number', 
                hintText: 'मोबाइल नंबर / Mobile (10 digits)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
                counterText: '',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: _role == UserRole.buyer ? 'Company/Organization' : 'Address', 
                hintText: _role == UserRole.buyer ? 'Company name' : 'पता / Address',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  final name = _nameController.text.trim();
                  final mobile = _mobileController.text.trim();
                  final address = _addressController.text.trim();
                  if (name.isEmpty || mobile.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all required fields')));
                    return;
                  }
                  if (mobile.length != 10) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Mobile number must be exactly 10 digits')));
                    return;
                  }
                  if (!RegExp(r'^[0-9]+$').hasMatch(mobile)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Mobile number should contain only digits')));
                    return;
                  }
                  final auth = context.read<AuthProvider>();
                  auth.startRegistration(mobile: mobile, role: _role);
                  await auth.sendOtp();
                  if (!mounted) return;
                  Navigator.of(context).pushNamed(OTPScreen.routeName, arguments: {
                    'mode': 'register',
                    'name': name,
                    'address': address,
                    'mobile': mobile,
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Send OTP / ओटीपी भेजें', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.landOwner:
        return Icons.agriculture;
      case UserRole.buyer:
        return Icons.shopping_cart;
      case UserRole.admin:
        return Icons.admin_panel_settings;
    }
  }
}


