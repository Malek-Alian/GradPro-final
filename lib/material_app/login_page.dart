import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:graduation_project/material_app/activate_page.dart';
import 'package:provider/provider.dart';

import '../components/wrapper.dart';
import '../services/firebase/user_auth.dart';
import '../services/firebase/users_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  static const String routeName = 'Active Page';
  static final _formKey = GlobalKey<FormState>();

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    final UserAuth auth = Provider.of<UserAuth>(context);
    final UsersFirestore userFirestore = Provider.of<UsersFirestore>(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: LoginPage._formKey,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                80.verticalSpace,
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
                50.verticalSpace,
                TextFormField(
                  autofocus: true,
                  keyboardType: TextInputType.emailAddress,
                  onSaved: (newValue) => auth.setUserEmail = newValue,
                  decoration: InputDecoration(
                    helperText: 'emailHelper'.tr(),
                    hintText: 'email'.tr(),
                  ),
                ),
                5.verticalSpace,
                TextFormField(
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: true,
                  onSaved: (newValue) => auth.setUserPassword = newValue,
                  decoration: InputDecoration(
                    hintText: 'password'.tr(),
                  ),
                ),
                30.verticalSpace,
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
                      LoginPage._formKey.currentState?.save();
                      User? user = await auth.activate;
                      if (user != null) {
                        if (user.email?.contains('std') ?? false) {
                          await userFirestore.updateStudentData(
                              registered: true, token: '');
                        } else {
                          await userFirestore.updateInstructorData(
                              registered: true, token: '');
                        }
                        if (mounted) {
                          await Navigator.pushNamedAndRemoveUntil(
                              context, Wrapper.routeName, (route) => false);
                        }
                        setState(() {});
                      } else {
                        Fluttertoast.showToast(
                          msg: auth.errorMessage,
                          toastLength: Toast.LENGTH_LONG,
                        );
                        auth.setMessage = '';
                      }
                      if (mounted) {
                        FocusScope.of(context).requestFocus(FocusNode());
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
                      'login',
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
                    const Text('haventYouActivated?').tr(),
                    TextButton(
                      onPressed: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                        Navigator.pushReplacementNamed(
                            context, ActivatePage.routeName);
                      },
                      style: const ButtonStyle(
                        overlayColor:
                            MaterialStatePropertyAll(Colors.transparent),
                      ),
                      child: Text(
                        'activate',
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
