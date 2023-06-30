import 'package:correctink/modify/modify_set.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:correctink/main.dart';
import 'package:correctink/theme.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

import '../realm/realm_services.dart';
import '../realm/schemas.dart';
import 'item_popup_option.dart';

enum MenuOption { edit, delete }

class SetItem extends StatelessWidget{
  final CardSet set;

  const SetItem(this.set, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final realmServices = Provider.of<RealmServices>(context);

    if (set.isValid) {
      return ListTile(
        horizontalTitleGap: 4,
        contentPadding: const EdgeInsets.fromLTRB(8, 0, 4, 0),
        onTap: () => GoRouter.of(context).push(RouterHelper.buildSetRoute(set.id.toString())),
        onLongPress: () {
          showModalBottomSheet(
            useRootNavigator: true,
            context: context,
            isScrollControlled: true,
            builder: (_) => Wrap(children: [ModifySetForm(set)]),
          );
        },
        leading: Icon(Icons.folder, color: set.color == null ? Theme.of(context).colorScheme.onBackground : HexColor.fromHex(set.color!),),
        title: Row(
          children: [
            Text(
              set.name,
            ),
            if(set.isPublic) Padding(

              padding: const EdgeInsets.fromLTRB(8,0, 0, 0),
              child: Icon(Icons.public, color: Theme.of(context).colorScheme.primary, size: 18,),
            ),
          ],
        ),
        subtitle: (set.description != null && set.description!.isNotEmpty) || (realmServices.showAllPublicSets && set.ownerId == realmServices.currentUser!.id)
            ?  Column(
              children: [
                if(set.description != null && set.description!.isNotEmpty)
                  Align(alignment: Alignment.centerLeft, child: Text(set.description!, maxLines: 2, overflow: TextOverflow.ellipsis,)),
                if(realmServices.showAllPublicSets && set.ownerId == realmServices.currentUser!.id)
                  Align(alignment: Alignment.centerLeft, child: Text('(mine)'.i18n(), style: boldTextStyle(context)))
              ],
            )
            : null,
        trailing: SetPopupOption(realmServices, set, realmServices.currentUser!.id == set.ownerId),
        shape: const Border(bottom: BorderSide()),
      );
    } else {
      return Container();
    }
  }
}