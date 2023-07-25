import UIKit
import Flutter
import WebKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, WKURLSchemeHandler {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // 注册 WKURLSchemeHandler
    if let registrar = self.registrar(forPlugin: "flutter_inappwebview") {
      registrar.addMethodCallDelegate(AppDelegate(), channel: nil)
      let webView = WKWebView(frame: CGRect.zero, configuration: WKWebViewConfiguration())
      webView.configuration.setURLSchemeHandler(self, forURLScheme: "flutter-inappwebview")
    }


    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // WKURLSchemeHandler 协议方法
  func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
    // 在这里处理拦截的资源请求
    // 你可以使用 http 包或其他网络请求方式来发送自定义的响应数据
    // 例如，你可以根据请求的 URL、请求头或其他属性来判断是否要拦截请求，并返回自定义的响应数据

    // 为了示例，这里返回一个空的响应
    let response = URLResponse(url: urlSchemeTask.request.url!, mimeType: "text/html", expectedContentLength: 0, textEncodingName: nil)
    urlSchemeTask.didReceive(response)
    urlSchemeTask.didFinish()
  }
}
