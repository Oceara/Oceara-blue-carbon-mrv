import 'role.dart';

class AppUser {
  final String id;
  final String name;
  final String mobile;
  final String address;
  final UserRole role;

  const AppUser({
    required this.id,
    required this.name,
    required this.mobile,
    required this.address,
    required this.role,
  });
}


