import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project/services/firebase/users_firestore.dart';
import 'package:provider/provider.dart';

import '../components/routes.dart';
import '../components/wrapper.dart';
import '../services/theme/app_theme.dart';
import '../services/theme/change_theme.dart';

class TheMaterialApp extends StatelessWidget {
  const TheMaterialApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ChangeTheme theme = Provider.of(context);
    final UsersFirestore users = Provider.of<UsersFirestore>(context);
    theme.updateSharedTheme();

    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (BuildContext context, Widget? child) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: MaterialApp(
            title: 'GPMS',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.appTheme(theme.isDark, context),
            routes: AppRoutes.routes,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            // home: Scaffold(
            //   body: Center(
            //     child: Column(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       children: [
            //         ElevatedButton(
            //           onPressed: () {
            //             users.addStudent();
            //           },
            //           child: const Text('Student'),
            //         ),
            //         ElevatedButton(
            //           onPressed: () {},
            //           child: const Text('Student'),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            home: const Wrapper(),
          ),
        );
      },
    );
  }
}
