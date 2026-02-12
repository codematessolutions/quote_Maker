import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/constants/app_assets.dart';
import '../../../core/utils/constants/constants.dart';
import '../../../core/utils/theme/app_colors.dart';
import '../../../core/utils/theme/app_typography.dart';
import '../../../core/errors/app_exception.dart';
import '../viewmodel/profile_viewmodel.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _termsController = TextEditingController();
  bool _initialized = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _brandController.dispose();
    _termsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }
    final vm = ref.read(profileViewModelProvider.notifier);
    setState(() {
      _isSaving = true;
    });
    try {
      await vm.saveProfile(
        brandName: _brandController.text.trim(),
        termsAndConditions: _termsController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved successfully')),
      );
    } on AppException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save profile. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileViewModelProvider);

    profileAsync.whenData((profile) {
      if (!_initialized && profile != null) {
        _brandController.text = profile.brandName;
        _termsController.text = profile.termsAndConditions;
        _initialized = true;
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon:Image.asset(AppAssets.circleArrowLeft,scale: 4,),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.screenPadding,
          vertical: AppDimens.screenPadding * 2,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
            Text(
              'Profile',
              style: AppTypography.h5,
            ),
            const SizedBox(height: 24),
            CircleAvatar(
              radius: 48,
              backgroundColor: AppColors.panel,
              child: Icon(
                Icons.person,
                size: 48,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Brand name',
              style: AppTypography.body1.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2,color: AppColors.primary,),
                    )
                  : Text(
                      'Edit',
                      style: AppTypography.body2.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _brandController,
              decoration: InputDecoration(
                labelText: 'Brand name',
                labelStyle: AppTypography.caption,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Brand name is required';
                }
                if (value.trim().length > 50) {
                  return 'Brand name too long';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Terms & Conditions',
                style: AppTypography.body1.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _termsController,
              maxLines: 5,
              decoration: InputDecoration(
                alignLabelWithHint: true,
                labelText: 'Enter terms & conditions',
                labelStyle: AppTypography.caption,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Terms & conditions are required';
                }
                if (value.trim().length > 1000) {
                  return 'Please keep this under 1000 characters';
                }
                return null;
              },
            ),
          ],
          ),
        ),
      ),
    );
  }
}

