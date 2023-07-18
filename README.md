# flutter_main

H5 壳应用

## TODO
1. request
2. upload
3. download
4. 文件预览 open_file

## 已知问题

### 引用 public 文件异常

应用 public 里的资源请求路径异常

### 指定内置在 APP 的前端资源包路径

> 前端资源包路径 assets/www/

问题：需要在 [pubspec.yaml](./pubspec.yaml) 文件里的 `assets` 把前端资源包的所有文件夹都定义一遍。  
eg：

```yaml
flutter:
  assets:
    - assets/www/
    - assets/www/assets/
```

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
