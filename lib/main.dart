import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/locale_provider.dart';
import 'app.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => LocaleProvider(),
      child: const WECOOPApp(),
    ),
  );
}
