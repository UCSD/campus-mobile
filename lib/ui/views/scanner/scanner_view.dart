import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:campus_mobile_experimental/core/constants/scanner_constants.dart';
import 'package:campus_mobile_experimental/core/data_providers/barcode_data_provider.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/container_view.dart';
import 'package:campus_mobile_experimental/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

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

  DateTime now = DateTime.now();

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
          ),
          ConstrainedBox(
            constraints: BoxConstraints.loose(Size(
                MediaQuery.of(context).size.width,
                0.3 * MediaQuery.of(context).size.height)),
            child: Container(
              color: Colors.white,
              child: SingleChildScrollView(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      _barcodeDataProvider.qrText.isNotEmpty &&
                              !_barcodeDataProvider.isLoading &&
                              _barcodeDataProvider.submitState !=
                                  ButtonText.SubmitButtonReceived
                          ? Padding(
                              padding:
                                  const EdgeInsets.only(top: 20.0, bottom: 4.0),
                              child: Text(
                                ScannerConstants.scannerSubmitPrompt,
                                style: TextStyle(
                                    color: Colors.black, fontSize: 18.0),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : _barcodeDataProvider.qrText.isNotEmpty &&
                                  !_barcodeDataProvider.isLoading &&
                                  _barcodeDataProvider.submitState ==
                                      ButtonText.SubmitButtonReceived
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                      top: 20.0, bottom: 4.0),
                                  child: buildConfirmationUi(
                                      DateFormat('kk:mm:ss \n EEE d MMM')
                                          .format(now)))
                              : Padding(
                                  padding: const EdgeInsets.only(
                                      top: 20.0, bottom: 4.0),
                                  child: Text(
                                    ScannerConstants.scannerViewPrompt,
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 18.0),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.all(16.0),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: FlatButton(
                                disabledTextColor: Colors.black,
                                disabledColor:
                                    Color.fromRGBO(218, 218, 218, 1.0),
                                onPressed: _barcodeDataProvider
                                            .qrText.isNotEmpty &&
                                        !_barcodeDataProvider.isLoading &&
                                        _barcodeDataProvider.submitState !=
                                            ButtonText.SubmitButtonReceived
                                    ? () => _barcodeDataProvider.submitBarcode()
                                    : null,
                                child: Text(_barcodeDataProvider.submitState),
                                color: ColorPrimary,
                                textColor: lightTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ]),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildConfirmationUi(String formattedTime) {
    return (Container(
      alignment: Alignment.center,
      child:
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 40.0,
            ),
          ],
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          Container(
            padding: new EdgeInsets.only(left: 2),
            child: FittedBox(
              child: Text(
                ("Scan Successful"),
                style: TextStyle(
                  color: ColorPrimary,
                ),
                maxLines: 1,
              ),
            ),
          ),
          SizedBox(height: 3),
          Container(
            padding: new EdgeInsets.only(left: 2),
            child: Text(
              ("Scan sent at" + " " + formattedTime),
              style: TextStyle(
                color: ColorSecondary,
              ),
              maxLines: 1,
            ),
          ),
        ]),
      ]),
    ));
  }

  @override
  void dispose() {
    _barcodeDataProvider.disposeController();
    _barcodeDataProvider.clearQrText();
    super.dispose();
  }
}
