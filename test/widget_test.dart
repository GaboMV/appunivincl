// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:appuniv/main.dart'; // Importá tu app

void main() {
  testWidgets('App carga correctamente', (WidgetTester tester) async {
    await tester.pumpWidget(const AppAccesible()); // Asegúrate que MyApp existe
    expect(find.byType(MaterialApp), findsOneWidget); // Verifica que MaterialApp esté presente
  });
}