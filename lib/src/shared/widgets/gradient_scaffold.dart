import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class GradientScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;

  const GradientScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: Stack(
        children: [
          // Animated Mesh Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        const Color(0xFF1A1A2E),
                        const Color(0xFF16213E),
                        const Color(0xFF0F3460),
                        const Color(0xFF301B5E), // Deep Purple
                      ]
                    : [
                        const Color(0xFFFDFBF7),
                        const Color(0xFFE2E2E2),
                        const Color(0xFFD1C4E9), // Light Purple
                        const Color(0xFFB2DFDB), // Light Teal
                      ],
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
           .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.05, 1.05), duration: 5000.ms, curve: Curves.easeInOut),
           
          // Content
          SafeArea(child: body),
        ],
      ),
    );
  }
}
