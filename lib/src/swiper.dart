// ignore_for_file: constant_identifier_names

import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:swiper_view_pro/swiper_view_pro.dart';

part 'custom_layout.dart';

typedef SwiperOnTap = void Function(int index);

typedef SwiperDataBuilder<T> = Widget Function(
    BuildContext context, T data, int index);

/// default auto play delay
const int kDefaultAutoplayDelayMs = 3000;

///  Default auto play transition duration (in millisecond)
const int kDefaultAutoplayTransactionDuration = 300;

const int kMaxValue = 2000000000;
const int kMiddleValue = 1000000000;

enum SwiperLayout {
  DEFAULT,
  STACK,
  TINDER,
  CUSTOM,
}

class Swiper extends StatefulWidget {
  /// If set true , the pagination will display 'outer' of the 'content' container.
  final bool outer;

  /// Inner item height, this property is valid if layout=STACK or layout=TINDER or LAYOUT=CUSTOM,
  final double? itemHeight;

  /// Inner item width, this property is valid if layout=STACK or layout=TINDER or LAYOUT=CUSTOM,
  final double? itemWidth;

  // height of the inside container,this property is valid when outer=true,otherwise the inside container size is controlled by parent widget
  final double? containerHeight;
  // width of the inside container,this property is valid when outer=true,otherwise the inside container size is controlled by parent widget
  final double? containerWidth;

  /// Build item on index
  final IndexedWidgetBuilder? itemBuilder;

  /// Support transform like Android PageView did.
  /// `itemBuilder` and `transformer` must have one not null.
  final PageTransformer? transformer;

  /// count of the display items
  final int itemCount;

  final ValueChanged<int>? onIndexChanged;

  ///auto play config
  final bool autoplay;

  ///Duration of the animation between transactions (in millisecond).
  final int autoplayDelay;

  ///disable auto play when interaction
  final bool autoplayDisableOnInteraction;

  ///auto play transition duration (in millisecond)
  final int duration;

  ///horizontal/vertical
  final Axis scrollDirection;

  ///left/right for Stack Layout
  final AxisDirection axisDirection;

  ///transition curve
  final Curve curve;

  /// Set to false to disable continuous loop mode.
  final bool loop;

  ///Index number of initial slide.
  ///If not set , the `Swiper` is 'uncontrolled', which means manage index by itself
  ///If set , the `Swiper` is 'controlled', which means the index is fully managed by parent widget.
  final int? index;

  ///Called when tap
  final SwiperOnTap? onTap;

  ///The swiper pagination plugin
  final SwiperPlugin? pagination;

  ///the swiper control button plugin
  final SwiperPlugin? control;

  ///other plugins, you can custom your own plugin
  final List<SwiperPlugin>? plugins;

  ///
  final SwiperController? controller;

  final ScrollPhysics? physics;

  ///
  final double viewportFraction;

  /// Build in layouts
  final SwiperLayout layout;

  /// this value is valid when layout == SwiperLayout.CUSTOM
  final CustomLayoutOption? customLayoutOption;

  // This value is valid when viewportFraction is set and < 1.0
  final double? scale;

  // This value is valid when viewportFraction is set and < 1.0
  final double? fade;

  /// 3D effect switch. Only applies when [layout] is [SwiperLayout.DEFAULT]
  /// and [transformer] is null.
  final bool enable3D;

  /// 3D style used when [enable3D] is true.
  ///
  /// [Swiper3DStyle.coverflow] and [Swiper3DStyle.carousel] look best with
  /// `viewportFraction` around 0.7–0.75.
  final Swiper3DStyle threeDStyle;

  /// Perspective strength written to `Matrix4.setEntry(3, 2, perspective)`.
  final double perspective;

  final PageIndicatorLayout indicatorLayout;

  final bool allowImplicitScrolling;

  /// Same as [PageView.pageSnapping]. Only [SwiperLayout.DEFAULT].
  final bool pageSnapping;

  /// How many slides are visible. Only [SwiperLayout.DEFAULT].
  /// Values like `2.5` peek the next slide. Ignored when [viewportFraction] is not 1.
  final double slidesPerView;

  /// Gap between slides. Only [SwiperLayout.DEFAULT].
  final double spaceBetween;

  /// Arrow keys change slides when the swiper is focused.
  final bool enableKeyboard;

  /// When non-null, overrides automatic RTL for horizontal [PageView.reverse].
  final bool? reverse;

  /// Host-owned media hooks. This package does not embed a video widget.
  final SwiperPlaybackConfig? playback;

  const Swiper({
    this.itemBuilder,
    this.indicatorLayout = PageIndicatorLayout.NONE,
    this.transformer,
    required this.itemCount,
    bool autoplay = false,
    this.layout = SwiperLayout.DEFAULT,
    this.autoplayDelay = kDefaultAutoplayDelayMs,
    this.autoplayDisableOnInteraction = true,
    this.duration = kDefaultAutoplayTransactionDuration,
    this.onIndexChanged,
    this.index,
    this.onTap,
    this.control,
    bool loop = true,
    this.curve = Curves.ease,
    this.scrollDirection = Axis.horizontal,
    this.axisDirection = AxisDirection.left,
    this.pagination,
    this.plugins,
    this.physics,
    super.key,
    this.controller,
    this.customLayoutOption,
    this.containerHeight,
    this.containerWidth,
    this.viewportFraction = 1.0,
    this.itemHeight,
    this.itemWidth,
    this.outer = false,
    this.scale,
    this.fade,
    this.enable3D = false,
    this.threeDStyle = Swiper3DStyle.cube,
    this.perspective = 0.001,
    this.allowImplicitScrolling = false,
    this.pageSnapping = true,
    this.slidesPerView = 1,
    this.spaceBetween = 0,
    this.enableKeyboard = true,
    this.reverse,
    this.playback,
  })  : assert(
          itemBuilder != null || transformer != null,
          'itemBuilder and transformer must not be both null',
        ),
        assert(
          layout != SwiperLayout.CUSTOM || customLayoutOption != null,
          'customLayoutOption must not be null when layout is SwiperLayout.CUSTOM',
        ),
        assert(slidesPerView > 0, 'slidesPerView must be greater than 0'),
        assert(
            !loop ||
                ((loop &&
                        layout == SwiperLayout.DEFAULT &&
                        (indicatorLayout == PageIndicatorLayout.SCALE ||
                            indicatorLayout == PageIndicatorLayout.COLOR ||
                            indicatorLayout == PageIndicatorLayout.NONE)) ||
                    (loop && layout != SwiperLayout.DEFAULT)),
            "Only support `PageIndicatorLayout.SCALE` and `PageIndicatorLayout.COLOR`when layout==SwiperLayout.DEFAULT in loop mode"),
        autoplay = (autoplay && itemCount > 1),
        loop = (loop && itemCount > 1);

  factory Swiper.children({
    required List<Widget> children,
    bool autoplay = false,
    PageTransformer? transformer,
    int autoplayDelay = kDefaultAutoplayDelayMs,
    bool autoplayDisableOnInteraction = true,
    int duration = kDefaultAutoplayTransactionDuration,
    ValueChanged<int>? onIndexChanged,
    int? index,
    SwiperOnTap? onTap,
    bool loop = true,
    Curve curve = Curves.ease,
    Axis scrollDirection = Axis.horizontal,
    AxisDirection axisDirection = AxisDirection.left,
    SwiperPlugin? pagination,
    SwiperPlugin? control,
    List<SwiperPlugin>? plugins,
    SwiperController? controller,
    Key? key,
    CustomLayoutOption? customLayoutOption,
    ScrollPhysics? physics,
    double? containerHeight,
    double? containerWidth,
    double viewportFraction = 1.0,
    double? itemHeight,
    double? itemWidth,
    bool outer = false,
    double? scale,
    double? fade,
    PageIndicatorLayout indicatorLayout = PageIndicatorLayout.NONE,
    SwiperLayout layout = SwiperLayout.DEFAULT,
    bool enable3D = false,
    Swiper3DStyle threeDStyle = Swiper3DStyle.cube,
    double perspective = 0.001,
    bool allowImplicitScrolling = false,
    bool pageSnapping = true,
    double slidesPerView = 1,
    double spaceBetween = 0,
    bool enableKeyboard = true,
    bool? reverse,
    SwiperPlaybackConfig? playback,
  }) =>
      Swiper(
        fade: fade,
        indicatorLayout: indicatorLayout,
        layout: layout,
        transformer: transformer,
        enable3D: enable3D,
        threeDStyle: threeDStyle,
        perspective: perspective,
        customLayoutOption: customLayoutOption,
        containerHeight: containerHeight,
        containerWidth: containerWidth,
        viewportFraction: viewportFraction,
        itemHeight: itemHeight,
        itemWidth: itemWidth,
        outer: outer,
        scale: scale,
        autoplay: autoplay,
        autoplayDelay: autoplayDelay,
        autoplayDisableOnInteraction: autoplayDisableOnInteraction,
        duration: duration,
        onIndexChanged: onIndexChanged,
        index: index,
        onTap: onTap,
        curve: curve,
        scrollDirection: scrollDirection,
        axisDirection: axisDirection,
        pagination: pagination,
        control: control,
        controller: controller,
        loop: loop,
        plugins: plugins,
        physics: physics,
        key: key,
        allowImplicitScrolling: allowImplicitScrolling,
        pageSnapping: pageSnapping,
        slidesPerView: slidesPerView,
        spaceBetween: spaceBetween,
        enableKeyboard: enableKeyboard,
        reverse: reverse,
        playback: playback,
        itemBuilder: (context, index) {
          return children[index];
        },
        itemCount: children.length,
      );

  static Swiper list<T>({
    PageTransformer? transformer,
    required List<T> list,
    CustomLayoutOption? customLayoutOption,
    required SwiperDataBuilder<T> builder,
    bool autoplay = false,
    int autoplayDelay = kDefaultAutoplayDelayMs,
    bool? reverse,
    bool autoplayDisableOnInteraction = true,
    int duration = kDefaultAutoplayTransactionDuration,
    ValueChanged<int>? onIndexChanged,
    int? index,
    SwiperOnTap? onTap,
    bool loop = true,
    Curve curve = Curves.ease,
    Axis scrollDirection = Axis.horizontal,
    AxisDirection axisDirection = AxisDirection.left,
    SwiperPlugin? pagination,
    SwiperPlugin? control,
    List<SwiperPlugin>? plugins,
    SwiperController? controller,
    Key? key,
    ScrollPhysics? physics,
    double? containerHeight,
    double? containerWidth,
    double viewportFraction = 1.0,
    double? itemHeight,
    double? itemWidth,
    bool outer = false,
    double? scale,
    double? fade,
    PageIndicatorLayout indicatorLayout = PageIndicatorLayout.NONE,
    SwiperLayout layout = SwiperLayout.DEFAULT,
    bool enable3D = false,
    Swiper3DStyle threeDStyle = Swiper3DStyle.cube,
    double perspective = 0.001,
    bool allowImplicitScrolling = false,
    bool pageSnapping = true,
    double slidesPerView = 1,
    double spaceBetween = 0,
    bool enableKeyboard = true,
    SwiperPlaybackConfig? playback,
  }) =>
      Swiper(
        fade: fade,
        indicatorLayout: indicatorLayout,
        layout: layout,
        transformer: transformer,
        enable3D: enable3D,
        threeDStyle: threeDStyle,
        perspective: perspective,
        customLayoutOption: customLayoutOption,
        containerHeight: containerHeight,
        containerWidth: containerWidth,
        viewportFraction: viewportFraction,
        itemHeight: itemHeight,
        itemWidth: itemWidth,
        outer: outer,
        scale: scale,
        autoplay: autoplay,
        autoplayDelay: autoplayDelay,
        autoplayDisableOnInteraction: autoplayDisableOnInteraction,
        duration: duration,
        onIndexChanged: onIndexChanged,
        index: index,
        onTap: onTap,
        curve: curve,
        key: key,
        scrollDirection: scrollDirection,
        axisDirection: axisDirection,
        pagination: pagination,
        control: control,
        controller: controller,
        loop: loop,
        plugins: plugins,
        physics: physics,
        reverse: reverse,
        allowImplicitScrolling: allowImplicitScrolling,
        pageSnapping: pageSnapping,
        slidesPerView: slidesPerView,
        spaceBetween: spaceBetween,
        enableKeyboard: enableKeyboard,
        playback: playback,
        itemBuilder: (context, index) {
          return builder(context, list[index], index);
        },
        itemCount: list.length,
      );

  /// Resolved transformer: explicit [transformer] > [enable3D] > [scale]/[fade].
  PageTransformer? get resolvedTransformer {
    if (transformer != null) return transformer;
    if (enable3D) {
      return build3DTransformer(threeDStyle, perspective: perspective);
    }
    if (scale != null || fade != null) {
      return ScaleAndFadeTransformer(scale: scale, fade: fade);
    }
    return null;
  }

  double get resolvedViewportFraction {
    if (viewportFraction != 1.0) return viewportFraction;
    if (slidesPerView != 1.0) return 1.0 / slidesPerView;
    return 1.0;
  }

  @override
  State<StatefulWidget> createState() => _SwiperState();
}

abstract class _SwiperTimerMixin extends State<Swiper> {
  Timer? _timer;

  late SwiperController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? SwiperController();
    _controller.addListener(_onController);
    if (widget.autoplay) {
      _controller.startAutoplay();
    } else {
      _controller.stopAutoplay();
    }
  }

  void _onController() {
    final event = _controller.event;
    if (event is AutoPlaySwiperControllerEvent) {
      if (event.autoplay) {
        if (_timer == null) {
          _startAutoplay();
        }
      } else {
        _stopAutoplay();
      }
    }
  }

  @override
  void didUpdateWidget(Swiper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _controller.removeListener(_onController);
      _controller = widget.controller ?? SwiperController();
      _controller.addListener(_onController);
    }
    if (widget.autoplay != oldWidget.autoplay) {
      if (widget.autoplay) {
        _controller.startAutoplay();
      } else {
        _controller.stopAutoplay();
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onController);
    _stopAutoplay();
    super.dispose();
  }

  bool _shouldPauseForPlayback() {
    final playback = widget.playback;
    if (playback == null || !playback.pauseAutoplayWhilePlaying) {
      return false;
    }
    return playback.playing?.value ?? false;
  }

  void _startAutoplay() {
    if (_shouldPauseForPlayback()) return;
    _stopAutoplay();
    _timer = Timer.periodic(
      Duration(
        milliseconds: widget.autoplayDelay,
      ),
      _onTimer,
    );
  }

  void _onTimer(Timer timer) {
    _controller.next(animation: true);
  }

  void _stopAutoplay() {
    _timer?.cancel();
    _timer = null;
  }
}

class _SwiperState extends _SwiperTimerMixin {
  late int _activeIndex;

  TransformerPageController? _pageController;

  Widget _buildItem(BuildContext context, int index) {
    return SwiperItemScope(
      index: index,
      activeIndex: _activeIndex,
      child: Builder(
        builder: (context) {
          Widget child = widget.itemBuilder!(context, index);
          if (widget.spaceBetween > 0 && _isPageViewLayout()) {
            final half = widget.spaceBetween / 2;
            child = Padding(
              padding: widget.scrollDirection == Axis.horizontal
                  ? EdgeInsets.symmetric(horizontal: half)
                  : EdgeInsets.symmetric(vertical: half),
              child: child,
            );
          }
          if (widget.onTap != null) {
            child = GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => widget.onTap!(index),
              child: child,
            );
          }
          return child;
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _activeIndex = widget.index ?? widget.controller?.index ?? 0;
    _controller.index = _activeIndex;
    widget.playback?.playing?.addListener(_onPlayingChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.playback?.onActiveChanged?.call(_activeIndex, true);
    });
  }

  bool _isPageViewLayout() {
    return widget.layout == SwiperLayout.DEFAULT;
  }

  bool _pageReverse(BuildContext context) {
    final transformerReverse = widget.resolvedTransformer?.reverse ?? false;
    final rtl = widget.scrollDirection == Axis.horizontal &&
        Directionality.of(context) == TextDirection.rtl;
    if (widget.reverse != null) {
      return widget.reverse! ^ transformerReverse;
    }
    return rtl ^ transformerReverse;
  }

  AxisDirection _stackAxisDirection(BuildContext context) {
    var dir = widget.axisDirection;
    final rtl = widget.scrollDirection == Axis.horizontal &&
        Directionality.of(context) == TextDirection.rtl;
    final flip = widget.reverse ?? rtl;
    if (flip && dir == AxisDirection.left) return AxisDirection.right;
    if (flip && dir == AxisDirection.right) return AxisDirection.left;
    return dir;
  }

  void _ensurePageController(BuildContext context) {
    if (!_isPageViewLayout()) {
      if (_pageController != null) {
        scheduleMicrotask(() {
          _pageController?.dispose();
          _pageController = null;
        });
      }
      return;
    }
    final reverse = _pageReverse(context);
    final vf = widget.resolvedViewportFraction;
    if (_pageController == null ||
        _pageController!.reverse != reverse ||
        _pageController!.viewportFraction != vf ||
        _pageController!.loop != widget.loop ||
        _pageController!.itemCount != widget.itemCount) {
      _pageController = TransformerPageController(
        initialPage: widget.index ?? _activeIndex,
        loop: widget.loop,
        itemCount: widget.itemCount,
        reverse: reverse,
        viewportFraction: vf,
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ensurePageController(context);
  }

  @override
  void didUpdateWidget(Swiper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.playback?.playing != oldWidget.playback?.playing) {
      oldWidget.playback?.playing?.removeListener(_onPlayingChanged);
      widget.playback?.playing?.addListener(_onPlayingChanged);
    }
    if (_isPageViewLayout()) {
      _ensurePageController(context);
    } else {
      scheduleMicrotask(() {
        if (_pageController != null) {
          _pageController!.dispose();
          _pageController = null;
        }
      });
    }
    if (widget.index != null && widget.index != _activeIndex) {
      _activeIndex = widget.index!;
      _controller.index = _activeIndex;
    }
  }

  void _onPlayingChanged() {
    if (_shouldPauseForPlayback()) {
      _stopAutoplay();
    } else if (widget.autoplay) {
      _startAutoplay();
    }
  }

  void _onIndexChanged(int index) {
    final previous = _activeIndex;
    setState(() {
      _activeIndex = index;
    });
    _controller.index = index;
    widget.onIndexChanged?.call(index);
    if (previous != index) {
      widget.playback?.onActiveChanged?.call(previous, false);
      widget.playback?.onActiveChanged?.call(index, true);
    }
  }

  VoidCallback? get _dragStart {
    if (widget.autoplayDisableOnInteraction && widget.autoplay) {
      return _stopAutoplay;
    }
    return null;
  }

  VoidCallback? get _dragEnd {
    if (widget.autoplayDisableOnInteraction && widget.autoplay) {
      return _startAutoplay;
    }
    return null;
  }

  Widget _buildSwiper() {
    final itemBuilder = widget.itemBuilder == null ? null : _buildItem;

    if (widget.layout == SwiperLayout.STACK) {
      return _StackSwiper(
        loop: widget.loop,
        itemWidth: widget.itemWidth,
        itemHeight: widget.itemHeight,
        itemCount: widget.itemCount,
        itemBuilder: itemBuilder,
        index: _activeIndex,
        curve: widget.curve,
        duration: widget.duration,
        onIndexChanged: _onIndexChanged,
        controller: _controller,
        scrollDirection: widget.scrollDirection,
        axisDirection: _stackAxisDirection(context),
        onDragStart: _dragStart,
        onDragEnd: _dragEnd,
      );
    } else if (_isPageViewLayout()) {
      PageTransformer? transformer = widget.resolvedTransformer;

      Widget child = TransformerPageView(
        pageController: _pageController,
        loop: widget.loop,
        itemCount: widget.itemCount,
        itemBuilder: itemBuilder,
        transformer: transformer,
        viewportFraction: widget.resolvedViewportFraction,
        index: _activeIndex,
        duration: Duration(milliseconds: widget.duration),
        scrollDirection: widget.scrollDirection,
        onPageChanged: _onIndexChanged,
        curve: widget.curve,
        physics: widget.physics,
        controller: _controller,
        allowImplicitScrolling: widget.allowImplicitScrolling,
        pageSnapping: widget.pageSnapping,
      );
      if (widget.autoplayDisableOnInteraction && widget.autoplay) {
        return NotificationListener(
          onNotification: (notification) {
            if (notification is ScrollStartNotification) {
              if (notification.dragDetails != null) {
                if (_timer != null) _stopAutoplay();
              }
            } else if (notification is ScrollEndNotification) {
              if (_timer == null) _startAutoplay();
            }

            return false;
          },
          child: child,
        );
      }

      return child;
    } else if (widget.layout == SwiperLayout.TINDER) {
      return _TinderSwiper(
        loop: widget.loop,
        itemWidth: widget.itemWidth,
        itemHeight: widget.itemHeight,
        itemCount: widget.itemCount,
        itemBuilder: itemBuilder,
        index: _activeIndex,
        curve: widget.curve,
        duration: widget.duration,
        onIndexChanged: _onIndexChanged,
        controller: _controller,
        scrollDirection: widget.scrollDirection,
        onDragStart: _dragStart,
        onDragEnd: _dragEnd,
      );
    } else if (widget.layout == SwiperLayout.CUSTOM) {
      return _CustomLayoutSwiper(
        loop: widget.loop,
        option: widget.customLayoutOption!,
        itemWidth: widget.itemWidth,
        itemHeight: widget.itemHeight,
        itemCount: widget.itemCount,
        itemBuilder: itemBuilder,
        index: _activeIndex,
        curve: widget.curve,
        duration: widget.duration,
        onIndexChanged: _onIndexChanged,
        controller: _controller,
        scrollDirection: widget.scrollDirection,
        onDragStart: _dragStart,
        onDragEnd: _dragEnd,
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  SwiperPluginConfig _ensureConfig(SwiperPluginConfig? config) {
    final con = config ??
        SwiperPluginConfig(
          outer: widget.outer,
          itemCount: widget.itemCount,
          layout: widget.layout,
          indicatorLayout: widget.indicatorLayout,
          pageController: _pageController,
          activeIndex: _activeIndex,
          scrollDirection: widget.scrollDirection,
          axisDirection: _stackAxisDirection(context),
          controller: _controller,
          loop: widget.loop,
        );
    return con;
  }

  List<Widget>? _ensureListForStack({
    required Widget swiper,
    required List<Widget>? listForStack,
    required Widget widget,
  }) {
    final resList = <Widget>[];
    if (listForStack == null) {
      resList.addAll([swiper, widget]);
    } else {
      resList.addAll([...listForStack, widget]);
    }
    return resList;
  }

  Widget _wrapKeyboard(Widget child) {
    if (!widget.enableKeyboard) return child;
    final rtl = widget.scrollDirection == Axis.horizontal &&
        Directionality.of(context) == TextDirection.rtl;
    final horizontal = widget.scrollDirection == Axis.horizontal;
    return CallbackShortcuts(
      bindings: {
        if (horizontal) ...{
          const SingleActivator(LogicalKeyboardKey.arrowLeft): () {
            if (rtl) {
              _controller.next();
            } else {
              _controller.previous();
            }
          },
          const SingleActivator(LogicalKeyboardKey.arrowRight): () {
            if (rtl) {
              _controller.previous();
            } else {
              _controller.next();
            }
          },
        } else ...{
          const SingleActivator(LogicalKeyboardKey.arrowUp): () {
            _controller.previous();
          },
          const SingleActivator(LogicalKeyboardKey.arrowDown): () {
            _controller.next();
          },
        },
      },
      child: Focus(
        autofocus: true,
        descendantsAreFocusable: false,
        child: child,
      ),
    );
  }

  Widget _constrain(Widget child) {
    if (widget.containerHeight == null && widget.containerWidth == null) {
      return child;
    }
    return SizedBox(
      height: widget.containerHeight,
      width: widget.containerWidth,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget swiper = _buildSwiper();
    List<Widget>? listForStack;
    SwiperPluginConfig? config;
    if (widget.control != null) {
      config = _ensureConfig(config);
      listForStack = _ensureListForStack(
        swiper: swiper,
        listForStack: listForStack,
        widget: widget.control!.build(context, config),
      );
    }

    if (widget.plugins != null) {
      config = _ensureConfig(config);
      for (SwiperPlugin plugin in widget.plugins!) {
        listForStack = _ensureListForStack(
          swiper: swiper,
          listForStack: listForStack,
          widget: plugin.build(context, config),
        );
      }
    }
    if (widget.pagination != null) {
      config = _ensureConfig(config);
      if (widget.outer) {
        return _wrapKeyboard(_buildOuterPagination(
          widget.pagination!,
          listForStack == null ? swiper : Stack(children: listForStack),
          config,
        ));
      } else {
        listForStack = _ensureListForStack(
          swiper: swiper,
          listForStack: listForStack,
          widget: widget.pagination!.build(context, config),
        );
      }
    }

    Widget result = listForStack != null
        ? Stack(children: listForStack)
        : swiper;
    return _wrapKeyboard(_constrain(result));
  }

  Widget _buildOuterPagination(
    SwiperPlugin pagination,
    Widget swiper,
    SwiperPluginConfig config,
  ) {
    final alignment =
        pagination is SwiperPagination ? pagination.alignment : null;
    final pager = Align(
      alignment: Alignment.center,
      child: pagination.build(context, config),
    );

    final hasSize =
        widget.containerHeight != null || widget.containerWidth != null;
    final sizedSwiper = hasSize
        ? SizedBox(
            height: widget.containerHeight,
            width: widget.containerWidth,
            child: swiper,
          )
        : swiper;

    final vertical = widget.scrollDirection == Axis.vertical;
    final putOnTop = alignment == Alignment.topCenter ||
        alignment == Alignment.topLeft ||
        alignment == Alignment.topRight;
    final putOnStart = vertical &&
        (alignment == Alignment.centerLeft ||
            alignment == Alignment.topLeft ||
            alignment == Alignment.bottomLeft);

    if (vertical) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (putOnStart) pager,
          hasSize ? sizedSwiper : Expanded(child: sizedSwiper),
          if (!putOnStart) pager,
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (putOnTop) pager,
        hasSize ? sizedSwiper : Expanded(child: sizedSwiper),
        if (!putOnTop) pager,
      ],
    );
  }

  @override
  void dispose() {
    widget.playback?.playing?.removeListener(_onPlayingChanged);
    super.dispose();
  }
}

abstract class _SubSwiper extends StatefulWidget {
  final IndexedWidgetBuilder? itemBuilder;
  final int itemCount;
  final int? index;
  final ValueChanged<int>? onIndexChanged;
  final SwiperController controller;
  final int? duration;
  final Curve curve;
  final double? itemWidth;
  final double? itemHeight;
  final bool loop;
  final Axis? scrollDirection;
  final AxisDirection? axisDirection;
  final VoidCallback? onDragStart;
  final VoidCallback? onDragEnd;

  const _SubSwiper({
    required this.loop,
    this.itemHeight,
    this.itemWidth,
    this.duration,
    required this.curve,
    this.itemBuilder,
    required this.controller,
    this.index,
    required this.itemCount,
    this.scrollDirection = Axis.horizontal,
    this.axisDirection = AxisDirection.left,
    this.onIndexChanged,
    this.onDragStart,
    this.onDragEnd,
  });

  @override
  State<StatefulWidget> createState();

  int getCorrectIndex(int indexNeedsFix) {
    if (itemCount == 0) return 0;
    var value = indexNeedsFix % itemCount;
    if (value < 0) {
      value += itemCount;
    }
    return value;
  }
}

class _TinderSwiper extends _SubSwiper {
  const _TinderSwiper({
    required super.curve,
    super.duration,
    required super.controller,
    super.onIndexChanged,
    super.itemHeight,
    super.itemWidth,
    super.itemBuilder,
    super.index,
    required super.loop,
    required super.itemCount,
    super.scrollDirection,
    super.onDragStart,
    super.onDragEnd,
  }) : assert(itemWidth != null && itemHeight != null);

  @override
  State<StatefulWidget> createState() {
    return _TinderState();
  }
}

class _StackSwiper extends _SubSwiper {
  const _StackSwiper({
    required super.curve,
    super.duration,
    required super.controller,
    super.onIndexChanged,
    super.itemHeight,
    super.itemWidth,
    super.itemBuilder,
    super.index,
    required super.loop,
    required super.itemCount,
    super.scrollDirection,
    super.axisDirection,
    super.onDragStart,
    super.onDragEnd,
  });

  @override
  State<StatefulWidget> createState() => _StackViewState();
}

class _TinderState extends _CustomLayoutStateBase<_TinderSwiper> {
  late List<double> scales;
  late List<double> offsetsX;
  late List<double> offsetsY;
  late List<double> opacity;
  late List<double> rotates;

  double getOffsetY(double scale) {
    return widget.itemHeight! - widget.itemHeight! * scale;
  }

  @override
  void didUpdateWidget(_TinderSwiper oldWidget) {
    _updateValues();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void afterRender() {
    super.afterRender();

    _startIndex = -3;
    _animationCount = 5;
    opacity = [0.0, 0.9, 0.9, 1.0, 0.0, 0.0];
    scales = [0.80, 0.80, 0.85, 0.90, 1.0, 1.0, 1.0];
    rotates = [0.0, 0.0, 0.0, 0.0, 20.0, 25.0];
    _updateValues();
  }

  void _updateValues() {
    if (widget.scrollDirection == Axis.horizontal) {
      offsetsX = [0.0, 0.0, 0.0, 0.0, _swiperWidth, _swiperWidth];
      offsetsY = [
        0.0,
        0.0,
        -5.0,
        -10.0,
        -15.0,
        -20.0,
      ];
    } else {
      offsetsX = [
        0.0,
        0.0,
        5.0,
        10.0,
        15.0,
        20.0,
      ];

      offsetsY = [0.0, 0.0, 0.0, 0.0, _swiperHeight, _swiperHeight];
    }
  }

  @override
  Widget _buildItem(int i, int realIndex, double animationValue) {
    double s = _getValue(scales, animationValue, i);
    double f = _getValue(offsetsX, animationValue, i);
    double fy = _getValue(offsetsY, animationValue, i);
    double o = _getValue(opacity, animationValue, i);
    double a = _getValue(rotates, animationValue, i);

    Alignment alignment = widget.scrollDirection == Axis.horizontal
        ? Alignment.bottomCenter
        : Alignment.centerLeft;

    return Opacity(
      opacity: o,
      child: Transform.rotate(
        angle: a / 180.0,
        child: Transform.translate(
          key: ValueKey<int>(_currentIndex + i),
          offset: Offset(f, fy),
          child: Transform.scale(
            scale: s,
            alignment: alignment,
            child: SizedBox(
              width: widget.itemWidth ?? double.infinity,
              height: widget.itemHeight ?? double.infinity,
              child: widget.itemBuilder!(context, realIndex),
            ),
          ),
        ),
      ),
    );
  }
}

class _StackViewState extends _CustomLayoutStateBase<_StackSwiper> {
  late List<double> scales;
  late List<double> offsets;
  late List<double> opacity;

  void _updateValues() {
    if (widget.scrollDirection == Axis.horizontal) {
      double space = (_swiperWidth - widget.itemWidth!) / 2;
      offsets = widget.axisDirection == AxisDirection.left
          ? [-space, -space / 3 * 2, -space / 3, 0.0, _swiperWidth]
          : [_swiperWidth, 0.0, -space / 3, -space / 3 * 2, -space];
    } else {
      double space = (_swiperHeight - widget.itemHeight!) / 2;
      offsets = [-space, -space / 3 * 2, -space / 3, 0.0, _swiperHeight];
    }
  }

  @override
  void didUpdateWidget(_StackSwiper oldWidget) {
    _updateValues();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void afterRender() {
    super.afterRender();
    final isRightSide = widget.axisDirection == AxisDirection.right;

    //length of the values array below
    _animationCount = 5;

    //Array below this line, '0' index is 1.0, which is the first item show in swiper.
    _startIndex = isRightSide ? -1 : -3;
    scales =
        isRightSide ? [1.0, 1.0, 0.9, 0.8, 0.7] : [0.7, 0.8, 0.9, 1.0, 1.0];
    opacity =
        isRightSide ? [1.0, 1.0, 1.0, 0.5, 0.0] : [0.0, 0.5, 1.0, 1.0, 1.0];

    _updateValues();
  }

  @override
  Widget _buildItem(int i, int realIndex, double animationValue) {
    double s = _getValue(scales, animationValue, i);
    double f = _getValue(offsets, animationValue, i);
    double o = _getValue(opacity, animationValue, i);

    Offset offset = widget.scrollDirection == Axis.horizontal
        ? widget.axisDirection == AxisDirection.left
            ? Offset(f, 0.0)
            : Offset(-f, 0.0)
        : Offset(0.0, f);

    Alignment alignment = widget.scrollDirection == Axis.horizontal
        ? widget.axisDirection == AxisDirection.left
            ? Alignment.centerLeft
            : Alignment.centerRight
        : Alignment.topCenter;

    return Opacity(
      opacity: o,
      child: Transform.translate(
        key: ValueKey<int>(_currentIndex + i),
        offset: offset,
        child: Transform.scale(
          scale: s,
          alignment: alignment,
          child: SizedBox(
            width: widget.itemWidth ?? double.infinity,
            height: widget.itemHeight ?? double.infinity,
            child: widget.itemBuilder!(context, realIndex),
          ),
        ),
      ),
    );
  }
}
