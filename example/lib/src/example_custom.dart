import 'package:material_ui/material_ui.dart';
import 'package:swiper_view_pro/swiper_view_pro.dart';

/// Custom layout demo linked from the package README.
class ExampleCustomPage extends StatelessWidget {
  const ExampleCustomPage({super.key});

  @override
  Widget build(BuildContext context) {
    final option = CustomLayoutOption(startIndex: -1, stateCount: 3)
      ..addRotate([-45.0 / 180, 0.0, 45.0 / 180])
      ..addTranslate([
        const Offset(-370.0, -40.0),
        Offset.zero,
        const Offset(370.0, -40.0),
      ]);

    return Scaffold(
      appBar: AppBar(title: const Text('CUSTOM')),
      body: Center(
        child: SizedBox(
          height: 240,
          child: Swiper(
            layout: SwiperLayout.CUSTOM,
            customLayoutOption: option,
            itemWidth: 300,
            itemHeight: 200,
            itemBuilder: (context, index) {
              return Container(
                color: Colors.grey.shade700,
                alignment: Alignment.center,
                child: Text(
                  '$index',
                  style: const TextStyle(color: Colors.white, fontSize: 32),
                ),
              );
            },
            itemCount: 10,
          ),
        ),
      ),
    );
  }
}
