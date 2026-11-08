
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('RecipeApp displays app title', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: Text('My Recipes'),
          ),
        ),
      ),
    );

    expect(find.text('My Recipes'), findsOneWidget);
  });
}
