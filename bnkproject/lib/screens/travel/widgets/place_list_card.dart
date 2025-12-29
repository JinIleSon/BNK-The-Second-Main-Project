import 'package:flutter/material.dart';

class PlaceListCard extends StatelessWidget {
  const PlaceListCard({
    required this.cardColor,
    required this.title,
    required this.subtitle,
    required this.assetPath,
    required this.badgeText,
    required this.onTap,
    this.badgeMuted = false,
    super.key,
  });

  final Color cardColor;
  final String title;
  final String subtitle;
  final String assetPath;
  final String badgeText;
  final VoidCallback onTap;
  final bool badgeMuted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final badgeBg = badgeMuted ? Colors.white.withOpacity(0.10) : Colors.white.withOpacity(0.18);
    final badgeBorder = badgeMuted
        ? Colors.white.withOpacity(0.12)
        : const Color(0xFF38E1C6).withOpacity(0.28);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.10)),
          ),
          padding: const EdgeInsets.all(14),
          child: Stack(
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      width: 96,
                      height: 72,
                      child: Image.asset(
                        assetPath,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.white.withOpacity(0.06),
                          alignment: Alignment.center,
                          child: Icon(Icons.image, color: Colors.white.withOpacity(0.6)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.80),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.55)),
                ],
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: badgeBorder),
                  ),
                  child: Text(
                    badgeText,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
