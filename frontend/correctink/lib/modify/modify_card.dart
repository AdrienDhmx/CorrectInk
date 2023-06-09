import 'package:flutter/material.dart';
import 'package:correctink/components/widgets.dart';
import 'package:localization/localization.dart';
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
  late int progress;

  _ModifyCardFormState();

  @override
  void initState() {
    _keyController = TextEditingController(text: widget.card.key);
    _valueController = TextEditingController(text: widget.card.value);

    progress = 0; // learning as default

    if(widget.card.isKnown){
      progress = widget.card.knowMinValue;
    } else if (!widget.card.isLearning){
      progress = widget.card.learningMinValue;
    }

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
                Text("Update card".i18n(), style: myTextTheme.titleLarge),
                TextFormField(
                  controller: _keyController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  validator: (value) => (value ?? "").isEmpty ? "key hint".i18n() : null,
                  decoration: InputDecoration(
                    labelText: "Key".i18n(),
                  ),
                ),
                TextFormField(
                  controller: _valueController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  validator: (value) => (value ?? "").isEmpty ? "Value hint".i18n() : null,
                  decoration: InputDecoration(
                    labelText: "Value".i18n(),
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
                Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    labeledAction(
                      context: context,
                      child: Radio<int>(
                        value: widget.card.learningMinValue,
                        groupValue: progress,
                        onChanged: (int? value){
                          setState(() {
                            progress = value ?? widget.card.learningMinValue;
                          });
                        },
                      ),
                      label: "Don't know".i18n(),
                      onTapAction: () {
                        setState(() {
                          progress = widget.card.learningMinValue;
                        });
                      },
                      width: 130,
                      labelFirst: false,
                    ),
                    labeledAction(
                      context: context,
                      child: Radio<int>(
                        value: 0,
                        groupValue: progress,
                        onChanged: (int? value){
                          setState(() {
                            progress = value ?? 0;
                          });
                        },
                      ),
                      label: "Learning".i18n(),
                      onTapAction: () {
                        setState(() {
                          progress = 0;
                        });
                      },
                      width: 130,
                      labelFirst: false,
                    ),
                    labeledAction(
                      context: context,
                      child: Radio<int>(
                        value: widget.card.knowMinValue,
                        groupValue: progress,
                        onChanged: (int? value){
                          setState(() {
                            progress = value ?? widget.card.knowMinValue;
                          });
                        },
                      ),
                      label: "Know".i18n(),
                      onTapAction: () {
                        setState(() {
                          progress = widget.card.knowMinValue;
                        });
                      },
                      width: 120,
                      labelFirst: false,
                    ),
                  ],
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

  Future<void> update(BuildContext context, RealmServices realmServices, KeyValueCard card, String key, String? value) async {
    if (_formKey.currentState!.validate()) {

      // check if the selected progress correspond to the current progress
      if(progress == widget.card.knowMinValue + 1 && widget.card.isKnown){
        progress = widget.card.learningProgress;
      } else if (progress == 0 && widget.card.isLearning) {
        progress = widget.card.learningProgress;
      } else if (progress == widget.card.learningMinValue - 1 && !widget.card.isLearning && !widget.card.isKnown){
        progress = widget.card.learningProgress;
      }

      await realmServices.cardCollection.update(card, key: key, value: value, learningProgress: progress);
      if(context.mounted) Navigator.pop(context);
    }
  }

  void delete(RealmServices realmServices, KeyValueCard card, BuildContext context) {
    realmServices.cardCollection.delete(card);
    Navigator.pop(context);
  }
}