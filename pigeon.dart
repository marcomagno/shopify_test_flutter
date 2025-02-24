import 'package:pigeon/pigeon.dart';

@PigeonOptions(
  kotlinOptions: KotlinOptions(
    package: "it.tannico.flutter_shopify_test",
  ),
  kotlinOut: "android/app/src/main/kotlin/it/tannico/flutter_shopify_test/Pigeon.kt",
  swiftOut: "ios/Runner/Pigeon.swift",
)
@HostApi()
abstract class ExampleHostApi {
  void presentCheckout(String url);
}
