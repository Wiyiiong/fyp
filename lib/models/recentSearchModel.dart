import 'package:cloud_firestore/cloud_firestore.dart';

class RecentSearch {
  final String id;
  final String searchString;
  final DateTime searchDatetime;
  final int occurrences;

  RecentSearch({
    this.id,
    this.searchString,
    this.searchDatetime,
    this.occurrences,
  });

  factory RecentSearch.fromDoc(DocumentSnapshot doc) {
    return RecentSearch(
      id: doc.id,
      searchString: doc['searchString'],
      searchDatetime: DateTime.parse(doc['searchDatetime']),
      occurrences: doc['occurrences'],
    );
  }
}
