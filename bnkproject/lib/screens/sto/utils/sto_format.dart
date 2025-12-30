String formatWon(num value) {
  final v = value.round();
  final s = v.toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final idxFromEnd = s.length - i;
    buf.write(s[i]);
    if (idxFromEnd > 1 && idxFromEnd % 3 == 1) buf.write(',');
  }
  return '${buf.toString()}원';
}

String formatSignedPercent(double value) {
  final sign = value >= 0 ? '+' : '';
  return '$sign${(value * 100).toStringAsFixed(2)}%';
}
