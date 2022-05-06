import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:adoptandlove/localization/app_localization.dart';
import 'package:url_launcher/url_launcher.dart';

class ConditionsRichText extends StatelessWidget {
  static const _FAIR_USE_RULES_URL =
      "https://adoptandlove.eu/felhasznalasiszabalyzat/";
  static const _PRIVACY_POLICY_URL =
      'https://adoptandlove.eu/gdpr';

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(children: [
        TextSpan(
          text: "${AppLocalizations.of(context).loginConditionsDescription}\n",
        ),
        TextSpan(
          style: TextStyle(
            decoration: TextDecoration.underline,
            fontWeight: FontWeight.bold,
          ),
          text: AppLocalizations.of(context).privacyPolicy,
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              if (await canLaunch(_PRIVACY_POLICY_URL)) {
                await launch(_PRIVACY_POLICY_URL);
              }
            },
        ),
        TextSpan(text: " ${AppLocalizations.of(context).and} "),
        TextSpan(
          style: TextStyle(
            decoration: TextDecoration.underline,
            fontWeight: FontWeight.bold,
          ),
          text: AppLocalizations.of(context).fairUseRules,
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              if (await canLaunch(_FAIR_USE_RULES_URL)) {
                await launch(_FAIR_USE_RULES_URL);
              }
            },
        ),
      ]),
    );
  }
}
