import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:adoptandlove/components/pet_favorites/favorites_component.dart';
import 'package:adoptandlove/components/swipe/pet_swipe_component.dart';
import 'package:adoptandlove/components/user_profile/user_login_component.dart';
import 'package:adoptandlove/localization/app_localization.dart';
import 'package:adoptandlove/pets_service.dart';
import 'package:adoptandlove/preferences/app_preferences.dart';
import 'package:adoptandlove/routes.dart';
import 'package:adoptandlove/widgets/getpet_app_bar_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeComponent extends StatelessWidget {
  final AsyncMemoizer _memoizer = AsyncMemoizer();

  @override
  Widget build(BuildContext context) {
    final controller = DefaultTabController(
      length: 3,
      initialIndex: 1,
      child: Scaffold(
        appBar: AppBar(
          title: const GetPetAppBarTitleImage(),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.help_outline),
              tooltip: AppLocalizations.of(context).userGuide,
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  Routes.ROUTE_ONBOARDING,
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.settings),
              tooltip: AppLocalizations.of(context).preferences,
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  Routes.ROUTE_PREFERENCES,
                );
              },
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.assignment_ind)),
              Tab(
                icon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    "assets/ic_home.png",
                    color: Colors.white70,
                  ),
                ),
              ),
              Tab(icon: Icon(Icons.favorite)),
            ],
          ),
        ),
        body: Stack(
          children: <Widget>[
            FutureBuilder(
              future: _updatePetProfiles(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasError) {
                  print("Error updating pet profiles: ${snapshot.error}");
                }
                return SizedBox();
              },
            ),
            TabBarView(
              physics: NeverScrollableScrollPhysics(),
              children: [
                UserLoginOrProfileComponent(),
                PetSwipeComponent(),
                FavoritePetsComponent(),
              ],
            ),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(milliseconds: 500), () async {
      final isOnboardingPassed = await AppPreferences().isOnboardingPassed();

      if (!isOnboardingPassed) {
        await AppPreferences().setOnboardingPassed();
        Navigator.pushNamed(
          context,
          Routes.ROUTE_ONBOARDING,
        );
      }
    });

    return controller;
  }

  _updatePetProfiles() async {
    return this._memoizer.runOnce(() async {
      return await PetsService().updatePetProfiles();
    });
  }
}
