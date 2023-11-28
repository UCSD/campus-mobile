import 'package:campus_mobile_experimental/core/providers/map.dart';
import 'package:campus_mobile_experimental/ui/map/map.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchHistoryList extends StatelessWidget {
  final void Function() fetchLocations;
  final List<String> searchHistory;
  final TextEditingController searchBarController;

  const SearchHistoryList({
    Key? key,
    required this.fetchLocations,
    required this.searchHistory,
    required this.searchBarController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Card(
        margin: EdgeInsets.all(5),
        child: ListView.separated(
          separatorBuilder: (context, index) => Divider(height: 0),
          itemCount: searchHistory.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
              leading: Icon(Icons.history),
              title: Text(searchHistory.reversed.toList()[index]),
              trailing: IconButton(
                iconSize: 20,
                icon: Icon(Icons.cancel),
                onPressed: () {
                  searchHistory.remove(searchHistory.reversed.toList()[index]);
                },
              ),
              onTap: () {
                searchBarController.text =
                    searchHistory.reversed.toList()[index];
                fetchLocations();
                Navigator.pop(context);
              },
            );
          },
        ),
      ),
    );
  }
}
