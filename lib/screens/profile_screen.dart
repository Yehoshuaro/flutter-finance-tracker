import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/transaction_provider.dart';
import '../services/auth_service.dart';
import '../main.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // final user = FirebaseAuth.instance.currentUser;
    final isGuest = Provider.of<GuestModeProvider>(context, listen: false).isGuest;
    if (/*user == null || */isGuest) {
      Future.microtask(() {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.read<LocaleProvider>().translations.translate('pleaseLogin'))),
        );
      });
      return Scaffold(
        body: Center(child: Text(context.read<LocaleProvider>().translations.translate('notLoggedIn'))),
      );
    }

    final t = context.watch<LocaleProvider>().translations;
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              //title: Text(t.translate('profile')),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFF8A65), // light orange
                      Color(0xFFFF7043), // deep orange
                      Color(0xFFE53935), // red
                    ],
                  ),
                ),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 24.0, bottom: 24.0),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 36,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person, size: 42, color: Colors.black54),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.translate('profileGreeting'),
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'guest@example.com',
                              style: TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: _StatCard(icon: Icons.trending_up, label: t.translate('income'), value: '—')),
                      const SizedBox(width: 12),
                      Expanded(child: _StatCard(icon: Icons.trending_down, label: t.translate('expense'), value: '—')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(t.translate('profileActions'), style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.edit),
                            title: const Text('Edit profile'),
                            onTap: () {},
                          ),
                          const Divider(height: 0),
                          ListTile(
                            leading: const Icon(Icons.lock),
                            title: const Text('Change password'),
                            onTap: () {},
                          ),
                          const Divider(height: 0),
                          ListTile(
                            leading: const Icon(Icons.logout, color: Colors.redAccent),
                            title: Text(t.translate('logout')),
                            onTap: () async {
                              context.read<TransactionProvider>().clearAndLoad([]);
                              await context.read<AuthService>().signOut();
                              if (!context.mounted) return;
                              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 10),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 4),
                Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 