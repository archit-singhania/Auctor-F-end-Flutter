import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'premium/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: AuctorApp()));
}

class AuctorApp extends StatelessWidget {
  const AuctorApp({super.key});
  @override
  Widget build(BuildContext context) => const PremiumApp();
}
