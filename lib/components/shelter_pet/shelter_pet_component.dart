import 'package:flutter/material.dart';
import 'package:adoptandlove/analytics/analytics.dart';
import 'package:adoptandlove/components/swipe/pet_card.dart';
import 'package:adoptandlove/localization/app_localization.dart';
import 'package:adoptandlove/pets.dart';
import 'package:adoptandlove/pets_service.dart';
import 'package:adoptandlove/utils/image_utils.dart';
import 'package:adoptandlove/utils/screen_utils.dart';
import 'package:adoptandlove/widgets/getpet_app_bar_image.dart';
import 'package:adoptandlove/widgets/getpet_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

class ShelterPetComponent extends StatelessWidget {
  final Pet pet;

  const ShelterPetComponent({
    Key key,
    @required this.pet,
  })  : assert(pet != null),
        super(key: key);

  Future callShelter(BuildContext context) async {
    var url = 'tel:${pet.shelter.phone}';
    if (await canLaunch(url)) {
      await Analytics().logShelterCall(pet);

      return await launch(url);
    } else {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).errorUnableToCallShelter,
          ),
        ),
      );
    }
  }

  Future emailShelter(BuildContext context) async {
    var url = 'mailto:${pet.shelter.email}';
    if (await canLaunch(url)) {
      await Analytics().logShelterEmail(pet);
      await launch(url);
    } else {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).errorUnableToEmailShelter,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    PetsService().shelterPet(pet);

    final screenWidth = getScreenWidth(context);
    final imageUrl = getSizedImageUrl(
      pet.profilePhoto,
      screenWidth,
      ceilToHundreds: true,
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 300,
            title: const GetPetAppBarTitleImage(),
            centerTitle: true,
            pinned: true,
            primary: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Hero(
                    tag: "pet-${pet.id}-photo-image-cover",
                    child: GetPetNetworkImage(
                      url: imageUrl,
                      color: Colors.white,
                    ),
                  ),
                  PetCardInformation(
                    pet: pet,
                    iconData: null,
                  ),
                ],
              ),
            ),
          ),
          SliverFillRemaining(
            fillOverscroll: true,
            hasScrollBody: false,
            child: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          pet.shelter.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            AppLocalizations.of(context).pushAndContact,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          child: Text(
                            pet.shelter.phone,
                            style: TextStyle(
                              fontSize: 16,
                              decoration: TextDecoration.underline,
                              color: Colors.lightBlue,
                            ),
                          ),
                        ),
                        onTap: () async {
                          await callShelter(context);
                        },
                      ),
                      InkWell(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          child: Text(
                            pet.shelter.email,
                            style: TextStyle(
                              fontSize: 16,
                              decoration: TextDecoration.underline,
                              color: Colors.lightBlueAccent,
                            ),
                          ),
                        ),
                        onTap: () async {
                          await emailShelter(context);
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: 72,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.phone_in_talk),
        label: Text(AppLocalizations.of(context).callShelter),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        onPressed: () async {
          await callShelter(context);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,


    );
  }
}
