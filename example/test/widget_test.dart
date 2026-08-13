import 'package:flutter_test/flutter_test.dart';
import 'package:swiper_view_pro_example/main.dart';

void main() {
  testWidgets('example home builds', (tester) async {
    await tester.pumpWidget(const SwiperExampleApp());
    expect(find.text('swiper_view_pro'), findsOneWidget);
    expect(find.text('3D switch'), findsOneWidget);
  });
}
