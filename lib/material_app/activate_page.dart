import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:graduation_project/material_app/login_page.dart';
import 'package:graduation_project/services/firebase/user_auth.dart';
import 'package:provider/provider.dart';

class ActivatePage extends StatelessWidget {
  const ActivatePage({super.key});

  static const String routeName = 'Login Page';
  static final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final UserAuth auth = Provider.of<UserAuth>(context);
    String? email;

    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: ActivatePage._formKey,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                90.verticalSpace,
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
                40.verticalSpace,
                const Text(
                  'enterEmailToResetPassword',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ).tr(),
                40.verticalSpace,
                TextFormField(
                  autofocus: true,
                  keyboardType: TextInputType.emailAddress,
                  onSaved: (newValue) => email = '$newValue',
                  decoration: InputDecoration(
                    helperText: 'emailHelper'.tr(),
                    hintText: 'email'.tr(),
                  ),
                ),
                20.verticalSpace,
                Container(
                  width: 250,
                  height: 50,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.fromRGBO(255, 48, 48, 1),
                        Color.fromRGBO(255, 197, 95, 1),
                        Color.fromRGBO(86, 255, 184, 1),
                      ],
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(30),
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      ActivatePage._formKey.currentState?.save();
                      await auth.resetPassword(email);
                      if (auth.errorMessage != '') {
                        Fluttertoast.showToast(
                          msg: auth.errorMessage,
                          toastLength: Toast.LENGTH_LONG,
                        );
                        auth.setMessage = '';
                      } else {
                        Fluttertoast.showToast(
                          msg: 'Set password email has been sent to your email',
                          toastLength: Toast.LENGTH_LONG,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      splashFactory: NoSplash.splashFactory,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'activate',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ).tr(),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('haveYouActivated?').tr(),
                    TextButton(
                      onPressed: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                        Navigator.pushReplacementNamed(
                            context, LoginPage.routeName);
                      },
                      style: const ButtonStyle(
                        overlayColor:
                            MaterialStatePropertyAll(Colors.transparent),
                      ),
                      child: Text(
                        'login',
                        style: TextStyle(
                          color: Colors.blue[400],
                        ),
                      ).tr(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
