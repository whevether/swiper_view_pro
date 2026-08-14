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
