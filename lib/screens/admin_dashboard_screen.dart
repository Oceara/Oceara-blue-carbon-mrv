import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:convert';

import '../models/land.dart';
import '../models/user.dart';
import '../models/role.dart';
import '../services/land_service.dart';
import '../services/storage_service.dart';

class AdminDashboardScreen extends StatelessWidget {
  static const String routeName = '/admin-dashboard';
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: FutureBuilder<List<AppUser>>(
            future: StorageService.loadUsers(),
            builder: (context, snapshot) {
              final count = snapshot.data?.length ?? 0;
              return Text('Admin Dashboard • Users: $count');
            },
          ),
          actions: [
            IconButton(
              tooltip: 'Refresh All',
              icon: const Icon(Icons.refresh),
              onPressed: () async {
                await context.read<LandService>().refreshAll();
                if (context.mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('Refreshed monitoring data')));
                }
              },
            ),
            IconButton(
              tooltip: 'Seed demo data',
              icon: const Icon(Icons.bolt),
              onPressed: () async {
                final svc = context.read<LandService>();
                // Add demo lands if none pending
                if (svc.pending.isEmpty && svc.approved.isEmpty) {
                  await svc.submitLand(
                    label: 'Demo Mangrove Plot',
                    latitude: 19.0760,
                    longitude: 72.8777,
                    ownerUserId: 'demo-owner-1',
                  );
                  await svc.submitLand(
                    label: 'Demo Coastal Plot',
                    latitude: 8.5241,
                    longitude: 76.9366,
                    ownerUserId: 'demo-owner-2',
                  );
                  await svc.submitLand(
                    label: 'Demo Estuary Plot',
                    latitude: 22.5726,
                    longitude: 88.3639,
                    ownerUserId: 'demo-owner-3',
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('Seeded demo submissions')));
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('Data already present')));
                  }
                }
              },
            )
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Pending Lands'),
              Tab(text: 'Approved Lands'),
              Tab(text: 'Registry'),
              Tab(text: 'Users'),
              Tab(text: 'Monitoring'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _PendingTab(),
            _ApprovedTab(),
            _RegistryTab(),
            _UsersTab(),
            _MonitoringTab(),
          ],
        ),
      ),
    );
  }
}

class _PendingTab extends StatelessWidget {
  const _PendingTab();

  @override
  Widget build(BuildContext context) {
    final landService = context.watch<LandService>();
    final items = landService.pending;
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No pending submissions'),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () async {
                final svc = context.read<LandService>();
                await svc.submitLand(
                  label: 'Demo Mangrove Plot',
                  latitude: 19.0760,
                  longitude: 72.8777,
                  ownerUserId: 'demo-owner-1',
                );
                await svc.submitLand(
                  label: 'Demo Coastal Plot',
                  latitude: 8.5241,
                  longitude: 76.9366,
                  ownerUserId: 'demo-owner-2',
                );
                await svc.submitLand(
                  label: 'Demo Estuary Plot',
                  latitude: 22.5726,
                  longitude: 88.3639,
                  ownerUserId: 'demo-owner-3',
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add demo submissions'),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final l = items[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: ListTile(
            title: Text(l.label),
            subtitle: Text('(${l.latitude.toStringAsFixed(4)}, ${l.longitude.toStringAsFixed(4)})'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check_circle, color: Colors.green),
                  onPressed: () => context.read<LandService>().approve(l.id),
                ),
                IconButton(
                  icon: const Icon(Icons.cancel, color: Colors.red),
                  onPressed: () => context.read<LandService>().reject(l.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ApprovedTab extends StatelessWidget {
  const _ApprovedTab();

  @override
  Widget build(BuildContext context) {
    final landService = context.watch<LandService>();
    final items = landService.approved;
    final totalCredits = items.fold<double>(0, (sum, land) => sum + (landService.latestCredit(land.id) ?? 0.0));
    if (items.isEmpty) {
      return const Center(child: Text('No approved lands'));
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Approved: ${items.length}'),
              Text('Total Credits: ${totalCredits.toStringAsFixed(1)} tCO2e'),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final l = items[index];
              final latest = landService.latestCredit(l.id) ?? 0.0;
              return ListTile(
                leading: const Icon(Icons.verified, color: Colors.green),
                title: Text(l.label),
                subtitle: Text('Owner: ${l.ownerUserId}'),
                trailing: Text('${latest.toStringAsFixed(1)} tCO2e'),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RegistryTab extends StatelessWidget {
  const _RegistryTab();

  @override
  Widget build(BuildContext context) {
    final landService = context.watch<LandService>();
    final items = landService.approved; // registry mirrors approved for now
    if (items.isEmpty) {
      return const Center(child: Text('Registry is empty'));
    }
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final l = items[index];
        return ListTile(
          leading: const Icon(Icons.article_outlined),
          title: Text(l.label),
          subtitle: Text('(${l.latitude.toStringAsFixed(4)}, ${l.longitude.toStringAsFixed(4)})'),
        );
      },
    );
  }
}

class _UsersTab extends StatefulWidget {
  const _UsersTab();

  @override
  State<_UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<_UsersTab> {
  List<AppUser> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    final users = await StorageService.loadUsers();
    setState(() {
      _users = users;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Users: ${_users.length}', 
                   style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: _loadUsers,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _users.isEmpty
                ? const Center(child: Text('No users registered yet'))
                : ListView.builder(
                    itemCount: _users.length,
                    itemBuilder: (context, index) {
                      final user = _users[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getRoleColor(user.role),
                            child: Icon(_getRoleIcon(user.role), color: Colors.white),
                          ),
                          title: Text(user.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Mobile: ${user.mobile}'),
                              Text('Role: ${user.role.label}'),
                              if (user.address.isNotEmpty) Text('Address: ${user.address}'),
                            ],
                          ),
                          trailing: Text('ID: ${user.id.substring(0, 8)}...'),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.landOwner:
        return Colors.green;
      case UserRole.buyer:
        return Colors.blue;
      case UserRole.admin:
        return Colors.red;
    }
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

class _MonitoringTab extends StatelessWidget {
  const _MonitoringTab();

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<LandService>();
    final last = svc.lastRefreshAt;
    final changed = svc.changedSinceLastRefresh;

    final List<_StatusDatum> statusData = <_StatusDatum>[
      _StatusDatum('Pending', svc.pending.length.toDouble(), Colors.orange),
      _StatusDatum('Approved', svc.approved.length.toDouble(), Colors.green),
      _StatusDatum('Rejected', svc.rejected.length.toDouble(), Colors.red),
    ];
    final List<_CreditDatum> creditsPerLand = svc.approved
        .map((l) => _CreditDatum(l.label, (svc.latestCredit(l.id) ?? 0.0)))
        .toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Active lands: ${svc.approved.length}'),
              Text('Last refresh: ${last?.toIso8601String() ?? 'Never'}', style: const TextStyle(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () async {
              await context.read<LandService>().refreshAll();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh All'),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Submission Status', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(
                    height: 220,
                    child: SfCircularChart(
                      legend: const Legend(isVisible: true, position: LegendPosition.bottom, overflowMode: LegendItemOverflowMode.wrap),
                      series: <CircularSeries>[
                        PieSeries<_StatusDatum, String>(
                          dataSource: statusData,
                          xValueMapper: (_StatusDatum d, _) => d.label,
                          yValueMapper: (_StatusDatum d, _) => d.value,
                          pointColorMapper: (_StatusDatum d, _) => d.color,
                          dataLabelSettings: const DataLabelSettings(isVisible: true),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (creditsPerLand.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Latest Credits per Approved Land', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(
                      height: 240,
                      child: SfCartesianChart(
                        primaryXAxis: const CategoryAxis(),
                        primaryYAxis: const NumericAxis(title: AxisTitle(text: 'tCO2e')),
                        series: <CartesianSeries>[
                          ColumnSeries<_CreditDatum, String>(
                            dataSource: creditsPerLand,
                            xValueMapper: (_CreditDatum d, _) => d.label,
                            yValueMapper: (_CreditDatum d, _) => d.value,
                            dataLabelSettings: const DataLabelSettings(isVisible: true),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),
          Text('Changed since refresh: ${changed.length}'),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              children: changed
                  .map((id) {
                    final land = (svc.approved + svc.pending + svc.rejected).firstWhere((l) => l.id == id, orElse: () => svc.approved.first);
                    return ListTile(
                      leading: const Icon(Icons.warning_amber, color: Colors.orange),
                      title: Text(land.label),
                      subtitle: Text('(${land.latitude.toStringAsFixed(4)}, ${land.longitude.toStringAsFixed(4)})'),
                    );
                  })
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusDatum {
  final String label;
  final double value;
  final Color color;
  _StatusDatum(this.label, this.value, this.color);
}

class _CreditDatum {
  final String label;
  final double value;
  _CreditDatum(this.label, this.value);
}


