import 'package:material_ui/material_ui.dart';
import 'package:swiper_view_pro/swiper_view_pro.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Control horizontal', (WidgetTester tester) async {
    SwiperController controller = SwiperController();

    SwiperPluginConfig config = SwiperPluginConfig(
        activeIndex: 0,
        controller: controller,
        itemCount: 10,
        loop: true,
        scrollDirection: Axis.horizontal);

    Key key = UniqueKey();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: Builder(builder: (BuildContext context) {
        return SwiperControl(key: key).build(context, config);
      })),
    ));

    expect(find.byKey(key), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back_ios));
  });

  testWidgets('Control vertical', (WidgetTester tester) async {
    SwiperController controller = SwiperController();

    SwiperPluginConfig config = SwiperPluginConfig(
        activeIndex: 0,
        controller: controller,
        itemCount: 10,
        loop: true,
        scrollDirection: Axis.vertical);

    Key key = UniqueKey();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: Builder(builder: (BuildContext context) {
        return SwiperControl(
                key: key, color: Colors.white, disableColor: Colors.black87)
            .build(context, config);
      })),
    ));

    expect(find.byKey(key), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back_ios));
  });
}
