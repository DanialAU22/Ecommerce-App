import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';
import '../providers/theme_provider.dart';
import 'login_screen.dart';
import 'order_history_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final XFile? picked =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (picked == null || !mounted) {
      return;
    }

    final bytes = await picked.readAsBytes();
    if (!mounted) {
      return;
    }
    await context.read<AuthProvider>().updateAvatar(bytes);
  }

  Future<void> _saveName() async {
    await context.read<AuthProvider>().updateName(_nameController.text);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile name updated')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<AuthProvider, ThemeProvider, OrderProvider>(
      builder: (
        BuildContext context,
        AuthProvider auth,
        ThemeProvider theme,
        OrderProvider orderProvider,
        Widget? child,
      ) {
        if (!auth.isLoggedIn) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(Icons.person_outline_rounded, size: 48),
                  const SizedBox(height: 12),
                  const Text('Please log in to access your profile.'),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text('Login'),
                  ),
                ],
              ),
            ),
          );
        }

        _nameController.text = auth.displayName;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 34,
                  backgroundImage:
                      auth.avatarBytes == null ? null : MemoryImage(auth.avatarBytes!),
                  child: auth.avatarBytes == null
                      ? const Icon(Icons.person, size: 34)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        auth.displayName,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(auth.email),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _pickAvatar,
                  icon: const Icon(Icons.photo_camera_outlined),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            FilledButton.tonal(
              onPressed: _saveName,
              child: const Text('Save Name'),
            ),
            const SizedBox(height: 12),
            SwitchListTile.adaptive(
              value: theme.isDarkMode,
              onChanged: (bool value) {
                theme.toggleDarkMode(value);
              },
              title: const Text('Dark mode'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.receipt_long_rounded),
              title: const Text('Order history'),
              subtitle: Text('${orderProvider.orders.length} orders'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const OrderHistoryScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () async {
                await auth.logout();
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
