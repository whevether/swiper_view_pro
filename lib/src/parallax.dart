import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';

import 'transformer_page_view.dart';

@Deprecated('Unused legacy callback; use CustomPainter instead.')
typedef PaintCallback = void Function(Canvas canvas, Size size);

class ColorPainter extends CustomPainter {
  final Paint _paint;
  final TransformInfo info;
  final List<Color> colors;

  ColorPainter(this._paint, this.info, this.colors);
  @Deprecated('Use Color.toARGB32 instead.')
  int colorToInt(Color color) => color.toARGB32();

  @override
  void paint(Canvas canvas, Size size) {
    if (colors.isEmpty) return;
    final index = info.fromIndex % colors.length;
    final rect = Offset.zero & size;
    _paint.color = colors[index];
    canvas.drawRect(rect, _paint);
    if (info.done ?? true) return;
    final forward = info.forward ?? true;
    final adjacent = index + (forward ? 1 : -1);
    if (!info.loop && (adjacent < 0 || adjacent >= colors.length)) return;
    final fraction = info.viewportFraction ?? 1;
    if (fraction <= 0) return;
    final position = (info.position ?? 0) / fraction;
    final opacity = forward
        ? (position <= 0 ? -position : 1 - position)
        : (position > 0 ? position : 1 + position);
    _paint.color = colors[adjacent % colors.length].withValues(
      alpha: opacity.clamp(0.0, 1.0),
    );
    canvas.drawRect(rect, _paint);
  }

  @override
  bool shouldRepaint(ColorPainter oldDelegate) {
    return oldDelegate.info != info || !listEquals(oldDelegate.colors, colors);
  }
}

class _ParallaxColorState extends State<ParallaxColor> {
  Paint paint = Paint();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ColorPainter(paint, widget.info, widget.colors),
      child: widget.child,
    );
  }
}

class ParallaxColor extends StatefulWidget {
  final Widget child;

  final List<Color> colors;

  final TransformInfo info;

  const ParallaxColor({
    super.key,
    required this.colors,
    required this.info,
    required this.child,
  });

  @override
  State<StatefulWidget> createState() {
    return _ParallaxColorState();
  }
}

class ParallaxContainer extends StatelessWidget {
  final Widget child;
  final double position;
  final double translationFactor;
  final double opacityFactor;

  const ParallaxContainer({
    super.key,
    required this.child,
    required this.position,
    this.translationFactor = 100.0,
    this.opacityFactor = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: (1 - position.abs()).clamp(0.0, 1.0) * opacityFactor,
      child: Transform.translate(
        offset: Offset(position * translationFactor, 0.0),
        child: child,
      ),
    );
  }
}

class ParallaxImage extends StatelessWidget {
  final Image image;
  final double imageFactor;

  ParallaxImage.asset(
    String name, {
    super.key,
    required double position,
    this.imageFactor = 0.3,
  }) : image = Image.asset(
         name,
         fit: BoxFit.cover,
         alignment: FractionalOffset(0.5 + position * imageFactor, 0.5),
       );

  @override
  Widget build(BuildContext context) {
    return image;
  }
}
