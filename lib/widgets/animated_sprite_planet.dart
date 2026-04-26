import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AnimatedSpritePlanet extends StatefulWidget {
  final String assetPath;
  final int frameCount;
  final int columns;
  final int rows;
  final Duration frameDuration;
  final bool animate;

  const AnimatedSpritePlanet({
    super.key,
    required this.assetPath,
    required this.frameCount,
    required this.columns,
    required this.rows,
    this.frameDuration = const Duration(milliseconds: 80),
    this.animate = true,
  });

  @override
  State<AnimatedSpritePlanet> createState() => _AnimatedSpritePlanetState();
}

class _AnimatedSpritePlanetState extends State<AnimatedSpritePlanet> {
  ui.Image? _image;
  Timer? _timer;
  int _frame = 0;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(covariant AnimatedSpritePlanet oldWidget) {
    super.didUpdateWidget(oldWidget);

    final assetChanged = oldWidget.assetPath != widget.assetPath;

    if (assetChanged) {
      _frame = 0;
      _timer?.cancel();
      _loadImage();
      return;
    }

    if (oldWidget.animate != widget.animate ||
        oldWidget.frameDuration != widget.frameDuration ||
        oldWidget.frameCount != widget.frameCount) {
      _frame = 0;

      if (widget.animate && _image != null) {
        _startAnimation();
      } else {
        _timer?.cancel();
        setState(() {});
      }
    }
  }

  Future<void> _loadImage() async {
    final data = await rootBundle.load(widget.assetPath);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();

    if (!mounted) {
      frame.image.dispose();
      return;
    }

    setState(() {
      _image?.dispose();
      _image = frame.image;
      _frame = 0;
    });

    if (widget.animate) {
      _startAnimation();
    }
  }

  void _startAnimation() {
    _timer?.cancel();

    if (!widget.animate || widget.frameCount <= 1) return;

    _timer = Timer.periodic(widget.frameDuration, (_) {
      if (!mounted || !widget.animate) return;

      setState(() {
        _frame = (_frame + 1) % widget.frameCount;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _image?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_image == null) {
      return const SizedBox.expand();
    }

    return CustomPaint(
      painter: _SpritePainter(
        image: _image!,
        frame: widget.animate ? _frame : 0,
        columns: widget.columns,
        rows: widget.rows,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _SpritePainter extends CustomPainter {
  final ui.Image image;
  final int frame;
  final int columns;
  final int rows;

  const _SpritePainter({
    required this.image,
    required this.frame,
    required this.columns,
    required this.rows,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final frameWidth = image.width / columns;
    final frameHeight = image.height / rows;

    final sourceX = (frame % columns) * frameWidth;
    final sourceY = (frame ~/ columns) * frameHeight;

    final src = Rect.fromLTWH(
      sourceX,
      sourceY,
      frameWidth,
      frameHeight,
    );

    final boxSize = min(size.width, size.height);

    final dst = Rect.fromLTWH(
      (size.width - boxSize) / 2,
      (size.height - boxSize) / 2,
      boxSize,
      boxSize,
    );

    canvas.drawImageRect(
      image,
      src,
      dst,
      Paint()
        ..filterQuality = FilterQuality.none
        ..isAntiAlias = false,
    );
  }

  @override
  bool shouldRepaint(covariant _SpritePainter oldDelegate) {
    return oldDelegate.frame != frame ||
        oldDelegate.image != image ||
        oldDelegate.columns != columns ||
        oldDelegate.rows != rows;
  }
}