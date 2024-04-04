import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/models/parking.dart';
import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/core/providers/parking.dart';
import 'package:campus_mobile_experimental/ui/common/card_container.dart';
import 'package:campus_mobile_experimental/ui/common/dots_indicator.dart';
import 'package:campus_mobile_experimental/ui/parking/circular_parking_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Get X import package
import 'package:get/get.dart';

// GetX Controller
class _ParkingController extends GetxController {
  RxList<Product> cartItems = RxList<Product>();

  void addItem(Product item) => cartItems.add(item);

  double get totalPrice => cartItems.fold(0, (sum, item) => sum + item.price);
}

// Get X Widget
class MyWidget extends StatelessWidget {
  final MyController controller =
      Get.put(MyController()); // Initialize the controller

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GetX Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GetBuilder<MyController>(
              builder: (_) => Text(
                'Count: ${controller.counter}',
                style: const TextStyle(fontSize: 24),
              ),
            ),
            ElevatedButton(
              onPressed: controller.increment,
              child: const Text('Increment'),
            ),
          ],
        ),
      ),
    );
  }
}
