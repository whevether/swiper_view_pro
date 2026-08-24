![Logo](banner.jpg)

<p align="center">
    <a href="https://github.com/whevether/swiper_view_pro">
        <img src="https://img.shields.io/badge/GitHub-swiper__view__pro-blue.svg" alt="GitHub" />
    </a>
    <a href="https://github.com/whevether/swiper_view_pro/pulls">
        <img src="https://img.shields.io/badge/PRs-Welcome-brightgreen.svg" alt="PRs Welcome" />
    </a>
    <a href="https://pub.flutter-io.cn/packages/swiper_view_pro">
        <img src="https://img.shields.io/pub/v/swiper_view_pro.svg" alt="pub package" />
    </a>
</p>
<p align="center">
    <a href="https://github.com/whevether/swiper_view_pro">
        <b>英文说明</b>
    </a>
</p>


# swiper_view_pro

Flutter swiper/carousel，多种布局、无限轮播、可配置 3D 效果，兼容 Android 与 iOS。


# :sparkles::sparkles: New Features: 视差

我们在 Swiper 中也像 Android 一样支持了 `PageTransformer`, 只要给 Swiper 设置一下 `transformer` 属性就行,
这里返回一个被转换的组件给 Swiper. 目前仅仅支持 `DEFAULT` 布局.
感谢 @FlutterRocks ,棒棒哒 👏.




# :sparkles::sparkles: 新功能


![](https://github.com/jzoom/images/raw/master/layout1.gif)

![](https://github.com/jzoom/images/raw/master/layout2.gif)

![](https://github.com/jzoom/images/raw/master/layout3.gif)

[更多](#内建的布局)


# 截图

![Horizontal](https://github.com/whevether/swiper_view_pro/raw/main/example/res/1.gif)

![Vertical](https://github.com/whevether/swiper_view_pro/raw/main/example/res/2.gif)

![Custom Pagination](https://github.com/whevether/swiper_view_pro/raw/main/example/res/3.gif)

![Custom Pagination](https://github.com/whevether/swiper_view_pro/raw/main/example/res/4.gif)

![Phone](https://github.com/whevether/swiper_view_pro/raw/main/example/res/5.gif)

![Example](https://github.com/jzoom/images/raw/master/swiper-example.gif)

[更多](#代码)

## 功能路线

1.x.x 功能实现：

- [x] 无限循环轮播
- [x] 控制按钮
- [x] 分页指示器
- [x] 非无限循环模式
- [x] 单元测试
- [x] 例子
- [x] 可配置 3D 效果
- [x] 滚动方向
- [x] 可定制控制按钮
- [x] 可定制分页
- [x] 自动播放
- [x] 控制器
- [x] 外部分页指示器
- [x] 更多布局方式


## 更新日志

>参考:[CHANGELOG.md](https://github.com/whevether/swiper_view_pro/blob/main/CHANGELOG-ZH.md)

## 目录

- [安装](#安装)
- [基本使用](#基本使用)
- [构建](#构建)
  + [基本构造函数](#基本构造函数)
  + [分页指示器](#分页指示器)
  + [控制按钮](#控制按钮)
  + [控制器](#控制器)
  + [自动播放](#自动播放)
+ [3D 效果](#3d-效果)
+ [多卡布局](#多卡布局)
+ [视频 / 媒体](#视频--媒体)
+ [内建的布局](#内建的布局)
+ [一些常用代码示例](#代码)

### 安装

增加

```dart
dependencies:
  swiper_view_pro: ^0.1.0
```
到项目根目录下的 pubspec.yaml ,并且根目录运行命令行 

```dart
flutter pub get 
```


### 基本使用

使用命令行创建一个新项目:

```dart
flutter create myapp
```

编辑 lib/main.dart:

```dart
import 'package:material_ui/material_ui.dart';

import 'package:swiper_view_pro/swiper_view_pro.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Swiper(
        itemBuilder: (context, index){
          return Image.network("https://via.placeholder.com/350x150",fit: BoxFit.fill,);
        },
        itemCount: 3,
        pagination: const SwiperPagination(),
        control: const SwiperControl(),
      ),
    );
  }
}
```



### 构建


#### 基本参数

| 参数            | 默认值             |           描述     |
| :-------------- |:-----------------:| :------------------------|
| scrollDirection | Axis.horizontal  |滚动方向，设置为 Axis.vertical 如果需要垂直滚动   |
| loop            | true             |无限轮播模式开关                              |
| index           | null             | 初始下标；为 null 时由 Swiper 自己管理（非受控） |
| autoplay        | false             |自动播放开关. |
| onIndexChanged  | void onIndexChanged(int index)  | 当用户手动拖拽或者自动播放引起下标改变的时候调用 |
| onTap           | void onTap(int index)  | 当用户点击某个轮播的时候调用 |
| duration        | 300.0            | 动画时间，单位是毫秒 |
| pagination      | null             | 设置 `SwiperPagination()` 展示默认分页指示器
| control | null | 设置 `SwiperControl()` 展示默认分页按钮
| enable3D | false | 3D 效果总开关。仅 `SwiperLayout.DEFAULT` 且未设置 `transformer` 时生效。 |
| threeDStyle | Swiper3DStyle.cube | 打开 3D 后的样式：`cube`、`threeD`、`flip`、`coverflow`、`carousel`、`cards`、`rotate`。 |
| perspective | 0.001 | 3D 透视强度。 |
| slidesPerView | 1 | 一屏可见张数，支持小数（如 `2.5`）。仅 DEFAULT。若同时设置了非 1 的 `viewportFraction`，以 `viewportFraction` 为准。 |
| spaceBetween | 0 | 卡片间距。仅 DEFAULT。 |
| pageSnapping | true | 是否页面对齐吸附。仅 DEFAULT。 |
| enableKeyboard | true | 焦点下用方向键切页。 |
| reverse | null | 非 null 时覆盖自动 RTL。 |
| playback | null | 宿主播放器钩子，见下方「视频 / 媒体」。 |


#### 分页指示器

分页指示器继承自 `SwiperPlugin`,`SwiperPlugin` 为 `Swiper` 提供额外的界面.设置为`SwiperPagination()` 展示默认分页.


| 参数            | 默认值             |           描述     |
| :------------ |:---------------:| :-----|
| alignment | Alignment.bottomCenter  | 如果要将分页指示器放到其他位置，那么可以修改这个参数 |
| margin | const EdgeInsets.all(10.0) | 分页指示器与容器边框的距离 |
| builder | SwiperPagination.dots | 目前已经定义了三个默认的分页指示器样式： `SwiperPagination.dots` 、 `SwiperPagination.fraction`、 `SwiperPagination.rect`，都可以做进一步的自定义. |

如果需要定制自己的分页指示器，那么可以这样写：

```dart
Swiper(
  ...,
  pagination: SwiperCustomPagination(
    builder: (context, config){
      return YourOwnPaginatipon();
    },
  )
);
```



#### 控制按钮

控制按钮组件也是继承自 `SwiperPlugin`,设置 `SwiperControl()` 展示默认控制按钮.


| 参数            | 默认值             |           描述     |
| :------------ |:---------------:| :-----|
| iconPrevious | Icons.arrow_back_ios  | 上一页的IconData |
| iconNext | Icons.arrow_forward_ios | 下一页的IconData |
| color | Theme.of(context).primaryColor | 控制按钮颜色 |
| size | 30.0                           | 控制按钮的大小 |
| padding | const EdgeInsets.all(5.0) | 控制按钮与容器的距离 |


#### 控制器(SwiperController)

`SwiperController` 用于控制 Swiper的`index`属性, 停止和开始自动播放. 通过 `SwiperController()` 创建一个 SwiperController 实例，并保存，以便将来能使用。


| 方法            | 描述     |
| :------------ |:-----|
| void move(int index, {bool animation: true}) | 移动到指定下标，设置是否播放动画|
| void next({bool animation: true}) | 下一页 |
| void previous({bool animation: true}) | 上一页 |
| void startAutoplay() | 开始自动播放 |
| void stopAutoplay() | 停止自动播放 |



#### 自动播放

| 参数            | 默认值             |           描述     |
| :------------ |:---------------:| :-----|
| autoplayDelay | 3000  | 自动播放延迟毫秒数. |
| autoplayDisableOnInteraction | true | 当用户拖拽的时候，是否停止自动播放. |

## 3D 效果

用 `enable3D` 打开 3D，仅 `layout: SwiperLayout.DEFAULT` 生效。若同时传入 `transformer`，以 `transformer` 为准。

```dart
Swiper(
  itemBuilder: (context, index) {
    return Image.network(
      "https://via.placeholder.com/350x150",
      fit: BoxFit.fill,
    );
  },
  itemCount: 5,
  enable3D: true,
  threeDStyle: Swiper3DStyle.cube, // cube, threeD, flip, coverflow, carousel, cards, rotate
  pagination: const SwiperPagination(),
)
```

内置 3D 样式：

| 样式 | 效果 |
|------|------|
| `cube` | 立方体面沿公共棱原地翻转 |
| `threeD` | 页面绕中心旋转并沿 Z 轴后退 |
| `flip` | 卡片翻转 180° |
| `coverflow` | 相邻页在一排中旋转、缩放 |
| `carousel` | 页面排列在 3D 圆柱上 |
| `cards` | 叠放卡片，顶卡带 3D 扭转飞出 |
| `rotate` | 页面绕底边摆动 |

`coverflow` 和 `carousel` 建议配合较小的 `viewportFraction`：

```dart
Swiper(
  itemBuilder: (context, index) { /* ... */ },
  itemCount: 5,
  viewportFraction: 0.75, // carousel 可用 0.7
  enable3D: true,
  threeDStyle: Swiper3DStyle.coverflow,
)
```

其他内置 transformer（不走 3D 开关）：

```dart
Swiper(
  transformer: AccordionTransformer(), // 或 DepthPageTransformer、ZoomInPageTransformer、ZoomOutPageTransformer
  itemBuilder: (context, index) { /* ... */ },
  itemCount: 5,
)
```

示例应用里可以用开关和下拉实时预览。

## 多卡布局

仅 `SwiperLayout.DEFAULT`。`slidesPerView` 支持小数；若同时传入非 1 的 `viewportFraction`，以 `viewportFraction` 为准。

```dart
Swiper(
  itemBuilder: (context, index) { /* ... */ },
  itemCount: 8,
  slidesPerView: 2.5,
  spaceBetween: 12,
)
```

水平方向会跟随 `Directionality` 做 RTL。方向键可切页（`enableKeyboard`，默认开启）。

## 视频 / 媒体

本包**不内置**视频组件，也不依赖 `video_player`。把你自己的播放器放进 `itemBuilder`，用 `playback` 和 `SwiperItemScope` 对接生命周期。

```dart
Swiper(
  itemCount: videos.length,
  playback: SwiperPlaybackConfig(
    playing: isPlaying, // ValueNotifier<bool>，为 true 时暂停轮播自动播放
    onActiveChanged: (index, active) {
      if (active) {
        players[index].play();
      } else {
        players[index].pause();
      }
    },
  ),
  itemBuilder: (context, index) {
    final active = SwiperItemScope.of(context).isActive;
    return YourVideoPlayer(url: videos[index], play: active);
  },
)
```

## 内建的布局
![](https://github.com/jzoom/images/raw/master/layout1.gif)

```dart
Swiper(
  itemBuilder: (context, index) {
    return Image.network(
      "https://via.placeholder.com/288x188",
      fit: BoxFit.fill,
    );
  },
  itemCount: 10,
  viewportFraction: 0.8,
  scale: 0.9,
)

```



![](https://github.com/jzoom/images/raw/master/layout2.gif)

```dart
Swiper(
  itemBuilder: (context, index) {
    return Image.network(
      "https://via.placeholder.com/288x188",
      fit: BoxFit.fill,
    );
  },
  itemCount: 10,
  itemWidth: 300.0,
  layout: SwiperLayout.STACK,
)
```

![](https://github.com/jzoom/images/raw/master/layout3.gif)

```dart
Swiper(
  itemBuilder: (context, index) {
    return Image.network(
      "https://via.placeholder.com/288x188",
      fit: BoxFit.fill,
    );
  },
  itemCount: 10,
  itemWidth: 300.0,
  itemHeight: 400.0,
  layout: SwiperLayout.TINDER,
)
```



![](https://github.com/jzoom/images/raw/master/layout4.gif)

构建你自己的动画十分简单:

```dart
Swiper(
  layout: SwiperLayout.CUSTOM,
  customLayoutOption: CustomLayoutOption(startIndex: -1, stateCount: 3)
    ..addRotate([-45.0 / 180, 0.0, 45.0 / 180])
    ..addTranslate([
      const Offset(-370.0, -40.0),
      const Offset(0.0, 0.0),
      const Offset(370.0, -40.0)
    ]),
  itemWidth: 300.0,
  itemHeight: 200.0,
  itemBuilder: (context, index) {
    return Container(
      color: Colors.grey,
      child: Center(
        child: Text("$index"),
      ),
    );
  },
  itemCount: 10,
),
```


`CustomLayoutOption` 被设计用来描述布局和动画,很简单的可以指定每一个元素的状态.

```dart
CustomLayoutOption(
      startIndex: -1,  /// 开始下标
      stateCount: 3    /// 下面的数组长度 
  )..addRotate([        //  每个元素的角度
    -45.0/180,
    0.0,
    45.0/180
  ])..addTranslate([           /// 每个元素的偏移
    const Offset(-370.0, -40.0),
    const Offset(0.0, 0.0),
    const Offset(370.0, -40.0)
  ])
```

## 代码


![Example](https://github.com/jzoom/images/raw/master/swiper-example.gif)


```dart
ConstrainedBox(
  constraints: BoxConstraints.loose(Size(screenWidth, 170.0))
  child: Swiper(
    outer: false,
    itemBuilder: (c, i) {
      return Wrap(
        runSpacing:  6.0,
        children: [0,1,2,3,4,5,6,7,8,9].map((i){
          return SizedBox(
            width: MediaQuery.of(context).size.width/5,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  height: MediaQuery.of(context).size.width * 0.12,
                  width: MediaQuery.of(context).size.width * 0.12,
                  child:  Image.network("https://fuss10.elemecdn.com/c/db/d20d49e5029281b9b73db1c5ec6f9jpeg.jpeg%3FimageMogr/format/webp/thumbnail/!90x90r/gravity/Center/crop/90x90"),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Text("$i"),
                )
              ],
            ),
          );
        }).toList(),
      );
    },
    pagination: const SwiperPagination(margin: EdgeInsets.all(5.0)),
    itemCount: 10,
  ),
),
```



这里可以找到所有的定制选项

>https://github.com/whevether/swiper_view_pro/blob/main/example/lib/src/example_custom.dart