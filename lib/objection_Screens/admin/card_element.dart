import "package:flutter/material.dart";
import "package:university_services/Constants.dart";

Widget BuildButton(
  BuildContext context,
  String label,
  Color color,
  Color textColor,
  String dialogTitle,
  Widget? dialogContent,
  String CancelText,
  String ConfirmText,
  VoidCallback onConfirm,
) {
  return MaterialButton(
    onPressed: () {
      showDialog(
          context: context,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  title: Text(
                    dialogTitle,
                    style: TextStyle(fontSize: 20),
                  ),
                  content: dialogContent,
                  actions: [
                    ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          CancelText,
                          style: TextStyle(color: Constants.primaryColor),
                        )),
                    ElevatedButton(
                        onPressed: () => onConfirm(),
                        child: Text(
                          ConfirmText,
                          style: TextStyle(color: Constants.primaryColor),
                        )),
                  ],
                );
              },
            );
          });
    },
    color: color,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    child: Padding(
      padding: const EdgeInsets.all(5.0),
      child: Text(
        label,
        style: TextStyle(color: textColor, fontSize: 17),
      ),
    ),
  );
}

TableRow BuildTableRow(
  String label,
  String value,
) {
  return TableRow(children: [
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Center(
        child: Text(
          label,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
    ),
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Center(
        child: Text(
          value,
          style: TextStyle(
            fontSize: 18,
          ),
        ),
      ),
    )
  ]);
}
