import 'dart:async';

class AuthService {
  Future<void> sendOtp({required String mobile}) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<bool> verifyOtp({required String mobile, required String code}) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return code.length == 6;
  }
}


