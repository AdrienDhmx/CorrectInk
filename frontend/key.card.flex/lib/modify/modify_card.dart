import 'package:flutter/material.dart';
import 'package:correctink/components/widgets.dart';
import 'package:provider/provider.dart';

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

  _ModifyCardFormState();

  @override
  void initState() {
    _keyController = TextEditingController(text: widget.card.key);
    _valueController = TextEditingController(text: widget.card.value);

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
    TextTheme myTextTheme = Theme.of(context).textTheme;
    final realmServices = Provider.of<RealmServices>(context, listen: false);
    return formLayout(
        context,
        Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text("Update your card", style: myTextTheme.titleLarge),
                TextFormField(
                  controller: _keyController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  validator: (value) => (value ?? "").isEmpty ? "Please enter a key" : null,
                  decoration: const InputDecoration(
                    labelText: "Key",
                  ),
                ),
                TextFormField(
                  controller: _valueController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  validator: (value) => (value ?? "").isEmpty ? "Please enter a value" : null,
                  decoration: const InputDecoration(
                    labelText: "Value",
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                      onPressed: (){
                        String key = _keyController.text;
                        _keyController.text = _valueController.text;
                        _valueController.text = key;
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
                        okButton(context, "Update",
                            onPressed: () async => await update(context, realmServices, widget.card, _keyController.text, _valueController.text)),
                      ]
                  ),
                ),
              ],
            )));
  }

  Future<void> update(BuildContext context, RealmServices realmServices, KeyValueCard card, String key, String? value) async {
    if (_formKey.currentState!.validate()) {
      await realmServices.updateKeyValueCard(card, key: key, value: value);
      if(context.mounted) Navigator.pop(context);
    }
  }

  void delete(RealmServices realmServices, KeyValueCard card, BuildContext context) {
    realmServices.deleteKeyValueCard(card);
    Navigator.pop(context);
  }
}