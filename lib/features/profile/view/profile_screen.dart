import 'package:flutter/material.dart';
import 'package:quatation_making/core/utils/constants/app_spacing.dart';
import 'package:quatation_making/core/utils/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> _openUrl(String url) async {
  final uri = Uri.parse(url);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    throw Exception('Could not launch $url');
  }
}

class BaymentProfileHeader extends StatelessWidget {
  const BaymentProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Profile',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const BaymentProfileHeader(),
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          children: [
            AppSpacing.h20,
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.18),
                ),

              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // LOGO CIRCLE
                  Container(
                    height: 64,
                    width: 64,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF4F8BFF), Color(0xFF35C9FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.solar_power_rounded,
                        color: Colors.black,
                        size: 34,
                      ),
                    ),
                  ),
                  AppSpacing.h16,

                  // COMPANY NAME
                  Text(
                    'BAYMENT SOLAR',
                    textAlign: TextAlign.center,
                    style: theme.textTheme. titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                      color: Colors.black,
                    ),
                  ),
                  AppSpacing.h6,

                  // LOCATIONS
                  Text(
                    'ERNAKULAM · PATTAMBI · VALANCHERY · KANNUR',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.displaySmall?.copyWith(
                      letterSpacing: 1.3,
                      fontSize: 12,
                      color: Colors.black.withOpacity(0.72),
                    ),
                  ),

                  const SizedBox(height: 20),
                   Divider(color: AppColors.secondaryButton, height: 1),
                  const SizedBox(height: 16),

                  // CONTACT ROWS
                  _ContactRow(
                    icon: Icons.phone_rounded,
                    label: 'Phone',
                    value: '86066 93000  ·  86066 98000',
                    onTap: () => _openUrl('tel:+918606693000'),
                  ),
                  const SizedBox(height: 12),
                  _ContactRow(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: 'contact@baymentsolar.com',
                    onTap: () => _openUrl('mailto:contact@baymentsolar.com'),
                  ),
                  const SizedBox(height: 12),
                  _ContactRow(
                    icon: Icons.language_rounded,
                    label: 'Website',
                    value: 'www.baymentsolar.com',
                    onTap: () => _openUrl('https://www.baymentsolar.com'),
                  ),

                  const SizedBox(height: 18),
                  const Divider(color: AppColors.secondaryButton, height: 1),
                  const SizedBox(height: 14),

                  // SOCIAL CHIPS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _SocialChip(
                        icon: Icons.facebook,
                        label: '@Bayment solar',
                        onTap: () => _openUrl(
                          'https://www.facebook.com/BaymentSolar',
                        ),
                      ),
                      const SizedBox(width: 5),
                      _SocialChip(
                        icon: Icons.camera_alt_outlined,
                        label: '@baymentsolar_',
                        onTap: () => _openUrl(
                          'https://www.instagram.com/baymentsolar_/',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(0.10),
            ),
            child: Icon(icon, size: 20, color: Colors.black),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.black.withOpacity(0.6),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.black54, size: 20),
        ],
      ),
    );
  }
}

class _SocialChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SocialChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.10),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              Icon(icon, color: Colors.black, size: 18),
              const SizedBox(width: 5),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.black,fontSize: 11
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}