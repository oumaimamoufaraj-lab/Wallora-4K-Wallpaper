import 'package:flutter_test/flutter_test.dart';

import 'package:fc_app3_wallany/main.dart';

void main() {
  testWidgets('App shows splash then Wallora', (WidgetTester tester) async {
    await tester.pumpWidget(const WallcandyRoot());
    expect(find.text('Wallora 4K Wallpaper'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('Wallora 4K Wallpaper'), findsWidgets);
  });
}
