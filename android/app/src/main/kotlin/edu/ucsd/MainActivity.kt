package edu.ucsd

import io.flutter.embedding.android.FlutterActivity
import com.ryanheise.audioservice.AudioServicePlugin
import io.flutter.embedding.engine.FlutterEngine
import android.content.Context

class MainActivity: FlutterActivity() {
    override fun provideFlutterEngine(context:Context):FlutterEngine {
        return AudioServicePlugin.getFlutterEngine(context);
    }
}
