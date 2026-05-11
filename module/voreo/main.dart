import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'main_app.dart';
import 'interface.dart';
import 'light_handle.dart';

Future<void> mainApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await initServices();

  // Initialize controllers
  await initControllers();

  // Initialize interface
  await Interface().prevInitialize();

  runApp(const MyApp());
}
