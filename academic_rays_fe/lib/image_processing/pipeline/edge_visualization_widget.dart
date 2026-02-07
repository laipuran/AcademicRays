import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class EdgeVisualizationWidget extends StatefulWidget {
  final Uint8List imageData;
  final List<Offset> points;

  const EdgeVisualizationWidget({
    super.key,
    required this.imageData,
    required this.points,
  });

  @override
  State<EdgeVisualizationWidget> createState() =>
      _EdgeVisualizationWidgetState();
}

class _EdgeVisualizationWidgetState extends State<EdgeVisualizationWidget> {
  ui.Image? _image;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void dispose() {
    _image?.dispose();
    super.dispose();
  }

  Future<void> _loadImage() async {
    final ui.ImmutableBuffer buffer = await ui.ImmutableBuffer.fromUint8List(
      widget.imageData,
    );
    
    final ui.ImageDescriptor descriptor = await ui.ImageDescriptor.encoded(
      buffer,
    );
    buffer.dispose();
    
    final ui.Codec codec = await descriptor.instantiateCodec();
    descriptor.dispose();
    
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    codec.dispose();

    if (mounted) {
      setState(() {
        _image = frameInfo.image;
      });
    } else {
      frameInfo.image.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_image == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edge Detection Result')),
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              maxScale: 10.0,
              child: AspectRatio(
                aspectRatio: _image!.width / _image!.height,
                child: CustomPaint(
                  painter: _EdgePainter(_image!, widget.points),
                  child: Container(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EdgePainter extends CustomPainter {
  final ui.Image image;
  final List<Offset> points;

  _EdgePainter(this.image, this.points);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw the image scaled to fit the size
    paintImage(
      canvas: canvas,
      rect: Offset.zero & size,
      image: image,
      fit: BoxFit.contain,
    );

    if (points.isEmpty) return;

    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round;

    // Calculate scale
    final double scaleX = size.width / image.width;
    final double scaleY = size.height / image.height;
    final double scale = scaleX < scaleY ? scaleX : scaleY;

    // Offset for fit: BoxFit.contain
    final double offsetX = (size.width - image.width * scale) / 2;
    final double offsetY = (size.height - image.height * scale) / 2;

    final List<Offset> scaledPoints = points.map((p) {
      return Offset(p.dx * scale + offsetX, p.dy * scale + offsetY);
    }).toList();

    // Draw lines
    final path = Path();
    path.moveTo(scaledPoints[0].dx, scaledPoints[0].dy);
    for (int i = 1; i < scaledPoints.length; i++) {
      path.lineTo(scaledPoints[i].dx, scaledPoints[i].dy);
    }
    path.close();
    canvas.drawPath(path, paint);

    // Draw points
    canvas.drawPoints(ui.PointMode.points, scaledPoints, pointPaint);

    // label points
    for (int i = 0; i < scaledPoints.length; i++) {
      final textSpan = TextSpan(
        text: '$i',
        style: const TextStyle(
          color: Colors.yellow,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, scaledPoints[i] + const Offset(5, 5));
    }
  }

  @override
  bool shouldRepaint(covariant _EdgePainter oldDelegate) {
    return oldDelegate.image != image || oldDelegate.points != points;
  }
}
