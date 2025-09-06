import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/app_styles.dart';

class PaymentFilterButton extends StatelessWidget {
  const PaymentFilterButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: "directions",
      child: Image.asset(
        "assets/images/payment_filter.png",
        width: 32,
        height: 32,
      ),
      backgroundColor: ColorPrimary,
      onPressed: () {
        Navigator.pushNamed(context, RoutePaths.DiningPaymentFilterView);
      },
    );
  }
}
