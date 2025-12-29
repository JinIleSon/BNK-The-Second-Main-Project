import 'package:flutter/material.dart';
import '../travel_theme.dart';

class OutlinedMintButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const OutlinedMintButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: TravelTheme.boogiMint.withOpacity(0.16),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: TravelTheme.boogiMint.withOpacity(0.35)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFFBFF8EE),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class SolidButton extends StatelessWidget {
  final String text;
  final Color accent;
  final VoidCallback onTap;

  const SolidButton({
    super.key,
    required this.text,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: accent.withOpacity(0.18),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accent.withOpacity(0.30)),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: Color.lerp(Colors.white, accent, 0.35),
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class GhostButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const GhostButton({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.10)),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white.withOpacity(0.85),
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
