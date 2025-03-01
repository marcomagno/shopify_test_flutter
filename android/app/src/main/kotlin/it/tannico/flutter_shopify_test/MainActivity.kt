package it.tannico.flutter_shopify_test

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity: FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Register the ExampleHostApiImpl
        ExampleHostApi.setUp(flutterEngine.dartExecutor.binaryMessenger, ExampleHostApiImpl(this))
    }
}
