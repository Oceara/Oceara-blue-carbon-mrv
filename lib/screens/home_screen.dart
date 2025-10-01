import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../services/land_service.dart';
import 'map_screen.dart';

class HomeScreen extends StatelessWidget {
  static const String routeName = '/home';
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final name = auth.currentUser?.name ?? 'User';
    final landService = context.watch<LandService>();
    final approved = landService.approved.where((l) => l.ownerUserId == auth.currentUser?.id).toList();
    final totalCredits = auth.currentUser == null ? 0.0 : landService.totalCreditsForOwner(auth.currentUser!.id);
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, $name'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: auth.currentUser == null
                ? null
                : () async {
                    await context.read<LandService>().refreshLandsForOwner(auth.currentUser!.id);
                    if (!context.mounted) return;
                    final notes = context.read<LandService>().getNotifications(auth.currentUser!.id);
                    if (notes.isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(notes.last)));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No updates found.')));
                    }
                  },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthProvider>().logout();
              Navigator.of(context).popUntil((r) => r.isFirst);
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await Navigator.of(context).pushNamed(MapScreen.routeName);
                },
                icon: const Icon(Icons.add_location_alt),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('Register Land / भूमि पंजीकरण', style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Your Carbon Credits: ${totalCredits.toStringAsFixed(1)} tCO2e',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            const Text('Your Approved Lands', style: TextStyle(fontWeight: FontWeight.bold)),
            if (auth.currentUser != null)
              Builder(builder: (context) {
                final notes = context.watch<LandService>().getNotifications(auth.currentUser!.id);
                if (notes.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Notifications:'),
                      ...notes.map((n) => Text('• $n')),
                      TextButton(
                        onPressed: () => context.read<LandService>().clearNotifications(auth.currentUser!.id),
                        child: const Text('Clear notifications'),
                      )
                    ],
                  ),
                );
              }),
            const SizedBox(height: 8),
            Expanded(
              child: approved.isEmpty
                  ? const Center(child: Text('No approved lands yet'))
                  : ListView.builder(
                      itemCount: approved.length,
                      itemBuilder: (context, index) {
                        final land = approved[index];
                        final latest = landService.latestCredit(land.id);
                        final history = landService.getHistory(land.id);
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(land.label, style: Theme.of(context).textTheme.titleMedium),
                                const SizedBox(height: 4),
                                Text('Latest: ${latest?.toStringAsFixed(1) ?? '-'} tCO2e'),
                                const SizedBox(height: 4),
                                Text('History: ${history.map((e) => e.toStringAsFixed(1)).join(', ')}'),
                                const SizedBox(height: 8),
                                OutlinedButton.icon(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Downloading certificate (mock)...')));
                                  },
                                  icon: const Icon(Icons.download),
                                  label: const Text('Download Certificate (PDF)'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}


