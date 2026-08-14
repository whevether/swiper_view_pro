import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swiper_view_pro/swiper_view_pro.dart';

Widget _item(BuildContext context, int index) {
  return Text('$index', key: ValueKey('item_$index'));
}

void main() {
  testWidgets('controller jump without animation', (WidgetTester tester) async {
    final controller = SwiperController();
    await tester.pumpWidget(MaterialApp(
      home: Swiper(
        controller: controller,
        loop: false,
        itemBuilder: _item,
        itemCount: 5,
      ),
    ));
    await tester.pumpAndSettle();
    await controller.move(2, animation: false);
    await tester.pumpAndSettle();
    expect(controller.index, 2);
    expect(find.text('2', skipOffstage: false), findsWidgets);
  });

  testWidgets('loop false next stays at last index',
      (WidgetTester tester) async {
    final controller = SwiperController();
    await tester.pumpWidget(MaterialApp(
      home: Swiper(
        controller: controller,
        loop: false,
        itemBuilder: _item,
        itemCount: 3,
      ),
    ));
    await tester.pumpAndSettle();
    await controller.move(2, animation: false);
    await tester.pumpAndSettle();
    await controller.next(animation: false);
    await tester.pumpAndSettle();
    expect(controller.index, 2);
  });

  testWidgets('slidesPerView builds', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Swiper(
        itemBuilder: _item,
        itemCount: 5,
        slidesPerView: 2.5,
        spaceBetween: 12,
      ),
    ));
    expect(find.byType(Swiper), findsOneWidget);
  });

  testWidgets('RTL builds', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Swiper(
          itemBuilder: _item,
          itemCount: 5,
          pagination: SwiperPagination(),
          control: SwiperControl(),
        ),
      ),
    ));
    expect(find.byType(Swiper), findsOneWidget);
  });

  testWidgets('pagination tap moves', (WidgetTester tester) async {
    final controller = SwiperController();
    await tester.pumpWidget(MaterialApp(
      home: Swiper(
        controller: controller,
        loop: false,
        itemBuilder: _item,
        itemCount: 5,
        pagination: const SwiperPagination(),
      ),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('pagination_2')));
    await tester.pumpAndSettle();
    expect(controller.index, 2);
  });

  testWidgets('keyboard arrow moves', (WidgetTester tester) async {
    final controller = SwiperController();
    await tester.pumpWidget(MaterialApp(
      home: Swiper(
        controller: controller,
        loop: false,
        itemBuilder: _item,
        itemCount: 5,
      ),
    ));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(controller.index, 1);
  });

  testWidgets('playback onActiveChanged and playing pauses autoplay',
      (WidgetTester tester) async {
    final active = <(int, bool)>[];
    final playing = ValueNotifier(false);
    await tester.pumpWidget(MaterialApp(
      home: Swiper(
        loop: false,
        autoplay: true,
        autoplayDelay: 50,
        itemBuilder: _item,
        itemCount: 3,
        playback: SwiperPlaybackConfig(
          playing: playing,
          onActiveChanged: (index, isActive) {
            active.add((index, isActive));
          },
        ),
      ),
    ));
    await tester.pump();
    expect(active, isNotEmpty);
    expect(active.first.$1, 0);
    expect(active.first.$2, isTrue);

    playing.value = true;
    await tester.pump(const Duration(milliseconds: 120));
    final indexAfterPause = active.last.$1;
    playing.value = false;
    await tester.pump(const Duration(milliseconds: 80));
    expect(indexAfterPause, 0);
  });

  testWidgets('SwiperItemScope reports active page',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Swiper(
        loop: false,
        itemBuilder: (context, index) {
          final scope = SwiperItemScope.of(context);
          return Text(
            '${scope.index}:${scope.isActive}',
            key: ValueKey('scope_$index'),
          );
        },
        itemCount: 3,
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('0:true', skipOffstage: false), findsWidgets);
  });
}
