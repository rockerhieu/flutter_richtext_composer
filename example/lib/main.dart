import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_richtext_composer/flutter_richtext_composer.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Demo(),
    );
  }
}

class Demo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter RichText Composer'),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: ListView(
          children: [
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
            SizedBox(
              height: 420,
              child: Markdown(
                data: '''
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
''',
              ),
            ),
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
            SizedBox(
              height: 220,
              child: Markdown(
                data: '''
```dart
RichTextComposer(
  'Hi \\\\{dad}, I am {batman}!',
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
''',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
