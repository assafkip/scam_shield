import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/detection.dart';
import '../core/models.dart';

class CheckScreen extends StatefulWidget {
  const CheckScreen({super.key});
  @override
  State<CheckScreen> createState() => _CheckScreenState();
}

class _CheckScreenState extends State<CheckScreen> {
  static const platform = MethodChannel('app.channel.scamshield');
  final _controller = TextEditingController();
  DetectionResult? _result;

  @override
  void initState() {
    super.initState();
    platform.setMethodCallHandler(_handleMethodCall);
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    if (call.method == 'processText') {
      _controller.text = call.arguments as String;
      _run();
    }
  }

  void _run() => setState(() => _result = Detector.analyze(_controller.text));

  @override
  Widget build(BuildContext context) {
    final r = _result;
    return Scaffold(
      appBar: AppBar(title: const Text('ScamShield — Check')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _controller,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: 'Paste a suspicious message…',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _run,
              icon: const Icon(Icons.search),
              label: const Text('Analyze'),
            ),
            if (r != null) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(value: r.riskScore, minHeight: 8),
              const SizedBox(height: 8),
              Text('${r.riskLabel}: ${(r.riskScore * 100).round()}%',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: r.hits
                    .map((h) => Chip(label: Text('${h.label} • ${h.tactic}')))
                    .toList(),
              ),
              const SizedBox(height: 8),
              ...r.suggestions.map((s) => ListTile(
                    leading: const Icon(Icons.shield_outlined),
                    title: Text(s),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}
