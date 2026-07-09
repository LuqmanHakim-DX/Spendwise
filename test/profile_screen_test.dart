import 'package:flutter_test/flutter_test.dart';
import 'package:spendwise/screens/profile_screen.dart';

void main() {
  group('ProfileScreen', () {
    test('buildInitials uses display name before email fallback', () {
      expect(ProfileScreen.buildInitials('Jane Doe', 'jane@example.com'), 'JD');
    });

    test('buildInitials falls back to email when display name is missing', () {
      expect(ProfileScreen.buildInitials(null, 'john@example.com'), 'JE');
    });
  });
}
