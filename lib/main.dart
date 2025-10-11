import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ Add this line to test Firestore after initialization
  await testFirestoreConnection();

  runApp(const MyApp());
}

// ✅ Firestore test function
Future<void> testFirestoreConnection() async {
  try {
    final snapshot = await FirebaseFirestore.instance.collection('places').get();
    for (var doc in snapshot.docs) {
      print('${doc.id} → ${doc.data()}');
    }

    if (snapshot.docs.isEmpty) {
      print('No documents found in "places" collection.');
    } else {
      print('✅ Firestore connection successful!');
    }
  } catch (e) {
    print('❌ Firestore connection failed: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuietFind',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home: const SplashScreen(),
    );
  }
}
