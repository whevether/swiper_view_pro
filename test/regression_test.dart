import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';

import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';
import 'package:swiper_view_pro/swiper_view_pro.dart';

Widget host(Swiper swiper) =>
    MaterialApp(home: SizedBox(width: 400, height: 300, child: swiper));
Swiper stack(
  SwiperController c, {
  int index = 0,
  ValueChanged<int>? changed,
  bool loop = false,
}) => Swiper(
  controller: c,
  index: index,
  itemCount: 5,
  layout: SwiperLayout.STACK,
  itemWidth: 200,
  itemHeight: 200,
  loop: loop,
  onIndexChanged: changed,
  itemBuilder: (_, i) => Text('slide:$i'),
);
void main() {
  testWidgets('stack command completes after transition', (t) async {
    final c = SwiperController();
    await t.pumpWidget(host(stack(c)));
    await t.pump();
    var completed = false;
    c.next().then((_) => completed = true);
    await t.pumpAndSettle();
    expect(c.index, 1);
    expect(completed, true);
  });
  testWidgets('stack command can jump without animation', (t) async {
    final c = SwiperController();
    await t.pumpWidget(host(stack(c)));
    await t.pump();
    c.next(animation: false);
    await t.pump();
    expect(c.index, 1);
    await t.pumpAndSettle();
    expect(c.index, 1);
  });
  testWidgets('stack synchronizes controlled index before next command', (
    t,
  ) async {
    final c = SwiperController();
    await t.pumpWidget(host(stack(c)));
    await t.pump();
    await t.pumpWidget(host(stack(c, index: 2)));
    await t.pump();
    expect(c.index, 2);
    c.next();
    await t.pumpAndSettle();
    expect(c.index, 3);
  });
  testWidgets('nonloop stack omits out of range cards', (t) async {
    final c = SwiperController();
    await t.pumpWidget(host(stack(c)));
    await t.pump();
    expect(find.text('slide:4'), findsNothing);
    expect(find.text('slide:3'), findsNothing);
  });
  testWidgets('custom scale respects its alignment', (t) async {
    final builder = ScaleTransformBuilder(
      values: [1],
      alignment: Alignment.topLeft,
    );
    final result = builder.build(0, .5, const SizedBox()) as Transform;
    expect(result.alignment, Alignment.topLeft);
  });
  testWidgets('loop parallax uses data indices without paint errors', (
    t,
  ) async {
    await t.pumpWidget(
      host(
        Swiper(
          itemCount: 3,
          itemBuilder: (_, i) => Text('$i'),
          transformer: PageTransformerBuilder(
            builder: (child, info) => ParallaxColor(
              colors: const [Colors.red, Colors.green, Colors.blue],
              info: info,
              child: child,
            ),
          ),
        ),
      ),
    );
    await t.pump();
    expect(t.takeException(), isNull);
  });
  testWidgets('reversed pagination starts at data index zero', (t) async {
    final c = TransformerPageController(
      initialPage: 0,
      itemCount: 5,
      loop: true,
      reverse: true,
    );
    await t.pumpWidget(
      MaterialApp(
        home: PageIndicator(
          count: 5,
          controller: c,
          layout: PageIndicatorLayout.SCALE,
        ),
      ),
    );
    final painter =
        t
                .widget<CustomPaint>(
                  find.byWidgetPredicate(
                    (w) => w is CustomPaint && w.painter is BasePainter,
                  ),
                )
                .painter
            as BasePainter;
    expect(painter.index, 0);
    expect(c.getRenderIndexFromRealIndex(c.initialPage), 0);
    await t.pumpWidget(const SizedBox());
    c.dispose();
  });
  testWidgets('indicator repaints after color changes', (t) async {
    final c = PageController();
    final p = Paint();
    final before = ScalePainter(
      PageIndicator(count: 3, controller: c, color: Colors.red),
      0,
      0,
      p,
    );
    final after = ScalePainter(
      PageIndicator(count: 3, controller: c, color: Colors.blue),
      0,
      0,
      p,
    );
    expect(after.shouldRepaint(before), true);
    c.dispose();
  });
  testWidgets('standalone page view applies viewport fraction', (t) async {
    await t.pumpWidget(
      MaterialApp(
        home: TransformerPageView(
          loop: false,
          itemCount: 3,
          viewportFraction: .5,
          itemBuilder: (_, i) => Text('$i'),
        ),
      ),
    );
    final page = t.widget<PageView>(find.byType(PageView));
    expect(page.controller!.viewportFraction, .5);
  });
  testWidgets('manual autoplay stop persists after scrolling', (t) async {
    final c = SwiperController();
    await t.pumpWidget(
      host(
        Swiper(
          controller: c,
          itemCount: 5,
          autoplay: true,
          autoplayDelay: 200,
          duration: 10,
          itemBuilder: (_, i) => Text('$i'),
        ),
      ),
    );
    c.stopAutoplay();
    c.next();
    await t.pump();
    await t.pump(const Duration(milliseconds: 20));
    expect(c.index, 1);
    await t.pump(const Duration(milliseconds: 210));
    await t.pump(const Duration(milliseconds: 20));
    expect(c.index, 1);
    await t.pumpWidget(const SizedBox());
  });

  testWidgets('keyboard wrapper allows descendant focus', (t) async {
    final focus = FocusNode();
    await t.pumpWidget(
      host(
        Swiper(
          itemCount: 1,
          itemBuilder: (_, i) => Material(child: TextField(focusNode: focus)),
        ),
      ),
    );
    expect(focus.canRequestFocus, true);
    await t.pumpWidget(const SizedBox());
    focus.dispose();
  });

  testWidgets('stack can shrink from looping content to empty', (t) async {
    final c = SwiperController();
    await t.pumpWidget(host(stack(c, loop: true)));
    await t.pump();
    await t.pumpWidget(
      host(
        Swiper(
          controller: c,
          itemCount: 0,
          layout: SwiperLayout.STACK,
          itemWidth: 200,
          itemHeight: 200,
          itemBuilder: (_, i) => Text('$i'),
        ),
      ),
    );
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
    expect(c.index, 0);
  });

  for (final layout in [
    SwiperLayout.STACK,
    SwiperLayout.TINDER,
    SwiperLayout.CUSTOM,
  ]) {
    testWidgets(
      '$layout queues commands and completes pending commands on removal',
      (t) async {
        final c = SwiperController();
        final option = CustomLayoutOption(startIndex: -1, stateCount: 3)
          ..addTranslate([
            const Offset(-100, 0),
            Offset.zero,
            const Offset(100, 0),
          ]);
        await t.pumpWidget(
          host(
            Swiper(
              controller: c,
              itemCount: 5,
              layout: layout,
              itemWidth: 200,
              itemHeight: 200,
              customLayoutOption: option,
              itemBuilder: (_, i) => Text('$i'),
            ),
          ),
        );
        await t.pumpAndSettle();
        var completed = 0;
        c.next().then((_) => completed++);
        c.next().then((_) => completed++);
        await t.pumpAndSettle();
        expect(c.index, 2);
        expect(completed, 2);
        final moving = c.next();
        final queued = c.next();
        await t.pump(const Duration(milliseconds: 10));
        await t.pumpWidget(const SizedBox());
        await moving;
        await queued;
        expect(t.takeException(), isNull);
        c.dispose();
      },
    );
  }

  testWidgets(
    'standalone page view preserves controller and page on parent rebuild',
    (t) async {
      Widget view(Duration duration) => MaterialApp(
        home: TransformerPageView(
          loop: false,
          index: 2,
          itemCount: 5,
          duration: duration,
          itemBuilder: (_, i) => Text('$i'),
        ),
      );
      await t.pumpWidget(view(const Duration(milliseconds: 300)));
      await t.pumpAndSettle();
      final controller = t.widget<PageView>(find.byType(PageView)).controller!;
      expect(controller.page, 2);
      await t.pumpWidget(view(const Duration(milliseconds: 500)));
      await t.pumpAndSettle();
      expect(
        t.widget<PageView>(find.byType(PageView)).controller,
        same(controller),
      );
      expect(controller.page, 2);
      await t.pumpWidget(const SizedBox());
      expect(() => controller.addListener(() {}), throwsFlutterError);
    },
  );

  testWidgets(
    'swiper retires internal page controllers but preserves external index controller',
    (t) async {
      final c = SwiperController();
      Widget view(double fraction) => host(
        Swiper(
          controller: c,
          itemCount: 5,
          viewportFraction: fraction,
          itemBuilder: (_, i) => Text('$i'),
        ),
      );
      await t.pumpWidget(view(1));
      await t.pumpAndSettle();
      final old = t.widget<PageView>(find.byType(PageView)).controller!;
      await t.pumpWidget(view(.5));
      await t.pumpAndSettle();
      final current = t.widget<PageView>(find.byType(PageView)).controller!;
      expect(current, isNot(same(old)));
      expect(() => old.addListener(() {}), throwsFlutterError);
      await t.pumpWidget(const SizedBox());
      expect(() => current.addListener(() {}), throwsFlutterError);
      expect(() => c.addListener(() {}), returnsNormally);
      c.dispose();
    },
  );

  testWidgets('standalone external page controller remains caller owned', (
    t,
  ) async {
    final c = TransformerPageController(itemCount: 5);
    await t.pumpWidget(
      MaterialApp(
        home: TransformerPageView(
          pageController: c,
          itemCount: 5,
          loop: false,
          itemBuilder: (_, i) => Text('$i'),
        ),
      ),
    );
    await t.pumpWidget(const SizedBox());
    expect(() => c.addListener(() {}), returnsNormally);
    c.dispose();
  });

  testWidgets('animation frames reuse expensive item content', (t) async {
    final c = SwiperController();
    final builds = <int, int>{};
    var transforms = 0;
    await t.pumpWidget(
      host(
        Swiper(
          controller: c,
          itemCount: 5,
          itemBuilder: (_, i) {
            builds.update(i, (count) => count + 1, ifAbsent: () => 1);
            return Text('$i');
          },
          transformer: PageTransformerBuilder(
            builder: (child, info) {
              transforms++;
              return child;
            },
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    final previousBuilds = Map<int, int>.of(builds);
    final previousTransforms = transforms;
    c.next();
    await t.pump();
    await t.pump(const Duration(milliseconds: 16));
    for (final entry in previousBuilds.entries) {
      expect(builds[entry.key], entry.value);
    }
    expect(transforms, greaterThan(previousTransforms));
    await t.pumpAndSettle();
  });

  testWidgets('focused text field keeps arrow keys for editing', (t) async {
    final c = SwiperController();
    final focus = FocusNode();
    await t.pumpWidget(
      host(
        Swiper(
          controller: c,
          loop: false,
          itemCount: 3,
          itemBuilder: (_, i) => Material(
            child: i == 0 ? TextField(focusNode: focus) : Text('$i'),
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    focus.requestFocus();
    await t.pump();
    await t.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await t.pump(const Duration(milliseconds: 400));
    expect(focus.hasFocus, true);
    expect(c.index, 0);
    await t.pumpWidget(const SizedBox());
    focus.dispose();
    c.dispose();
  });

  test('indicator paints the configured active dot size', () async {
    final c = PageController();
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final indicator = PageIndicator(
      count: 2,
      size: 4,
      activeSize: 12,
      controller: c,
      activeColor: Colors.red,
      color: Colors.blue,
    );
    SlidePainter(indicator, 0, 0, Paint()).paint(canvas, const Size(30, 20));
    final picture = recorder.endRecording();
    final image = await picture.toImage(30, 20);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    var redPixels = 0;
    for (var i = 0; i < bytes!.lengthInBytes; i += 4) {
      if (bytes.getUint8(i) > 200 &&
          bytes.getUint8(i + 1) < 120 &&
          bytes.getUint8(i + 3) > 200) {
        redPixels++;
      }
    }
    expect(redPixels, greaterThan(70));
    image.dispose();
    picture.dispose();
    c.dispose();
  });

  testWidgets('indicator handles empty counts and controller replacement', (
    t,
  ) async {
    final first = TransformerPageController(
      itemCount: 5,
      initialPage: 2,
      loop: true,
    );
    final second = TransformerPageController(
      itemCount: 5,
      initialPage: 4,
      loop: true,
    );
    Widget view(PageController c, int count) => MaterialApp(
      home: PageIndicator(count: count, controller: c),
    );
    await t.pumpWidget(view(first, 5));
    await t.pumpWidget(view(second, 5));
    final painted = t.widget<CustomPaint>(
      find.byWidgetPredicate(
        (w) => w is CustomPaint && w.painter is BasePainter,
      ),
    );
    expect((painted.painter as BasePainter).index, 4);
    await t.pumpWidget(view(second, 0));
    expect(t.takeException(), isNull);
    await t.pumpWidget(const SizedBox());
    first.dispose();
    second.dispose();
  });
  testWidgets('loop pagination animates between the last and first dots', (
    t,
  ) async {
    final c = SwiperController();
    await t.pumpWidget(
      host(
        Swiper(
          controller: c,
          index: 4,
          itemCount: 5,
          itemBuilder: (_, i) => Text('$i'),
          indicatorLayout: PageIndicatorLayout.SCALE,
          pagination: const SwiperPagination(),
        ),
      ),
    );
    await t.pumpAndSettle();
    c.next();
    await t.pump();
    await t.pump(const Duration(milliseconds: 60));
    final painted = t.widget<CustomPaint>(
      find.byWidgetPredicate(
        (w) => w is CustomPaint && w.painter is BasePainter,
      ),
    );
    expect((painted.painter as BasePainter).page, greaterThan(4));
    await t.pumpAndSettle();
    expect(c.index, 0);
  });

  testWidgets(
    'transform metadata settles on logical indices across loop boundaries',
    (t) async {
      final c = SwiperController();
      final states = <TransformInfo>[];
      await t.pumpWidget(
        host(
          Swiper(
            controller: c,
            itemCount: 3,
            itemBuilder: (_, i) => Text('$i'),
            transformer: PageTransformerBuilder(
              builder: (child, info) {
                states.add(info);
                return child;
              },
            ),
          ),
        ),
      );
      await t.pumpAndSettle();
      c.previous();
      await t.pumpAndSettle();
      expect(c.index, 2);
      expect(states.every((s) => s.fromIndex >= 0 && s.fromIndex < 3), true);
      expect(states.last.done, true);
      expect(states.last.fromIndex, 2);
    },
  );

  testWidgets('swiper disposes its internally created index controller', (
    t,
  ) async {
    SwiperController? owned;
    await t.pumpWidget(
      host(
        Swiper(
          itemCount: 3,
          itemBuilder: (_, i) => Text('$i'),
          pagination: SwiperCustomPagination(
            builder: (_, config) {
              owned = config.controller;
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
    await t.pumpWidget(const SizedBox());
    expect(() => owned!.addListener(() {}), throwsFlutterError);
  });
}
