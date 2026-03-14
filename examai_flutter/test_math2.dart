void main() {
  String text = "Test \$x^2\$ and \$\$y^2\$\$ and \\(z^2\\) and \\[a^2\\]";

  // Regex to match:
  // 1: \[ ... \] block
  // 2: $$ ... $$ block
  // 3: \( ... \) inline
  // 4: $ ... $ inline
  final regex = RegExp(
      r'(\\\[[\s\S]*?\\\])|(\$\$[\s\S]*?\$\$)|(\\\([\s\S]*?\\\))|((?<!\$)\$[\s\S]+?\$+(?!\$))');

  final matches = regex.allMatches(text);
  for (final match in matches) {
    final rawMath = match.group(0)!;
    final isBlock = rawMath.startsWith(r'\[') || rawMath.startsWith(r'$$');

    String mathExpression = '';
    if (rawMath.startsWith(r'\[') || rawMath.startsWith(r'\(')) {
      mathExpression = rawMath.substring(2, rawMath.length - 2).trim();
    } else if (rawMath.startsWith(r'$$')) {
      mathExpression = rawMath.substring(2, rawMath.length - 2).trim();
    } else if (rawMath.startsWith(r'$')) {
      mathExpression = rawMath.substring(1, rawMath.length - 1).trim();
    }

    print("rawMath: " + rawMath);
    print("isBlock: " + isBlock.toString());
    print("mathExpression: " + mathExpression);
  }
}
