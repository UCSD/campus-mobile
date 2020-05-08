import 'package:campus_mobile_experimental/core/constants/scanner_constants.dart';
import 'package:campus_mobile_experimental/core/data_providers/barcode_data_provider.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/container_view.dart';
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
  BarcodeDataProvider _barcodeDataProvider;

  @override
  void didChangeDependencies() {
    // TODO: implement didUpdateWidget
    super.didChangeDependencies();
    context.dependOnInheritedWidgetOfExactType();
    _barcodeDataProvider = Provider.of<BarcodeDataProvider>(context);
  }

  @override
  Widget build(BuildContext context) {
    return ContainerView(
      child: Column(
        children: <Widget>[
          Expanded(
            child: QRView(
              key: qrKey,
              onQRViewCreated: _barcodeDataProvider.onQRViewCreated,
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
              color: Theme.of(context).accentColor,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    _barcodeDataProvider.qrText.isNotEmpty
                        ? Text(_barcodeDataProvider.qrText,
                            style: Theme.of(context).textTheme.title)
                        : Text(ScannerConstants.scannerViewPrompt,
                        style: Theme.of(context).textTheme.title),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.all(8.0),
                          child: FlatButton(
                            disabledTextColor: Colors.black,
                            disabledColor: Color.fromRGBO(218, 218, 218, 1.0),
                            onPressed: _barcodeDataProvider.qrText.isNotEmpty
                                ? () => _barcodeDataProvider.submitBarcode()
                                : null,
                            child: Text(_barcodeDataProvider.submitState,
                                style: Theme.of(context).textTheme.button),
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
      ),
    );
  }

  @override
  void dispose() {
    _barcodeDataProvider.disposeController();
    super.dispose();
  }
}
