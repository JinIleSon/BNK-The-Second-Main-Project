import 'package:flutter/material.dart';
import '../models/sto_team.dart';
import '../sto_theme.dart';
import '../utils/sto_format.dart';
import 'sto_price_badge.dart';

class StoTeamTile extends StatelessWidget {
  const StoTeamTile({
    super.key,
    required this.team,
    required this.onTap,
    required this.onBuy,
    required this.onSell,
  });

  final StoTeam team;
  final VoidCallback onTap;
  final VoidCallback onBuy;
  final VoidCallback onSell;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(StoTheme.radius),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: StoTheme.card,
          borderRadius: BorderRadius.circular(StoTheme.radius),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Row(
          children: [
            _logo(team.logoAsset),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(team.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(formatWon(team.price), style: TextStyle(color: StoTheme.subText, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            StoPriceBadge(changePct: team.changePct),
            const SizedBox(width: 10),
            Column(
              children: [
                _miniBtn('매수', onBuy),
                const SizedBox(height: 6),
                _miniBtn('매도', onSell),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniBtn(String text, VoidCallback onPressed) {
    return SizedBox(
      height: 30,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          side: BorderSide(color: StoTheme.mint.withOpacity(0.5)),
          foregroundColor: StoTheme.mint,
        ),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
      ),
    );
  }

  Widget _logo(String asset) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 44,
        height: 44,
        color: Colors.white.withOpacity(0.06),
        child: Image.asset(
          asset,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.sports_baseball, color: Colors.white),
        ),
      ),
    );
  }
}
