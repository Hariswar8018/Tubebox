package com.starwish.diskly

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Register Native Ad Factory
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine, 
            "listTile", 
            ListTileNativeAdFactory(context)
        )
    }
}
