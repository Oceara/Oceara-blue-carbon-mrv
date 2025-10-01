import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/role.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  AuthProvider({AuthService? authService}) : _authService = authService ?? AuthService() {
    _loadUser();
  }

  AppUser? _currentUser;
  String? _pendingMobile;
  UserRole? _pendingRole;

  AppUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  String? get pendingMobile => _pendingMobile;
  UserRole? get pendingRole => _pendingRole;

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('current_user');
    if (userJson != null) {
      final userData = jsonDecode(userJson);
      _currentUser = AppUser(
        id: userData['id'],
        name: userData['name'],
        mobile: userData['mobile'],
        address: userData['address'],
        role: UserRole.values.firstWhere((r) => r.name == userData['role']),
      );
      notifyListeners();
    }
  }

  Future<void> _saveUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (_currentUser != null) {
      final userData = {
        'id': _currentUser!.id,
        'name': _currentUser!.name,
        'mobile': _currentUser!.mobile,
        'address': _currentUser!.address,
        'role': _currentUser!.role.name,
      };
      await prefs.setString('current_user', jsonEncode(userData));
    } else {
      await prefs.remove('current_user');
    }
  }

  void startRegistration({required String mobile, required UserRole role}) {
    _pendingMobile = mobile;
    _pendingRole = role;
    notifyListeners();
  }

  Future<void> sendOtp() async {
    if (_pendingMobile == null) return;
    await _authService.sendOtp(mobile: _pendingMobile!);
  }

  Future<bool> verifyOtpAndCreateUser({
    required String code,
    required String name,
    required String address,
  }) async {
    if (_pendingMobile == null || _pendingRole == null) return false;
    final ok = await _authService.verifyOtp(mobile: _pendingMobile!, code: code);
    if (!ok) return false;
    _currentUser = AppUser(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      mobile: _pendingMobile!,
      address: address,
      role: _pendingRole!,
    );
    _pendingMobile = null;
    _pendingRole = null;
    await _saveUser();
    // persist to global users list for admin
    final existing = await StorageService.loadUsers();
    if (!existing.any((u) => u.mobile == _currentUser!.mobile)) {
      existing.add(_currentUser!);
      await StorageService.saveUsers(existing);
    }
    notifyListeners();
    return true;
  }

  Future<bool> loginAdminWithOtp({required String mobile, required String code}) async {
    final ok = await _authService.verifyOtp(mobile: mobile, code: code);
    if (!ok) return false;
    _currentUser = AppUser(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Administrator',
      mobile: mobile,
      address: '',
      role: UserRole.admin,
    );
    await _saveUser();
    // ensure admin exists in users list
    final existing = await StorageService.loadUsers();
    if (!existing.any((u) => u.mobile == _currentUser!.mobile)) {
      existing.add(_currentUser!);
      await StorageService.saveUsers(existing);
    }
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _currentUser = null;
    await _saveUser();
    notifyListeners();
  }
}


