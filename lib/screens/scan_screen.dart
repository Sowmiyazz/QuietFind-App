import 'package:flutter/material.dart';
import 'dart:async'; // ✅ Needed for StreamSubscription
import 'package:noise_meter/noise_meter.dart';

class SoundScanPage extends StatefulWidget {
  const SoundScanPage({super.key});

  @override
  State<SoundScanPage> createState() => _SoundScanPageState();
}

class _SoundScanPageState extends State<SoundScanPage> {
  final NoiseMeter _noiseMeter = NoiseMeter();
  StreamSubscription<NoiseReading>? _noiseSubscription;

  bool isRecording = false;
  String resultText = "Tap mic to scan the environment";
  String statusText = "";

  void startScan() {
    // ✅ Updated: use noiseEvents instead of noiseStream
    _noiseSubscription = _noiseMeter.noise.listen((event) {
      double decibel = event.meanDecibel;

      String level = "";
      String suggestion = "";

      if (decibel < 40) {
        level = "Very Quiet 🌿";
        suggestion = "Perfect for Reading";
      } else if (decibel < 60) {
        level = "Moderate 🛋️";
        suggestion = "Ideal for Studying";
      } else {
        level = "Noisy 🔊";
        suggestion = "Avoid for Focus Tasks";
      }

      setState(() {
        resultText = "Detected: ${decibel.toStringAsFixed(1)} dB – $level";
        statusText = suggestion;
      });
    });
  }

  void stopScan() {
    _noiseSubscription?.cancel();
    _noiseSubscription = null;
    setState(() {
      isRecording = false;
    });
  }

  void toggleScan() {
    if (isRecording) {
      stopScan();
    } else {
      startScan();
      setState(() {
        isRecording = true;
      });
    }
  }

  @override
  void dispose() {
    _noiseSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6E9C84),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ✅ Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Sound Scan',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Icon(Icons.volume_up, color: Colors.white),
                ],
              ),
              const SizedBox(height: 60),

              // Instruction
              Text(
                isRecording ? "Listening..." : "Tap mic to scan the environment",
                style: const TextStyle(fontSize: 18, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Mic Button
              GestureDetector(
                onTap: toggleScan,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: isRecording ? Colors.red : const Color(0xFF3F7056),
                  child: Icon(
                    isRecording ? Icons.stop : Icons.mic,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),
              const SizedBox(height: 50),

              // Result Box
              if (resultText.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3F7056),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text(
                        resultText,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        statusText,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
