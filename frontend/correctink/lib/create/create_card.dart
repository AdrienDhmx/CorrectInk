import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:objectid/objectid.dart';
import 'package:provider/provider.dart';

import '../components/widgets.dart';
import '../realm/realm_services.dart';

class CreateCardForm extends StatefulWidget {
  const CreateCardForm(this.setId, this.cardAdded, {Key? key}) : super(key: key);
  final ObjectId setId;
  final Function cardAdded;

  @override
  createState() => _CreateCardFormState();
}

class _CreateCardFormState extends State<CreateCardForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _keyController;
  late TextEditingController _valueController;

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
    TextTheme theme = Theme.of(context).textTheme;
    return formLayout(
        context,
        Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text("Create card".i18n(), style: theme.titleLarge),
              TextFormField(
                controller: _keyController,
                keyboardType: TextInputType.multiline,
                autofocus: true,
                maxLines: null,
                validator: (value) => (value ?? "").isEmpty ? "Key hint".i18n() : null,
                decoration: InputDecoration(
                    labelText: 'Key'.i18n()
                ),
              ),
              TextFormField(
                controller: _valueController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                validator: (value) => (value ?? "").isEmpty ? "Value hint".i18n() : null,
                decoration: InputDecoration(
                    labelText: "Value".i18n()
                ),
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
      realmServices.cardCollection.create(key, value, widget.setId);
      widget.cardAdded();
      Navigator.pop(context);
    }
  }
}