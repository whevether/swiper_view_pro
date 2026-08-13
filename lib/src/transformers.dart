import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'transformer_page_view.dart';

/// 3D style used when [Swiper.enable3D] is true.
enum Swiper3DStyle {
  cube,
  threeD,
  flip,
  coverflow,
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
  }
}

double _position(TransformInfo info) => info.position ?? 0.0;

bool _isHorizontal(TransformInfo info) =>
    info.scrollDirection != Axis.vertical;

Matrix4 _perspectiveMatrix(double perspective) {
  return Matrix4.identity()..setEntry(3, 2, perspective);
}

/// Cube face rotation around the swipe axis.
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

    return Transform(
      alignment: alignment,
      transform: transform,
      child: child,
    );
  }
}

/// Classic 3D rotate (transformer_page_view ThreeDTransformer).
class ThreeDTransformer extends PageTransformer {
  final double perspective;

  ThreeDTransformer({this.perspective = 0.001});

  @override
  Widget transform(Widget child, TransformInfo info) {
    final position = _position(info);
    final width = info.width ?? 0.0;
    final height = info.height ?? 0.0;
    final horizontal = _isHorizontal(info);

    double pivotX = 0.0;
    double pivotY = height / 2;
    if (position < 0 && position >= -1) {
      if (horizontal) {
        pivotX = width;
      } else {
        pivotY = height;
      }
    }

    final transform = _perspectiveMatrix(perspective);
    if (horizontal) {
      transform.rotateY(position * 1.5);
    } else {
      transform.rotateX(-position * 1.5);
    }

    return Transform(
      transform: transform,
      origin: Offset(pivotX, pivotY),
      child: child,
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

/// Cover-flow: perspective rotate + scale.
class CoverflowTransformer extends PageTransformer {
  final double perspective;

  CoverflowTransformer({this.perspective = 0.001});

  @override
  Widget transform(Widget child, TransformInfo info) {
    final position = _position(info);
    final horizontal = _isHorizontal(info);
    final scale = (1 - position.abs() * 0.25).clamp(0.7, 1.0);
    final transform = _perspectiveMatrix(perspective);
    if (horizontal) {
      transform.rotateY(position * 0.85);
    } else {
      transform.rotateX(-position * 0.85);
    }

    return Transform(
      alignment: Alignment.center,
      transform: transform,
      child: Transform.scale(
        scale: scale,
        child: child,
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
