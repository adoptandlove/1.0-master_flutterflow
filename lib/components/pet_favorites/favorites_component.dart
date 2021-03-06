import 'package:flutter/material.dart';
import 'package:adoptandlove/localization/app_localization.dart';
import 'package:adoptandlove/pets.dart';
import 'package:adoptandlove/pets_service.dart';
import 'package:adoptandlove/routes.dart';
import 'package:adoptandlove/utils/image_utils.dart';
import 'package:adoptandlove/utils/screen_utils.dart';
import 'package:adoptandlove/widgets/empty_state.dart';
import 'package:adoptandlove/widgets/getpet_network_image.dart';
import 'package:adoptandlove/widgets/label.dart';
import 'package:adoptandlove/widgets/progress_indicator.dart';
import 'dart:developer' as developer;

class FavoritePetsComponent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Pet>>(
        stream: PetsService().getFavoritePets(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            developer.log("Error loading favorite pets", error: snapshot.error);
          }

          if (snapshot.hasData) {
            var pets = snapshot.data;

            if (pets.isNotEmpty) {
              return ListViewFavoritePets(
                pets: pets,
              );
            } else {
              return EmptyStateWidget(
                assetImage: "assets/no_pets.png",
                emptyText: AppLocalizations.of(context).emptyFavoritesList,
              );
            }
          } else {
            return Center(
              child: AppProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

class ListViewFavoritePets extends StatelessWidget {
  final List<Pet> pets;

  ListViewFavoritePets({Key key, this.pets}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<dynamic> cells = [];

    var shelterPets =
        pets.where((pet) => pet.decision == PetDecision.getPet).toList();
    var favoritePets =
        pets.where((pet) => pet.decision == PetDecision.like).toList();
    if (shelterPets.isNotEmpty) {
      cells.add(LabelItem(AppLocalizations.of(context).myGetPetRequests));
      cells.addAll(shelterPets);
    }

    if (favoritePets.isNotEmpty) {
      cells.add(LabelItem(AppLocalizations.of(context).myFavoritePets));
      cells.addAll(favoritePets);
    }

    return ListView.builder(
      itemCount: cells.length,
      padding: const EdgeInsets.all(15.0),
      itemBuilder: (context, position) {
        final cell = cells[position];

        if (cell is Pet) {
          return _PetListCell(key: Key("_PetListCell: ${cell.id}"), pet: cell);
        } else if (cell is LabelItem) {
          return Label(text: cell.text);
        }

        throw UnsupportedError(
            "Unable to build favorite pets with passed cell type");
      },
    );
  }
}

class _PetListCell extends StatelessWidget {
  final Pet pet;

  const _PetListCell({Key key, @required this.pet})
      : assert(pet != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageSize = convertLogicalPixelsToPixels(context, 72);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () => _onTapItem(context, pet),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: ClipOval(
                child: Container(
                  width: 72,
                  height: 72,
                  color: Theme.of(context).primaryColor,
                  child: GetPetNetworkImage(
                    url: getSizedImageUrl(
                      pet.profilePhoto,
                      imageSize,
                      height: imageSize,
                    ),
                    showLoadingIndicator: false,
                    useDiskCache: true,
                  ),
                ),
              ),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
                      child: Text(
                        pet.name,
                        style: TextStyle(
                          fontSize: 22.0,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      pet.shortDescription,
                      style: new TextStyle(
                        fontSize: 18.0,
                      ),
                      maxLines: 2,
                      softWrap: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onTapItem(BuildContext context, Pet pet) {
    Navigator.pushNamed(context, Routes.ROUTE_PET_PROFILE, arguments: pet);
  }
}
