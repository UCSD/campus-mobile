package edu.ucsd;

import android.os.Bundle;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;

// App Center
import com.microsoft.appcenter.AppCenter;
import com.microsoft.appcenter.analytics.Analytics;
import com.microsoft.appcenter.crashes.Crashes;

public class MainActivity extends FlutterActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);
    
    // App Center
    AppCenter.start(
    	getApplication(),
    	"75afbc3f-becc-496a-be84-39344686ca4d",
    	Analytics.class,
    	Crashes.class
    );
  }
}
