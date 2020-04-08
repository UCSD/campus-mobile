import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/container_view.dart';

class BaselineView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ContainerView(
      child: Center(
        child: Text('BaseLine View'),
      ),
    );
  }
}
