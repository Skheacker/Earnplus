import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coin App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CoinHomePage(),
    );
  }
}

class CoinHomePage extends StatefulWidget {
  @override
  _CoinHomePageState createState() => _CoinHomePageState();
}

class _CoinHomePageState extends State<CoinHomePage> {
  int coinCount = 0;
  RewardedAd? _rewardedAd;
  bool _isAdLoaded = false;

  final String adUnitId = 'ca-app-pub-3940256099942544/5224354917'; // Test Rewarded Ad Unit ID

  @override
  void initState() {
    super.initState();
    _loadRewardedAd();
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: adUnitId,
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          setState(() {
            _rewardedAd = ad;
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (error) {
          print('RewardedAd failed to load: $error');
          _isAdLoaded = false;
        },
      ),
    );
  }

  void _showRewardedAd() {
    if (_isAdLoaded && _rewardedAd != null) {
      _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          setState(() {
            coinCount += 10; // Add 10 coins on completion
          });
          print('User earned reward: ${reward.amount} ${reward.type}');
        },
      );
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _loadRewardedAd(); // Load a new ad
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _loadRewardedAd();
        },
      );
    } else {
      print('Ad not loaded yet');
    }
  }

  void _showWithdrawDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Withdraw'),
          content: Text('Withdraw temporarily locked'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.monetization_on),
            SizedBox(width: 8),
            Text('Coins: $coinCount'),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _showRewardedAd,
              child: Text('Watch Ad'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showWithdrawDialog,
              child: Text('Withdraw'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _rewardedAd?.dispose();
    super.dispose();
  }
}
