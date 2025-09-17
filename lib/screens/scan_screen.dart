import 'package:flutter/material.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:permission_handler/permission_handler.dart';

class SoundScanPage extends StatefulWidget {
  const SoundScanPage({super.key});

  @override
  State<SoundScanPage> createState() => _SoundScanPageState();
}

class _SoundScanPageState extends State<SoundScanPage> {
  String resultText = "Tap to scan the environment";
  String statusText = "";
  IconData volumeIcon = Icons.volume_up;

  NoiseMeter? _noiseMeter;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _noiseMeter = NoiseMeter();
  }

  Future<void> startRealScan() async {
    // ✅ Ask for microphone permission
    var status = await Permission.microphone.request();
    if (!status.isGranted) {
      setState(() {
        resultText = "Microphone permission denied ❌";
        statusText = "Please enable mic access in settings.";
      });
      return;
    }

    setState(() {
      resultText = "Scanning...";
      statusText = "";
    });

    try {
      if (!_isRecording) {
        _isRecording = true;
        _noiseMeter!.noise.listen((event) {
          final double decibel = event.meanDecibel;

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
        }, onError: (err) {
          setState(() {
            resultText = "Error reading noise ❌";
            statusText = err.toString();
          });
          _isRecording = false;
        });
      }
    } catch (e) {
      setState(() {
        resultText = "Error starting scan ❌";
        statusText = e.toString();
      });
      _isRecording = false;
    }
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
              // ✅ Top Bar with Back Arrow
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

              // Scan Prompt
              const Text(
                "Tap to scan the environment",
                style: TextStyle(fontSize: 18, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Microphone Button
              GestureDetector(
                onTap: startRealScan,
                child: const CircleAvatar(
                  radius: 60,
                  backgroundColor: Color(0xFF3F7056),
                  child: Icon(Icons.mic, color: Colors.white, size: 50),
                ),
              ),
              const SizedBox(height: 50),

              // Result Box
              if (resultText != "Tap to scan the environment")
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFF3F7056),
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
