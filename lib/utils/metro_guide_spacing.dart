class MetroGuideSpacing {
  MetroGuideSpacing._();

  static bool shouldReduceSpacing(String currentFile, String nextFile) {
    final isSpecialCurrent = RegExp(
      r'oth@(one|two|thr|fou)\.svg',
    ).hasMatch(currentFile);
    final isSpecialNext = RegExp(
      r'oth@(one|two|thr|fou)\.svg',
    ).hasMatch(nextFile);
    final isOthSeriesCurrent = RegExp(
      r'oth@(0[1-9]|1[0-9]|2[0-9]|30|A)\.svg',
    ).hasMatch(currentFile);
    final isOthSeriesNext = RegExp(
      r'oth@(0[1-9]|1[0-9]|2[0-9]|30|A)\.svg',
    ).hasMatch(nextFile);
    return (isSpecialCurrent && isOthSeriesNext) ||
        (isOthSeriesCurrent && isSpecialNext);
  }

  static bool isDotPair(String currentFile, String nextFile) {
    return (currentFile == 'oth@Dot.svg' && nextFile == 'oth@A.svg') ||
        (currentFile == 'oth@A.svg' && nextFile == 'oth@Dot.svg');
  }

  static bool isSubLinePair(String currentType, String nextType) {
    return (currentType == 'sub' && nextType == 'sub') ||
        (currentType == 'sub' && nextType == 'line') ||
        (currentType == 'line' && nextType == 'sub');
  }

  static bool isSubSeries(String fileName) {
    return RegExp(
      r'sub@(0[3-9]|1[0-9]|20|21|text|long|exit|space)\.svg',
    ).hasMatch(fileName);
  }

  static double getSubSeriesSpacing(String currentFile, String nextFile) {
    final isExit = currentFile == 'sub@exit.svg' || nextFile == 'sub@exit.svg';
    final isLong = currentFile == 'sub@long.svg' || nextFile == 'sub@long.svg';
    final isText = currentFile == 'sub@text.svg' || nextFile == 'sub@text.svg';

    if (isExit) return 10;
    if (isLong) return 0;
    if (isText) return 15;
    return 0;
  }

  static double getDynamicSpacing(
    String currentFile,
    String nextFile,
    String currentType,
    String nextType, {
    double defaultSpacing = 25,
  }) {
    if (shouldReduceSpacing(currentFile, nextFile)) return 5;
    if (isDotPair(currentFile, nextFile)) return 0;
    if (isSubLinePair(currentType, nextType)) return 0;
    if (currentFile == 'oth@Dot.svg' || nextFile == 'oth@Dot.svg') return 15;
    if (isSubSeries(currentFile) && isSubSeries(nextFile)) {
      return getSubSeriesSpacing(currentFile, nextFile);
    }
    return defaultSpacing;
  }
}
