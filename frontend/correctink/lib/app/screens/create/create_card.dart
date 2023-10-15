import 'package:correctink/app/data/models/schemas.dart';
import 'package:correctink/utils/card_helper.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:objectid/objectid.dart';
import 'package:provider/provider.dart';

import '../../../utils/learn_utils.dart';
import '../../../widgets/widgets.dart';
import '../../data/repositories/realm_services.dart';

class CreateCardForm extends StatefulWidget {
  const CreateCardForm(this.setId, {Key? key}) : super(key: key);
  final ObjectId setId;

  @override
  createState() => _CreateCardFormState();
}

class _CreateCardFormState extends State<CreateCardForm> {
  final _formKey = GlobalKey<FormState>();
  late FocusNode _frontFocusNode;
  late TextEditingController _frontController;
  late TextEditingController _backController;
  late bool allowFrontMultipleValues = true;
  late bool allowBackMultipleValues = true;
  late bool frontHasMultipleValues = false;
  late bool backHasMultipleValues = false;
  late String frontValuesSeparator = '';
  late String backValuesSeparator = '';

  @override
  void initState() {
    _frontController = TextEditingController();
    _backController = TextEditingController();
    _frontFocusNode = FocusNode();
    _frontFocusNode.requestFocus();
    super.initState();
  }

  @override
  void dispose() {
    _frontController.dispose();
    _backController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return modalLayout(
        context,
        Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: _frontController,
                focusNode: _frontFocusNode,
                keyboardType: TextInputType.multiline,
                autofocus: true,
                maxLines: null,
                validator: (value) => (value ?? "").isEmpty ? "Front side hint".i18n() : null,
                decoration: InputDecoration(
                    labelText: 'Front side'.i18n(),
                  suffixIcon: frontHasMultipleValues
                      ? IconButton(
                        icon: Icon(Icons.format_list_bulleted_rounded, color: allowFrontMultipleValues ? Colors.green : Colors.red,),
                        tooltip: allowFrontMultipleValues ? "Multiple values have been detected" : "Multiple values detected but considered as one",
                        onPressed: () {
                            setState(() {
                              allowFrontMultipleValues = !allowFrontMultipleValues;
                            });
                          },
                      )
                      : null,
                ),
                onChanged: (String? value){
                  if(value != null) {
                    bool multipleValues = false;
                    String separator = '';
                    (multipleValues, separator) = LearnUtils.hasMultipleValues(value);
                    setState(() {
                      frontHasMultipleValues = multipleValues;
                      frontValuesSeparator = separator;
                    });
                  }
                },
              ),
              TextFormField(
                controller: _backController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                validator: (value) => (value ?? "").isEmpty ? "Back side hint".i18n() : null,
                decoration: InputDecoration(
                    labelText: "Back side".i18n(),
                  suffixIcon: backHasMultipleValues
                      ? IconButton(
                        icon: Icon(Icons.format_list_bulleted_rounded, color: allowBackMultipleValues ? Colors.green : Colors.red, size: 25,),
                        tooltip: allowBackMultipleValues ? "Multiple values have been detected" : "Multiple values detected but considered as one",
                        onPressed: () {
                          setState(() {
                            allowBackMultipleValues = !allowBackMultipleValues;
                          });
                        },
                      )
                      : null,
                ),
                onChanged: (String? value){
                  if(value != null) {
                    bool multipleValues = false;
                    String separator = '';
                    (multipleValues, separator) = LearnUtils.hasMultipleValues(value);
                    setState(() {
                      backHasMultipleValues = multipleValues;
                      backValuesSeparator = separator;
                    });
                  }
                },
              ),
              Consumer<RealmServices>(
                builder: (context, realmServices, child) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          cancelButton(context),
                          okButton(context, "Create".i18n(), onPressed: () => save(realmServices, context)),
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: pushButton(context, onTap: () => save(realmServices, context, pop: false),),
                          )
                        ],
                    ),
                  );
                }
              ),
            ],
          ),
        ));
  }

  void save(RealmServices realmServices, BuildContext context, {bool pop = true}) {
    if (_formKey.currentState!.validate()) {
      final key = _frontController.text;
      final value = _backController.text;
      final set = realmServices.setCollection.get(widget.setId.hexString);
      if(set != null){
        KeyValueCard newCard = KeyValueCard(ObjectId(), key, value,
            allowFrontMultipleValues: frontHasMultipleValues && allowFrontMultipleValues,
            allowBackMultipleValues: backHasMultipleValues && allowBackMultipleValues
        );
        CardHelper.addCard(context, realmServices: realmServices, card: newCard, set: set);
      }
      if(pop) {
        Navigator.pop(context);
      } else {
        _frontController.text = "";
        _backController.text = "";
        _frontFocusNode.requestFocus();
      }
    }
  }
}