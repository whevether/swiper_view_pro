import 'package:flutter/widgets.dart';

import 'index_controller.dart';
import 'swiper_constants.dart';

export 'swiper_constants.dart' show kMaxValue, kMiddleValue;

/// PageView with optional [PageTransformer] support.
/// Built-in transformers live in `transformers.dart`.

///  Default auto play transition duration (in millisecond)
const int kDefaultTransactionDuration = 300;

class TransformInfo {
  /// The `width` of the `TransformerPageView`
  final double? width;

  /// The `height` of the `TransformerPageView`
  final double? height;

  /// The `position` of the widget pass to [PageTransformer.transform]
  ///  A `position` describes how visible the widget is.
  ///  The widget in the center of the screen' which is  full visible, position is 0.0.
  ///  The widge in the left ,may be hidden, of the screen's position is less than 0.0, -1.0 when out of the screen.
  ///  The widge in the right ,may be hidden, of the screen's position is greater than 0.0,  1.0 when out of the screen
  ///
  ///
  final double? position;

  /// The `index` of the widget pass to [PageTransformer.transform]
  final int? index;

  /// The `activeIndex` of the PageView
  final int? activeIndex;

  /// The `activeIndex` of the PageView, from user start to swipe
  /// It will change when user end drag
  final int fromIndex;

  /// Whether the page sequence wraps at its ends.
  final bool loop;

  /// Next `index` is greater than this `index`
  final bool? forward;

  /// User drag is done.
  final bool? done;

  /// Same as [TransformerPageView.viewportFraction]
  final double? viewportFraction;

  /// Copy from [TransformerPageView.scrollDirection]
  final Axis? scrollDirection;

  TransformInfo({
    this.index,
    this.position,
    this.width,
    this.height,
    this.activeIndex,
    required this.fromIndex,
    this.loop = false,
    this.forward,
    this.done,
    this.viewportFraction,
    this.scrollDirection,
  });
}

abstract class PageTransformer {
  ///
  final bool reverse;

  PageTransformer({this.reverse = false});

  /// Return a transformed widget, based on child and TransformInfo
  Widget transform(Widget child, TransformInfo info);
}

typedef PageTransformerBuilderCallback = Widget Function(
  Widget child,
  TransformInfo info,
);

class PageTransformerBuilder extends PageTransformer {
  final PageTransformerBuilderCallback builder;

  PageTransformerBuilder({super.reverse = false, required this.builder});

  @override
  Widget transform(Widget child, TransformInfo info) {
    return builder(child, info);
  }
}

class TransformerPageController extends PageController {
  final bool loop;
  final int itemCount;
  final bool reverse;

  TransformerPageController({
    int initialPage = 0,
    super.keepPage = true,
    super.viewportFraction = 1.0,
    this.loop = false,
    this.itemCount = 0,
    this.reverse = false,
  }) : super(
         initialPage: TransformerPageController._getRealIndexFromRenderIndex(
           initialPage,
           loop,
           itemCount,
           reverse,
         ),
       );

  int getRenderIndexFromRealIndex(num index) {
    return _getRenderIndexFromRealIndex(index, loop, itemCount, reverse);
  }

  int? getRealItemCount() {
    if (itemCount == 0) return 0;
    return loop ? itemCount + kMaxValue : itemCount;
  }

  static int _getRenderIndexFromRealIndex(
    num index,
    bool loop,
    int itemCount,
    bool reverse,
  ) {
    if (itemCount == 0) return 0;
    int renderIndex;
    if (loop) {
      renderIndex = (index - kMiddleValue).toInt();
      renderIndex = renderIndex % itemCount;
      if (renderIndex < 0) {
        renderIndex += itemCount;
      }
    } else {
      renderIndex = index.toInt();
    }
    if (reverse) {
      renderIndex = itemCount - renderIndex - 1;
    }

    return renderIndex;
  }

  double get realPage => super.page ?? 0.0;

  static double? _getRenderPageFromRealPage(
    double page,
    bool loop,
    int itemCount,
    bool reverse,
  ) {
    if (itemCount == 0) return 0;
    double? renderPage;
    if (loop) {
      renderPage = page - kMiddleValue;
      renderPage = renderPage % itemCount;
      if (renderPage < 0) {
        renderPage += itemCount;
      }
    } else {
      renderPage = page;
    }
    if (reverse) {
      renderPage = itemCount - renderPage - 1;
    }

    return loop ? renderPage % itemCount : renderPage;
  }

  @override
  double? get page {
    return _getRenderPageFromRealPage(realPage, loop, itemCount, reverse);
  }

  int getRealIndexFromRenderIndex(num index) {
    return _getRealIndexFromRenderIndex(index, loop, itemCount, reverse);
  }

  static int _getRealIndexFromRenderIndex(
    num index,
    bool loop,
    int itemCount,
    bool reverse,
  ) {
    return swiperRealIndex(index.toInt(), itemCount, loop, reverse);
  }
}

class TransformerPageView extends StatefulWidget {
  /// Create a `transformed` widget base on the widget that has been passed to  the [PageTransformer.transform].
  /// See [TransformInfo]
  ///
  final PageTransformer? transformer;

  /// Same as [PageView.scrollDirection]
  ///
  /// Defaults to [Axis.horizontal].
  final Axis scrollDirection;

  /// Same as [PageView.physics]
  final ScrollPhysics? physics;

  /// Set to false to disable page snapping, useful for custom scroll behavior.
  /// Same as [PageView.pageSnapping]
  final bool pageSnapping;

  /// Called whenever the page in the center of the viewport changes.
  /// Same as [PageView.onPageChanged]
  final ValueChanged<int>? onPageChanged;

  final IndexedWidgetBuilder? itemBuilder;

  // See [IndexController.mode],[IndexController.next],[IndexController.previous]
  final IndexController? controller;

  /// Animation duration
  final Duration duration;

  /// Animation curve
  final Curve curve;

  final TransformerPageController? pageController;

  /// Set true to open infinity loop mode.
  final bool loop;

  /// This value is only valid when `pageController` is not set,
  final int itemCount;

  /// This value is only valid when `pageController` is not set,
  final double viewportFraction;

  /// If not set, it is controlled by this widget.
  final int? index;

  final bool allowImplicitScrolling;

  /// Creates a scrollable list that works page by page using widgets that are
  /// created on demand.
  ///
  /// This constructor is appropriate for page views with a large (or infinite)
  /// number of children because the builder is called only for those children
  /// that are actually visible.
  ///
  /// Providing a non-null [itemCount] lets the [PageView] compute the maximum
  /// scroll extent.
  ///
  /// [itemBuilder] will be called only with indices greater than or equal to
  /// zero and less than [itemCount].
  const TransformerPageView({
    super.key,
    this.index,
    Duration? duration,
    this.curve = Curves.ease,
    this.viewportFraction = 1.0,
    required this.loop,
    this.scrollDirection = Axis.horizontal,
    this.physics,
    this.pageSnapping = true,
    this.onPageChanged,
    this.controller,
    this.transformer,
    this.allowImplicitScrolling = false,
    this.itemBuilder,
    this.pageController,
    required this.itemCount,
  }) : assert(itemCount == 0 || itemBuilder != null || transformer != null),
       duration =
           duration ??
           const Duration(milliseconds: kDefaultTransactionDuration);

  factory TransformerPageView.children({
    Key? key,
    int? index,
    Duration? duration,
    Curve curve = Curves.ease,
    double viewportFraction = 1.0,
    bool loop = false,
    Axis scrollDirection = Axis.horizontal,
    ScrollPhysics? physics,
    bool pageSnapping = true,
    ValueChanged<int?>? onPageChanged,
    IndexController? controller,
    PageTransformer? transformer,
    bool allowImplicitScrolling = false,
    required List<Widget> children,
    TransformerPageController? pageController,
  }) {
    return TransformerPageView(
      itemCount: children.length,
      itemBuilder: (context, index) {
        return children[index];
      },
      pageController: pageController,
      transformer: transformer,
      pageSnapping: pageSnapping,
      key: key,
      index: index,
      loop: loop,
      duration: duration,
      curve: curve,
      viewportFraction: viewportFraction,
      scrollDirection: scrollDirection,
      physics: physics,
      allowImplicitScrolling: allowImplicitScrolling,
      onPageChanged: onPageChanged,
      controller: controller,
    );
  }

  @override
  State<StatefulWidget> createState() => _TransformerPageViewState();

  static int getRealIndexFromRenderIndex({
    required bool reverse,
    int index = 0,
    int itemCount = 0,
    required bool loop,
  }) {
    return swiperRealIndex(index, itemCount, loop, reverse);
  }

  static PageController createPageController({
    required bool reverse,
    int index = 0,
    int itemCount = 0,
    required bool loop,
    required double viewportFraction,
  }) {
    return PageController(
      initialPage: getRealIndexFromRenderIndex(
        reverse: reverse,
        index: index,
        itemCount: itemCount,
        loop: loop,
      ),
      viewportFraction: viewportFraction,
    );
  }
}

class _TransformerPageViewState extends State<TransformerPageView> {
  Size? _size;
  int _activeIndex = 0;
  double _currentPixels = 0;
  bool _done = true;

  ///This value will not change until user end drag.
  late int _fromIndex;

  PageTransformer? _transformer;

  late TransformerPageController _pageController;
  bool _ownsPageController = false;

  TransformerPageController _createPageController(int index) =>
      TransformerPageController(
        initialPage: index,
        itemCount: widget.itemCount,
        loop: widget.loop,
        reverse: widget.transformer?.reverse ?? false,
        viewportFraction: widget.viewportFraction,
      );

  void _retirePageController(TransformerPageController controller) {
    WidgetsBinding.instance.addPostFrameCallback((_) => controller.dispose());
  }

  Widget _buildItemNormal(BuildContext context, int index) {
    int renderIndex = _pageController.getRenderIndexFromRealIndex(index);
    return widget.itemBuilder!(context, renderIndex);
  }

  Widget _buildItem(BuildContext context, int index) {
    final renderIndex = _pageController.getRenderIndexFromRealIndex(index);
    return AnimatedBuilder(
      animation: _pageController,
      child:
          widget.itemBuilder?.call(context, renderIndex) ??
          const SizedBox.shrink(),
      builder: (c, child) {
        if (_size == null) {
          return child!;
        }

        double position;

        double page = _pageController.realPage;

        if (_transformer!.reverse) {
          position = page - index;
        } else {
          position = index - page;
        }
        position *= _pageController.viewportFraction;

        TransformInfo info = TransformInfo(
          index: renderIndex,
          width: _size!.width,
          height: _size!.height,
          position: position.clamp(-1.0, 1.0),
          activeIndex: _pageController.getRenderIndexFromRealIndex(
            _activeIndex,
          ),
          fromIndex: _pageController.getRenderIndexFromRealIndex(_fromIndex),
          loop: _pageController.loop,
          forward:
              (_pageController.position.pixels - _currentPixels) *
                  (_pageController.reverse ? -1 : 1) >=
              0,
          done: _done,
          scrollDirection: widget.scrollDirection,
          viewportFraction: _pageController.viewportFraction,
        );
        return _transformer!.transform(child!, info);
      },
    );
  }

  void _calcCurrentPixels() {
    if (_pageController.hasClients) {
      _currentPixels = _pageController.position.pixels;
    }
  }

  @override
  Widget build(BuildContext context) {
    IndexedWidgetBuilder builder = _transformer == null
        ? _buildItemNormal
        : _buildItem;
    Widget child = PageView.builder(
      allowImplicitScrolling: widget.allowImplicitScrolling,
      itemBuilder: builder,
      itemCount: _pageController.getRealItemCount(),
      onPageChanged: _onIndexChanged,
      controller: _pageController,
      scrollDirection: widget.scrollDirection,
      physics: widget.physics,
      pageSnapping: widget.pageSnapping,
      reverse: _pageController.reverse,
    );
    if (_transformer == null) {
      return child;
    }
    return NotificationListener(
      onNotification: (notification) {
        if (notification is ScrollStartNotification &&
            notification.depth == 0) {
          _calcCurrentPixels();
          _done = false;
          _fromIndex = _activeIndex;
        } else if (notification is ScrollEndNotification &&
            notification.depth == 0) {
          setState(() {
            _calcCurrentPixels();
            _fromIndex = _activeIndex;
            _done = true;
          });
        }

        return false;
      },
      child: child,
    );
  }

  void _onIndexChanged(int index) {
    _activeIndex = index;
    widget.onPageChanged?.call(
      _pageController.getRenderIndexFromRealIndex(index),
    );
  }

  void _onGetSize(Duration _) {
    if (!mounted) return;
    Size? size;
    RenderObject? renderObject = context.findRenderObject();
    if (renderObject != null) {
      Rect bounds = renderObject.paintBounds;
      size = bounds.size;
    }
    _calcCurrentPixels();
    onGetSize(size);
  }

  void onGetSize(Size? size) {
    if (mounted) {
      setState(() {
        _size = size;
      });
    }
  }

  IndexController? _controller;

  @override
  void initState() {
    _transformer = widget.transformer;
    _ownsPageController = widget.pageController == null;
    _pageController =
        widget.pageController ?? _createPageController(widget.index ?? 0);
    _fromIndex = _activeIndex = _pageController.initialPage;

    _controller = widget.controller;
    _controller?.addListener(onChangeNotifier);
    super.initState();
  }

  @override
  void didUpdateWidget(TransformerPageView oldWidget) {
    _transformer = widget.transformer;
    final previousIndex = _pageController.getRenderIndexFromRealIndex(
      _activeIndex,
    );
    final replace =
        widget.pageController != oldWidget.pageController ||
        (widget.pageController == null &&
            (widget.itemCount != oldWidget.itemCount ||
                widget.loop != oldWidget.loop ||
                widget.viewportFraction != oldWidget.viewportFraction ||
                widget.transformer?.reverse != oldWidget.transformer?.reverse));
    if (replace) {
      final oldController = _pageController;
      final owned = _ownsPageController;
      _ownsPageController = widget.pageController == null;
      _pageController =
          widget.pageController ??
          _createPageController(widget.index ?? previousIndex);
      _fromIndex = _activeIndex = _pageController.initialPage;
      if (owned) _retirePageController(oldController);
    } else if (widget.index != null && widget.index != previousIndex) {
      final controller = _pageController;
      final target = controller.getRealIndexFromRenderIndex(widget.index!);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted ||
            controller != _pageController ||
            !controller.hasClients) {
          return;
        }
        controller.animateToPage(
          target,
          duration: widget.duration,
          curve: widget.curve,
        );
      });
    }
    if (_transformer != null) {
      WidgetsBinding.instance.addPostFrameCallback(_onGetSize);
    }

    if (_controller != widget.controller) {
      _controller?.removeListener(onChangeNotifier);
      _controller = widget.controller;
      _controller?.addListener(onChangeNotifier);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    if (_transformer != null) {
      WidgetsBinding.instance.addPostFrameCallback(_onGetSize);
    }
    super.didChangeDependencies();
  }

  void onChangeNotifier() {
    final controller = widget.controller!;
    final event = controller.event;
    int index;
    if (event == null) return;
    if (event is MoveIndexControllerEvent) {
      index = _pageController.getRealIndexFromRenderIndex(event.newIndex);
    } else if (event is StepBasedIndexControllerEvent) {
      index = event.calcNextIndex(
        currentIndex: _activeIndex,
        itemCount: _pageController.itemCount,
        loop: _pageController.loop,
        reverse: _pageController.reverse,
      );
    } else {
      //ignore other events
      return;
    }
    if (_pageController.hasClients) {
      if (event.animation) {
        _pageController
            .animateToPage(
              index,
              duration: widget.duration,
              curve: widget.curve,
            )
            .whenComplete(event.complete);
      } else {
        _pageController.jumpToPage(index);
        event.complete();
      }
    } else {
      event.complete();
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(onChangeNotifier);
    if (_ownsPageController) _pageController.dispose();
    super.dispose();
  }
}
