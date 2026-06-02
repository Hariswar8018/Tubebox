package com.starwish.diskly

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.widget.Button
import android.widget.ImageView
import android.widget.TextView
import com.google.android.gms.ads.nativead.MediaView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class ListTileNativeAdFactory(private val context: Context) : GoogleMobileAdsPlugin.NativeAdFactory {

    override fun createNativeAd(nativeAd: NativeAd, customOptions: MutableMap<String, Any>?): NativeAdView {
        val nativeAdView = LayoutInflater.from(context).inflate(R.layout.list_tile_native_ad, null) as NativeAdView

        with(nativeAdView) {
            val adHeadline = findViewById<TextView>(R.id.ad_headline)
            val adBody = findViewById<TextView>(R.id.ad_body)
            val adAppIcon = findViewById<ImageView>(R.id.ad_app_icon)
            val adMedia = findViewById<MediaView>(R.id.ad_media)
            val adCallToAction = findViewById<Button>(R.id.ad_call_to_action)

            // Map UI Elements
            headlineView = adHeadline
            bodyView = adBody
            iconView = adAppIcon
            mediaView = adMedia
            callToActionView = adCallToAction

            // Assign data
            adHeadline.text = nativeAd.headline
            adMedia.mediaContent = nativeAd.mediaContent
            
            if (nativeAd.body == null) {
                adBody.visibility = View.INVISIBLE
            } else {
                adBody.visibility = View.VISIBLE
                adBody.text = nativeAd.body
            }

            if (nativeAd.callToAction == null) {
                adCallToAction.visibility = View.INVISIBLE
            } else {
                adCallToAction.visibility = View.VISIBLE
                adCallToAction.text = nativeAd.callToAction
            }

            if (nativeAd.icon == null) {
                adAppIcon.visibility = View.GONE
            } else {
                adAppIcon.setImageDrawable(nativeAd.icon?.drawable)
                adAppIcon.visibility = View.VISIBLE
            }

            setNativeAd(nativeAd)
        }

        return nativeAdView
    }
}
