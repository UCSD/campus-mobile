import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/core/models/news_model.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/container_view.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/image_loader.dart';

class NewsDetailView extends StatelessWidget {
  const NewsDetailView({Key key, @required this.data}) : super(key: key);
  final Item data;
  @override
  Widget build(BuildContext context) {
    return ContainerView(
      child: Column(
        children: buildDetailView(),
      ),
    );
  }

  List<Widget> buildDetailView() {
    return [
      ImageLoader(
        url: data.image,
        fullSize: true,
      ),
      Text(data.title),
      Text(data.date.toIso8601String()),
      Text(data.description)
    ];
  }
}
