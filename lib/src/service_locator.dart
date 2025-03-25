import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:http/http.dart' as http;

class ServiceLocator {
  ServiceLocator._();
  static final instance = ServiceLocator._();

  // TannicoKeyValueStore? _keyValueStore;
  // TannicoKeyValueStore get keyValueStore => _keyValueStore!;

  // Future<void> kickoff() async {
  //   _keyValueStore = await TannicoKeyValueStore.inDirectory(
  //     await getApplicationDocumentsDirectory(),
  //     fileName: "central_kvs",
  //     encryptionKey: r"hS%2BZb!$V?x%-?kZHT2?s4k_gzaWy23",
  //   );
  // }

  final http.BaseClient httpClient = ChuckerHttpClient(http.Client());
}
