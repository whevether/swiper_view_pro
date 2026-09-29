## [0.3.0] - [2026/09/28]

    * 将 `material_ui` 升级至 `^1.4.0`
    * 最低环境要求提升至 Dart 3.13 与 Flutter 3.47+

## [0.2.0] - [2026/08/24]

    * 迁移到独立包 `material_ui ^1.0.1`
    * 全部 `package:flutter/material.dart` import 改为 `package:material_ui/material_ui.dart`
    * 最低环境要求提升至 Dart 3.12 与 Flutter 3.44+

## [0.1.0] - [2026/08/13]

    * 包名改为 `swiper_view_pro`
    * 增加可配置 3D 开关：`enable3D`、`threeDStyle`、`perspective`
    * 内置 3D 样式：cube、threeD、flip、coverflow、carousel、cards、rotate
    * `cube` 为原地立方体翻面，`threeD` 为中心旋转并沿 Z 轴后退
    * 内置 transformer：Accordion、Depth、ZoomIn、ZoomOut、ScaleAndFade
    * 导出 `PageTransformer` 与视差辅助组件
    * 显式 `transformer` 优先于 `scale` / `fade`
    * 新增 example，含 Android 测试签名
    * 多卡：`slidesPerView`、`spaceBetween`
    * 键盘方向键与 RTL（`Directionality`，可用 `reverse` 覆盖）
    * 宿主媒体钩子：`SwiperPlaybackConfig`、`SwiperItemScope`（不内置播放器）
    * 分页可点、外部分页位置、`pageSnapping`
    * 修复无动画跳页、controller 替换、非 loop 绕回、工厂 `scale`/`reverse`
