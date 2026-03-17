import 'package:flutter/material.dart';

import 'ui/app_pressable_scale.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.title,
    required this.body,
    super.key,
    this.floatingActionButton,
    this.animateBody = true,
  });

  final String title;
  final Widget body;
  final Widget? floatingActionButton;
  final bool animateBody;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
          child: animateBody
              ? TweenAnimationBuilder<double>(
                  key: ValueKey(title),
                  duration: const Duration(milliseconds: 240),
                  tween: Tween(begin: 0, end: 1),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) => Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, (1 - value) * 8),
                      child: child,
                    ),
                  ),
                  child: body,
                )
              : body,
        ),
      ),
      floatingActionButton: floatingActionButton == null
          ? null
          : AppPressableScale(child: floatingActionButton!),
    );
  }
}
