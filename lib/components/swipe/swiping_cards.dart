import 'package:flutter/material.dart';
import 'package:adoptandlove/analytics/analytics.dart';
import 'package:adoptandlove/components/swipe/pet_engine.dart';
import 'package:adoptandlove/localization/app_localization.dart';
import 'package:adoptandlove/pets.dart';
import 'package:adoptandlove/pets_service.dart';
import 'package:adoptandlove/routes.dart';
import 'package:adoptandlove/widgets/empty_state.dart';

import 'draggable_card.dart';
import 'pet_card.dart';

// Adapter from https://github.com/SpokenBanana/pawdoption/blob/master/lib/widgets/swiping_cards.dart
class SwipingCards extends StatefulWidget {
  final PetEngine engine;

  const SwipingCards({Key key, this.engine}) : super(key: key);

  @override
  _SwipingCardsState createState() => _SwipingCardsState();
}

class _SwipingCardsState extends State<SwipingCards>
    with AutomaticKeepAliveClientMixin<SwipingCards> {
  @override
  bool get wantKeepAlive => true;

  double _backCardScale = 0.9;

  final petsService = PetsService();

  @override
  void initState() {
    super.initState();
    widget.engine.notifier.addListener(_onSwipeChange);
  }

  _onSwipeChange() {
    if (widget.engine.notifier.swiped == Swiped.undo) {
      setState(() {
        widget.engine.getRecentlySkipped();
      });
    }
  }

  @override
  void dispose() {
    widget.engine.notifier.removeListener(_onSwipeChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (widget.engine.currentList.isEmpty) {
      return EmptyStateWidget(
        assetImage: "assets/no_pets.png",
        emptyText: AppLocalizations.of(context).noMorePetsToSwipe,
      );
    }
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        widget.engine.nextPet == null
            ? SizedBox()
            : Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..scale(_backCardScale, _backCardScale),
                child: PetCard(pet: widget.engine.nextPet),
              ),
        DraggableCard(
          onLeftSwipe: () {
            setState(() {
              var pet = widget.engine.currentPet;
              widget.engine.skip(widget.engine.currentPet);
              petsService.dislikePet(pet);

              widget.engine.removeCurrentPet();
            });
          },
          onRightSwipe: () {
            setState(() {
              var pet = widget.engine.currentPet;
              if (!widget.engine.liked.contains(pet)) {
                widget.engine.liked.add(pet);

                petsService.likePet(pet);
              }
              widget.engine.removeCurrentPet();
            });
          },
          onSwipe: (Offset offset) {
            setState(() {
              _backCardScale =
                  0.9 + (0.1 * (offset.distance / 150)).clamp(0.0, 0.1);
            });
          },
          notifier: widget.engine.notifier,
          onTap: () async {
            final pet = widget.engine.currentPet;

            Analytics().logPetProfileOpenedWhileSwiping(pet);

            final res = await Navigator.pushNamed(
              context,
              Routes.ROUTE_PET_PROFILE,
              arguments: pet,
            );

            if (res == PetDecision.like) {
              widget.engine.notifier.likeCurrent();
            } else if (res == PetDecision.dislike) {
              widget.engine.notifier.skipCurrent();
            }
          },
          child: PetCard(
            pet: widget.engine.currentPet,
          ),
        ),
      ],
    );
  }
}
