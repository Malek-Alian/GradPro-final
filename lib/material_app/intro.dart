import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

import 'choose.dart';

class AppIntro extends StatefulWidget {
  const AppIntro({super.key});

  @override
  State<AppIntro> createState() => _AppIntroState();
}

class _AppIntroState extends State<AppIntro> {
  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Positioned(
              top: 75,
              left: 38,
              child: Container(
                width: 334,
                height: 334,
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(47, 47, 47, 1),
                  borderRadius: BorderRadius.all(
                    Radius.circular(334),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 121,
              left: 84,
              child: Container(
                width: 242,
                height: 242,
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(255, 255, 255, 1),
                  borderRadius: BorderRadius.all(
                    Radius.circular(242),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 65,
              left: 25,
              child: SizedBox(
                width: 350,
                height: 350,
                child: SvgPicture.asset('assets/images/intro_images/girl.svg'),
              ),
            ),
            Positioned(
              top: 100,
              left: 250,
              child: Transform.rotate(
                angle: 0.3,
                child: SizedBox(
                  width: 75,
                  height: 75,
                  child:
                      SvgPicture.asset('assets/images/intro_images/book.svg'),
                ),
              ),
            ),
            Positioned(
              top: 57,
              left: -39,
              child: Container(
                width: 78,
                height: 78,
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(211, 47, 47, 1),
                  borderRadius: BorderRadius.all(
                    Radius.circular(78),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 401,
              left: 121,
              child: Container(
                width: 15,
                height: 15,
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(217, 217, 217, 1),
                  borderRadius: BorderRadius.all(
                    Radius.circular(15),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 216,
              left: 59,
              child: Container(
                width: 15,
                height: 15,
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(211, 47, 47, 1),
                  borderRadius: BorderRadius.all(
                    Radius.circular(15),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 187,
              left: 353,
              child: Container(
                width: 15,
                height: 15,
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(217, 217, 217, 1),
                  borderRadius: BorderRadius.all(
                    Radius.circular(15),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 363,
              left: 361,
              child: Container(
                width: 78,
                height: 78,
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(211, 47, 47, 1),
                  borderRadius: BorderRadius.all(
                    Radius.circular(78),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 499,
              left: 22,
              child: Row(
                children: [
                  GradientText(
                    'manage'.tr(),
                    style: GoogleFonts.poppins(
                      fontSize: 42,
                      fontWeight: FontWeight.w600,
                    ),
                    colors: const [
                      Color(0xFF74FFC5),
                      Color(0xFFFF5757),
                    ],
                  ),
                  Localizations.localeOf(context).languageCode == 'en'
                      ? Text(
                          'Your',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : Text(
                          'مهام',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ],
              ),
            ),
            Positioned(
              top: 561,
              left: 22,
              child: Row(
                children: [
                  Localizations.localeOf(context).languageCode == 'en'
                      ? const Text(
                          'Project ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : Container(),
                  Localizations.localeOf(context).languageCode == 'en'
                      ? GradientText(
                          'Tasks',
                          style: const TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w600,
                          ),
                          colors: const [
                            Color(0xFF74FFC5),
                            Color(0xFFFF5757),
                          ],
                        )
                      : GradientText(
                          'مشروعك',
                          style: const TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w600,
                          ),
                          colors: const [
                            Color(0xFF74FFC5),
                            Color(0xFFFF5757),
                          ],
                        ),
                ],
              ),
            ),
            Positioned(
              top: 618,
              left: 22,
              child: Text(
                'findTeam',
                style: GoogleFonts.poppins(
                  color: const Color.fromRGBO(255, 255, 255, 0.7),
                  fontSize: 15,
                ),
              ).tr(),
            ),
          ],
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(23.0),
          child: SizedBox(
            width: 85,
            height: 85,
            child: FloatingActionButton(
              shape: const CircleBorder(),
              backgroundColor: Colors.white,
              child: Localizations.localeOf(context).languageCode == 'en'
                  ? SvgPicture.asset(
                      'assets/images/intro_images/forward.svg',
                      width: 60,
                    )
                  : RotatedBox(
                      quarterTurns: 2,
                      child: SvgPicture.asset(
                        'assets/images/intro_images/forward.svg',
                        width: 60,
                      ),
                    ),
              onPressed: () {
                Navigator.pushNamed(context, Choose.routeName);
              },
            ),
          ),
        ),
      ),
    );
  }
}
