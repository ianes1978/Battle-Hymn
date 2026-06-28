import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// Esito di un tentativo di "caffè" (mancia), per mostrare un messaggio.
enum CoffeeResult { thanks, pending, error, canceled }

/// Gestione dell'acquisto in-app "Offrimi un caffè" tramite Google Play Billing.
///
/// È una **mancia** (prodotto consumabile da ~1€) che NON sblocca nulla di
/// funzionale: serve solo a supportare lo sviluppo. Il consumo viene completato
/// subito, così la donazione può essere ripetuta.
///
/// Sul web (e ovunque il billing non sia disponibile) [available] resta `false`
/// e il pulsante non viene mostrato.
class IapManager {
  /// ID del prodotto da creare nella Play Console (tipo: prodotto in-app
  /// "consumabile"). Deve combaciare esattamente.
  static const String coffeeProductId = 'coffee_tip';

  /// Vero se il billing è disponibile e il prodotto è stato caricato.
  bool available = false;

  ProductDetails? _coffee;
  StreamSubscription<List<PurchaseDetails>>? _sub;

  /// Notifica l'esito di un acquisto all'interfaccia (un solo ascoltatore).
  final ValueNotifier<CoffeeResult?> lastResult =
      ValueNotifier<CoffeeResult?>(null);

  /// Inizializza il billing. Sicura da chiamare su ogni piattaforma.
  Future<void> init() async {
    // Il web non ha un'implementazione di in_app_purchase: niente pulsante.
    if (kIsWeb) return;
    try {
      final InAppPurchase iap = InAppPurchase.instance;
      available = await iap.isAvailable();
      if (!available) return;

      _sub = iap.purchaseStream.listen(
        _onPurchases,
        onError: (_) => lastResult.value = CoffeeResult.error,
      );

      final ProductDetailsResponse resp =
          await iap.queryProductDetails({coffeeProductId});
      if (resp.productDetails.isNotEmpty) {
        _coffee = resp.productDetails.first;
      } else {
        // Prodotto non ancora configurato sullo Store: niente pulsante.
        available = false;
      }
    } catch (_) {
      available = false;
    }
  }

  /// Prezzo localizzato dallo Store (es. "1,00 €"), o null se non disponibile.
  String? get price => _coffee?.price;

  /// Avvia l'acquisto della mancia.
  Future<void> buyCoffee() async {
    final ProductDetails? p = _coffee;
    if (!available || p == null) {
      lastResult.value = CoffeeResult.error;
      return;
    }
    try {
      final PurchaseParam param = PurchaseParam(productDetails: p);
      // Consumabile: si può donare più volte.
      await InAppPurchase.instance.buyConsumable(purchaseParam: param);
    } catch (_) {
      lastResult.value = CoffeeResult.error;
    }
  }

  Future<void> _onPurchases(List<PurchaseDetails> purchases) async {
    for (final PurchaseDetails pd in purchases) {
      switch (pd.status) {
        case PurchaseStatus.pending:
          lastResult.value = CoffeeResult.pending;
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          lastResult.value = CoffeeResult.thanks;
          break;
        case PurchaseStatus.error:
          lastResult.value = CoffeeResult.error;
          break;
        case PurchaseStatus.canceled:
          lastResult.value = CoffeeResult.canceled;
          break;
      }
      // Va sempre completato l'acquisto, altrimenti resta in sospeso.
      if (pd.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(pd);
      }
    }
  }

  void dispose() {
    _sub?.cancel();
  }
}
