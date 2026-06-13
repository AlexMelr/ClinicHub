// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:clinichub_app/main.dart';

void main() {
  testWidgets('ClinicHub shell renders main navigation', (WidgetTester tester) async {
    await tester.pumpWidget(const ClinicHubApp());

    expect(find.text('ClinicHub 中医诊所'), findsOneWidget);
    expect(find.text('首页'), findsOneWidget);
    expect(find.text('药材'), findsOneWidget);
    expect(find.text('患者'), findsOneWidget);
    expect(find.text('就诊'), findsOneWidget);
    expect(find.text('处方'), findsOneWidget);
    expect(find.text('库存'), findsOneWidget);

    await tester.tap(find.text('药材'));
    await tester.pump();

    expect(find.text('药材管理'), findsOneWidget);
  });
}
