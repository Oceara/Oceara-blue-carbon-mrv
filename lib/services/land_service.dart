import 'dart:async';
import 'package:flutter/foundation.dart';

import '../models/land.dart';
import 'storage_service.dart';

class LandService extends ChangeNotifier {
  LandService._internal();
  static final LandService instance = LandService._internal();

  final List<LandParcel> _storage = [];
  final Map<String, List<double>> _landIdToCredits = {};
  final Map<String, List<String>> _ownerIdToNotifications = {};
  final Set<String> _changedSinceLastRefresh = <String>{};
  DateTime? _lastRefreshAt;
  bool _isInitialized = false;

  Future<void> _initialize() async {
    if (_isInitialized) return;
    _storage.addAll(await StorageService.loadLands());
    _landIdToCredits.addAll(await StorageService.loadCredits());
    _ownerIdToNotifications.addAll(await StorageService.loadNotifications());
    _isInitialized = true;
  }

  Future<void> _saveData() async {
    await StorageService.saveLands(_storage);
    await StorageService.saveCredits(_landIdToCredits);
    await StorageService.saveNotifications(_ownerIdToNotifications);
  }

  List<LandParcel> get pending => _storage.where((l) => l.status == LandStatus.pending).toList();
  List<LandParcel> get approved => _storage.where((l) => l.status == LandStatus.approved).toList();
  List<LandParcel> get rejected => _storage.where((l) => l.status == LandStatus.rejected).toList();

  Future<LandParcel> submitLand({
    required String label,
    required double latitude,
    required double longitude,
    required String ownerUserId,
  }) async {
    await _initialize();
    await Future.delayed(const Duration(milliseconds: 300));
    final land = LandParcel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      label: label,
      latitude: latitude,
      longitude: longitude,
      ownerUserId: ownerUserId,
      status: LandStatus.pending,
    );
    _storage.add(land);
    await _saveData();
    notifyListeners();
    return land;
  }

  Future<void> approve(String id) async {
    await _initialize();
    await Future.delayed(const Duration(milliseconds: 150));
    final idx = _storage.indexWhere((l) => l.id == id);
    if (idx != -1) {
      _storage[idx].status = LandStatus.approved;
      await _saveData();
      notifyListeners();
    }
  }

  Future<void> reject(String id) async {
    await _initialize();
    await Future.delayed(const Duration(milliseconds: 150));
    final idx = _storage.indexWhere((l) => l.id == id);
    if (idx != -1) {
      _storage[idx].status = LandStatus.rejected;
      await _saveData();
      notifyListeners();
    }
  }

  Future<List<LandParcel>> listOwned({required String ownerUserId}) async {
    await Future.delayed(const Duration(milliseconds: 120));
    return _storage.where((l) => l.ownerUserId == ownerUserId).toList();
  }

  Future<void> addCredit({required String landId, required double creditsTco2e}) async {
    await _initialize();
    final list = _landIdToCredits.putIfAbsent(landId, () => <double>[]);
    list.add(creditsTco2e);
    await _saveData();
    notifyListeners();
  }

  List<double> getHistory(String landId) {
    return List<double>.unmodifiable(_landIdToCredits[landId] ?? const <double>[]);
  }

  double? latestCredit(String landId) {
    final list = _landIdToCredits[landId];
    if (list == null || list.isEmpty) return null;
    return list.last;
  }

  double totalCreditsForOwner(String ownerUserId) {
    double sum = 0;
    for (final land in _storage.where((l) => l.ownerUserId == ownerUserId && l.status == LandStatus.approved)) {
      final history = _landIdToCredits[land.id];
      if (history != null && history.isNotEmpty) {
        sum += history.reduce((a, b) => a + b);
      }
    }
    return sum;
  }

  // Monitoring & refresh simulation
  DateTime? get lastRefreshAt => _lastRefreshAt;
  Set<String> get changedSinceLastRefresh => Set<String>.unmodifiable(_changedSinceLastRefresh);

  List<String> getNotifications(String ownerUserId) {
    return List<String>.unmodifiable(_ownerIdToNotifications[ownerUserId] ?? const <String>[]);
  }

  void clearNotifications(String ownerUserId) {
    _ownerIdToNotifications.remove(ownerUserId);
    notifyListeners();
  }

  Future<void> refreshLandsForOwner(String ownerUserId) async {
    await Future.delayed(const Duration(milliseconds: 350));
    _changedSinceLastRefresh.clear();
    final approvedLands = _storage.where((l) => l.ownerUserId == ownerUserId && l.status == LandStatus.approved);
    for (final land in approvedLands) {
      // Pseudo change detection: 30% chance of change
      final changed = (land.id.hashCode ^ DateTime.now().millisecondsSinceEpoch).abs() % 10 < 3;
      if (changed) {
        _changedSinceLastRefresh.add(land.id);
        // Simulate a small credit update +/- 0.2
        final latest = latestCredit(land.id) ?? 6.0;
        final updated = (latest + ([-0.2, 0.2]..shuffle()).first).clamp(0.0, 9999.0);
        addCredit(landId: land.id, creditsTco2e: updated.toDouble());
        final list = _ownerIdToNotifications.putIfAbsent(ownerUserId, () => <String>[]);
        list.add('Land "${land.label}" shows cover change. Review updated estimate.');
      }
    }
    _lastRefreshAt = DateTime.now();
    notifyListeners();
  }

  Future<void> refreshAll() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _changedSinceLastRefresh.clear();
    final approvedLands = _storage.where((l) => l.status == LandStatus.approved);
    for (final land in approvedLands) {
      final changed = (land.id.hashCode ^ DateTime.now().millisecondsSinceEpoch).abs() % 10 < 3;
      if (changed) {
        _changedSinceLastRefresh.add(land.id);
        final latest = latestCredit(land.id) ?? 6.0;
        final updated = (latest + ([-0.2, 0.2]..shuffle()).first).clamp(0.0, 9999.0);
        addCredit(landId: land.id, creditsTco2e: updated.toDouble());
        final list = _ownerIdToNotifications.putIfAbsent(land.ownerUserId, () => <String>[]);
        list.add('Land "${land.label}" shows cover change. Review updated estimate.');
      }
    }
    _lastRefreshAt = DateTime.now();
    notifyListeners();
  }

  // Seed demo data for buyers
  Future<void> seedDemoData() async {
    await _initialize();
    
    // Check if demo data already exists
    if (_storage.any((land) => land.label.contains('Demo'))) {
      return; // Demo data already exists
    }

    final demoLands = [
      LandParcel(
        id: 'demo_1',
        label: 'Demo Mangrove Forest - Sundarbans',
        latitude: 21.9497,
        longitude: 88.9201,
        ownerUserId: 'demo_owner_1',
        status: LandStatus.approved,
      ),
      LandParcel(
        id: 'demo_2',
        label: 'Demo Coastal Wetland - Kerala',
        latitude: 9.9312,
        longitude: 76.2673,
        ownerUserId: 'demo_owner_2',
        status: LandStatus.approved,
      ),
      LandParcel(
        id: 'demo_3',
        label: 'Demo Blue Carbon Reserve - Goa',
        latitude: 15.2993,
        longitude: 74.1240,
        ownerUserId: 'demo_owner_3',
        status: LandStatus.approved,
      ),
      LandParcel(
        id: 'demo_4',
        label: 'Demo Seagrass Meadow - Tamil Nadu',
        latitude: 10.7905,
        longitude: 79.1378,
        ownerUserId: 'demo_owner_4',
        status: LandStatus.approved,
      ),
    ];

    for (final land in demoLands) {
      _storage.add(land);
      // Add some credit history for each demo land
      final baseCredits = [8.5, 12.3, 6.7, 15.2][demoLands.indexOf(land)];
      await addCredit(landId: land.id, creditsTco2e: baseCredits);
      await addCredit(landId: land.id, creditsTco2e: baseCredits + 1.2);
      await addCredit(landId: land.id, creditsTco2e: baseCredits + 0.8);
    }

    await _saveData();
    notifyListeners();
  }
}


