part of 'swiper.dart';

abstract class _CustomLayoutStateBase<T extends _SubSwiper> extends State<T>
    with SingleTickerProviderStateMixin {
  double _swiperWidth = 0;
  double _swiperHeight = 0;
  late AnimationController _animationController;
  SwiperController get _controller => widget.controller;
  late int _startIndex;
  int? _animationCount;
  int _currentIndex = 0;
  int _moveGeneration = 0;
  Future<void> _pendingMove = Future<void>.value();
  final _pendingEvents = <IndexControllerEventBase>{};
  Size? _layoutSize;

  @override
  void initState() {
    _currentIndex = _ensureIndex(widget.index ?? 0);
    if (widget.itemWidth == null) {
      throw Exception(
        '==============\n\nwidget.itemWidth must not be null when use stack layout.\n========\n',
      );
    }

    _createAnimationController();
    _controller.addListener(_onController);
    super.initState();
  }

  void _createAnimationController() {
    _animationController = AnimationController(vsync: this, value: 0.5);
  }

  @override
  void didChangeDependencies() {
    WidgetsBinding.instance.addPostFrameCallback(_getSize);
    super.didChangeDependencies();
  }

  void _getSize(Duration _) {
    if (!mounted) return;
    afterRender();
  }

  @mustCallSuper
  void afterRender() {
    RenderObject renderObject = context.findRenderObject()!;
    Size size = renderObject.paintBounds.size;
    _swiperWidth = size.width;
    _swiperHeight = size.height;
    setState(() {});
  }

  @override
  void didUpdateWidget(T oldWidget) {
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(_onController);
      widget.controller.addListener(_onController);
    }

    if ((widget.index != oldWidget.index && widget.index != _currentIndex) ||
        widget.itemCount != oldWidget.itemCount ||
        widget.loop != oldWidget.loop) {
      _moveGeneration++;
      _animationController.stop();
      _animationController.value = 0.5;
      _lockScroll = false;
      _currentIndex = _ensureIndex(widget.index ?? _currentIndex);
    }
    if (widget.axisDirection != oldWidget.axisDirection ||
        widget.scrollDirection != oldWidget.scrollDirection ||
        widget.itemWidth != oldWidget.itemWidth ||
        widget.itemHeight != oldWidget.itemHeight) {
      WidgetsBinding.instance.addPostFrameCallback(_getSize);
    }

    super.didUpdateWidget(oldWidget);
  }

  int _ensureIndex(int index) {
    return normalizeSwiperIndex(index, widget.itemCount, widget.loop);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onController);
    _moveGeneration++;
    _animationController.dispose();
    for (final event in _pendingEvents) {
      event.complete();
    }
    _pendingEvents.clear();
    super.dispose();
  }

  Widget _buildItem(int i, int realIndex, double animationValue);

  Widget _buildContainer(List<Widget> list) {
    return Stack(children: list);
  }

  Widget _buildAnimation(BuildContext context, Widget? w) {
    List<Widget> list = [];

    double animationValue = _animationController.value;

    for (int i = 0; i < _animationCount! && widget.itemCount > 0; ++i) {
      int realIndex = _currentIndex + i + _startIndex;
      if (!widget.loop && (realIndex < 0 || realIndex >= widget.itemCount)) {
        continue;
      }
      realIndex %= widget.itemCount;

      if (widget.axisDirection == AxisDirection.right) {
        list.insert(0, _buildItem(i, realIndex, animationValue));
      } else {
        list.add(_buildItem(i, realIndex, animationValue));
      }
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: _onPanStart,
      onPanEnd: _onPanEnd,
      onPanUpdate: _onPanUpdate,
      onPanCancel: () {
        widget.onDragEnd?.call();
        _move(0.5);
      },
      child: ClipRect(child: Center(child: _buildContainer(list))),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_animationCount == null) {
      return Container();
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        if (_layoutSize != constraints.biggest) {
          _layoutSize = constraints.biggest;
          WidgetsBinding.instance.addPostFrameCallback(_getSize);
        }
        return AnimatedBuilder(
          animation: _animationController,
          builder: _buildAnimation,
        );
      },
    );
  }

  late double _currentValue;
  late double _currentPos;

  bool _lockScroll = false;

  Future<void> _move(
    double position, {
    int? nextIndex,
    bool animation = true,
  }) async {
    if (_lockScroll || !mounted || widget.itemCount == 0) return;
    final generation = _moveGeneration;
    _lockScroll = true;
    try {
      if (animation) {
        await _animationController
            .animateTo(
              position,
              duration: Duration(milliseconds: widget.duration!),
              curve: widget.curve,
            )
            .orCancel;
      }
      if (!mounted || generation != _moveGeneration) return;
      if (nextIndex != null) {
        _currentIndex = _ensureIndex(nextIndex);
        _animationController.value = 0.5;
        setState(() {});
        widget.onIndexChanged?.call(_currentIndex);
      }
    } on TickerCanceled {
      // Widget updates and disposal cancel the active transition.
    } finally {
      if (mounted && generation == _moveGeneration) {
        _lockScroll = false;
      }
    }
  }

  void _onController() {
    final event = widget.controller.event;
    if (event is! TargetedPositionControllerEvent) return;
    _pendingEvents.add(event);
    _pendingMove = _pendingMove.then((_) async {
      try {
        if (!mounted || widget.itemCount == 0) return;
        // A drag may already be settling when a command arrives.
        if (_lockScroll) {
          _moveGeneration++;
          _animationController.stop();
          _animationController.value = 0.5;
          _lockScroll = false;
        }
        final int nextIndex;
        if (event is StepBasedIndexControllerEvent) {
          nextIndex = event.calcNextIndex(
            currentIndex: _currentIndex,
            itemCount: widget.itemCount,
            loop: widget.loop,
            reverse: false,
          );
        } else if (event is MoveIndexControllerEvent) {
          nextIndex = event.newIndex;
        } else {
          return;
        }
        if (_ensureIndex(nextIndex) == _currentIndex) return;
        await _move(
          event.targetPosition,
          nextIndex: nextIndex,
          animation: event.animation,
        );
      } finally {
        event.complete();
        _pendingEvents.remove(event);
      }
    });
  }

  void _onPanEnd(DragEndDetails details) {
    widget.onDragEnd?.call();
    if (_lockScroll) return;

    double velocity = widget.scrollDirection == Axis.horizontal
        ? details.velocity.pixelsPerSecond.dx
        : details.velocity.pixelsPerSecond.dy;

    if (_animationController.value >= 0.75 || velocity > 500.0) {
      if (_currentIndex <= 0 && !widget.loop) {
        return;
      }
      _move(1.0, nextIndex: _currentIndex - 1);
    } else if (_animationController.value < 0.25 || velocity < -500.0) {
      if (_currentIndex >= widget.itemCount - 1 && !widget.loop) {
        return;
      }
      _move(0.0, nextIndex: _currentIndex + 1);
    } else {
      _move(0.5);
    }
  }

  void _onPanStart(DragStartDetails details) {
    if (_lockScroll) return;
    widget.onDragStart?.call();
    _currentValue = _animationController.value;
    _currentPos = widget.scrollDirection == Axis.horizontal
        ? details.globalPosition.dx
        : details.globalPosition.dy;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_lockScroll) return;
    final dimension = widget.scrollDirection == Axis.horizontal
        ? _swiperWidth
        : _swiperHeight;
    if (dimension <= 0 || widget.itemCount == 0) return;
    double value =
        _currentValue +
        ((widget.scrollDirection == Axis.horizontal
                    ? details.globalPosition.dx
                    : details.globalPosition.dy) -
                _currentPos) /
            dimension /
            2;
    // no loop ?
    if (!widget.loop) {
      if (_currentIndex >= widget.itemCount - 1) {
        if (value < 0.5) {
          value = 0.5;
        }
      } else if (_currentIndex <= 0) {
        if (value > 0.5) {
          value = 0.5;
        }
      }
    }

    _animationController.value = value;
  }
}

T _interpolateValue<T>(
  List<T> values,
  double animationValue,
  int index,
  T Function(T, T, double) lerp,
) {
  final adjacent = animationValue >= 0.5 ? index + 1 : index - 1;
  if (adjacent < 0 || adjacent >= values.length) return values[index];
  return lerp(
    values[index],
    values[adjacent],
    (animationValue - 0.5).abs() * 2,
  );
}

double _getValue(List<double> values, double animationValue, int index) =>
    _interpolateValue(
      values,
      animationValue,
      index,
      (a, b, t) => a + (b - a) * t,
    );

Offset _getOffsetValue(List<Offset> values, double animationValue, int index) =>
    _interpolateValue(
      values,
      animationValue,
      index,
      (a, b, t) => Offset.lerp(a, b, t)!,
    );

abstract class TransformBuilder<T> {
  final List<T> values;

  TransformBuilder({required this.values});

  Widget build(int i, double animationValue, Widget widget);
}

class ScaleTransformBuilder extends TransformBuilder<double> {
  final Alignment alignment;

  ScaleTransformBuilder({
    required super.values,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(int i, double animationValue, Widget widget) {
    double s = _getValue(values, animationValue, i);
    return Transform.scale(scale: s, alignment: alignment, child: widget);
  }
}

class OpacityTransformBuilder extends TransformBuilder<double> {
  OpacityTransformBuilder({required super.values});

  @override
  Widget build(int i, double animationValue, Widget widget) {
    double v = _getValue(values, animationValue, i);
    return Opacity(opacity: v, child: widget);
  }
}

class RotateTransformBuilder extends TransformBuilder<double> {
  RotateTransformBuilder({required super.values});

  @override
  Widget build(int i, double animationValue, Widget widget) {
    double v = _getValue(values, animationValue, i);
    return Transform.rotate(angle: v, child: widget);
  }
}

class TranslateTransformBuilder extends TransformBuilder<Offset> {
  TranslateTransformBuilder({required super.values});

  @override
  Widget build(int i, double animationValue, Widget widget) {
    Offset s = _getOffsetValue(values, animationValue, i);
    return Transform.translate(offset: s, child: widget);
  }
}

class CustomLayoutOption {
  final List<TransformBuilder> builders = [];
  final int startIndex;
  final int? stateCount;

  CustomLayoutOption({this.stateCount, required this.startIndex});

  void addOpacity(List<double> values) {
    builders.add(OpacityTransformBuilder(values: values));
  }

  void addTranslate(List<Offset> values) {
    builders.add(TranslateTransformBuilder(values: values));
  }

  void addScale(List<double> values, Alignment alignment) {
    builders.add(ScaleTransformBuilder(values: values, alignment: alignment));
  }

  void addRotate(List<double> values) {
    builders.add(RotateTransformBuilder(values: values));
  }
}

class _CustomLayoutSwiper extends _SubSwiper {
  final CustomLayoutOption option;

  const _CustomLayoutSwiper({
    required this.option,
    super.itemWidth,
    required super.loop,
    super.itemHeight,
    super.onIndexChanged,
    super.itemBuilder,
    required super.curve,
    super.duration,
    super.index,
    required super.itemCount,
    super.scrollDirection,
    required super.controller,
    super.onDragStart,
    super.onDragEnd,
  });

  @override
  State<StatefulWidget> createState() {
    return _CustomLayoutState();
  }
}

class _CustomLayoutState extends _CustomLayoutStateBase<_CustomLayoutSwiper> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _startIndex = widget.option.startIndex;
    _animationCount = widget.option.stateCount;
  }

  @override
  void didUpdateWidget(_CustomLayoutSwiper oldWidget) {
    _startIndex = widget.option.startIndex;
    _animationCount = widget.option.stateCount;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget _buildItem(int index, int realIndex, double animationValue) {
    List<TransformBuilder> builders = widget.option.builders;

    Widget child = SizedBox(
      width: widget.itemWidth ?? double.infinity,
      height: widget.itemHeight ?? double.infinity,
      child: widget.itemBuilder!(context, realIndex),
    );

    for (int i = builders.length - 1; i >= 0; --i) {
      TransformBuilder builder = builders[i];
      child = builder.build(index, animationValue, child);
    }

    return child;
  }
}
