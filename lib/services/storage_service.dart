import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/land.dart';
import '../models/role.dart';

class StorageService {
  static const String _usersKey = 'stored_users';
  static const String _landsKey = 'stored_lands';
  static const String _creditsKey = 'stored_credits';
  static const String _notificationsKey = 'stored_notifications';

  static Future<void> saveUsers(List<AppUser> users) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = users.map((user) => {
      'id': user.id,
      'name': user.name,
      'mobile': user.mobile,
      'address': user.address,
      'role': user.role.name,
    }).toList();
    await prefs.setString(_usersKey, jsonEncode(usersJson));
  }

  static Future<List<AppUser>> loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);
    if (usersJson == null) return [];
    
    final List<dynamic> usersList = jsonDecode(usersJson);
    return usersList.map((userData) => AppUser(
      id: userData['id'],
      name: userData['name'],
      mobile: userData['mobile'],
      address: userData['address'],
      role: UserRole.values.firstWhere((r) => r.name == userData['role']),
    )).toList();
  }

  static Future<void> saveLands(List<LandParcel> lands) async {
    final prefs = await SharedPreferences.getInstance();
    final landsJson = lands.map((land) => {
      'id': land.id,
      'label': land.label,
      'latitude': land.latitude,
      'longitude': land.longitude,
      'ownerUserId': land.ownerUserId,
      'status': land.status.name,
    }).toList();
    await prefs.setString(_landsKey, jsonEncode(landsJson));
  }

  static Future<List<LandParcel>> loadLands() async {
    final prefs = await SharedPreferences.getInstance();
    final landsJson = prefs.getString(_landsKey);
    if (landsJson == null) return [];
    
    final List<dynamic> landsList = jsonDecode(landsJson);
    return landsList.map((landData) => LandParcel(
      id: landData['id'],
      label: landData['label'],
      latitude: landData['latitude'].toDouble(),
      longitude: landData['longitude'].toDouble(),
      ownerUserId: landData['ownerUserId'],
      status: LandStatus.values.firstWhere((s) => s.name == landData['status']),
    )).toList();
  }

  static Future<void> saveCredits(Map<String, List<double>> credits) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_creditsKey, jsonEncode(credits));
  }

  static Future<Map<String, List<double>>> loadCredits() async {
    final prefs = await SharedPreferences.getInstance();
    final creditsJson = prefs.getString(_creditsKey);
    if (creditsJson == null) return {};
    
    final Map<String, dynamic> creditsMap = jsonDecode(creditsJson);
    return creditsMap.map((key, value) => MapEntry(key, List<double>.from(value)));
  }

  static Future<void> saveNotifications(Map<String, List<String>> notifications) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_notificationsKey, jsonEncode(notifications));
  }

  static Future<Map<String, List<String>>> loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = prefs.getString(_notificationsKey);
    if (notificationsJson == null) return {};
    
    final Map<String, dynamic> notificationsMap = jsonDecode(notificationsJson);
    return notificationsMap.map((key, value) => MapEntry(key, List<String>.from(value)));
  }

  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_usersKey);
    await prefs.remove(_landsKey);
    await prefs.remove(_creditsKey);
    await prefs.remove(_notificationsKey);
  }
}
