import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quatation_making/core/utils/theme/app_typography.dart';

class VersionText extends StatelessWidget {
  final String label;
  final String value;
  final bool isProfile;

  const VersionText({super.key, required this.label, required this.value,this.isProfile=false});

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: AppTypography.body1,
        children: [
          TextSpan(
            text: '$label : ',
            style: AppTypography.caption.copyWith(
                fontSize: 13.sp
            ),

          ),
          TextSpan(
            text: value,
            style:AppTypography.caption.copyWith(
                fontWeight: .bold
            ),
          ),
        ],
      ),
    );
  }
}