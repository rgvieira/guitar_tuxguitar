import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../core/ads/widgets/banner_ad_widget.dart';
import '../../core/ads/admob_interstitial_service.dart';
import '../../core/ads/admob_rewarded_service.dart';
import '../../core/ads/admob_rewarded_interstitial_service.dart';

/// Página de exemplo para testar TODOS os formatos de AdMob
/// Usando:
/// - BannerAdWidget (banner fixo)
/// - AdMobInterstitialService (interstitial)
/// - AdMobRewardedService (rewarded)
/// - AdMobRewardedInterstitialService (rewarded interstitial)
class AdsDebugPage extends StatefulWidget {
  const AdsDebugPage({super.key});

  @override
  State<AdsDebugPage> createState() => _AdsDebugPageState();
}

class _AdsDebugPageState extends State<AdsDebugPage> {
  InterstitialAd? _interstitial;
  RewardedAd? _rewarded;
  RewardedInterstitialAd? _rewardedInterstitial;

  @override
  void initState() {
    super.initState();
    _loadAllAds();
  }

  Future<void> _loadAllAds() async {
    // Carrega interstitial
    _interstitial = await AdMobInterstitialService.loadInterstitial();

    // Carrega rewarded
    _rewarded = await AdMobRewardedService.loadRewarded();

    // Carrega rewarded interstitial
    _rewardedInterstitial =
        await AdMobRewardedInterstitialService.loadRewardedInterstitial();

    setState(() {});
  }

  @override
  void dispose() {
    _interstitial?.dispose();
    _rewarded?.dispose();
    _rewardedInterstitial?.dispose();
    super.dispose();
  }

  void _showInterstitial() {
    final ad = _interstitial;
    if (ad == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Interstitial ainda não carregado')),
      );
      return;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitial = null;
        _loadAllAds(); // recarrega para uso futuro
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitial = null;
      },
    );

    ad.show();
  }

  void _showRewarded() {
    final ad = _rewarded;
    if (ad == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rewarded ainda não carregado')),
      );
      return;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewarded = null;
        _loadAllAds();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewarded = null;
      },
    );

    ad.show(
      onUserEarnedReward: (ad, reward) {
        // Aqui você dá a recompensa ao usuário
        // Exemplo: liberar uma tablatura premium / repetir playback / etc.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Recompensa recebida: ${reward.amount} ${reward.type}',
            ),
          ),
        );
      },
    );
  }

  void _showRewardedInterstitial() {
    final ad = _rewardedInterstitial;
    if (ad == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rewarded interstitial ainda não carregado'),
        ),
      );
      return;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedInterstitial = null;
        _loadAllAds();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedInterstitial = null;
      },
    );

    ad.show(
      onUserEarnedReward: (ad, reward) {
        // Recompensa ao usuário
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Rewarded interstitial: recompensa ${reward.amount} ${reward.type}',
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Observação: o banner é permanente no rodapé, via BannerAdWidget.
    return Scaffold(
      appBar: AppBar(title: const Text('Debug de Anúncios AdMob')),
      body: Column(
        children: [
          const Expanded(
            child: Padding(padding: EdgeInsets.all(16), child: _ButtonsArea()),
          ),

          // Banner fixo no rodapé usando nosso widget reutilizável
          const bannerFooter(),
        ],
      ),
    );
  }
}

/// Área de botões (separado só para clareza)
class _ButtonsArea extends StatelessWidget {
  const _ButtonsArea();

  @override
  Widget build(BuildContext context) {
    final state = context
        .findAncestorStateOfType<_AdsDebugPageState>()!; // só para demo

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: state._showInterstitial,
          child: const Text('Mostrar Interstitial'),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: state._showRewarded,
          child: const Text('Mostrar Rewarded'),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: state._showRewardedInterstitial,
          child: const Text('Mostrar Rewarded Interstitial'),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: state._loadAllAds,
          child: const Text('Recarregar todos os anúncios'),
        ),
      ],
    );
  }
}

/// Widget separado para deixar claro onde entra o banner
class bannerFooter extends StatelessWidget {
  const bannerFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      alignment: Alignment.center,
      child: const BannerAdWidget(),
    );
  }
}
