import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart' as app_auth_provider;
import '../widgets/app_drawer.dart';
import '../widgets/exit_confirmation_scope.dart';
import 'add_expense_screen.dart';
import 'analytics_screen.dart';
import 'budget_screen.dart';
import 'calendar_screen.dart';
import 'home_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  static String buildInitials(String? displayName, String email) {
    final trimmedDisplayName = (displayName ?? '').trim();
    if (trimmedDisplayName.isNotEmpty) {
      final parts = trimmedDisplayName.split(RegExp(r'\s+'));
      if (parts.length == 1) {
        final word = parts.first;
        final length = word.length < 2 ? word.length : 2;
        return word.substring(0, length).toUpperCase();
      }

      final first = parts.first[0];
      final last = parts.last[0];
      return '$first$last'.toUpperCase();
    }

    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty) {
      return 'U';
    }

    final atIndex = trimmedEmail.indexOf('@');
    if (atIndex > 0 && atIndex < trimmedEmail.length - 1) {
      final localPart = trimmedEmail.substring(0, atIndex);
      final domainPart = trimmedEmail.substring(atIndex + 1);
      return '${localPart[0].toUpperCase()}${domainPart[0].toUpperCase()}';
    }

    final length = trimmedEmail.length < 2 ? trimmedEmail.length : 2;
    return trimmedEmail.substring(0, length).toUpperCase();
  }

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isUpdatingPassword = false;
  bool _isUpdatingEmail = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<app_auth_provider.AuthProvider>();
    final user = authProvider.user;
    final displayName = user?.displayName?.trim();
    final email = user?.email ?? 'No email available';
    final initials = ProfileScreen.buildInitials(displayName, email);

    return ExitConfirmationScope(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
        ),
        drawer: AppDrawer(
          currentIndex: 5,
          onDestinationSelected: (index) => _navigateToIndex(context, index),
          onLogout: () async {
            await context.read<app_auth_provider.AuthProvider>().signOut();
            if (!context.mounted) return;
            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          },
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          initials,
                          style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        displayName?.isNotEmpty == true ? displayName! : 'SpendWise User',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        email,
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Account Security',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.lock_outline),
                      title: const Text('Change Password'),
                      subtitle: const Text('Update your password for better account security.'),
                      trailing: _isUpdatingPassword ? const CircularProgressIndicator(strokeWidth: 2) : const Icon(Icons.chevron_right),
                      onTap: _isUpdatingPassword ? null : () => _showPasswordDialog(context),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.email_outlined),
                      title: const Text('Update Login Email'),
                      subtitle: const Text('Change the email tied to your account.'),
                      trailing: _isUpdatingEmail ? const CircularProgressIndicator(strokeWidth: 2) : const Icon(Icons.chevron_right),
                      onTap: _isUpdatingEmail ? null : () => _showEmailDialog(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToIndex(BuildContext context, int index) {
    if (index == 4) return;
    Widget target;
    switch (index) {
      case 0:
        target = const HomeScreen();
        break;
      case 1:
        target = const AddExpenseScreen();
        break;
      case 2:
        target = const CalendarScreen();
        break;
      case 3:
        target = const AnalyticsScreen();
        break;
      case 4:
        target = const BudgetScreen();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => target));
  }

  Future<void> _showPasswordDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'New password',
              hintText: 'At least 6 characters',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                await _updatePassword(dialogContext);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEmailDialog(BuildContext context) async {
    _emailController.text = context.read<app_auth_provider.AuthProvider>().user?.email ?? '';
    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Update Login Email'),
          content: TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'New email address',
              hintText: 'name@example.com',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                await _updateEmail(dialogContext);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updatePassword(BuildContext dialogContext) async {
    final newPassword = _passwordController.text.trim();
    if (newPassword.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password must be at least 6 characters.')));
      return;
    }

    setState(() => _isUpdatingPassword = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No active account found.');
      }
      await user.updatePassword(newPassword);
      if (!mounted) return;
      Navigator.pop(dialogContext);
      _passwordController.clear();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password updated successfully.')));
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      Navigator.pop(dialogContext);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_mapFirebaseError(e))));
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(dialogContext);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() => _isUpdatingPassword = false);
      }
    }
  }

  Future<void> _updateEmail(BuildContext dialogContext) async {
    final newEmail = _emailController.text.trim();
    if (newEmail.isEmpty || !newEmail.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid email address.')));
      return;
    }

    setState(() => _isUpdatingEmail = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No active account found.');
      }
      await user.verifyBeforeUpdateEmail(newEmail);
      if (!mounted) return;
      Navigator.pop(dialogContext);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Verification email sent. Please confirm the new address to complete the change.')));
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      Navigator.pop(dialogContext);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_mapFirebaseError(e))));
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(dialogContext);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() => _isUpdatingEmail = false);
      }
    }
  }

  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'email-already-in-use':
        return 'That email is already in use.';
      case 'requires-recent-login':
        return 'Please sign out and sign in again before changing your email or password.';
      case 'weak-password':
        return 'Choose a stronger password.';
      default:
        return e.message ?? 'Unable to update account details.';
    }
  }
}
