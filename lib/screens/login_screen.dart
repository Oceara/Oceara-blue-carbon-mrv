import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Oceara')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF0F8FF), // Alice Blue
              Color(0xFFE6F3FF), // Light Blue
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              // Logo/Icon Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF87CEEB),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: const Icon(
                        Icons.eco,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Welcome to Oceara',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: const Color(0xFF2C3E50),
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Blue Carbon MRV Platform',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF7F8C8D),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose your role to continue',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF34495E),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            
            // Role Selection Cards
            ...UserRole.values.map((role) => _buildRoleCard(role)).toList(),
            
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mobile Number',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF2C3E50),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _mobileController,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    style: Theme.of(context).textTheme.bodyLarge,
                    decoration: const InputDecoration(
                      hintText: 'Enter 10-digit mobile number',
                      prefixIcon: Icon(Icons.phone, color: Color(0xFF4682B4)),
                      counterText: '',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 56,
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
                  backgroundColor: const Color(0xFF4682B4),
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Continue',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Divider with "OR"
            Row(
              children: [
                const Expanded(child: Divider(color: Color(0xFFE0E0E0))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'OR',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF7F8C8D),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Expanded(child: Divider(color: Color(0xFFE0E0E0))),
              ],
            ),
            
            const SizedBox(height: 24),
            
            const SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(RegisterScreen.routeName);
                },
                child: Text(
                  'New User? Register Here',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF4682B4),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildRoleCard(UserRole role) {
    final isSelected = _selectedRole == role;
    final icon = _getRoleIcon(role);
    final description = _getRoleDescription(role);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? const Color(0xFF4682B4) : const Color(0xFFE0E0E0),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected ? const Color(0xFF4682B4).withOpacity(0.2) : Colors.black.withOpacity(0.05),
            blurRadius: isSelected ? 8 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _selectedRole = role),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF4682B4) : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon, 
                    color: isSelected ? Colors.white : const Color(0xFF7F8C8D),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        role.label, 
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: isSelected ? const Color(0xFF2C3E50) : const Color(0xFF34495E),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        description, 
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF7F8C8D),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4682B4),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
              ],
            ),
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

  Future<void> _handleGoogleSignIn() async {
    try {
      // Show role selection dialog for Google Sign-In
      final selectedRole = await _showRoleSelectionDialog();
      if (selectedRole == null) return;

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Sign in with Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User cancelled the sign-in
        if (mounted) Navigator.of(context).pop();
        return;
      }

      // Get user details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Create user from Google account
      final auth = context.read<AuthProvider>();
      await auth.signInWithGoogle(
        email: googleUser.email,
        name: googleUser.displayName ?? 'Google User',
        role: selectedRole,
      );

      // Hide loading indicator
      if (mounted) Navigator.of(context).pop();

      // Navigate to appropriate dashboard
      if (mounted) {
        switch (selectedRole) {
          case UserRole.admin:
            Navigator.of(context).pushReplacementNamed('/admin-dashboard');
            break;
          case UserRole.buyer:
            Navigator.of(context).pushReplacementNamed('/buyer-dashboard');
            break;
          case UserRole.landOwner:
            Navigator.of(context).pushReplacementNamed('/home');
            break;
        }
      }

    } catch (error) {
      // Hide loading indicator
      if (mounted) Navigator.of(context).pop();
      
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Sign-In failed: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<UserRole?> _showRoleSelectionDialog() async {
    return showDialog<UserRole>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Select Your Role',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: UserRole.values.map((role) {
            return ListTile(
              leading: Icon(_getRoleIcon(role)),
              title: Text(role.label),
              subtitle: Text(_getRoleDescription(role)),
              onTap: () => Navigator.of(context).pop(role),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}


