import 'package:eco_credit/services/api_service.dart';
import 'package:eco_credit/wast_collection_card.dart';
import 'package:flutter/material.dart';

class CollectionTabs extends StatefulWidget {
  final int initialIndex;
  final bool showCompleted;

  const CollectionTabs({
    this.initialIndex = 0,
    this.showCompleted = false,
    Key? key,
  }) : super(key: key);

  @override
  State<CollectionTabs> createState() => _CollectionTabsState();
}

class _CollectionTabsState extends State<CollectionTabs> with SingleTickerProviderStateMixin {
  late final ApiService _apiService = ApiService();
  late TabController _tabController;
  List<Tab> myTabs = [];
  List<Widget> myTabViews = [];

  @override
  void initState() {
    super.initState();
    initializeTabs();
  }

  void initializeTabs() {
    myTabs = <Tab>[
      const Tab(text: 'بالانتظار'),
      const Tab(text: 'في الطريق'),
    ];

    myTabViews = <Widget>[
      createListViewPending(),
      createListViewPicked(),
    ];

    if (widget.showCompleted) {
      myTabs.add(const Tab(text: 'اكتملت'));
      myTabViews.add(createListViewCompleted());
    }

    _tabController = TabController(
      length: myTabs.length,
      vsync: this,
      initialIndex: widget.initialIndex,
    );
  }

  Future<ListView> createListView(int status) async {
    try {
      final collections = await _apiService.getCollections(
        status,
        userId: 1, // Replace with actual user ID
        userType: 'generator' // Replace with actual user type
      );
      
      return ListView(
        children: collections.map((collection) => WasteCollectionCard(
          status: collection.collectionStatusName ?? 'Unknown',
          title: collection.wasteTypeName ?? 'Unknown',
          name: collection.generator?.name ?? 'Unknown',
          imageUrl: collection.image ?? 'assets/images/default.jpg',
          timeAgo: _formatTimeAgo(collection.createdDate),
        )).toList(),
      );
    } catch (e) {
      return ListView(children: [Text('Error: ${e.toString()}')]);
    }
  }

  String _formatTimeAgo(DateTime? date) {
    if (date == null) return 'Unknown time';
    final difference = DateTime.now().difference(date);
    
    if (difference.inDays > 0) {
      return 'من ${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return 'من ${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return 'من ${difference.inMinutes} دقيقة';
    }
    return 'Just now';
  }

  // Update list view methods to handle async
  Widget createListViewPending() => FutureBuilder<ListView>(
    future: createListView(1),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      if (snapshot.hasError) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 40),
            Text('Error: ${snapshot.error}'),
            ElevatedButton(
              onPressed: () => setState(() {}),
              child: const Text('Retry'),
            ),
          ],
        );
      }
      return snapshot.data ?? const Text('No pending collections');
    },
  );

  Widget createListViewPicked() => FutureBuilder<ListView>(
    future: createListView(3),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      return snapshot.data ?? const Text('No picked collections');
    },
  );

  Widget createListViewCompleted() => FutureBuilder<ListView>(
    future: createListView(4),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      return snapshot.data ?? const Text('No completed collections');
    },
  );

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