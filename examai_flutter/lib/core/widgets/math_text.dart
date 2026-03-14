import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class MathText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;

  const MathText(
    this.text, {
    super.key,
    this.style,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    return SelectableText.rich(
      _buildSpan(context),
      textAlign: textAlign,
    );
  }

  TextSpan _buildSpan(BuildContext context) {
    final defaultStyle = style ?? DefaultTextStyle.of(context).style;
    final mathStyle = defaultStyle.copyWith(
      fontFamily: null, // Let flutter_math handle the font for LaTeX
    );

    // Regex to match:
    // 1: \[ ... \] block
    // 2: $$ ... $$ block
    // 3: \( ... \) inline
    // 4: $ ... $ inline
    final regex = RegExp(
        r'(\\\[[\s\S]*?\\\])|(\$\$[\s\S]*?\$\$)|(\\\([\s\S]*?\\\))|((?<!\$)\$[\s\S]+?\$+(?!\$))');

    final matches = regex.allMatches(text);
    if (matches.isEmpty) {
      return TextSpan(text: text, style: defaultStyle);
    }

    List<InlineSpan> spans = [];
    int lastMatchEnd = 0;

    for (final match in matches) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: text.substring(lastMatchEnd, match.start),
          style: defaultStyle,
        ));
      }

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

      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: isBlock ? 8.0 : 0.0,
              // Add horizontal padding for block equations
              horizontal: isBlock ? 16.0 : 2.0,
            ),
            child: isBlock
                ? SizedBox(
                    width: double.infinity,
                    child: Center(
                      child: _buildMath(mathExpression, mathStyle,
                          MathStyle.display, defaultStyle, rawMath),
                    ),
                  )
                : _buildMath(mathExpression, mathStyle, MathStyle.text,
                    defaultStyle, rawMath),
          ),
        ),
      );

      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: defaultStyle,
      ));
    }

    return TextSpan(children: spans);
  }

  Widget _buildMath(String expression, TextStyle style, MathStyle mathStyle,
      TextStyle defaultStyle, String rawSource) {
    return Math.tex(
      expression,
      textStyle: style,
      mathStyle: mathStyle,
      onErrorFallback: (err) {
        // If parsing fails, fallback to rendering the raw string so it's not totally broken
        return Text(
          rawSource,
          style: defaultStyle.copyWith(color: Colors.redAccent),
        );
      },
    );
  }
}
