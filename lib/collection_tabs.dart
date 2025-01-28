import 'package:eco_credit/wast_collection_card.dart';
import 'package:flutter/material.dart';

class CollectionTabs extends StatefulWidget {
  final int initialIndex;
  final bool showCompleted;

  CollectionTabs({this.initialIndex = 0, this.showCompleted = false});

  @override
  _CollectionTabsState createState() => _CollectionTabsState();
}

class _CollectionTabsState extends State<CollectionTabs> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<Tab> myTabs;
  late List<Widget> myTabViews;

  @override
  void initState() {
    super.initState();
    initializeTabs();
  }

  void initializeTabs() {
    myTabs = <Tab>[
      Tab(text: 'Pending'),
      Tab(text: 'Picked'),
    ];

    myTabViews = <Widget>[
      createListViewPending(), // Refactored to method for better readability
      createListViewPicked(),
    ];

    if (widget.showCompleted) {
      myTabs.add(Tab(text: 'Completed'));
      myTabViews.add(createListViewCompleted());
    }

    _tabController = TabController(length: myTabs.length, vsync: this, initialIndex: widget.initialIndex);
  }

  ListView createListViewPending() {
    return ListView(
      children: <Widget>[
        WasteCollectionCard(
          status: 'Pending',
          title: 'Cartoon',
          name: 'Mohammad',
          imageUrl: 'assets/images/carton.jpg',
          timeAgo: '2 hrs ago',
        ),
        WasteCollectionCard(
          status: 'Pending',
          title: 'Iron',
          name: 'Zaid',
          imageUrl: 'assets/images/iron.jpg',
          timeAgo: '4 hrs ago',
        ),
      ],
    );
  }

  ListView createListViewPicked() {
    return ListView(
      children: <Widget>[
        WasteCollectionCard(
          status: 'Picked',
          title: 'Plastic',
          name: 'Khalid',
          imageUrl: 'assets/images/plastic.jpg',
          timeAgo: '5 hrs ago',
        ),
      ],
    );
  }

  ListView createListViewCompleted() {
    return ListView(
      children: <Widget>[
        WasteCollectionCard(
          status: 'Completed',
          title: 'Paper',
          name: 'Sara',
          imageUrl: 'assets/images/paper.jpeg',
          timeAgo: '1 day ago',
        ),
      ],
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TabBar(
          controller: _tabController,
          tabs: myTabs,
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: myTabViews,
          ),
        ),
      ],
    );
  }
}
