/// Copyright 2021 Palo Alto Networks
///
/// Licensed under the Apache License, Version 2.0 (the "License");
/// you may not use this file except in compliance with the License.
/// You may obtain a copy of the License at
///
///   http://www.apache.org/licenses/LICENSE-2.0
///
/// Unless required by applicable law or agreed to in writing, software
/// distributed under the License is distributed on an "AS IS" BASIS,
/// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
/// See the License for the specific language governing permissions and
/// limitations under the License.
import 'package:flutter/widgets.dart';

/// This widget allows to compose a [RichText] in a i18n friendly way.
///
/// ```dart
/// RichTextComposer(
///   'Hi \\\\{dad}, I am {batman}!',
///   style: TextStyle(fontSize: 25),
///   placeholders: {
///     'batman': TextSpan(
///         text: 'Batman',
///         style: TextStyle(
///           color: Colors.red,
///           decoration: TextDecoration.underline,
///         ),
///     ),
///   },
/// ),
/// ```
class RichTextComposer extends StatelessWidget {
  /// Create a new [RichTextComposer] from the given [formula].
  ///
  /// [formula] can have placeholders in this format {place_holder_name}.
  /// [style] - default text style for all text spans.
  RichTextComposer(
    this.formula, {
    Key? key,
    Map<String, InlineSpan> placeholders = const <String, InlineSpan>{},
    this.style,
    this.textAlign,
  })  : _placeholders = placeholders,
        super(key: key) {
    final tokenizer = Tokenizer(formula);
    while (tokenizer.hasNext()) {
      _tokens.add(tokenizer.next()!);
    }
  }

  final String formula;
  final Map<String, InlineSpan> _placeholders;
  final TextStyle? style;
  final TextAlign? textAlign;
  final List<Token> _tokens = [];

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: style,
        children: _tokens
            .map((token) {
              switch (token.type) {
                case TokenType.text:
                  return TextSpan(text: token.value);
                case TokenType.placeholder:
                  if (!_placeholders.containsKey(token.value)) {
                    throw 'Missing placeholder for ‘${token.value}’';
                  }
                  return _placeholders[token.value];
                default:
                  throw 'Unsupported token: $token';
              }
            })
            .cast<InlineSpan>()
            .toList(),
      ),
      textAlign: textAlign,
    );
  }
}

@visibleForTesting
class Tokenizer {
  var cursor = -1;
  final String formula;
  final int formulaLength;

  Tokenizer(this.formula) : formulaLength = formula.length;

  bool hasNext() {
    return cursor < formulaLength - 1;
  }

  @visibleForTesting
  void reset() {
    cursor = -1;
  }

  Token? next() {
    final preStart = cursor;
    if (preStart >= formulaLength - 1) {
      return null;
    }
    final start = ++cursor;
    if (formula[start] == '{') {
      cursor = start + 1;
      String? ch;
      var firstCh = true;
      while (cursor < formulaLength && (ch = formula[cursor]) != '}') {
        var code = ch.codeUnits.first;
        if (firstCh && code >= 48 /* 0 */ && code <= 57 /* 9 */) {
          throw 'Placeholder name must start with a lowercase alphabet letter';
        }
        if ((code < 48 /* 0 */ || code > 57 /* 9 */) &&
            (code < 97 /* a */ || code > 122) /* z */ &&
            code != 95 /* _ */) {
          break;
        }
        firstCh = false;
        cursor++;
      }

      var placeholder = formula.substring(start + 1, cursor);
      if (ch == null || ch != '}') {
        throw 'Invalid placeholder: $placeholder (only accepts [a-z0-9_] in between {})';
      }
      return Token.placeholder(placeholder);
    }

    String? ch;
    final tokenValue = StringBuffer();
    String? escape;
    while (cursor < formulaLength) {
      ch = formula[cursor];
      if (ch == '{') {
        if (escape == null) {
          cursor--;
          break;
        }

        escape = null;
        tokenValue.write(ch);
        cursor++;
        continue;
      }

      if (escape != null) {
        tokenValue.write(escape);
        escape = null;
      }
      if (ch == '\\') {
        escape = ch;
      } else {
        tokenValue.write(ch);
      }
      cursor++;
    }

    if (ch == null) return null;

    if (escape != null) {
      tokenValue.write(escape);
    }
    return Token.text(tokenValue.toString());
  }
}

@visibleForTesting
enum TokenType { text, placeholder }

@visibleForTesting
class Token {
  final TokenType type;
  final String value;

  Token._({
    required this.type,
    required this.value,
  });

  factory Token.text(String text) {
    return Token._(type: TokenType.text, value: text);
  }

  factory Token.placeholder(String name) {
    return Token._(type: TokenType.placeholder, value: name);
  }

  @override
  String toString() => '$type($value)';

  @override
  int get hashCode => _hash2(type, value);

  @override
  bool operator ==(Object other) {
    return other is Token && other.type == type && other.value == value;
  }
}

// Jenkins hash functions

int _combine(int hash, int value) {
  hash = 0x1fffffff & (hash + value);
  hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
  return hash ^ (hash >> 6);
}

int _finish(int hash) {
  hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
  hash = hash ^ (hash >> 11);
  return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
}

/// Generates a hash code for two objects.
int _hash2(a, b) => _finish(_combine(_combine(0, a.hashCode), b.hashCode));
