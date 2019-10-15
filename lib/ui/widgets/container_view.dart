import 'package:flutter/material.dart';

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
        child: AppBar(
          title: Container(
            padding: EdgeInsets.only(top: 14),
            child: Center(
              child: Image.asset(
                'assets/images/UCSanDiegoLogo-nav.png',
                height: 28,
              ),
            ),
          ),
        ),
      ),
      body: child,
    );
  }
}
