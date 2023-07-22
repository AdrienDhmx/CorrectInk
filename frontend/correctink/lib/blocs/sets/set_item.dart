import 'package:correctink/blocs/sets/popups_menu.dart';
import 'package:correctink/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:correctink/main.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

import '../../app/data/models/schemas.dart';
import '../../app/data/repositories/realm_services.dart';
import '../../app/screens/edit/modify_set.dart';
import '../../app/services/theme.dart';

class SetItem extends StatelessWidget{
  final CardSet set;
  final bool border;

  const SetItem(this.set, {Key? key, required this.border}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final realmServices = Provider.of<RealmServices>(context);

    if (set.isValid) {
      return ListTile(
        horizontalTitleGap: 16,
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
        shape: border ? Border(bottom: BorderSide(
            color: Theme.of(context).colorScheme.onBackground.withAlpha(100)
        )) : null,
      );
    } else {
      return Container();
    }
  }
}