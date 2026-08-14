import 'package:flutter/material.dart';
import 'package:swiper_view_pro/swiper_view_pro.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _item(BuildContext context, int index) {
  return Container(
    color: Colors.grey,
    child: Center(child: Text('$index')),
  );
}

void main() {
  testWidgets('enable3D cube builds', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Swiper(
        enable3D: true,
        threeDStyle: Swiper3DStyle.cube,
        itemBuilder: _item,
        itemCount: 5,
      ),
    ));
    expect(find.text('0', skipOffstage: false), findsWidgets);
  });

  testWidgets('enable3D styles build', (WidgetTester tester) async {
    for (final style in Swiper3DStyle.values) {
      await tester.pumpWidget(MaterialApp(
        home: Swiper(
          enable3D: true,
          threeDStyle: style,
          itemBuilder: _item,
          itemCount: 5,
        ),
      ));
      expect(find.text('0', skipOffstage: false), findsWidgets);
    }
  });

  testWidgets('explicit transformer wins over enable3D',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Swiper(
        enable3D: true,
        threeDStyle: Swiper3DStyle.cube,
        transformer: AccordionTransformer(),
        itemBuilder: _item,
        itemCount: 5,
      ),
    ));
    expect(find.text('0', skipOffstage: false), findsWidgets);
  });

  testWidgets('built-in transformers build', (WidgetTester tester) async {
    final transformers = <PageTransformer>[
      AccordionTransformer(),
      DepthPageTransformer(),
      ZoomInPageTransformer(),
      ZoomOutPageTransformer(),
      ScaleAndFadeTransformer(),
      CubeTransformer(),
      ThreeDTransformer(),
      FlipTransformer(),
      CoverflowTransformer(),
      CarouselTransformer(),
      CardsTransformer(),
      RotateTransformer(),
    ];
    for (final transformer in transformers) {
      await tester.pumpWidget(MaterialApp(
        home: Swiper(
          transformer: transformer,
          itemBuilder: _item,
          itemCount: 5,
        ),
      ));
      expect(find.byType(Swiper), findsOneWidget);
    }
  });
}
