import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:adoptandlove/authentication/authentication_manager.dart';
import 'package:adoptandlove/localization/app_localization.dart';
import 'package:adoptandlove/widgets/getpet_network_image.dart';

class UserProfileComponent extends StatelessWidget {
  final User user;

  UserProfileComponent({this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 128,
              height: 128,
              child: getUserProfilePhotoProvider(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            user.displayName ?? user.email ?? user.phoneNumber,
            style: TextStyle(
              fontSize: 30,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.bold,
                ),
                text: AppLocalizations.of(context).logout,
                recognizer: TapGestureRecognizer()..onTap = _logout),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: FractionallySizedBox(
              widthFactor: 0.4,
              child: Image.asset("assets/two_logos.png"),
            ),
          ),
        ),
      ],
    );
  }

  Widget getUserProfilePhotoProvider() {
    final anonymousAssetImagePath = "assets/anonymous_avatar.png";

    if (user.photoURL != null) {
      var photoUrl = user.photoURL.replaceFirst("/s96-c/", "/s300-c/");
      photoUrl += "?height=300";

      return GetPetNetworkImage(
        url: photoUrl,
        useDiskCache: true,
        color: Colors.white,
        fallbackAssetImage: anonymousAssetImagePath,
      );
    }

    return Image.asset(anonymousAssetImagePath);
  }

  _logout() async {
    await AuthenticationManager().logout();
  }
}
