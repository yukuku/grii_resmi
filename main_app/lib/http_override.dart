import 'dart:io';

class YukuHttpOverrides extends HttpOverrides {
  final String appVersionName;
  final bool useProxy;
  final bool? isAndroid;

  YukuHttpOverrides(this.appVersionName, this.useProxy, this.isAndroid);

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);

    if (useProxy) {
      if (isAndroid == true) {
        client.findProxy = (uri) {
          return 'PROXY 10.0.2.2:8888;';
        };
      } else if (isAndroid == false) {
        client.findProxy = (uri) {
          return 'PROXY 127.0.0.1:8888;';
        };
      }
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    }

    final originalUserAgent = client.userAgent!;
    final additionalUserAgent = ' tia_mobile_app $appVersionName';
    final modifiedUserAgent =
        originalUserAgent.contains(additionalUserAgent) ? originalUserAgent : (originalUserAgent + additionalUserAgent);
    client.userAgent = modifiedUserAgent;

    return client;
  }
}
