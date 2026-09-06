import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/profile_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/vault_provider.dart';
import '../profile/profile_screen.dart';
import '../settings/settings_screen.dart';
import 'add_profile_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  void _loadData() {
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      context.read<VaultProvider>().loadProfiles(user.id);
    }
  }

  void _openAddProfile() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddProfileSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(child: _buildBody(context)),
          ],
        ),
      ),
      floatingActionButton: _buildFab(),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Family Vault',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text(
                  user?.name ?? '',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.mutedGrey,
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
            icon: const Icon(Icons.settings_outlined),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surface,
              shape: const RoundedRectangleBorder(),
              side: const BorderSide(color: AppColors.border),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final vault = context.watch<VaultProvider>();
    final profiles = vault.profiles;

    if (profiles.isEmpty) {
      return _buildEmptyState();
    }

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: profiles.length,
      itemBuilder: (_, i) => _ProfileLockerCard(
        profile: profiles[i],
        index: i,
        onTap: () {
          context.read<VaultProvider>().selectProfile(profiles[i]);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProfileScreen(profile: profiles[i]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.border, width: 1.5),
                boxShadow: [AppTheme.neoShadow(AppColors.electricYellow)],
              ),
              child: const Icon(
                Icons.add_circle_outline,
                color: AppColors.electricYellow,
                size: 36,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No profiles yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Create a profile for each family member to start organising documents.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.mutedGrey,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.95, 0.95)),
    );
  }

  Widget _buildFab() {
    return GestureDetector(
      onTap: _openAddProfile,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.electricYellow,
          border: Border.all(color: AppColors.white.withOpacity(0.2), width: 1.5),
          boxShadow: [AppTheme.neoShadow(AppColors.electricBlue)],
        ),
        child: const Icon(Icons.add, color: AppColors.black, size: 28),
      ),
    );
  }
}

class _ProfileLockerCard extends StatelessWidget {
  final ProfileModel profile;
  final int index;
  final VoidCallback onTap;

  const _ProfileLockerCard({
    required this.profile,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(profile.colorValue);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          border: Border.all(color: color.withOpacity(0.6), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              offset: const Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top accent bar
            Container(height: 3, color: color),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Emoji avatar
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        border: Border.all(
                            color: color.withOpacity(0.4), width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          profile.emoji,
                          style: const TextStyle(fontSize: 26),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      profile.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      profile.relationship,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: color,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.folder_outlined, size: 12, color: AppColors.mutedGrey),
                        const SizedBox(width: 4),
                        Text(
                          '${context.watch<VaultProvider>().profiles.isNotEmpty ? _folderCount(context, profile.id) : 0} folders',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Lock icon bottom-right
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color,
                  border: Border(
                    left: BorderSide(color: color.withOpacity(0.6), width: 1.5),
                    top: BorderSide(color: color.withOpacity(0.6), width: 1.5),
                  ),
                ),
                child: Icon(
                  Icons.lock_outlined,
                  size: 16,
                  color: color.computeLuminance() > 0.4
                      ? AppColors.black
                      : AppColors.white,
                ),
              ),
            ),
          ],
        ),
      )
          .animate(delay: (index * 60).ms)
          .fadeIn(duration: 400.ms)
          .slideY(begin: 0.15, end: 0),
    );
  }

  int _folderCount(BuildContext context, String profileId) {
    return context.read<VaultProvider>().folders
        .where((f) => f.profileId == profileId)
        .length;
  }
}
