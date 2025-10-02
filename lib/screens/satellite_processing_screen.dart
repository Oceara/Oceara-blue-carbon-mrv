import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../widgets/step_progress.dart';

class SatelliteProcessingScreen extends StatefulWidget {
  static const String routeName = '/satellite-processing';
  const SatelliteProcessingScreen({super.key});

  @override
  State<SatelliteProcessingScreen> createState() => _SatelliteProcessingScreenState();
}

class _SatelliteProcessingScreenState extends State<SatelliteProcessingScreen> {
  bool _done = false;
  late final double _lat;
  late final double _lng;
  late final String _label;
  String? _landId;
  bool _animationShown = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _lat = (args?['lat'] as num?)?.toDouble() ?? 0;
    _lng = (args?['lng'] as num?)?.toDouble() ?? 0;
    _label = args?['label'] as String? ?? 'Your Land';
    _landId = args?['landId'] as String?;
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _done = true);
      // After image is shown, play animation ~3.5s then navigate
      Future.delayed(const Duration(milliseconds: 3500), () {
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed(
          '/ai-results',
          arguments: {'lat': _lat, 'lng': _lng, 'label': _label, 'landId': _landId},
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Processing Satellite Data'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: _done
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Builder(builder: (context) {
                    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
                    final hide = (args?['role'] == 'buyer');
                    if (hide) return const SizedBox.shrink();
                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: StepProgress(currentStep: 4, totalSteps: 5, labels: ['Register', 'OTP', 'Map', 'Process', 'Result']),
                    );
                  }),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 220,
                    child: Image.network(
                      'https://via.placeholder.com/600x220.png?text=Satellite+Image+(${0})'
                          .replaceFirst('(${0})', '${_lat.toStringAsFixed(4)},${_lng.toStringAsFixed(4)}'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Satellite image acquired for your land',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(_label, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 24),
                  Container(
                    height: 140,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(
                            strokeWidth: 4,
                            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text('Calculating Carbon Credits...', 
                               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        const Text('AI is analyzing satellite data...', 
                               style: TextStyle(fontSize: 14, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Processing Satellite Data...'),
                ],
              ),
      ),
    );
  }
}


