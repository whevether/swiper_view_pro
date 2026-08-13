# 测试签名（可提交仓库） / Test signing (OK to commit)

仅用于 `swiper_view_pro` **示例应用**本地 / CI 打包，**不可**用于正式发布。

For the `swiper_view_pro` **example app** local / CI builds only — **not** for production release.

| 项 / Item | 值 / Value |
|-----------|------------|
| 文件 / File | `swiper_view_pro_test.jks` |
| alias | `swiper_view_pro_test` |
| storePassword / keyPassword | `swiper123` |
| 有效期 / Validity | 约 10000 天 / ~10000 days |

Gradle 配置 / Gradle config：`example/android/key.properties`
