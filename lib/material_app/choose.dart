import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../guest_view/main_scaffold/main_scaffold.dart';
import 'login_page.dart';

class Choose extends StatelessWidget {
  const Choose({super.key});

  static const String routeName = 'Choose Page';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              SvgPicture.asset(
                'assets/images/logo.svg',
                width: 200,
              ),
              15.verticalSpace,
              const Text(
                'GradPro',
                style: TextStyle(
                  fontFamily: 'Bruno Ace SC',
                  fontSize: 40,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, LoginPage.routeName);
                },
                child: Container(
                  width: 180,
                  height: 200,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF8888),
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SvgPicture.asset(
                        'assets/images/login.svg',
                        width: 80,
                        colorFilter: const ColorFilter.mode(
                            Colors.black, BlendMode.srcIn),
                      ),
                      Text(
                        'login',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ).tr(),
                    ],
                  ),
                ),
              ),
              10.horizontalSpace,
              InkWell(
                onTap: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, GuestMainScaffold.routeName, (route) => false);
                },
                child: Container(
                  width: 180,
                  height: 200,
                  decoration: const BoxDecoration(
                    color: Color(0xFF88A9FF),
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SvgPicture.asset(
                        'assets/images/guest.svg',
                        width: 85,
                      ),
                      Text(
                        'guest',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ).tr(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
