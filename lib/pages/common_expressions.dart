import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class CommonExpressions {
  List<String> expressions = [];

  Future<void> loadExpressions() async {
    final String response =
        await rootBundle.loadString('assets/promts/common_expressions.json');
    final data = await json.decode(response);
    expressions = List<String>.from(data['expressions']);
  }

  List<String> findCommonExpressions(String text) {
    List<String> foundExpressions = [];
    for (var expression in expressions) {
      if (text.contains(expression)) {
        foundExpressions.add(expression);
      }
    }
    return foundExpressions;
  }
}
