import 'package:correctink/learn/helper/learn_utils.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:objectid/objectid.dart';
import 'package:provider/provider.dart';

import '../components/widgets.dart';
import '../realm/realm_services.dart';

class CreateCardForm extends StatefulWidget {
  const CreateCardForm(this.setId, {Key? key}) : super(key: key);
  final ObjectId setId;

  @override
  createState() => _CreateCardFormState();
}

class _CreateCardFormState extends State<CreateCardForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _keyController;
  late TextEditingController _valueController;
  late bool allowFrontMultipleValues = true;
  late bool allowBackMultipleValues = true;
  late bool frontHasMultipleValues = false;
  late bool backHasMultipleValues = false;
  late String frontValuesSeparator = '';
  late String backValuesSeparator = '';

  @override
  void initState() {
    _keyController = TextEditingController();
    _valueController = TextEditingController();
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
                controller: _valueController,
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
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    cancelButton(context),
                    Consumer<RealmServices>(builder: (context, realmServices, child) {
                      return okButton(context, "Create".i18n(), onPressed: () => save(realmServices, context));
                    }),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  void save(RealmServices realmServices, BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final key = _keyController.text;
      final value = _valueController.text;
      final set = realmServices.setCollection.get(widget.setId.hexString);
      if(set != null){
        realmServices.setCollection.addCard(set, key, value,
            frontHasMultipleValues && allowFrontMultipleValues, backHasMultipleValues && allowBackMultipleValues,
        );
      }
      Navigator.pop(context);
    }
  }
}