class FaceAuthResult {
  final String path;
  final DateTime capturedAt;
  final bool turnedLeft;
  final bool turnedRight;

  const FaceAuthResult({
    required this.path,
    required this.capturedAt,
    required this.turnedLeft,
    required this.turnedRight,
  });

  bool get demoPass => turnedLeft && turnedRight && path.isNotEmpty;
}
