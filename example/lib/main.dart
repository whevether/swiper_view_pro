import 'package:flutter/material.dart';
import 'package:swiper_view_pro/swiper_view_pro.dart';

import 'src/example_custom.dart';

const _colors = <Color>[
  Color(0xFF1565C0),
  Color(0xFF00897B),
  Color(0xFFEF6C00),
  Color(0xFF6A1B9A),
  Color(0xFFC62828),
];

void main() => runApp(const SwiperExampleApp());

class SwiperExampleApp extends StatelessWidget {
  const SwiperExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'swiper_view_pro example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ExampleHomePage(),
    );
  }
}

class ExampleHomePage extends StatelessWidget {
  const ExampleHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final demos = <_DemoItem>[
      _DemoItem('Default', const DefaultDemoPage()),
      _DemoItem('Scale & fade', const ScaleFadeDemoPage()),
      _DemoItem('3D switch', const ThreeDDemoPage()),
      _DemoItem('STACK', const StackDemoPage()),
      _DemoItem('TINDER', const TinderDemoPage()),
      _DemoItem('CUSTOM', const ExampleCustomPage()),
      _DemoItem('Accordion / Depth / Zoom', const ExtraTransformerDemoPage()),
      _DemoItem('Pagination & control', const PluginDemoPage()),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('swiper_view_pro')),
      body: ListView.separated(
        itemCount: demos.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final demo = demos[index];
          return ListTile(
            title: Text(demo.title),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => demo.page),
              );
            },
          );
        },
      ),
    );
  }
}

class _DemoItem {
  const _DemoItem(this.title, this.page);
  final String title;
  final Widget page;
}

Widget _colorCard(int index, {BorderRadius? radius}) {
  return Container(
    decoration: BoxDecoration(
      color: _colors[index % _colors.length],
      borderRadius: radius,
    ),
    alignment: Alignment.center,
    child: Text(
      '${index + 1}',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 48,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

class DefaultDemoPage extends StatelessWidget {
  const DefaultDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Default')),
      body: Swiper(
        itemBuilder: (context, index) => _colorCard(index),
        itemCount: _colors.length,
        pagination: const SwiperPagination(),
        control: const SwiperControl(),
        autoplay: true,
      ),
    );
  }
}

class ScaleFadeDemoPage extends StatelessWidget {
  const ScaleFadeDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scale & fade')),
      body: Swiper(
        itemBuilder: (context, index) => _colorCard(index),
        itemCount: _colors.length,
        viewportFraction: 0.8,
        scale: 0.9,
        fade: 0.4,
        pagination: const SwiperPagination(),
      ),
    );
  }
}

class ThreeDDemoPage extends StatefulWidget {
  const ThreeDDemoPage({super.key});

  @override
  State<ThreeDDemoPage> createState() => _ThreeDDemoPageState();
}

class _ThreeDDemoPageState extends State<ThreeDDemoPage> {
  bool enable3D = true;
  Swiper3DStyle style = Swiper3DStyle.cube;

  @override
  Widget build(BuildContext context) {
    final coverflow = style == Swiper3DStyle.coverflow && enable3D;
    return Scaffold(
      appBar: AppBar(title: const Text('3D switch')),
      body: Column(
        children: [
          SwitchListTile(
            title: const Text('enable3D'),
            value: enable3D,
            onChanged: (value) => setState(() => enable3D = value),
          ),
          ListTile(
            title: const Text('threeDStyle'),
            trailing: DropdownButton<Swiper3DStyle>(
              value: style,
              onChanged: enable3D
                  ? (value) {
                      if (value != null) setState(() => style = value);
                    }
                  : null,
              items: Swiper3DStyle.values
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text(item.name),
                    ),
                  )
                  .toList(),
            ),
          ),
          Expanded(
            child: Swiper(
              itemBuilder: (context, index) => _colorCard(index),
              itemCount: _colors.length,
              enable3D: enable3D,
              threeDStyle: style,
              viewportFraction: coverflow ? 0.75 : 1.0,
              pagination: const SwiperPagination(),
              control: const SwiperControl(),
            ),
          ),
        ],
      ),
    );
  }
}

class StackDemoPage extends StatelessWidget {
  const StackDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('STACK')),
      body: Center(
        child: SizedBox(
          height: 300,
          child: Swiper(
            itemBuilder: (context, index) => _colorCard(
              index,
              radius: BorderRadius.circular(12),
            ),
            itemCount: _colors.length,
            itemWidth: 300,
            itemHeight: 220,
            layout: SwiperLayout.STACK,
          ),
        ),
      ),
    );
  }
}

class TinderDemoPage extends StatelessWidget {
  const TinderDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TINDER')),
      body: Center(
        child: SizedBox(
          height: 420,
          child: Swiper(
            itemBuilder: (context, index) => _colorCard(
              index,
              radius: BorderRadius.circular(16),
            ),
            itemCount: _colors.length,
            itemWidth: 300,
            itemHeight: 400,
            layout: SwiperLayout.TINDER,
          ),
        ),
      ),
    );
  }
}

class ExtraTransformerDemoPage extends StatefulWidget {
  const ExtraTransformerDemoPage({super.key});

  @override
  State<ExtraTransformerDemoPage> createState() =>
      _ExtraTransformerDemoPageState();
}

class _ExtraTransformerDemoPageState extends State<ExtraTransformerDemoPage> {
  int selected = 0;

  PageTransformer get _transformer {
    switch (selected) {
      case 1:
        return DepthPageTransformer();
      case 2:
        return ZoomInPageTransformer();
      case 3:
        return ZoomOutPageTransformer();
      default:
        return AccordionTransformer();
    }
  }

  @override
  Widget build(BuildContext context) {
    const labels = ['Accordion', 'Depth', 'ZoomIn', 'ZoomOut'];
    return Scaffold(
      appBar: AppBar(title: const Text('Extra transformers')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Wrap(
              spacing: 8,
              children: [
                for (var i = 0; i < labels.length; i++)
                  ChoiceChip(
                    label: Text(labels[i]),
                    selected: selected == i,
                    onSelected: (_) => setState(() => selected = i),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Swiper(
              transformer: _transformer,
              itemBuilder: (context, index) => _colorCard(index),
              itemCount: _colors.length,
              pagination: const SwiperPagination(),
            ),
          ),
        ],
      ),
    );
  }
}

class PluginDemoPage extends StatelessWidget {
  const PluginDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pagination & control')),
      body: Swiper(
        itemBuilder: (context, index) => _colorCard(index),
        itemCount: _colors.length,
        autoplay: true,
        pagination: const SwiperPagination(
          builder: SwiperPagination.fraction,
        ),
        control: const SwiperControl(),
      ),
    );
  }
}
