import 'package:flutter_test/flutter_test.dart';

import 'package:ai_food_delivery/main.dart';

void main() {
  testWidgets('launches the premium discovery screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AiFoodDeliveryConceptApp());
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.textContaining('AI-curated food'), findsOneWidget);
    expect(find.text('Featured restaurants'), findsOneWidget);
  });
}
