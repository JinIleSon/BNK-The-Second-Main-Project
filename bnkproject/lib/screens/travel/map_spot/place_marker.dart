import 'package:flutter/material.dart';
import '../travel_theme.dart';

class PlaceMarker extends StatelessWidget {
  final VoidCallback onTap;

  const PlaceMarker({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: TravelTheme.boogiMint.withOpacity(0.20),
          shape: BoxShape.circle,
          border: Border.all(color: TravelTheme.boogiMint.withOpacity(0.55), width: 2),
          boxShadow: [
            BoxShadow(
              blurRadius: 14,
              spreadRadius: 2,
              color: Colors.black.withOpacity(0.25),
            ),
          ],
        ),
        child: const Icon(Icons.place, color: Colors.white, size: 22),
      ),
    );
  }
}
