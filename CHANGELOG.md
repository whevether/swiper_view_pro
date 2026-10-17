## [0.3.2] - [2026/10/17]

- Fix custom-layout controller completion, command queuing, animation disabling, controlled indices, empty data, and non-loop boundaries.
- Fix looping parallax indices, reversed pagination initialization, pagination repainting, and custom scale alignment.
- Preserve manual autoplay stops and allow focused input controls inside the swiper.
- Honor standalone page-view viewport fractions; preserve page position on rebuild and dispose internally owned controllers.
- Reuse page content during animation, avoid repeated plugin-list copies, and share loop constants, index conversion, and interpolation helpers.
- Implement animated pagination `activeSize`; preserve fractional animation across loop boundaries.
- Deprecate unused legacy events and callbacks while retaining source compatibility.
- Upgrade `material_ui` to `^1.7.0` and Gradle to `9.8.1`; correct the example AGP version to the available stable `9.4.1`.
- Add regression coverage for controller lifecycle, focus, autoplay, layout updates, animation reuse, and pagination rendering.

## [0.3.1] - [2026/10/10]

    * Bump `material_ui` to `^1.6.0`
    * Example Android: AGP `9.4.2`, Kotlin `2.4.21`, Gradle `9.8.0`

## [0.3.0] - [2026/09/28]

    * Bump `material_ui` to `^1.4.0`
    * Raise minimum SDK requirements to Dart 3.13 and Flutter 3.47+

## [0.2.0] - [2026/08/24]

    * Migrate to standalone `material_ui ^1.0.1`
    * Replace all `package:flutter/material.dart` imports with `package:material_ui/material_ui.dart`
    * Raise minimum SDK requirements to Dart 3.12 and Flutter 3.44+

## [0.1.0] - [2026/08/13]

    * Rename package to `swiper_view_pro`
    * Add configurable 3D switch: `enable3D`, `threeDStyle`, `perspective`
    * Built-in 3D styles: cube, threeD, flip, coverflow, carousel, cards, rotate
    * Distinct `cube` (in-place cube faces) and `threeD` (center rotate + recede)
    * Built-in transformers: Accordion, Depth, ZoomIn, ZoomOut, ScaleAndFade
    * Export `PageTransformer`, parallax helpers
    * Explicit `transformer` now takes priority over `scale` / `fade`
    * Add example app with Android test signing
    * Multi-card: `slidesPerView`, `spaceBetween`
    * Keyboard arrows and RTL via `Directionality` (`reverse` to override)
    * Host media hooks: `SwiperPlaybackConfig`, `SwiperItemScope` (no built-in player)
    * Clickable pagination, outer pagination placement, `pageSnapping`
    * Fix controller jump without animation, controller swap, non-loop wrap, factory `scale`/`reverse`
