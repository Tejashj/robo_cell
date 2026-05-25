import 'package:flutter_svg/flutter_svg.dart';

class AppIcons {
  static const String x = 'assets/icons/x.svg';
  static const String instagram = 'assets/icons/instagram.svg';
  static const String linkedin = 'assets/icons/linkedin.svg';

  static const List<String> allSvgs = [x, instagram, linkedin];

  static void precacheSVGs() {
    for (String path in allSvgs) {
      final loader = SvgAssetLoader(path);
      svg.cache.putIfAbsent(loader.cacheKey(null), () => loader.loadBytes(null));
    }
  }
}
