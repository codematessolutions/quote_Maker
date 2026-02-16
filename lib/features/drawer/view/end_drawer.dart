import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quatation_making/core/utils/constants/app_spacing.dart';
import 'package:quatation_making/core/utils/theme/app_colors.dart';
import 'package:quatation_making/core/utils/theme/app_padding.dart';
import 'package:quatation_making/core/utils/theme/app_typography.dart';
import 'package:quatation_making/features/addMaterials/view/add_materials_screen.dart';
import 'package:quatation_making/router/app_routes.dart';
import 'package:quatation_making/widgets/menu_item_widget.dart';
import 'package:quatation_making/widgets/version_text.dart';
import 'package:package_info_plus/package_info_plus.dart';

class CustomDrawer extends StatelessWidget {
   CustomDrawer({super.key});
  final ValueNotifier<int> selectedIndex = ValueNotifier<int>(0);
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(   // <-- removes curve
        borderRadius: BorderRadius.zero,
      ),
      child: ValueListenableBuilder<int>(
        valueListenable: selectedIndex,
        builder: (context5, selectedIndex, _) {
          return Padding(
            padding: AppPadding.pxy2016,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AppSpacing.h26,

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
                  style:AppTypography.body1.copyWith(
                    fontWeight: FontWeight.w600
                  ),
                ),
                AppSpacing.h6,
                Text(
                  'ERNAKULAM · PATTAMBI · VALANCHERY · KANNUR',
                  textAlign: TextAlign.center,
                  style:AppTypography.caption.copyWith(
                     color: AppColors.textSecondary
                  ),
                ),


                AppSpacing.h24,

                MenuItemWidget(
                  index: 0,
                  selectedIndex: selectedIndex,
                  icon:Icons.add_business_outlined,
                  text: "Add Materials",
                  onTap: () {
                    NavigationService.pop(context);
                    NavigationService.push(context, AddMaterialScreen());

                    // customerPro.unselectionDrawer();
                  },
                ),
                AppSpacing.h10,
                MenuItemWidget(
                  index: 0,
                  selectedIndex: selectedIndex,
                  icon:Icons.history_outlined,
                  text: "History",
                  onTap: () {
                    // customerPro.navigate(context, 0, const HomeScreen());
                    // customerPro.unselectionDrawer();
                  },
                ),


                Spacer(),
                // ------------------- LOGOUT -------------------

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
          );
        },
      ),
    );
  }

}