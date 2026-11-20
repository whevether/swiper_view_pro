import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:swiper_view_pro/swiper_view_pro.dart';

Widget _item(BuildContext c, int i) => Text('item $i');

Widget _host(Widget w) =>
    MaterialApp(home: SizedBox(width: 400, height: 300, child: w));

void main() {
  testWidgets('emptyBuilder is shown when itemCount is 0', (t) async {
    await t.pumpWidget(_host(Swiper(
      itemCount: 0,
      itemBuilder: _item,
      emptyBuilder: (c) => const Text('nothing here'),
    )));
    expect(find.text('nothing here'), findsOneWidget);
  });

  testWidgets('onScroll reports fractional pages while dragging', (t) async {
    final pages = <double>[];
    await t.pumpWidget(_host(Swiper(
      itemCount: 3,
      itemBuilder: _item,
      onScroll: pages.add,
    )));
    await t.drag(find.byType(Swiper), const Offset(-120, 0));
    await t.pumpAndSettle();
    expect(pages, isNotEmpty);
  });

  testWidgets('semantics expose page value and increase/decrease actions',
      (t) async {
    final handle = t.ensureSemantics();
    final controller = SwiperController();
    await t.pumpWidget(_host(Swiper(
      itemCount: 3,
      loop: false,
      controller: controller,
      semanticLabel: 'banner',
      itemBuilder: _item,
    )));
    final node = t.getSemantics(find.bySemanticsLabel('banner'));
    expect(node.value, '1 / 3');
    t.semantics
        .performAction(find.semantics.byLabel('banner'), SemanticsAction.increase);
    await t.pumpAndSettle();
    expect(controller.index, 1);
    handle.dispose();
  });

  testWidgets('autoplay pauses in background and resumes', (t) async {
    final controller = SwiperController();
    await t.pumpWidget(_host(Swiper(
      itemCount: 3,
      autoplay: true,
      autoplayDelay: 100,
      controller: controller,
      itemBuilder: _item,
    )));
    t.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    await t.pump(const Duration(milliseconds: 500));
    expect(controller.index, 0);
    t.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    t.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    for (var i = 0; i < 20; i++) {
      await t.pump(const Duration(milliseconds: 50));
    }
    expect(controller.index, isNot(0));
    await t.pumpWidget(const SizedBox());
  });

  testWidgets('keyboard does not autofocus by default', (t) async {
    final controller = SwiperController();
    await t.pumpWidget(_host(Swiper(
      itemCount: 3,
      loop: false,
      controller: controller,
      itemBuilder: _item,
    )));
    await t.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await t.pumpAndSettle();
    expect(controller.index, 0);
  });

  testWidgets('vertical stack without itemHeight reports a clear error',
      (t) async {
    await t.pumpWidget(_host(Swiper(
      itemCount: 3,
      layout: SwiperLayout.STACK,
      scrollDirection: Axis.vertical,
      itemWidth: 100,
      itemBuilder: _item,
    )));
    expect(t.takeException(), isA<FlutterError>());
  });
}
