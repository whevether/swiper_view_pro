## [0.3.2] - [2026/10/17]

- 修复自定义布局控制器 Future 未完成、连续命令丢失、禁用动画失效、受控索引不同步、空数据异常及非循环边界问题。
- 修复循环视差索引越界、反向分页初始化、分页样式重绘及自定义缩放对齐问题。
- 保留手动停止自动播放的状态，允许轮播内部输入控件获取焦点。
- 修复独立分页组件的 viewportFraction，重建时保留页码，并释放内部持有的控制器。
- 复用动画中的页面内容，避免反复复制插件列表，统一循环常量、索引转换和插值逻辑。
- 实现动画分页 activeSize，保留首尾循环时的小数页码过渡。
- 废弃未使用的旧事件及回调，同时保留源码兼容入口。
- 将 material_ui 升级至 ^1.7.0、Gradle 升级至 9.8.1；示例 AGP 修正为可用稳定版 9.4.1。
- 增加控制器生命周期、焦点、自动播放、布局更新、动画复用及分页绘制回归测试。

## [0.3.1] - [2026/10/10]

    * 将 `material_ui` 升级至 `^1.6.0`
    * 示例 Android：AGP `9.4.2`、Kotlin `2.4.21`、Gradle `9.8.0`

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
