import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class Base64ImageWidget extends StatelessWidget {
  final String? base64String;
  final String placeholderAssetPath;
  final BoxFit fit;
  final double? width;
  final double? height;

  const Base64ImageWidget({
    Key? key,
    required this.base64String,
    required this.placeholderAssetPath,
    this.fit = BoxFit.fill,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check if base64String is valid and not empty
    final bool isNull = base64String == null;
    final bool isEmpty = base64String?.isEmpty ?? true;
    final bool isTrimmedEmpty = base64String?.trim().isEmpty ?? true;
    if (isNull || isEmpty || isTrimmedEmpty) return _buildPlaceholder();

    try {
      // Clean the base64 string (remove any whitespace)
      String cleanBase64 = base64String!.trim();

      // Decode the base64 string
      Uint8List bytes = base64Decode(cleanBase64);

      // Return the decoded image
      return Image.memory(
        bytes,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) {
          // If there's an error displaying the base64 image, show placeholder
          print('Error displaying base64 image: $error');
          return _buildPlaceholder();
        },
      );
    } catch (e) {
      // If base64 decoding fails, show placeholder
      print('Error decoding base64 image: $e');
      return _buildPlaceholder();
    }
  }

  Widget _buildPlaceholder() => Image.asset(placeholderAssetPath, fit: fit, width: width, height: height);
}
