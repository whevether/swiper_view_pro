import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'transformer_page_view.dart';

/// 3D style used when [Swiper.enable3D] is true.
enum Swiper3DStyle {
  /// Cube faces rotate in place around the shared edge.
  cube,

  /// Page rotates from its center and recedes in Z.
  threeD,

  /// Card flips 180° around the swipe axis.
  flip,

  /// Cover-flow: neighbors rotate, scale, and sit in a row.
  coverflow,

  /// Pages sit on a 3D cylinder.
  carousel,

  /// Stacked cards; the top card flies off with a 3D twist.
  cards,

  /// Pages swing around the bottom edge like a rotary card.
  rotate,
}

PageTransformer build3DTransformer(
  Swiper3DStyle style, {
  double perspective = 0.001,
}) {
  switch (style) {
    case Swiper3DStyle.cube:
      return CubeTransformer(perspective: perspective);
    case Swiper3DStyle.threeD:
      return ThreeDTransformer(perspective: perspective);
    case Swiper3DStyle.flip:
      return FlipTransformer(perspective: perspective);
    case Swiper3DStyle.coverflow:
      return CoverflowTransformer(perspective: perspective);
    case Swiper3DStyle.carousel:
      return CarouselTransformer(perspective: perspective);
    case Swiper3DStyle.cards:
      return CardsTransformer(perspective: perspective);
    case Swiper3DStyle.rotate:
      return RotateTransformer(perspective: perspective);
  }
}

double _position(TransformInfo info) => info.position ?? 0.0;

bool _isHorizontal(TransformInfo info) =>
    info.scrollDirection != Axis.vertical;

Matrix4 _perspectiveMatrix(double perspective) {
  return Matrix4.identity()..setEntry(3, 2, perspective);
}

/// Undo the PageView slide so pages can share the same origin.
Offset _counteractSlide(TransformInfo info) {
  final position = _position(info);
  final width = info.width ?? 0.0;
  final height = info.height ?? 0.0;
  if (_isHorizontal(info)) {
    return Offset(-position * width, 0.0);
  }
  return Offset(0.0, -position * height);
}

Widget _faceShade(Widget child, double amount) {
  if (amount <= 0) return child;
  return DecoratedBox(
    position: DecorationPosition.foreground,
    decoration: BoxDecoration(
      color: Color.fromRGBO(0, 0, 0, amount.clamp(0.0, 1.0)),
    ),
    child: child,
  );
}

/// Cube faces rotate in place around the inner edge.
class CubeTransformer extends PageTransformer {
  final double perspective;

  CubeTransformer({this.perspective = 0.001});

  @override
  Widget transform(Widget child, TransformInfo info) {
    final position = _position(info);
    final horizontal = _isHorizontal(info);
    final transform = _perspectiveMatrix(perspective);
    if (horizontal) {
      transform.rotateY(position * math.pi / 2);
    } else {
      transform.rotateX(-position * math.pi / 2);
    }

    final Alignment alignment;
    if (horizontal) {
      alignment =
          position <= 0 ? Alignment.centerRight : Alignment.centerLeft;
    } else {
      alignment =
          position <= 0 ? Alignment.bottomCenter : Alignment.topCenter;
    }

    final scale = 1 - 0.12 * math.sin(position.abs() * math.pi / 2);
    transform.scaleByDouble(scale, scale, 1.0, 1.0);

    return Transform.translate(
      offset: _counteractSlide(info),
      child: Transform(
        alignment: alignment,
        transform: transform,
        child: _faceShade(child, position.abs() * 0.5),
      ),
    );
  }
}

/// Center-pivot 3D rotate: the page turns and recedes into the distance.
class ThreeDTransformer extends PageTransformer {
  final double perspective;

  ThreeDTransformer({this.perspective = 0.001});

  @override
  Widget transform(Widget child, TransformInfo info) {
    final position = _position(info);
    final width = info.width ?? 0.0;
    final height = info.height ?? 0.0;
    final horizontal = _isHorizontal(info);
    final depth = (horizontal ? width : height) * 0.65;

    final transform = _perspectiveMatrix(perspective);
    transform.translateByDouble(0.0, 0.0, -position.abs() * depth, 1.0);
    if (horizontal) {
      transform.rotateY(position * 0.85);
    } else {
      transform.rotateX(-position * 0.85);
    }

    final scale = (1 - position.abs() * 0.28).clamp(0.6, 1.0);

    return Opacity(
      opacity: (1 - position.abs() * 0.25).clamp(0.55, 1.0),
      child: Transform(
        alignment: Alignment.center,
        transform: transform,
        child: Transform.scale(
          scale: scale,
          child: child,
        ),
      ),
    );
  }
}

/// Card flip around the swipe axis.
class FlipTransformer extends PageTransformer {
  final double perspective;

  FlipTransformer({this.perspective = 0.001});

  @override
  Widget transform(Widget child, TransformInfo info) {
    final position = _position(info);
    final horizontal = _isHorizontal(info);
    final transform = _perspectiveMatrix(perspective);
    if (horizontal) {
      transform.rotateY(position * math.pi);
    } else {
      transform.rotateX(-position * math.pi);
    }

    return Transform(
      alignment: Alignment.center,
      transform: transform,
      child: child,
    );
  }
}

/// Cover-flow: perspective rotate + scale, pages stay in a row.
class CoverflowTransformer extends PageTransformer {
  final double perspective;

  CoverflowTransformer({this.perspective = 0.001});

  @override
  Widget transform(Widget child, TransformInfo info) {
    final position = _position(info);
    final horizontal = _isHorizontal(info);
    final scale = (1 - position.abs() * 0.32).clamp(0.62, 1.0);
    final transform = _perspectiveMatrix(perspective);
    transform.translateByDouble(0.0, 0.0, -position.abs() * 90, 1.0);
    if (horizontal) {
      transform.rotateY(position * 1.05);
    } else {
      transform.rotateX(-position * 1.05);
    }

    return Transform(
      alignment: Alignment.center,
      transform: transform,
      child: Transform.scale(
        scale: scale,
        child: _faceShade(child, position.abs() * 0.28),
      ),
    );
  }
}

/// Pages sit on a 3D cylinder. Works best with `viewportFraction` around 0.7.
class CarouselTransformer extends PageTransformer {
  final double perspective;

  CarouselTransformer({this.perspective = 0.001});

  @override
  Widget transform(Widget child, TransformInfo info) {
    final position = _position(info);
    final width = info.width ?? 0.0;
    final height = info.height ?? 0.0;
    final horizontal = _isHorizontal(info);
    final size = horizontal ? width : height;
    final radius = size * 0.72;
    final angle = position * 1.15;

    final transform = _perspectiveMatrix(perspective);
    transform.translateByDouble(0.0, 0.0, -radius, 1.0);
    if (horizontal) {
      transform.rotateY(angle);
    } else {
      transform.rotateX(-angle);
    }
    transform.translateByDouble(0.0, 0.0, radius, 1.0);

    final scale = (1 - position.abs() * 0.14).clamp(0.72, 1.0);

    return Transform.translate(
      offset: _counteractSlide(info),
      child: Transform(
        alignment: Alignment.center,
        transform: transform,
        child: Transform.scale(
          scale: scale,
          child: _faceShade(child, position.abs() * 0.32),
        ),
      ),
    );
  }
}

/// Stacked cards: the leaving card twists away, the next cards stay stacked.
class CardsTransformer extends PageTransformer {
  final double perspective;

  CardsTransformer({this.perspective = 0.001});

  @override
  Widget transform(Widget child, TransformInfo info) {
    final position = _position(info);
    final width = info.width ?? 0.0;
    final height = info.height ?? 0.0;
    final horizontal = _isHorizontal(info);
    final transform = _perspectiveMatrix(perspective);

    if (position <= 0) {
      final progress = position.abs();
      if (horizontal) {
        transform
          ..rotateY(position * 0.7)
          ..rotateZ(position * 0.22);
      } else {
        transform
          ..rotateX(-position * 0.7)
          ..rotateZ(-position * 0.22);
      }
      return Transform(
        alignment: Alignment.center,
        transform: transform,
        child: Transform.translate(
          offset: horizontal
              ? Offset(width * position * 0.2, progress * 28)
              : Offset(progress * 28, height * position * 0.2),
          child: child,
        ),
      );
    }

    final scale = (1 - position * 0.12).clamp(0.78, 1.0);
    transform.translateByDouble(0.0, 0.0, -position * 70, 1.0);
    final stacked = horizontal
        ? Offset(-width * position, position * 16)
        : Offset(position * 16, -height * position);

    return Transform.translate(
      offset: stacked,
      child: Transform(
        alignment: Alignment.center,
        transform: transform,
        child: Transform.scale(
          scale: scale,
          child: _faceShade(child, position * 0.22),
        ),
      ),
    );
  }
}

/// Rotary swing around the bottom edge with a 3D tilt.
class RotateTransformer extends PageTransformer {
  final double perspective;

  RotateTransformer({this.perspective = 0.001});

  @override
  Widget transform(Widget child, TransformInfo info) {
    final position = _position(info);
    final horizontal = _isHorizontal(info);
    final transform = _perspectiveMatrix(perspective);
    transform.rotateZ(position * math.pi / 2.4);
    if (horizontal) {
      transform.rotateY(position * 0.5);
    } else {
      transform.rotateX(-position * 0.5);
    }

    final scale = (1 - position.abs() * 0.18).clamp(0.7, 1.0);

    return Opacity(
      opacity: (1 - position.abs() * 0.35).clamp(0.4, 1.0),
      child: Transform(
        alignment: Alignment.bottomCenter,
        transform: transform,
        child: Transform.scale(
          scale: scale,
          child: child,
        ),
      ),
    );
  }
}

/// Accordion fold from the inner edge.
class AccordionTransformer extends PageTransformer {
  AccordionTransformer();

  @override
  Widget transform(Widget child, TransformInfo info) {
    final position = _position(info);
    final horizontal = _isHorizontal(info);
    if (position < 0.0) {
      return Transform.scale(
        scale: 1 + position,
        alignment: horizontal ? Alignment.centerRight : Alignment.bottomCenter,
        child: child,
      );
    }
    return Transform.scale(
      scale: 1 - position,
      alignment: horizontal ? Alignment.centerLeft : Alignment.topCenter,
      child: child,
    );
  }
}

/// Incoming page zooms in while the current page stays put.
class ZoomInPageTransformer extends PageTransformer {
  ZoomInPageTransformer();

  @override
  Widget transform(Widget child, TransformInfo info) {
    final position = _position(info);
    final width = info.width ?? 0.0;
    final height = info.height ?? 0.0;
    final horizontal = _isHorizontal(info);
    if (position > 0 && position <= 1) {
      return Transform.translate(
        offset: horizontal
            ? Offset(-width * position, 0.0)
            : Offset(0.0, -height * position),
        child: Transform.scale(
          scale: 1 - position,
          child: child,
        ),
      );
    }
    return child;
  }
}

/// Pages shrink and fade as they leave the center.
class ZoomOutPageTransformer extends PageTransformer {
  static const double minScale = 0.85;
  static const double minAlpha = 0.5;

  ZoomOutPageTransformer();

  @override
  Widget transform(Widget child, TransformInfo info) {
    final position = _position(info);
    if (position >= -1 && position <= 1) {
      final scaleFactor = minScale + (1 - minScale) * (1 - position.abs());
      final fadeFactor = minAlpha + (1 - minAlpha) * (1 - position.abs());
      return Opacity(
        opacity: fadeFactor.clamp(0.0, 1.0),
        child: Transform.scale(
          scale: scaleFactor,
          child: child,
        ),
      );
    }
    return child;
  }
}

/// Depth stack: the leaving page stays, the next page slides over it.
class DepthPageTransformer extends PageTransformer {
  static const double minScale = 0.75;

  DepthPageTransformer() : super(reverse: true);

  @override
  Widget transform(Widget child, TransformInfo info) {
    final position = _position(info);
    if (position <= 0) {
      return child;
    }
    if (position <= 1) {
      final scaleFactor = minScale + (1 - minScale) * (1 - position);
      final width = info.width ?? 0.0;
      final height = info.height ?? 0.0;
      final horizontal = _isHorizontal(info);
      return Opacity(
        opacity: (1 - position).clamp(0.0, 1.0),
        child: Transform.translate(
          offset: horizontal
              ? Offset(width * -position, 0.0)
              : Offset(0.0, height * -position),
          child: Transform.scale(
            scale: scaleFactor,
            child: child,
          ),
        ),
      );
    }
    return child;
  }
}

/// Scale + fade, used when [Swiper.scale] / [Swiper.fade] are set.
class ScaleAndFadeTransformer extends PageTransformer {
  final double? _scale;
  final double? _fade;

  ScaleAndFadeTransformer({double? fade = 0.3, double? scale = 0.8})
      : _fade = fade,
        _scale = scale;

  @override
  Widget transform(Widget child, TransformInfo info) {
    final position = _position(info);
    Widget newChild = child;
    if (_scale != null) {
      final scaleFactor = (1 - position.abs()) * (1 - _scale!);
      final scale = _scale! + scaleFactor;
      newChild = Transform.scale(
        scale: scale,
        child: child,
      );
    }

    if (_fade != null) {
      final fadeFactor = (1 - position.abs()) * (1 - _fade!);
      final opacity = (_fade! + fadeFactor).clamp(0.0, 1.0);
      newChild = Opacity(
        opacity: opacity,
        child: newChild,
      );
    }

    return newChild;
  }
}
