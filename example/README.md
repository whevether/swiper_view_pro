# swiper_view_pro_example

演示 `swiper_view_pro` 布局、3D 开关与内置 transformer 的示例应用。

[English](README_en.md)

## 运行

```bash
cd example
flutter pub get
flutter run
```

## 操作

| 操作 | 效果 |
|------|------|
| 首页列表 | 进入各布局 / 效果演示 |
| 3D switch 页 | 开关 `enable3D`，下拉选择 cube / threeD / flip / coverflow |
| Accordion / Depth / Zoom | 预览非 3D 的内置 transformer |
| CUSTOM | 见 [lib/src/example_custom.dart](lib/src/example_custom.dart) |

## Android 签名

示例 release 打包使用仓库内测试证书，见 [jks/README.md](jks/README.md)。Gradle 读取 `android/key.properties`。

Android 构建使用 [Gradle 9.7.0](https://services.gradle.org/distributions/gradle-9.7.0-all.zip) 官方发行包，依赖仓库为 Google Maven 与 Maven Central。

```bash
cd example
flutter build apk --release
```

## 依赖

通过 `path: ../` 引用本地 package，与仓库当前代码一致。
