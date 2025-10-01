import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/role.dart';
import '../providers/auth_provider.dart';
import 'otp_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _mobileController = TextEditingController();
  UserRole _selectedRole = UserRole.landOwner;

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Oceara')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Text('Welcome to Oceara', 
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            const Text('Choose your role to continue', 
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center),
            const SizedBox(height: 32),
            
            // Role Selection Cards
            ...UserRole.values.map((role) => _buildRoleCard(role)).toList(),
            
            const SizedBox(height: 24),
            const Text('Mobile Number', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: _mobileController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: const InputDecoration(
                hintText: 'Enter 10-digit mobile number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
                counterText: '',
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  final mobile = _mobileController.text.trim();
                  if (mobile.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter mobile number')));
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
                  auth.startRegistration(mobile: mobile, role: _selectedRole);
                  await auth.sendOtp();
                  if (!mounted) return;
                  
                  if (_selectedRole == UserRole.admin) {
                    Navigator.of(context).pushNamed(OTPScreen.routeName,
                        arguments: {'mode': 'admin', 'mobile': mobile});
                  } else {
                    Navigator.of(context).pushNamed(RegisterScreen.routeName,
                        arguments: {'mobile': mobile, 'role': _selectedRole});
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Continue', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed(RegisterScreen.routeName);
              },
              child: const Text('New User? Register Here'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard(UserRole role) {
    final isSelected = _selectedRole == role;
    final icon = _getRoleIcon(role);
    final description = _getRoleDescription(role);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 1,
      color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
      child: InkWell(
        onTap: () => setState(() => _selectedRole = role),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: isSelected ? Colors.white : Colors.grey.shade600),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(role.label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(description, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary),
            ],
          ),
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

  String _getRoleDescription(UserRole role) {
    switch (role) {
      case UserRole.landOwner:
        return 'Register your land and earn carbon credits';
      case UserRole.buyer:
        return 'Purchase carbon credits from verified sources';
      case UserRole.admin:
        return 'Manage and verify land registrations';
    }
  }
}


