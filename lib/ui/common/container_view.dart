import 'package:campus_mobile_experimental/ui/navigator/top.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ContainerView extends StatelessWidget {
  const ContainerView({
    Key key,
    @required this.child,
  }) : super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(42),
          child: Provider.of<CustomAppBar>(context).appBar),
      body: child,
    );
  }
}
