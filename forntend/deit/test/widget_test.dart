// test/widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deit/main.dart';  // عدّل هنا ليطابق اسم الحزمة

void main() {
  testWidgets('Displays initial choice screen', (WidgetTester tester) async {
    // شغّل تطبيقك
    await tester.pumpWidget(MealPlannerApp());

    // تأكد من ظهور نص "اختر الطريقة" و الأزرار
    expect(find.text('اختر الطريقة'), findsOneWidget);
    expect(find.text('احسب بناءً على ملفي الشخصي'), findsOneWidget);
    expect(find.text('أدخل السعرات يدوياً'), findsOneWidget);
  });
}
