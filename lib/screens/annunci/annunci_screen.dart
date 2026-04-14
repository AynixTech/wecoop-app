import 'package:flutter/material.dart';

class AnnunciScreen extends StatelessWidget {
  const AnnunciScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Text(
            'Annunci',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2933),
            ),
          ),
        ),
      ),
    );
  }
}
