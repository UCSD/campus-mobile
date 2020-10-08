import 'package:flutter/material.dart';
import 'package:flutter_scandit_plugin/flutter_scandit_plugin.dart';

class ScanditScanner extends StatefulWidget {
  @override
  _ScanditScannerState createState() => _ScanditScannerState();
}

class _ScanditScannerState extends State<ScanditScanner> {
  String _message = '';
  ScanditController _controller;


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Barcode Scanner"),
      ),
      body: Stack(
        children: [
            Scandit(
                scanned: _handleBarcodeResult,
                onError: (e) => setState(() => _message = e.message),
                symbologies: [Symbology.CODE128, Symbology.DATA_MATRIX],
                onScanditCreated: (controller) => _controller = controller,
                licenseKey:
                "AcUfBiaXOVIQCeCwChcl05QwFCPbKhuZ5DFFHEdC7zjHZYV/XnS2CZJ5D9dnJcBTDW+Jh6RMOSJmXnJ8KywJjb9AHZNUU+j3MAZZX6hHx9fzc4UT4CAHEPRw2uVAIDBuKD8ozkMfw3qfOIanzJAM4oHLaUyHj9Qvxbh6eWOr/llZDzdB+mTTkUGW4ibe4XAhafCl7Y/pmyyS3KhREOJVIiMp8j0UoIjidTqBGq73dF9Ai2yXJKpAARXu4FAarFfWUoHIL2810iaDkpXhauSEv9KhCzWclhXFc/wD7kE9rfUYbq4gl0Wf3w7YTtvvaY+WeHYVvO4X+lDWn6GEf/hgRAPtyPLo2qTfD0TKxI/x7WoYw7rBFsRl43RrTbFb+a2ILhkp2A851a/xgzgv2VFFwKxZMRgwKb53JhWbF71zV5ZCvg8wi3MX502RnC6s+ljo3+EcJj3LDQ/1jIv8AH/9II2RWJKDPIx1WK4dojZiBYGPAp3cdgfatl6gx/PBFtJB2h+8No2KlzQRCRoY803Ir18GCQ7vJEevFEeQ/3X27vCrbyv/02hzMdmdSy3Im6CrH3WrVvrp+HioMCh6Yhao6c+hWNIBDvKgXUsMwQmVxtVg5TebF3GdJoW1rUDgMzXfRIBG+ApPecihGw37yjkL7FPLFMLytePm3h2a2HZJmrGs/1yZRhgVCynFGfzUa2rcL5ClXz7l7L4RW3GwP72fxwXjcNCwxOKe8chhGWJlOrKKKYwSkiQIg0d+I5B9YY7ryBFNHFzF0hYsRag7doW/oWclfbW2n/LLmn+Ict0bQd6BMJzjOh7R3e7R" //'INSERT YOUR TEST KEY',
            ),
          Center(
            child: Container(
                width: 300,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: Colors.teal),
                )),
          ),
          Center(child: Text(_message)),
        ],
      ),
      floatingActionButton: IconButton(
        onPressed: () {},
        icon: Container(),
      ),
    );
  }

  void _handleBarcodeResult(BarcodeResult result) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Barcode scanned'),
          content: Text('The barcode is ${result.data}'),
          actions: [
            FlatButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Stop'),
            ),
            FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
                _controller.resumeBarcodeScanning();
              },
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }
}