void main() {
  String text =
      "Bir üçgende iki iç açının ölçüsü \\( 47^\\circ \\) ve \\( 68^\\circ \\) olduğuna göre, üçüncü iç açının ölçüsü kaç derecedir?";
  final regex = RegExp(r'(\\\([\s\S]*?\\\))|(\\\[[\s\S]*?\\\])');

  final matches = regex.allMatches(text);
  for (final match in matches) {
    final rawMath = match.group(0)!;
    final isBlock = rawMath.startsWith(r'\[');

    // Remove the \( \) or \[ \] delimiters
    final mathExpression = rawMath.substring(2, rawMath.length - 2).trim();

    print("rawMath: " + rawMath);
    print("mathExpression: " + mathExpression);
  }
}
