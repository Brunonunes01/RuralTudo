import 'dart:async';

import 'package:flutter/material.dart';

class AppAnimatedEntry extends StatefulWidget {
  const AppAnimatedEntry({
    required this.child,
    super.key,
    this.index = 0,
    this.delayStep = const Duration(milliseconds: 45),
    this.duration = const Duration(milliseconds: 280),
    this.yOffset = 14,
  });

  final Widget child;
  final int index;
  final Duration delayStep;
  final Duration duration;
  final double yOffset;

  @override
  State<AppAnimatedEntry> createState() => _AppAnimatedEntryState();
}

class _AppAnimatedEntryState extends State<AppAnimatedEntry>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  Timer? _delayTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _fade = Tween<double>(begin: 0, end: 1).animate(curved);
    _slide = Tween<Offset>(
      begin: Offset(0, widget.yOffset / 100),
      end: Offset.zero,
    ).animate(curved);

    final delayMs = widget.delayStep.inMilliseconds * widget.index.clamp(0, 20);
    _delayTimer = Timer(Duration(milliseconds: delayMs), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
