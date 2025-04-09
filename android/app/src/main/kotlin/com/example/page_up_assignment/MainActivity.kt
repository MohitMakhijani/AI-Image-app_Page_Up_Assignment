package com.example.page_up_assignment
import android.os.Bundle
import android.media.MediaScannerConnection
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "gallery_saver"

    override fun configureFlutterEngine(flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "scanFile") {
                val path = call.argument<String>("path")
                if (path != null) {
                    MediaScannerConnection.scanFile(this, arrayOf(path), null, null)
                    result.success(true)
                } else {
                    result.error("INVALID_PATH", "Path is null", null)
                }
            }
        }
    }
}