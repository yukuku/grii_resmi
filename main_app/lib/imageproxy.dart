import 'package:grii_resmi/flavors.dart';

extension ImageProxyExtension on String {
  String imageProxy() {
    return Uri.https(Flavor.current.imageProxyHost, 'imageproxy', {
      'url': this,
    }).toString();
  }
}
