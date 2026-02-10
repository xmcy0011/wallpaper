# generated_plugin_registrant.cc 的作用

`generated_plugin_registrant.cc` 是 **Flutter 自动生成的插件注册文件**，用于在 Windows 原生层注册 Flutter 插件。

## 作用

1. **自动生成**：由 Flutter 在构建时根据 `pubspec.yaml` 中声明的插件生成，文件顶部的注释也说明了这一点：`Generated file. Do not edit.`

2. **注册原生插件**：包含 `RegisterPlugins()` 函数，在 Flutter 引擎启动时被调用，为每个插件向 Flutter 注册对应的原生实现。

3. **当前项目中的插件**：
   - **ScreenRetrieverWindowsPluginCApi**：`screen_retriever` 的 Windows 实现（`window_manager` 的依赖）
   - **WindowManagerPlugin**：`window_manager` 的 Windows 实现

## 调用流程

```text
Flutter 引擎启动
    → 调用 RegisterPlugins()
    → 依次注册各个插件的原生实现
    → 使 Dart 侧可以调用这些原生能力
```

## 注意事项

- 不要手动修改该文件，修改会在下次构建时被覆盖。
- 添加或移除插件后，通常会重新生成该文件。
- 它只负责把插件“挂”到 Flutter 引擎上，具体功能由各插件自己实现。
