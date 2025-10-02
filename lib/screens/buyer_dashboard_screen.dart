import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/auth_provider.dart';
import '../services/land_service.dart';

class BuyerDashboardScreen extends StatelessWidget {
  static const String routeName = '/buyer-dashboard';
  const BuyerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final name = auth.currentUser?.name ?? 'Buyer';
    final landService = context.watch<LandService>();
    final approved = landService.approved;
    final availableCredits = approved
        .map((land) => landService.latestCredit(land.id) ?? 0.0)
        .fold(0.0, (a, b) => a + b);
    // Simple pricing model (editable): price per tCO2e
    const double pricePerTco2e = 1000; // in INR (example)
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    // Mangrove-only summary (label contains 'mangrove')
    final mangroveCredits = approved
        .where((l) => l.label.toLowerCase().contains('mangrove'))
        .map((l) => landService.latestCredit(l.id) ?? 0.0)
        .fold(0.0, (a, b) => a + b);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, $name'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await landService.seedDemoData();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Demo data loaded!')),
                );
              }
            },
            tooltip: 'Load Demo Data',
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
            // Available Credits Summary
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.eco, size: 48, color: Colors.green),
                    const SizedBox(height: 8),
                    Text('Available Carbon Credits', 
                         style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text('${availableCredits.toStringAsFixed(1)} tCO2e', 
                         style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.green)),
                    const SizedBox(height: 4),
                    Text('Est. Cost: ${currency.format(availableCredits * pricePerTco2e)}',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.green.withOpacity(0.08),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Mangrove Credits Offered'),
                          Text('${mangroveCredits.toStringAsFixed(1)} tCO2e'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (approved.isNotEmpty) ...[
              const SizedBox(height: 12),
              // Featured Offer
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Builder(builder: (context) {
                    final featured = approved.first;
                    final credits = landService.latestCredit(featured.id) ?? 0.0;
                    final cost = credits * pricePerTco2e;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.local_offer, color: Colors.deepPurple),
                            SizedBox(width: 8),
                            Text('Featured Offer', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('This land is available: ${featured.label}'),
                        const SizedBox(height: 4),
                        Text('Credits offered: ${credits.toStringAsFixed(1)} tCO2e'),
                        const SizedBox(height: 4),
                        Text('Price: ${currency.format(cost)}'),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _showPurchaseDialog(context, featured.label, credits, pricePerTco2e, currency);
                            },
                            icon: const Icon(Icons.shopping_cart),
                            label: const Text('Buy this credit'),
                          ),
                        )
                      ],
                    );
                  }),
                ),
              ),
            ],
            const SizedBox(height: 16),
            
            // Available Lands for Purchase
            const Text('Available Lands for Credit Purchase', 
                       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: approved.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.agriculture, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text('No verified lands available yet', 
                               style: TextStyle(fontSize: 16, color: Colors.grey)),
                          const SizedBox(height: 8),
                          const Text('Check back later for carbon credit opportunities'),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await landService.seedDemoData();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Demo data loaded!')),
                                );
                              }
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Load Demo Data'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: approved.length,
                      itemBuilder: (context, index) {
                        final land = approved[index];
                        final latestCredit = landService.latestCredit(land.id) ?? 0.0;
                        final isMangrove = land.label.toLowerCase().contains('mangrove');
                        final landCost = latestCredit * pricePerTco2e;
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isMangrove ? Colors.green : Colors.blueGrey,
                              child: Icon(isMangrove ? Icons.forest : Icons.terrain, color: Colors.white),
                            ),
                            title: Text(land.label),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Location: ${land.latitude.toStringAsFixed(4)}, ${land.longitude.toStringAsFixed(4)}'),
                                Text('Available Credits: ${latestCredit.toStringAsFixed(1)} tCO2e'),
                                Text('Est. Cost: ${currency.format(landCost)}'),
                              ],
                            ),
                            trailing: ElevatedButton(
                              onPressed: () {
                                _showPurchaseDialog(context, land.label, latestCredit, pricePerTco2e, currency);
                              },
                              child: const Text('Purchase'),
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

  void _showPurchaseDialog(BuildContext context, String landLabel, double credits, double pricePerTco2e, NumberFormat currency) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Purchase Credits from $landLabel'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Available: ${credits.toStringAsFixed(1)} tCO2e'),
            const SizedBox(height: 8),
            Text('Price per tCO2e: ${currency.format(pricePerTco2e)}'),
            const SizedBox(height: 16),
            const Text('Enter amount to purchase:'),
            const SizedBox(height: 8),
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount (tCO2e)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Purchase request submitted (mock)')));
            },
            child: const Text('Purchase'),
          ),
        ],
      ),
    );
  }
}
