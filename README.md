# flutter_richtext_composer

[![Latest version on pub.dev](https://shields.io/pub/v/flutter_richtext_composer)](https://pub.dev/packages/flutter_richtext_composer)

A Flutter package for composing [RichText](https://api.flutter.dev/flutter/widgets/RichText-class.html) in a i18n friendly way.

## Getting Started

Import the library with

```dart
import 'package:flutter_richtext_composer/flutter_richtext_composer.dart';
```

## Example
Then you can start composing `RichText` like this:

```dart
RichTextComposer(
  'Hi {name}, I am {my_name}! {icon}',
  style: TextStyle(fontSize: 30),
  placeholders: {
    'name': TextSpan(
          text: 'Son',
          style: TextStyle(fontWeight: FontWeight.bold),
    ),
    'my_name': TextSpan(
          text: 'Dad',
          style: TextStyle(
            color: Colors.red,
            decoration: TextDecoration.underline,
          ),
    ),
    'icon': WidgetSpan(
      child: GestureDetector(
        child: Icon(Icons.person),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Icon has been clicked'),
          ));
        },
      ),
    ),
  },
),
```

To escape the placeholder, prefix with `\`, e.g `\{placeholder}`:
```dart
RichTextComposer(
  'Hi \\{dad}, I am {batman}!',
  style: TextStyle(fontSize: 25),
  placeholders: {
    'batman': TextSpan(
          text: 'Batman',
          style: TextStyle(
            color: Colors.red,
            decoration: TextDecoration.underline,
          ),
    ),
  },
),
```

![Example](https://github.com/rockerhieu/flutter_richtext_composer/blob/master/screenshots/screenshot.png?raw=true)