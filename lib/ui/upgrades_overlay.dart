import 'package:flutter/material.dart';

import '../game/battle_hymn_game.dart';
import '../game/upgrades.dart';
import '../i18n/strings.dart';

/// Schermata Potenziamenti (roguelite): spendi i cristalli per migliorie
/// permanenti applicate alle partite future.
class UpgradesOverlay extends StatefulWidget {
  final BattleHymnGame game;
  const UpgradesOverlay({super.key, required this.game});

  @override
  State<UpgradesOverlay> createState() => _UpgradesOverlayState();
}

class _UpgradesOverlayState extends State<UpgradesOverlay> {
  Upgrades get u => widget.game.upgrades;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.72),
      alignment: Alignment.center,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              L.upgradesTitle,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 6),
            Text('💎 ${L.crystals(u.crystals)}',
                style: const TextStyle(
                    color: Color(0xFF7FE3FF),
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...Upgrades.keys.map(_row),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: widget.game.closeUpgrades,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2BA8E0),
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                textStyle:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              child: Text(L.back),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String k) {
    final int lvl = u.levelOf(k);
    final bool maxed = u.isMaxed(k);
    final bool can = u.canBuy(k);
    return Container(
      width: 320,
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(Upgrades.title(k),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
                Text(Upgrades.describe(k),
                    style:
                        const TextStyle(color: Colors.white60, fontSize: 11)),
                _pips(lvl),
              ],
            ),
          ),
          const SizedBox(width: 8),
          maxed
              ? Text(L.max,
                  style: const TextStyle(
                      color: Color(0xFFFFD54F), fontWeight: FontWeight.bold))
              : ElevatedButton(
                  onPressed: can
                      ? () => setState(() {
                            u.buy(k);
                            widget.game.saveUpgrades();
                          })
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2BA8E0),
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: Colors.white24,
                    disabledForegroundColor: Colors.white38,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                  ),
                  child: Text('💎 ${u.costOf(k)}',
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.bold)),
                ),
        ],
      ),
    );
  }

  Widget _pips(int lvl) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: List.generate(Upgrades.maxLevel, (i) {
          final bool full = i < lvl;
          return Container(
            width: 16,
            height: 6,
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: full ? const Color(0xFF7FE3FF) : Colors.white24,
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }),
      ),
    );
  }
}
