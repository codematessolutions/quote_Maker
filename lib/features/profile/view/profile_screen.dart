import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:quatation_making/core/utils/constants/app_assets.dart';
import 'package:quatation_making/core/utils/constants/app_spacing.dart';
import 'package:quatation_making/core/utils/theme/app_colors.dart';
import 'package:quatation_making/core/utils/theme/app_padding.dart';
import 'package:quatation_making/core/utils/theme/app_radius.dart';
import 'package:quatation_making/core/utils/theme/app_typography.dart';
import 'package:quatation_making/features/addMaterials/application/material_state.dart';
import 'package:quatation_making/features/addMaterials/view/add_materials_screen.dart';
import 'package:quatation_making/features/profile/view/widgets/bank_details_row.dart';
import 'package:quatation_making/features/quotation/view/quotation_history_screen.dart';
import 'package:quatation_making/router/app_routes.dart';
import 'package:quatation_making/widgets/custom_button.dart';
import 'package:quatation_making/widgets/version_text.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> _openUrl(String url) async {
  final uri = Uri.parse(url);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    throw Exception('Could not launch $url');
  }
}

class BaymentProfileHeader extends ConsumerWidget {
  const BaymentProfileHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Profile',
          style:AppTypography.h5.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        centerTitle: false,
      ),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: AppPadding.p16,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 90.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: AppRadius.r8,
                  image: DecorationImage(image: AssetImage(AppAssets.appLogo,),fit: BoxFit.cover)
                ), 
              ),
          
              AppSpacing.h16,
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadius.r8,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.18),
                  ),
          
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Contact Details',
                      textAlign: TextAlign.center,
                      style:AppTypography.h3.copyWith(
                        fontSize: 19.sp,
                        color: AppColors.grey5D,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    AppSpacing.h20,
          
                    // CONTACT ROWS
                    _ContactRow(
                      icon: Icons.phone_outlined,
                      value: '+91 77366 84546, +91 80861 38435',
                      onTap: () => _openUrl('tel:+917736684546'),
                    ),
                   AppSpacing.h12,
                    _ContactRow(
                      icon: Icons.email_outlined,
                      value: 'energyecovolt71@gmail.com',
                      onTap: () => _openUrl('mailto:energyecovolt71@gmail.com'),
                    ),
                    AppSpacing.h12,
                    _ContactRow(
                      icon: Icons.language_rounded,
                      value: 'www.baymentsolar.com',
                      onTap: () => _openUrl('https://www.baymentsolar.com'),
                    ),
          
          
                    AppSpacing.h14,
                    const Divider(color: AppColors.greyF8,),
                    AppSpacing.h14,
          
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
              AppSpacing.h16,
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadius.r8,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.18),
                  ),
          
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Bank Details',
                      textAlign: TextAlign.center,
                      style:AppTypography.h3.copyWith(
                          fontSize: 19.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.grey5D
                      ),
                    ),
                    AppSpacing.h12,
                    DetailRow(label: 'Account Number', value: '4691101003940'),
                    AppSpacing.h6,
                    DetailRow(label: 'IFSC code', value: 'CNRB0004691'),
                    AppSpacing.h6,
                    DetailRow(label: 'Bank Name', value: 'CANARA BANK'),
          
          
          
                  ],
                ),
              ),
              AppSpacing.h16,
              CustomButton(
                label: 'Previous Proposals',
                onTap: () {
                  // NavigationService.pop(context);
                  NavigationService.push(
                    context,
                    const QuotationHistoryScreen(),
                  );
                },
              ),
              AppSpacing.h16,
              CustomButton(
                label:'Add Materials' ,
                onTap: () {
                  // NavigationService.pop(context);
                  ref.read(addMaterialProvider.notifier).clearForNewEntry();
                  NavigationService.push(context, AddMaterialScreen());
                },
              ),
              AppSpacing.h24,
              SafeArea(
                minimum: EdgeInsets.only(
                  top: 22.h,
                  bottom: 25.h, // Extra safe margin for all devices
                ),
                child: Align(
                  alignment: .bottomCenter,
                  child:  FutureBuilder(
                    future: PackageInfo.fromPlatform(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox();
                      final info = snapshot.data!;
                      return VersionText(
                          label: 'Version', value: "${info.version}+${info.buildNumber}");
                    },
                  ),
                ),
              ),
          
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String value;
  final VoidCallback onTap;

  const _ContactRow({
    required this.icon,
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
          Icon(icon, size: 20,color: AppColors.grey52,),
          AppSpacing.w12,
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.grey52,
          )
        ),

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