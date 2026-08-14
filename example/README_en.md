# swiper_view_pro_example

Demo app for `swiper_view_pro` layouts, the 3D switch, and built-in transformers.

[中文](README.md)

## Run

```bash
cd example
flutter pub get
flutter run
```

## Controls

| Action | Effect |
|--------|--------|
| Home list | Open each layout / effect demo |
| 3D switch page | Toggle `enable3D`, pick cube / threeD / flip / coverflow / carousel / cards / rotate |
| Multi-card / RTL / Playback | Multi-card, RTL, host playback hooks (no built-in video widget) |
| Accordion / Depth / Zoom | Preview non-3D built-in transformers |
| CUSTOM | See [lib/src/example_custom.dart](lib/src/example_custom.dart) |

## Android signing

Release builds use the committed test keystore — see [jks/README.md](jks/README.md). Gradle loads `android/key.properties`.

The Android build uses the official [Gradle 9.7.0](https://services.gradle.org/distributions/gradle-9.7.0-all.zip) distribution, with Google Maven and Maven Central.

```bash
cd example
flutter build apk --release
```

## Dependencies

Local package via `path: ../`, matching the current repo sources.
