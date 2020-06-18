import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_util.dart';

final uuid = new Uuid(options: {'grng': UuidUtil.cryptoRNG});

Future<String> getInstallationId() async {
  final sp = await SharedPreferences.getInstance();
  final old = sp.getString("installation_id");
  if (old != null) {
    return old;
  }
  final generated = 'i1:' + uuid.v4();
  sp.setString('installation_id', generated);
  return generated;
}
