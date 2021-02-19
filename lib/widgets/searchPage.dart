import 'package:expiry_reminder/models/personalProductModel.dart';
import 'package:expiry_reminder/services/productServices.dart';
import 'package:flutter/material.dart';

class SearchBarUtils extends SearchDelegate {
  List<PersonalProduct> productList;
  List<String> recentList;
  String selectedResult;
  String currentUserId;

  SearchBarUtils(List<PersonalProduct> productList, currentUserId) {
    this.productList = productList;
    this.currentUserId = currentUserId;
  }

  Future _getRecentSearchList(String userId) async {
    List<String> recentSearchList = await ProductService.getRecentLists(userId);
    recentList = recentSearchList;
  }

  Future _addRecentSearch(String userId, String selectedResult) async {
    await ProductService.addRecentSearch(currentUserId, selectedResult);
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    if (query != "") {
      return <Widget>[
        IconButton(
          icon: Icon(Icons.close,
              size: 18.0, color: Theme.of(context).primaryColor),
          onPressed: () {
            query = "";
          },
        )
      ];
    }
    return <Widget>[Text("")];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: Icon(Icons.arrow_back, color: Theme.of(context).primaryColor),
        onPressed: () {
          Navigator.pop(context);
        });
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> suggestionList = [];
    _getRecentSearchList(currentUserId);

    if (query.isEmpty) {
      suggestionList = recentList;
      if (suggestionList == null) {
        return Center(child: CircularProgressIndicator());
      }
      return ListView.builder(
        itemBuilder: (context, index) {
          return Padding(
              padding: EdgeInsets.all(5),
              child: ListTile(
                title: Text(suggestionList[index]),
                leading: Icon(Icons.history_outlined),
                onTap: () {
                  selectedResult = suggestionList[index];
                  showResults(context);
                  recentList.add(selectedResult);
                },
              ));
        },
        itemCount: suggestionList?.length,
      );
    } else {
      suggestionList.addAll(productList
          .where(
            (element) =>
                element.productName.toLowerCase().contains(query.toLowerCase()),
          )
          .map((element) => element.productName));
      return ListView.builder(
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(suggestionList[index]),
            onTap: () {
              selectedResult = suggestionList[index];
              showResults(context);
              _addRecentSearch(currentUserId, selectedResult);
            },
          );
        },
        itemCount: suggestionList?.length,
      );
    }
  }

  @override
  Widget buildResults(BuildContext context) {
    query = selectedResult;
    return Container(child: Center(child: Text('$selectedResult')));
  }
}
