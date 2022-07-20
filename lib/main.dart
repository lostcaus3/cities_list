import 'package:city_list/screens/homepage.dart';
import 'package:city_list/screens/loading.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    initialRoute: '/homepage',
    routes: {
      '/': (context) => const Loading(),
      '/homepage': (context) => const Homepage()
    },
  ));
}
