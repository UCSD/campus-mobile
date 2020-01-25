import 'package:campus_mobile_experimental/core/data_providers/special_events_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class SpecialEventsInfoView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return addScaffold(
        context,
        Provider.of<SpecialEventsDataProvider>(context)
            .specialEventsModel
            .name);
  }

  Widget addScaffold(context, String title) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
          //   child: new ListView.builder(
          //     itemCount:
          //         Provider.of<SpecialEventsDataProvider>(context).filters.length,
          //     itemBuilder: (BuildContext ctxt, int index) =>
          //         makeFiltersList(ctxt, index),
          //   ),
          ),
    );
  }
}
