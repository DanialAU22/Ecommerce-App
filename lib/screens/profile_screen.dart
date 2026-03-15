import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../core/widgets/empty_state_widget.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/custom_button.dart';
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
    final XFile? picked = await _imagePicker.pickImage(source: ImageSource.gallery);
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
              child: EmptyStateWidget(
                icon: Icons.person_outline_rounded,
                title: 'Sign In Required',
                message: 'Log in to view your profile, orders, and saved details.',
                actionLabel: 'Login',
                onAction: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const LoginScreen(),
                    ),
                  );
                },
              ),
            ),
          );
        }

        _nameController.text = auth.displayName;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Theme.of(context).colorScheme.surface,
              ),
              child: Row(
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
                        Text(auth.displayName, style: Theme.of(context).textTheme.titleLarge),
                        Text(auth.email, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    onPressed: _pickAvatar,
                    icon: const Icon(Icons.camera_alt_outlined),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _SectionCard(
              title: 'User Info',
              child: Column(
                children: <Widget>[
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Display name'),
                  ),
                  const SizedBox(height: 10),
                  CustomButton(
                    label: 'Save Changes',
                    onPressed: _saveName,
                    expanded: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Order History',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.receipt_long_rounded),
                title: const Text('View orders'),
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
            ),
            const SizedBox(height: 12),
            const _SectionCard(
              title: 'Saved Addresses',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.location_on_outlined),
                title: Text('Home Address'),
                subtitle: Text('123 Main Street, New York, NY 10001'),
              ),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Preferences',
              child: SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: theme.isDarkMode,
                onChanged: (bool value) {
                  theme.toggleDarkMode(value);
                },
                title: const Text('Dark mode'),
                secondary: const Icon(Icons.dark_mode_outlined),
              ),
            ),
            const SizedBox(height: 16),
            CustomButton(
              label: 'Logout',
              icon: Icons.logout_rounded,
              style: CustomButtonStyle.secondary,
              onPressed: () async {
                await auth.logout();
              },
            ),
          ],
        );
      },
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
