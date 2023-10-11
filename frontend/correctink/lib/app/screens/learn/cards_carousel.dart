import 'package:carousel_slider/carousel_slider.dart';
import 'package:correctink/widgets/learn_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../utils/sorting_helper.dart';
import '../../../utils/utils.dart';
import '../../../widgets/widgets.dart';
import '../../data/models/schemas.dart';
import '../../data/repositories/realm_services.dart';
import '../../services/theme.dart';

class CardsCarouselPage extends StatefulWidget{
  const CardsCarouselPage(this.setId, this.startIndex, {Key? key}) : super(key: key);
  final String setId;
  final int startIndex;

  @override
  State<StatefulWidget> createState() => _CardsCarouselPage();
}

class _CardsCarouselPage extends State<CardsCarouselPage>{
  int currentCardIndex = 0;
  int totalCount = 0;
  bool flipped = false;
  late RealmServices realmServices;
  late List<KeyValueCard> cards = <KeyValueCard>[];
  late CardSet? set;
  final carouselController = CarouselController();

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if(cards.isEmpty){
      realmServices = Provider.of<RealmServices>(context);
      set = realmServices.setCollection.get(widget.setId);

      var tempCards = set!.cards.toList();
      // the cards must be sorted the same way as in the set page since the index is used
      tempCards.sort((c1, c2) => SortingHelper.compareCards(c1, c2));
      cards = tempCards;
      currentCardIndex = widget.startIndex;
      totalCount = cards.length;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            constraints: BoxConstraints(minHeight: Utils.isOnPhone() ? 80 : 60),
            child: Material(
              elevation: 1,
              child: Container(
                color: set!.color == null ? Theme.of(context).colorScheme.surface : HexColor.fromHex(set!.color!).withAlpha(40),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 0, 5.0, 0),
                  child: SafeArea(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.navigate_before)),
                        ),
                        Flexible(child: Text(set!.name, style: listTitleTextStyle(),),),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: CallbackShortcuts(
              bindings: <ShortcutActivator, VoidCallback>{
                const SingleActivator(LogicalKeyboardKey.arrowRight): () {
                  carouselController.nextPage();
                },
                const SingleActivator(LogicalKeyboardKey.arrowLeft): () {
                  carouselController.previousPage();
                },
              },
              child: Focus(
                child: Column(
                  children: [
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraint) {
                          double width = constraint.maxWidth * 0.8;
                          double height = constraint.maxHeight * 0.8;
                          return CarouselSlider.builder(
                            itemCount: cards.length,
                            itemBuilder: (BuildContext context, int index, int realIndex) {
                              return AutoFlipCard(
                                color: set!.color == null ? Theme.of(context).colorScheme.surfaceVariant : HexColor.fromHex(set!.color!),
                                containerWidth: width,
                                containerHeight: height,
                                top: cards[index].front,
                                bottom: cards[index].back,
                                border: index == currentCardIndex,
                              );
                            },
                            options: CarouselOptions(
                                initialPage: widget.startIndex,
                                enlargeCenterPage: true,
                                enlargeFactor: 0.2,
                                aspectRatio: width / height,
                                enableInfiniteScroll: false,
                                onPageChanged: (index, event) {
                                  setState(() {
                                    currentCardIndex = index;
                                  });
                                }
                            ),
                            carouselController: carouselController,
                          );
                        }
                      ),
                    ),
                    AnimatedSmoothIndicator(
                        activeIndex: currentCardIndex,
                        count: cards.length,
                      onDotClicked: (index) {
                          carouselController.animateToPage(index);
                      },
                      effect: ScrollingDotsEffect(
                            dotHeight: 14,
                            dotWidth: 14,
                            radius: 7,
                            maxVisibleDots: 5,
                            dotColor: set!.color == null ? Theme.of(context).colorScheme.surfaceVariant : HexColor.fromHex(set!.color!).withAlpha(80),
                            activeDotColor: set!.color == null ? Theme.of(context).colorScheme.secondary : HexColor.fromHex(set!.color!)
                      )
                    ),
                    const SizedBox(height: 18,),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}