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
    if (base64String == null || base64String!.isEmpty || base64String!.trim().isEmpty) {
      return _buildPlaceholder();
    }

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

  Widget _buildPlaceholder() {
    return Image.asset(
      placeholderAssetPath,
      fit: fit,
      width: width,
      height: height,
    );
  }
}
