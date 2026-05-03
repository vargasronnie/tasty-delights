import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../bloc/app_bloc.dart';
import '../../models/user_model.dart';
import '../../theme/app_theme.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<AppBloc>();
    final user = bloc.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Avatar
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: AppTheme.primary.withOpacity(0.1),
                  child: Text(
                    user?.name.isNotEmpty == true
                        ? user!.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        user?.name ?? 'Guest',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _showEditProfile(context, user),
                      child: const Icon(Icons.edit,
                          size: 16, color: AppTheme.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  user?.email ?? '',
                  style:
                      const TextStyle(color: AppTheme.textGrey, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _MenuItem(
            icon: Icons.location_on_outlined,
            title: 'Address',
            subtitle: user?.address.isNotEmpty == true
                ? user!.address
                : 'Add delivery address',
            onTap: () => _showEditAddress(context, user),
          ),
          _MenuItem(
            icon: Icons.notifications_outlined,
            title: 'Notification',
            subtitle: 'Manage your notifications',
            onTap: () => _snack(context, 'Notifications coming soon!'),
          ),
          _MenuItem(
            icon: Icons.payment_outlined,
            title: 'Payment',
            subtitle: 'Manage payment methods',
            onTap: () => _snack(context, 'Payment settings coming soon!'),
          ),
          _MenuItem(
            icon: Icons.help_outline,
            title: 'Help Center',
            subtitle: 'Get help and support',
            onTap: () => _snack(context, 'Help center coming soon!'),
          ),
          _MenuItem(
            icon: Icons.person_add_outlined,
            title: 'Invite Friends',
            subtitle: 'Share Tasty Delights with friends',
            onTap: () => _snack(context, 'Invite feature coming soon!'),
          ),
          const SizedBox(height: 6),
          _MenuItem(
            icon: Icons.logout,
            title: 'Logout',
            subtitle: 'Sign out of your account',
            isDestructive: true,
            onTap: () => _confirmLogout(context, bloc),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text('Tasty Delights v1.0.0',
                style: TextStyle(color: Colors.grey[400], fontSize: 11)),
          ),
        ],
      ),
    );
  }

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));
  }

  void _confirmLogout(BuildContext context, AppBloc bloc) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title:
            const Text('Logout', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              bloc.logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showEditProfile(BuildContext context, UserModel? user) {
    if (user == null) return;
    final nameCtrl = TextEditingController(text: user.name);
    final phoneCtrl = TextEditingController(text: user.phone);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Edit Profile',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                    hintText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline))),
            const SizedBox(height: 10),
            TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                    hintText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone_outlined))),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: () {
                user.name = nameCtrl.text;
                user.phone = phoneCtrl.text;
                context.read<AppBloc>().updateUser(user);
                Navigator.pop(ctx);
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditAddress(BuildContext context, UserModel? user) {
    if (user == null) return;
    final addrCtrl = TextEditingController(text: user.address);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Delivery Address',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            TextField(
              controller: addrCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                  hintText: 'Enter your full address',
                  prefixIcon: Icon(Icons.location_on_outlined)),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: () {
                user.address = addrCtrl.text;
                context.read<AppBloc>().updateUser(user);
                Navigator.pop(ctx);
              },
              child: const Text('Save Address'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppTheme.error : AppTheme.primary;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)
        ],
      ),
      child: ListTile(
        onTap: onTap,
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        title: Text(title,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDestructive ? AppTheme.error : AppTheme.textDark,
                fontSize: 13)),
        subtitle: Text(subtitle,
            style: const TextStyle(color: AppTheme.textGrey, fontSize: 11)),
        trailing: Icon(Icons.chevron_right, color: Colors.grey[400], size: 16),
      ),
    );
  }
}
