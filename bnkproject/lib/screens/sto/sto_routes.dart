import 'package:flutter/material.dart';
import 'pages/sto_entry_page.dart';
import 'pages/sto_season_page.dart';

class StoRoutes {
  static const entry = '/sto';
  static const season = '/sto/season';

  static Route<dynamic>? onGenerate(RouteSettings settings) {
    switch (settings.name) {
      case entry:
        return MaterialPageRoute(builder: (_) => const StoEntryPage());
      case season:
        return MaterialPageRoute(builder: (_) => const StoSeasonPage());
      default:
        return null;
    }
  }
}
