import 'dart:io';

import 'package:correctink/app/data/models/schemas.dart';
import 'package:correctink/blocs/sets/card_exist_dialog.dart';
import 'package:correctink/blocs/sets/set_picker_dialog.dart';
import 'package:correctink/utils/learn_utils.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';
import 'package:objectid/objectid.dart';
import 'package:path_provider/path_provider.dart';

import '../app/data/repositories/realm_services.dart';
import '../widgets/snackbars_widgets.dart';

class CardHelper {
  static void addCard(BuildContext context, {required RealmServices realmServices, required KeyValueCard card, required CardSet set}) {
    int index = set.cards.toList().indexWhere((c) => c.front.toLowerCase().trim() == card.front.toLowerCase().trim());

    if(index != -1) { // there already exist a card with the same front
      KeyValueCard foundCard = set.cards.toList()[index];
      String backAdded = _findDifference(foundCard.back, card.back, foundCard.allowBackMultipleValues, card.allowBackMultipleValues);
      bool sameBack = backAdded == '';

      showDialog(context: context,
          useRootNavigator: true,
          builder: (context) {
            return CardExistDialog(card: foundCard, backAlreadyExists: sameBack, originalBack: card.back, newBack: backAdded,
                onConfirm: (choice) {
                  if(choice == CardExistChoice.create) {
                    realmServices.setCollection.addCard(set, card.front, card.back, card.allowFrontMultipleValues, card.allowBackMultipleValues);
                  } else if(choice == CardExistChoice.addBackToExistingCard){
                    realmServices.cardCollection.update(foundCard, foundCard.front, '${foundCard.back}$backAdded', foundCard.allowFrontMultipleValues, true);
                  }
                }
            );
        }
      );
    } else {
      realmServices.setCollection.addCard(set, card.front, card.back, card.allowFrontMultipleValues, card.allowBackMultipleValues);
    }
  }

  static Future<(bool?, CardExistChoice, bool)> addCardAsync(BuildContext context, {required RealmServices realmServices, required KeyValueCard card, required CardSet set, required bool? rememberChoice, required CardExistChoice choice}) async {
    int index = set.cards.toList().indexWhere((c) => c.front.toLowerCase().trim() == card.front.toLowerCase().trim());
    bool created = false;

    if(index != -1) { // there already exist a card with the same front
      KeyValueCard foundCard = set.cards.toList()[index];
      String backAdded = _findDifference(foundCard.back, card.back, foundCard.allowBackMultipleValues, card.allowBackMultipleValues);
      bool sameBack = backAdded == '';

      if(rememberChoice != null && rememberChoice) {
        if(choice == CardExistChoice.create) {
          realmServices.setCollection.addCard(set, card.front, card.back, card.allowFrontMultipleValues, card.allowBackMultipleValues);
          created = true;
        } else if(choice == CardExistChoice.addBackToExistingCard){
          realmServices.cardCollection.update(foundCard, foundCard.front, '${foundCard.back}$backAdded', foundCard.allowFrontMultipleValues, true);
        }
      } else {
        await showDialog(context: context,
            builder: (context) {
              return CardExistDialog(card: foundCard, backAlreadyExists: sameBack, originalBack: card.back, newBack: backAdded,
                  onConfirm: (currentChoice) {
                    choice = currentChoice;
                    if(choice == CardExistChoice.create) {
                      realmServices.setCollection.addCard(set, card.front, card.back, card.allowFrontMultipleValues, card.allowBackMultipleValues);
                      created = true;
                    } else if(choice == CardExistChoice.addBackToExistingCard){
                      realmServices.cardCollection.update(foundCard, foundCard.front, '${foundCard.back}$backAdded', foundCard.allowFrontMultipleValues, true);
                    }
                  },
                  rememberChoice: rememberChoice,
                  onRememberChoiceChange: (value) {rememberChoice = value;},
              );
            }
        );
      }
    } else {
      realmServices.setCollection.addCard(set, card.front, card.back, card.allowFrontMultipleValues, card.allowBackMultipleValues);
      created = true;
    }
    return (rememberChoice, choice, created);
  }

  static Future<int> addCards(BuildContext context, {required RealmServices realmServices, required List<KeyValueCard> cards, required CardSet set}) async {
    bool rememberChoice = false;
    CardExistChoice choice = CardExistChoice.create;
    int addedCount = 0;

    for (KeyValueCard card in cards) {
      if(context.mounted) {
        bool created = false;
        (rememberChoice!, choice, created) = await CardHelper.addCardAsync(context,
            realmServices: realmServices, card: card, set: set,
            rememberChoice: rememberChoice, choice: choice
        );
        if(created) {
          addedCount++;
        }
      } else {
        realmServices.setCollection.addCard(set, card.front, card.back, true, true);
        addedCount++;
      }
    }
    return addedCount;
  }

  static String _findDifference(String card1, String card2, bool allowMultipleValues1, bool allowMultipleValues2) {
    bool multipleValues1;
    String separator1;
    bool multipleValues2;
    String separator2;

    (multipleValues1, separator1) = LearnUtils.hasMultipleValues(card1);
    (multipleValues2, separator2) = LearnUtils.hasMultipleValues(card2);

    if((multipleValues1 && allowMultipleValues1)|| (multipleValues2 && allowMultipleValues2)) {

      // the user choice is more important
      multipleValues1 = allowMultipleValues1;
      multipleValues2 = allowMultipleValues2;

      List<String> values1 = multipleValues1 ? card1.split(separator1) : [card1];
      List<String> values2 = multipleValues2 ? card2.split(separator2) : [card2];
      String separator = separator1;

      if(!multipleValues1) {
        if(multipleValues2) {
          separator = separator2;
        } else {
          bool containComa = card1.contains(",") || card2.contains(",");
          separator = card1.split(' ').length > 4 || containComa ? " ${LearnUtils.secondaryValuesSeparator}" : LearnUtils.multipleValuesSeparator;
        }
      }

      String differences = "";
      for(int i = 0; i < values2.length; i++) {
        String value2 = values2[i];
        bool found = false;
        for(String value1 in values1) {
          if(value1.toLowerCase().trim() == value2.toLowerCase().trim()) {
            found = true;
            break;
          }
        }

        if(!found) {
          differences += '$separator ${values2[i].trim()}';
        }
      }
      return differences;
    } else {
      bool containComa = card1.contains(",") || card2.contains(",");
      String separator = card1.split(' ').length > 4 || containComa ? " ${LearnUtils.secondaryValuesSeparator}" : LearnUtils.multipleValuesSeparator;
      return card1.toLowerCase().trim() == card2.toLowerCase().trim() ? "" : "$separator $card2";
    }
  }

  static Future<String> exportToCsv(List<KeyValueCard> cards, String filename, {String? directory}) async {
    List<List<dynamic>> rows = [];
    rows.add(["Exported from Correctink."]);
    rows.add(["Front".i18n(), "Back".i18n()]);

    for (var card in cards) {
      rows.add([card.front, card.back]);
    }

    String csv = const ListToCsvConverter().convert(rows);

    String dirPath = "";
    if(directory == null) {
      Directory? dir = await getDownloadsDirectory();
      dir ??= await getApplicationDocumentsDirectory();
      dirPath = dir.path;
    } else {
      dirPath = directory;
    }

    String filePath = "$dirPath/$filename.csv";

    File file = File(filePath);
    await file.writeAsString(csv);

    return filePath;
  }

  static Future<List<KeyValueCard>> importFromCSV(String filePath) async {
    File file = File(filePath);
    String fileData = await file.readAsString();
    final parsedData = const CsvToListConverter().convert(fileData);

    int i = 0;

    if(parsedData.isNotEmpty && parsedData[0][0] == "Exported from Correctink.") {
        i = 2;  // skip first key/value pair if it's the header of an exported set from CorrectInk
    }

    List<KeyValueCard> cards = [];
    while(i < parsedData.length) {
      if(parsedData[i][0].toString().isNotEmpty || parsedData[i][1].toString().isNotEmpty) {
        KeyValueCard card = KeyValueCard(ObjectId(), parsedData[i][0], parsedData[i][1]);
        cards.add(card);
      }
      i++;
    }

    return cards;
  }

  static void importCards({required BuildContext context, required RealmServices realmServices, required CardSet set}) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      dialogTitle: "Import cards to".i18n([set.name]),
      type: FileType.custom,
      allowedExtensions: [
        'csv',
      ],
    );

    if (result != null) {
      try {
        List<KeyValueCard> cards = await CardHelper.importFromCSV(result.files.single.path!);
        if(context.mounted) {
          final addedCount = await addCards(context, realmServices: realmServices, cards: cards, set: set);
          if(context.mounted) {
            successMessageSnackBar(context, "Cards import successful".i18n([addedCount.toString()]), icon: Icons.download_done_rounded).show(context);
          }
        }
      } catch (error) {
        if(context.mounted) {
          errorMessageSnackBar(context, "Error Importing CSV".i18n(), error.toString()).show(context);
        }
      }
    }
  }

  static Future<void> exportCards(BuildContext context, List<KeyValueCard> cards, String filename) async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
        dialogTitle: "Pick directory".i18n(),
        initialDirectory: (await getDownloadsDirectory())?.path
    );

    String filePath = await CardHelper.exportToCsv(cards, filename, directory: selectedDirectory);
    if(context.mounted) {
      successMessageSnackBar(context, "Set exported success".i18n([filename]), description: "Set exported success description".i18n([filePath]), icon: Icons.download_done_rounded).show(context);
    }
  }

  static Future<void> copyCardToSet(BuildContext context, CardSet currentSet, KeyValueCard card, RealmServices realmServices) async {
      final sets = await realmServices.setCollection.getAll(realmServices.currentUser!.id);
      sets.removeWhere((set) => set.id == currentSet.id);

      onSetSelected(CardSet set) async {
        bool added = false;
        (_, _, added) = await addCardAsync(context, realmServices: realmServices, card: card, set: set, rememberChoice: null, choice: CardExistChoice.create);
        if(context.mounted) {
          GoRouter.of(context).pop();
          if(added) {
            successMessageSnackBar(context, "Card copied to set".i18n([set.name])).show(context);
          } else {
            infoMessageSnackBar(context, "No card added to set".i18n()).show(context);
          }
        }
      }

      if(context.mounted) {
        await showDialog(context: context,
          builder: (context) {
              return SetPicker(title: "Choose a set".i18n(), sets: sets, onCancel: () {}, onSetSelected: onSetSelected);
          }
        );
      }
  }

  static Future<void> copyCardsToSet(BuildContext context, CardSet currentSet, List<KeyValueCard> cards, RealmServices realmServices) async {
    final sets = await realmServices.setCollection.getAll(realmServices.currentUser!.id);
    sets.removeWhere((set) => set.id == currentSet.id);

    onSetSelected(CardSet set) async {
      final addedCount = await addCards(context, realmServices: realmServices, cards: cards, set: set);
      if(context.mounted) {
        GoRouter.of(context).pop();
        if(addedCount == 0) {
          infoMessageSnackBar(context, "No card added to set".i18n()).show(context);
        } else if(addedCount == 1) {
          successMessageSnackBar(context, "x card copied to set".i18n([addedCount.toString(), set.name])).show(context);
        } else {
          successMessageSnackBar(context, "x cards copied to set".i18n([addedCount.toString(), set.name])).show(context);
        }
      }
    }

    if(context.mounted) {
      await showDialog(context: context,
          builder: (context) {
            return SetPicker(title: "Choose a set".i18n(), sets: sets, onCancel: () {}, onSetSelected: onSetSelected);
          }
      );
    }
  }
}