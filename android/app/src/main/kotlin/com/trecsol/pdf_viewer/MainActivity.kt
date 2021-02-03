package com.trecsol.pdf_viewer

import android.content.Intent
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.system.OsConstants.EBUSY
import androidx.annotation.NonNull
import com.artifex.mupdf.viewer.DocumentActivity
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File


class MainActivity: FlutterActivity() {
    private val CHANNEL = "it.hamza/pdfViewer"
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        runOnUiThread(
                Runnable(){
                    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->

                        if (call.method == "viewPdf") {
                            if (call.hasArgument("url")) {
                                val url = call.argument<String>("url")

                                val file = File(url)
                                val uri: Uri = Uri.fromFile(file)
                                val intent = Intent(this, DocumentActivity::class.java)
                                intent.action = Intent.ACTION_VIEW
                                intent.data = uri
                                startActivity(intent)
                            }
                        } else {
                            result.notImplemented()
                        }

                    }
        });


    }

}
