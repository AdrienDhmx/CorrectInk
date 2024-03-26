import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';
import '../../../widgets/buttons.dart';
import '../../../widgets/snackbars_widgets.dart';
import '../../../widgets/widgets.dart';
import '../../data/models/schemas.dart';
import '../../data/repositories/collections/users_collection.dart';
import '../../data/repositories/realm_services.dart';
import '../../services/theme.dart';

void modifySet(BuildContext context, FlashcardSet set, RealmServices realmServices){
  bool isMine = (set.owner!.userId.hexString == realmServices.currentUser?.id);
  if (isMine) {
    showBottomSheetModal(context, ModifySetForm(set));
  } else {
    errorMessageSnackBar(context, "Error edit".i18n(), "Error edit message".i18n(['Sets'.i18n()])).show(context);
  }
}

class ModifySetForm extends StatefulWidget {
  final FlashcardSet set;
  const ModifySetForm(this.set, { Key? key }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ModifySetFormState();
}

class _ModifySetFormState extends State<ModifySetForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  int selectedColorIndex = 0;
  late double availableWidth;
  late ScrollController setColorsScrollController;
  late bool isPublic;
  late UserService userService;

  _ModifySetFormState();

  @override
  void initState() {
    _nameController = TextEditingController(text: widget.set.name);
    _descriptionController = TextEditingController(text: widget.set.description);

    selectedColorIndex = widget.set.color != null ? ThemeProvider.setColors.indexOf(HexColor.fromHex(widget.set.color!)) : ThemeProvider.setColors.length;
    isPublic = widget.set.isPublic;

    super.initState();
  }

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();

    userService = Provider.of(context);
    availableWidth = MediaQuery.sizeOf(context).width - 40;
    final double selectedColorOffset = (selectedColorIndex + 1) * 60;
    double initScrollOffset = 0;

    if(selectedColorOffset > availableWidth && selectedColorIndex != ThemeProvider.setColors.length){
      initScrollOffset = selectedColorOffset - 120;
    }

    setColorsScrollController = ScrollController(initialScrollOffset: initScrollOffset);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final realmServices = Provider.of<RealmServices>(context, listen: false);
    return modalLayout(
        context,
        Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                TextFormField(
                  controller: _nameController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  maxLength: 50,
                  validator: (value) => (value ?? "").isEmpty ? "Set name hint".i18n() : null,
                  decoration: InputDecoration(
                    labelText: "Name".i18n(),
                  ),
                ),
                TextFormField(
                  controller: _descriptionController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  maxLength: 300,
                  decoration: InputDecoration(
                    labelText: "Description optional".i18n(),
                  ),
                ),
                setColorsPicker(
                  context: context,
                  selectedIndex: selectedColorIndex,
                  onPressed: (index) {
                      if(index == 0){
                        index = ThemeProvider.setColors.length;
                      } else {
                        index = index - 1;
                      }

                      setState(() {
                        selectedColorIndex = index;
                      });
                  },
                  controller: setColorsScrollController
                ),
                if(widget.set.originalOwner == null && !userService.currentUserData!.blocked && !widget.set.blocked)
                  labeledAction(
                    context: context,
                    child: Switch(
                      value: isPublic,
                      onChanged: (value) {
                        setState(() {
                          isPublic = value;
                        });
                      },
                    ),
                    label: 'Public'.i18n(),
                    center: true,
                    width: 150
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        cancelButton(context),
                        okButton(context, "Update".i18n(),
                            onPressed: () async => await update(context, realmServices, widget.set, _nameController.text, _descriptionController.text)),
                      ]
                  ),
                ),
              ],
            )
        ));
  }

  Future<void> update(BuildContext context, RealmServices realmServices, FlashcardSet set, String name, String? description) async {
    if (_formKey.currentState!.validate()) {
      await realmServices.setCollection.update(set, name: name, description: description, isPublic: isPublic, color: selectedColorIndex ==  ThemeProvider.setColors.length ? null : ThemeProvider.setColors[selectedColorIndex].toHex());
      if(context.mounted) Navigator.pop(context);
    }
  }
}