// ignore_for_file: constant_identifier_names

import 'package:material_ui/material_ui.dart';
import 'package:swiper_view_pro/swiper_view_pro.dart';

class WarmPainter extends BasePainter {
  WarmPainter(super.widget, super.page, super.index, super.paint);

  @override
  void draw(Canvas canvas, double space, double size, double radius) {
    final progress = page - index;
    final distance = size + space;
    final center = index * distance + radius;
    final activeRadius = widget.activeSize / 2;
    final left =
        center -
        activeRadius +
        (progress > 0.5 ? distance * (progress - 0.5) * 2 : 0);
    final right =
        center +
        activeRadius +
        (progress > 0.5 ? distance : distance * progress * 2);
    canvas.drawRRect(
      RRect.fromLTRBR(
        left,
        radius - activeRadius,
        right,
        radius + activeRadius,
        Radius.circular(activeRadius),
      ),
      _paint,
    );
  }
}

class DropPainter extends BasePainter {
  DropPainter(super.widget, super.page, super.index, super.paint);

  @override
  void draw(Canvas canvas, double space, double size, double radius) {
    double progress = page - index;
    double dropHeight = widget.dropHeight;
    double rate = (0.5 - progress).abs() * 2;
    double scale = widget.scale;

    canvas.drawCircle(
      Offset(
        radius + ((page) * (size + space)),
        radius - dropHeight * (1 - rate),
      ),
      widget.activeSize / 2 * (scale + rate * (1.0 - scale)),
      _paint,
    );
  }
}

class NonePainter extends BasePainter {
  NonePainter(super.widget, super.page, super.index, super.paint);

  @override
  void draw(Canvas canvas, double space, double size, double radius) {
    double progress = page - index;
    double secondOffset = index == widget.count - 1
        ? radius
        : radius + ((index + 1) * (size + space));

    if (progress > 0.5) {
      canvas.drawCircle(
        Offset(secondOffset, radius),
        widget.activeSize / 2,
        _paint,
      );
    } else {
      canvas.drawCircle(
        Offset(radius + (index * (size + space)), radius),
        widget.activeSize / 2,
        _paint,
      );
    }
  }
}

class SlidePainter extends BasePainter {
  SlidePainter(super.widget, super.page, super.index, super.paint);

  @override
  void draw(Canvas canvas, double space, double size, double radius) {
    canvas.drawCircle(
      Offset(radius + (page * (size + space)), radius),
      widget.activeSize / 2,
      _paint,
    );
  }
}

class ScalePainter extends BasePainter {
  ScalePainter(super.widget, super.page, super.index, super.paint);

  // 连续的两个点，含有最后一个和第一个
  @override
  bool _shouldSkip(int i) {
    if (index == widget.count - 1) {
      return i == 0 || i == index;
    }
    return (i == index || i == index + 1);
  }

  @override
  double get inactiveScale => widget.scale;

  @override
  void draw(Canvas canvas, double space, double size, double radius) {
    double secondOffset = index == widget.count - 1
        ? radius
        : radius + ((index + 1) * (size + space));

    double progress = page - index;
    _paint.color = Color.lerp(widget.activeColor, widget.color, progress)!;
    //last
    canvas.drawCircle(
      Offset(radius + (index * (size + space)), radius),
      lerp(widget.activeSize / 2, radius * widget.scale, progress),
      _paint,
    );
    //first
    _paint.color = Color.lerp(widget.color, widget.activeColor, progress)!;
    canvas.drawCircle(
      Offset(secondOffset, radius),
      lerp(radius * widget.scale, widget.activeSize / 2, progress),
      _paint,
    );
  }
}

class ColorPainter extends BasePainter {
  ColorPainter(super.widget, super.page, super.index, super.paint);

  // 连续的两个点，含有最后一个和第一个
  @override
  bool _shouldSkip(int i) {
    if (index == widget.count - 1) {
      return i == 0 || i == index;
    }
    return (i == index || i == index + 1);
  }

  @override
  void draw(Canvas canvas, double space, double size, double radius) {
    double progress = page - index;
    double secondOffset = index == widget.count - 1
        ? radius
        : radius + ((index + 1) * (size + space));

    _paint.color = Color.lerp(widget.activeColor, widget.color, progress)!;
    //left
    canvas.drawCircle(
      Offset(radius + (index * (size + space)), radius),
      lerp(widget.activeSize / 2, radius, progress),
      _paint,
    );
    //right
    _paint.color = Color.lerp(widget.color, widget.activeColor, progress)!;
    canvas.drawCircle(
      Offset(secondOffset, radius),
      lerp(radius, widget.activeSize / 2, progress),
      _paint,
    );
  }
}

abstract class BasePainter extends CustomPainter {
  final PageIndicator widget;
  final double page;
  final int index;
  final Paint _paint;

  double lerp(double begin, double end, double progress) {
    return begin + (end - begin) * progress;
  }

  BasePainter(this.widget, this.page, this.index, Paint paint) : _paint = paint;

  void draw(Canvas canvas, double space, double size, double radius);

  double get inactiveScale => 1;

  bool _shouldSkip(int i) {
    return false;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final padding = widget.paintPadding;
    canvas.save();
    canvas.translate(padding, padding);
    _paint.color = widget.color;
    double space = widget.space;
    double size = widget.size;
    double radius = size / 2;
    int c = widget.count;
    for (int i = 0; i < c; ++i) {
      if (_shouldSkip(i)) {
        continue;
      }
      canvas.drawCircle(
        Offset(i * (size + space) + radius, radius),
        radius * inactiveScale,
        _paint,
      );
    }

    _paint.color = widget.activeColor;
    draw(canvas, space, size, radius);
    canvas.restore();
  }

  @override
  bool shouldRepaint(BasePainter oldDelegate) {
    final old = oldDelegate.widget;
    return oldDelegate.page != page ||
        oldDelegate.index != index ||
        old.count != widget.count ||
        old.size != widget.size ||
        old.activeSize != widget.activeSize ||
        old.space != widget.space ||
        old.color != widget.color ||
        old.activeColor != widget.activeColor ||
        old.scale != widget.scale ||
        old.dropHeight != widget.dropHeight ||
        old.layout != widget.layout;
  }
}

class _PageIndicatorState extends State<PageIndicator> {
  int index = 0;
  double page = 0;
  final Paint _paint = Paint();

  BasePainter _createPainter() {
    switch (widget.layout) {
      case PageIndicatorLayout.NONE:
        return NonePainter(widget, page, index, _paint);
      case PageIndicatorLayout.SLIDE:
        return SlidePainter(widget, page, index, _paint);
      case PageIndicatorLayout.WARM:
        return WarmPainter(widget, page, index, _paint);
      case PageIndicatorLayout.COLOR:
        return ColorPainter(widget, page, index, _paint);
      case PageIndicatorLayout.SCALE:
        return ScalePainter(widget, page, index, _paint);
      case PageIndicatorLayout.DROP:
        return DropPainter(widget, page, index, _paint);
      default:
        throw Exception("Not a valid layout");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.count <= 0) return const SizedBox.shrink();
    Widget child = SizedBox(
      width:
          widget.count * widget.size +
          (widget.count - 1) * widget.space +
          widget.paintPadding * 2,
      height: widget.size + widget.paintPadding * 2,
      child: CustomPaint(painter: _createPainter()),
    );

    if (widget.layout == PageIndicatorLayout.SCALE ||
        widget.layout == PageIndicatorLayout.COLOR) {
      child = ClipRect(child: child);
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: widget.onDotTap == null
          ? null
          : (details) {
              final slot = widget.size + widget.space;
              if (slot <= 0) return;
              final i =
                  ((details.localPosition.dx - widget.paintPadding) / slot)
                      .floor()
                      .clamp(0, widget.count - 1);
              widget.onDotTap!(i);
            },
      child: child,
    );
  }

  void _setInitialPage() {
    final controller = widget.controller;
    final initial = controller is TransformerPageController
        ? controller
              .getRenderIndexFromRealIndex(controller.initialPage)
              .toDouble()
        : controller.initialPage.toDouble();
    page = controller.hasClients && controller.position.hasContentDimensions
        ? controller.page ?? initial
        : initial;
    if (widget.count <= 0) {
      page = 0;
    } else if (controller is TransformerPageController && controller.loop) {
      page %= widget.count;
    } else {
      page = page.clamp(0.0, (widget.count - 1).toDouble());
    }
    index = page.floor();
  }

  void _onController() {
    if (!widget.controller.hasClients) return;
    setState(_setInitialPage);
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onController);
    _setInitialPage();
  }

  @override
  void didUpdateWidget(PageIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(_onController);
      widget.controller.addListener(_onController);
    }
    _setInitialPage();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onController);
    super.dispose();
  }
}

enum PageIndicatorLayout { NONE, SLIDE, WARM, COLOR, SCALE, DROP }

class PageIndicator extends StatefulWidget {
  /// size of the dots
  final double size;

  /// space between dots.
  final double space;

  /// count of dots
  final int count;

  /// active color
  final Color activeColor;

  /// normal color
  final Color color;

  /// layout of the dots,default is [PageIndicatorLayout.SLIDE]
  final PageIndicatorLayout? layout;

  // Only valid when layout==PageIndicatorLayout.scale
  final double scale;

  // Only valid when layout==PageIndicatorLayout.drop
  final double dropHeight;

  final PageController controller;

  final double activeSize;

  final ValueChanged<int>? onDotTap;

  const PageIndicator({
    super.key,
    this.size = 20.0,
    this.space = 5.0,
    required this.count,
    double? activeSize,
    required this.controller,
    this.color = Colors.white30,
    this.layout = PageIndicatorLayout.SLIDE,
    this.activeColor = Colors.white,
    this.scale = 0.6,
    this.dropHeight = 20.0,
    this.onDotTap,
  }) : activeSize = activeSize ?? size,
       assert(count >= 0),
       assert(size > 0),
       assert(activeSize == null || activeSize > 0);

  double get paintPadding => activeSize > size ? (activeSize - size) / 2 : 0;

  @override
  State<StatefulWidget> createState() {
    return _PageIndicatorState();
  }
}
