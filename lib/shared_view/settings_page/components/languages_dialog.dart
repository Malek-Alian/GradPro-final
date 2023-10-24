import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

class LanguagesDialog extends StatelessWidget {
  const LanguagesDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'selectLanguage',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        textAlign: TextAlign.center,
      ).tr(),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              if (Localizations.localeOf(context).languageCode == 'en') {
                context.setLocale(const Locale('ar', 'JO'));
                Phoenix.rebirth(context);
              }
              Navigator.pop(context);
            },
            child: const Text('العربية', style: TextStyle(fontSize: 18)),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              if (Localizations.localeOf(context).languageCode == 'ar') {
                context.setLocale(const Locale('en', 'US'));
                Phoenix.rebirth(context);
              }
              Navigator.pop(context);
            },
            child: const Text('English', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }
}
