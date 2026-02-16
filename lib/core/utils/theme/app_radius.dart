import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppRadius {
  static BorderRadius r4 = BorderRadius.circular(4.r);
  static BorderRadius r8 = BorderRadius.circular(8.r);
  static BorderRadius r10 = BorderRadius.circular(10.r);
  static BorderRadius r12 = BorderRadius.circular(12.r);
  static BorderRadius r14 = BorderRadius.circular(14.r);
  static BorderRadius r16 = BorderRadius.circular(16.r);
  static BorderRadius r20 = BorderRadius.circular(20.r);
  static BorderRadius r22 = BorderRadius.circular(22.r);
  static BorderRadius r24 = BorderRadius.circular(24.r);
  static BorderRadius r32 = BorderRadius.circular(32.r);
  static BorderRadius r30 = BorderRadius.circular(30.r);
  static BorderRadius r40 = BorderRadius.circular(40.r);
  static BorderRadius r50 = BorderRadius.circular(50.r);
  static BorderRadius r100 = BorderRadius.circular(100.r);

  static BorderRadius onlyBL32 = BorderRadius.only(
    bottomLeft: Radius.circular(32.r),
  );

  static BorderRadius onlyBR32 = BorderRadius.only(
    bottomRight: Radius.circular(32.r),
  );

  static BorderRadius onlyTL32 = BorderRadius.only(
    topLeft: Radius.circular(32.r),
  );

  static BorderRadius onlyTR32 = BorderRadius.only(
    topRight: Radius.circular(32.r),
  );

  static BorderRadius bottom32 = BorderRadius.only(
    bottomLeft: Radius.circular(32.r),
    bottomRight: Radius.circular(32.r),
  );
  static BorderRadius top20 = BorderRadius.only(
    topLeft: Radius.circular(20.r),
    topRight: Radius.circular(20.r),
  );

}