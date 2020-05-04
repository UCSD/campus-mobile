import 'package:campus_mobile_experimental/core/data_providers/barcode_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_code_scanner/qr_scanner_overlay_shape.dart';

class ScannerView extends StatefulWidget {
  const ScannerView({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<ScannerView> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: QRView(
            key: qrKey,
            onQRViewCreated:
                Provider.of<BarcodeDataProvider>(context, listen: false)
                    .onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderColor: Color.fromRGBO(54, 216, 113, 1.0),
              borderRadius: 10,
              borderLength: 30,
              borderWidth: 10,
              cutOutSize: 300,
            ),
          ),
          flex: 4,
        ),
        Expanded(
          child: Container(
            constraints: BoxConstraints.expand(),
            color: Color.fromRGBO(237, 236, 236, 1.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Provider.of<BarcodeDataProvider>(context).qrText.isNotEmpty
                      ? Text(Provider.of<BarcodeDataProvider>(context).qrText,
                          style: TextStyle(fontSize: 20))
                      : Text("Please scan a test kit.",
                          style: TextStyle(fontSize: 20)),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.all(8.0),
                        child: FlatButton(
                          disabledTextColor: Colors.black,
                          disabledColor: Color.fromRGBO(218, 218, 218, 1.0),
                          onPressed: Provider.of<BarcodeDataProvider>(context)
                                  .qrText
                                  .isNotEmpty
                              ? () => Provider.of<BarcodeDataProvider>(context,
                                      listen: false)
                                  .submitBarcode()
                              : null,
                          child: Text(
                              Provider.of<BarcodeDataProvider>(context)
                                  .submitState,
                              style: TextStyle(fontSize: 20)),
                          color: Theme.of(context).buttonColor,
                          textColor: Theme.of(context).textTheme.button.color,
                        ),
                      ),
                    ],
                  ),
                ]),
          ),
          flex: 1,
        )
      ],
    );
  }

  @override
  void dispose() {
    Provider.of<BarcodeDataProvider>(context).dispose();
    super.dispose();
  }
}
