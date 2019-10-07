import 'package:flutter/material.dart';
import 'package:campus_mobile/ui/widgets/container_view.dart';

class BaselineView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ContainerView(
      child: Center(
        child: Container(
          child: Text('BaseLine View'),
        ),
      ),
    );
  }
}
