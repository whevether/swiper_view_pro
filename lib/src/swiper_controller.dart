import 'package:swiper_view_pro/swiper_view_pro.dart';

@Deprecated('Legacy event; use IndexController.move instead.')
class SwipeIndexControllerEvent extends IndexControllerEventBase {
  SwipeIndexControllerEvent({required this.pos, required super.animation});
  final double pos;
}

@Deprecated('Legacy event; build plugins with SwiperPluginConfig instead.')
class BuildIndexControllerEvent extends IndexControllerEventBase {
  BuildIndexControllerEvent({required super.animation, required this.config});
  final SwiperPluginConfig config;
}

class AutoPlaySwiperControllerEvent extends IndexControllerEventBase {
  AutoPlaySwiperControllerEvent({
    required super.animation,
    required this.autoplay,
  });

  AutoPlaySwiperControllerEvent.start({required bool animation})
    : this(animation: animation, autoplay: true);
  AutoPlaySwiperControllerEvent.stop({required bool animation})
    : this(animation: animation, autoplay: false);
  final bool autoplay;
}

class SwiperController extends IndexController {
  void startAutoplay({bool animation = true}) {
    event = AutoPlaySwiperControllerEvent.start(animation: animation);
    notifyListeners();
  }

  void stopAutoplay({bool animation = true}) {
    event = AutoPlaySwiperControllerEvent.stop(animation: animation);
    notifyListeners();
  }
}
