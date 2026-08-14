import 'package:flutter/widgets.dart';

/// Host-owned media playback hooks. This package does not embed a video widget.
class SwiperPlaybackConfig {
  const SwiperPlaybackConfig({
    this.onActiveChanged,
    this.playing,
    this.pauseAutoplayWhilePlaying = true,
  });

  /// Fired when a page becomes the active page or leaves it.
  /// The host should play / pause its own player here.
  final void Function(int index, bool active)? onActiveChanged;

  /// Host sets `true` while media is playing so swiper autoplay can pause.
  final ValueNotifier<bool>? playing;

  /// When [playing] is true, stop the swiper autoplay timer.
  final bool pauseAutoplayWhilePlaying;
}

/// Provides the item index and whether it is the active page.
class SwiperItemScope extends InheritedWidget {
  const SwiperItemScope({
    super.key,
    required this.index,
    required this.activeIndex,
    required super.child,
  });

  final int index;
  final int activeIndex;

  bool get isActive => index == activeIndex;

  static SwiperItemScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SwiperItemScope>();
  }

  static SwiperItemScope of(BuildContext context) {
    final scope = maybeOf(context);
    assert(scope != null, 'SwiperItemScope.of() called with no ancestor');
    return scope!;
  }

  @override
  bool updateShouldNotify(SwiperItemScope oldWidget) {
    return index != oldWidget.index || activeIndex != oldWidget.activeIndex;
  }
}
