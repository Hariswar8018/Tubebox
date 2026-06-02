import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_manager.dart';

class NativeVideoAdCard extends StatefulWidget {
  final String? adKey; // Optional now, since we use AdManager

  const NativeVideoAdCard({super.key, this.adKey});

  @override
  State<NativeVideoAdCard> createState() => _NativeVideoAdCardState();
}

class _NativeVideoAdCardState extends State<NativeVideoAdCard> {
  NativeAd? _nativeAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _nativeAd = NativeAd(
      adUnitId: AdManager.nativeAdUnitId, // Ignore adKey string
      factoryId: 'listTile', // Matches factory registered in MainActivity.kt
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (!mounted) return;
          setState(() {
            _nativeAd = ad as NativeAd;
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('NativeAd failed to load: $error');
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdLoaded || _nativeAd == null) {
      return const SizedBox.shrink(); // Hide if not loaded
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      height: 250, // Give it a fixed height or match parent depending on layout
      decoration: BoxDecoration(
        color: const Color(0xFF1B1B2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      clipBehavior: Clip.hardEdge,
      child: AdWidget(ad: _nativeAd!),
    );
  }
}
