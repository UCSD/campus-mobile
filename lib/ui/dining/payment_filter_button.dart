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
        Theme.of(context).brightness == Brightness.light
            ? "assets/images/payment_filter.png"
            : "assets/images/payment_filter_dark.png",
        width: 32,
        height: 32,
      ),
      backgroundColor: Theme.of(context).brightness == Brightness.light ? ColorPrimary : Colors.white,
      onPressed: () {
        Navigator.pushNamed(context, RoutePaths.DiningPaymentFilterView);
      },
    );
  }
}
