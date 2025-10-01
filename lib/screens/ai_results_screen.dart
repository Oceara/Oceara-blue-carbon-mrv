import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../services/land_service.dart';
import '../widgets/step_progress.dart';

class AIResultsScreen extends StatelessWidget {
  static const String routeName = '/ai-results';
  const AIResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final lat = (args?['lat'] as num?)?.toDouble();
    final lng = (args?['lng'] as num?)?.toDouble();
    final label = args?['label'] as String?;
    final landId = args?['landId'] as String?;

    // Simulate saving a credit result for this land if provided
    if (landId != null) {
      // Using a fixed mock value consistent with UI
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<LandService>().addCredit(landId: landId, creditsTco2e: 6.2);
      });
    }

    // Mock data for charts
    final carbonData = [
      _CarbonData('Soil Carbon', 2.1, Colors.brown),
      _CarbonData('Biomass Carbon', 3.0, Colors.green),
      _CarbonData('Litter Carbon', 1.1, Colors.orange),
    ];

    final totalCredits = carbonData.fold(0.0, (sum, item) => sum + item.value);

    return Scaffold(
      appBar: AppBar(title: const Text('AI Carbon Stock Estimation')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Builder(builder: (context) {
              final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
              final hide = (args?['role'] == 'buyer');
              if (hide) return const SizedBox.shrink();
              return const StepProgress(currentStep: 5, totalSteps: 5, labels: ['Register', 'OTP', 'Map', 'Process', 'Result']);
            }),
            const SizedBox(height: 16),
            
            // Land Info Card
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (label != null) 
                      Text(label, style: Theme.of(context).textTheme.titleLarge),
                    if (lat != null && lng != null)
                      Text('Location: ${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}',
                           style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Total Credits Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(Icons.eco, size: 48, color: Colors.green),
                    const SizedBox(height: 8),
                    const Text('Total Carbon Stock', 
                           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('${totalCredits.toStringAsFixed(1)} tCO2e', 
                         style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green)),
                    const SizedBox(height: 8),
                    const Text('Estimated Carbon Credits Available', 
                           style: TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Pie Chart
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Carbon Stock Breakdown', 
                           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 300,
                      child: SfCircularChart(
                        legend: const Legend(
                          isVisible: true,
                          position: LegendPosition.bottom,
                          overflowMode: LegendItemOverflowMode.wrap,
                        ),
                        series: <CircularSeries>[
                          PieSeries<_CarbonData, String>(
                            dataSource: carbonData,
                            xValueMapper: (_CarbonData data, _) => data.category,
                            yValueMapper: (_CarbonData data, _) => data.value,
                            pointColorMapper: (_CarbonData data, _) => data.color,
                            dataLabelSettings: const DataLabelSettings(
                              isVisible: true,
                              labelPosition: ChartDataLabelPosition.outside,
                            ),
                            dataLabelMapper: (_CarbonData data, _) => '${data.value.toStringAsFixed(1)} tCO2e',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Bar Chart
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Carbon Stock Comparison', 
                           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 250,
                      child: SfCartesianChart(
                        primaryXAxis: const CategoryAxis(),
                        primaryYAxis: const NumericAxis(
                          title: AxisTitle(text: 'Carbon Stock (tCO2e)'),
                        ),
                        series: <CartesianSeries>[
                          ColumnSeries<_CarbonData, String>(
                            dataSource: carbonData,
                            xValueMapper: (_CarbonData data, _) => data.category,
                            yValueMapper: (_CarbonData data, _) => data.value,
                            pointColorMapper: (_CarbonData data, _) => data.color,
                            dataLabelSettings: const DataLabelSettings(
                              isVisible: true,
                              textStyle: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Detailed Breakdown
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Detailed Analysis', 
                           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ...carbonData.map((data) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: data.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(data.category)),
                          Text('${data.value.toStringAsFixed(1)} tCO2e',
                               style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    )).toList(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.home),
                    label: const Text('Back to Home'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Report downloaded (mock)')));
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('Download Report'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CarbonData {
  final String category;
  final double value;
  final Color color;

  _CarbonData(this.category, this.value, this.color);
}