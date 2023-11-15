import 'package:flutter/material.dart';

Future<void> displayTextInputDialog(
  BuildContext context,
  String label,
  String btnLabel,
  Function fct, {
  String initialValue = "",
}) async {
  TextEditingController controller = TextEditingController(text: initialValue);
  return showDialog(
    context: context,
    builder: (context) {
      String data = initialValue;
      bool enabled = data != initialValue && data != "";
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(label),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            content: TextField(
              controller: controller,
              onChanged: (value) {
                setState(() {
                  data = value;
                  enabled = value != initialValue && value != "";
                });
              },
              decoration: const InputDecoration(hintText: "Enter a name"),
            ),
            actions: <Widget>[
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    Theme.of(context).colorScheme.secondary,
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
              enabled
                  ? ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      child: Text(
                        btnLabel,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      onPressed: () {
                        fct(data);
                        Navigator.pop(context);
                      })
                  : Container(),
            ],
          );
        },
      );
    },
  );
}

Future<void> displayConfirmDialog(
  BuildContext context,
  String label,
  String btnLabel,
  Function confirm,
) async {
  return showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(label),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actions: <Widget>[
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    Theme.of(context).colorScheme.secondary,
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
              ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  child: Text(
                    btnLabel,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  onPressed: () {
                    confirm();
                    Navigator.pop(context);
                  }),
            ],
          );
        },
      );
    },
  );
}
