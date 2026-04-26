class PlanetData {
  final String name;
  final String subtitle;
  final String description;

  final String diameter;
  final String mass;
  final String dayLength;

  final String? assetPath;
  final int frameCount;
  final int columns;
  final int rows;

  const PlanetData({
    required this.name,
    required this.subtitle,
    required this.description,
    required this.diameter,
    required this.mass,
    required this.dayLength,
    this.assetPath,
    this.frameCount = 1,
    this.columns = 1,
    this.rows = 1,
  });

  bool get hasSprite => assetPath != null;
}