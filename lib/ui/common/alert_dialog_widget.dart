import 'package:flutter/material.dart';

class AlertDialogWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onClose;

  const AlertDialogWidget({
    Key? key,
    required this.icon,
    required this.title,
    required this.description,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: EdgeInsets.fromLTRB(5, 5, 0, 0),
      contentPadding: EdgeInsets.fromLTRB(0, 5, 0, 20),
      backgroundColor: Color(0xFFE6EFF5),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Color(0xFF00629B)),
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Icon(
              icon,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
            flex: 1,
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.left,
              style: Theme.of(context).brightness == Brightness.dark
                  ? TextStyle(
                      color: Colors.white,
                      fontFamily: 'Brix Sans',
                      fontWeight: FontWeight.w700,
                      fontSize: 18.0,
                    )
                  : TextStyle(
                      color: Colors.black,
                      fontFamily: 'Brix Sans',
                      fontWeight: FontWeight.w700,
                      fontSize: 18.0,
                    ),
            ),
            flex: 7,
          ),
          Expanded(
            child: IconButton(
              icon: Icon(
                Icons.close,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
              alignment: Alignment.topRight,
              onPressed: onClose,
            ),
            flex: 2,
          ),
        ],
      ),
      content: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: SingleChildScrollView(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Container(),
              ),
              Expanded(
                flex: 6,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      description,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                        fontFamily: 'Source Sans Pro',
                        fontWeight: FontWeight.w400,
                        fontSize: 12.0,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
