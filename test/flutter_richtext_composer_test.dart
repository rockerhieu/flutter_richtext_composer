import 'package:flutter_richtext_composer/flutter_richtext_composer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Tokenizer', () {
    void expectTokens(Tokenizer tokenizer, List<Token> tokens) {
      tokens.forEach((token) {
        expect(tokenizer.hasNext(), true);
        expect(tokenizer.next(), token);
      });
      expect(tokenizer.hasNext(), false);
    }

    test('Iterate through tokens', () async {
      expectTokens(Tokenizer(''), []);

      expectTokens(Tokenizer('Hello \\a\\b\\c \\{\\n\\a\\m\\e}'), [
        Token.text('Hello \\a\\b\\c {\\n\\a\\m\\e}'),
      ]);

      expectTokens(Tokenizer('Hello \\{name}!'), [
        Token.text('Hello {name}!'),
      ]);

      expectTokens(Tokenizer('Hello {name}, my name is {my_name}'), [
        Token.text('Hello '),
        Token.placeholder('name'),
        Token.text(', my name is '),
        Token.placeholder('my_name'),
      ]);

      expectTokens(Tokenizer('Hello {name}, my name is {my_name}!'), [
        Token.text('Hello '),
        Token.placeholder('name'),
        Token.text(', my name is '),
        Token.placeholder('my_name'),
        Token.text('!'),
      ]);

      expectTokens(Tokenizer('Hello {name}, my name is {my_name}!}'), [
        Token.text('Hello '),
        Token.placeholder('name'),
        Token.text(', my name is '),
        Token.placeholder('my_name'),
        Token.text('!}'),
      ]);

      expectTokens(Tokenizer('{name}, my name is {my_name}!}'), [
        Token.placeholder('name'),
        Token.text(', my name is '),
        Token.placeholder('my_name'),
        Token.text('!}'),
      ]);
    });

    test('Placeholder name validation', () async {
      expect(
        () => Tokenizer('{1invalid_name').next(),
        throwsA(anything),
        reason: 'Placeholder name must start with a lowercase alphabet letter',
      );

      expect(() => Tokenizer('{invalid_name').next(), throwsA(anything));
      expect(() => Tokenizer('{Invalid_name}').next(), throwsA(anything));
      expect(() => Tokenizer('{invalid_name*}').next(), throwsA(anything));
      expect(() => Tokenizer('{{invalid_name}').next(), throwsA(anything));
      expect(() => Tokenizer('{{invalid_name}}').next(), throwsA(anything));

      expectTokens(Tokenizer('{name}}'), [
        Token.placeholder('name'),
        Token.text('}'),
      ]);

      expectTokens(Tokenizer('{valid_name_1}'), [
        Token.placeholder('valid_name_1'),
      ]);

      expectTokens(Tokenizer('{_valid_name_1}'), [
        Token.placeholder('_valid_name_1'),
      ]);
    });
  });
}
