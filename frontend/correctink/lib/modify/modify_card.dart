import 'package:flutter/material.dart';
import 'package:correctink/components/widgets.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

import '../learn/helper/learn_utils.dart';
import '../realm/realm_services.dart';
import '../realm/schemas.dart';

class ModifyCardForm extends StatefulWidget {
  final KeyValueCard card;
  const ModifyCardForm(this.card, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ModifyCardFormState();
}

class _ModifyCardFormState extends State<ModifyCardForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _keyController;
  late TextEditingController _valueController;
  late bool allowFrontMultipleValues = true;
  late bool allowBackMultipleValues = true;
  late bool frontHasMultipleValues = false;
  late bool backHasMultipleValues = false;
  late String frontValuesSeparator = '';
  late String backValuesSeparator = '';

  _ModifyCardFormState();

  @override
  void initState() {
    _keyController = TextEditingController(text: widget.card.front);
    _valueController = TextEditingController(text: widget.card.back);

    allowBackMultipleValues = widget.card.allowBackMultipleValues;
    allowFrontMultipleValues = widget.card.allowFrontMultipleValues;

    bool frontMultiple  = false;
    String frontSeparator = '';
    (frontMultiple, frontSeparator) = LearnUtils.hasMultipleValues(widget.card.front);

    bool backMultiple = false;
    String backSeparator = '';
    (backMultiple, backSeparator) = LearnUtils.hasMultipleValues(widget.card.back);

    frontHasMultipleValues = frontMultiple;
    backHasMultipleValues = backMultiple;

    frontValuesSeparator = frontSeparator;
    backValuesSeparator = backSeparator;
    super.initState();
  }

  @override
  void dispose() {
    _keyController.dispose();
    _valueController.dispose();
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
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: _keyController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  validator: (value) => (value ?? "").isEmpty ? "Front side hint".i18n() : null,
                  decoration: InputDecoration(
                    labelText: "Front side".i18n(),
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
                  controller: _valueController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  validator: (value) => (value ?? "").isEmpty ? "Back side hint".i18n() : null,
                  decoration: InputDecoration(
                    labelText: "Back side".i18n(),
                    suffixIcon: backHasMultipleValues
                        ? IconButton(
                          icon: Icon(Icons.format_list_bulleted_rounded, color: allowBackMultipleValues ? Colors.green : Colors.red,),
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                      onPressed: (){
                        String key = _keyController.text;
                        _keyController.text = _valueController.text;
                        _valueController.text = key;

                        bool backMultipleValues = backHasMultipleValues;
                        setState(() {
                          backHasMultipleValues = frontHasMultipleValues;
                          frontHasMultipleValues = backMultipleValues;
                        });
                      },
                      icon: const Icon(Icons.swap_vert)
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        cancelButton(context),
                        deleteButton(context, onPressed: () => delete(realmServices, widget.card, context)),
                        okButton(context, "Update".i18n(),
                            onPressed: () async => await update(context, realmServices, widget.card, _keyController.text, _valueController.text)),
                      ]
                  ),
                ),
              ],
            )));
  }

  Future<void> update(BuildContext context, RealmServices realmServices, KeyValueCard card, String key, String value) async {
    if (_formKey.currentState!.validate()) {

      await realmServices.cardCollection.update(card, key, value,
          frontHasMultipleValues && allowFrontMultipleValues, backHasMultipleValues && allowBackMultipleValues);
      if(context.mounted) Navigator.pop(context);
    }
  }

  void delete(RealmServices realmServices, KeyValueCard card, BuildContext context) {
    realmServices.cardCollection.delete(card);
    Navigator.pop(context);
  }
}