import 'package:eco_credit/services/api_service.dart';
import 'package:eco_credit/wast_collection_card.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Add this in your main app file (e.g., main.dart)
final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();

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

class _CollectionTabsState extends State<CollectionTabs>
  with SingleTickerProviderStateMixin, RouteAware {
  late final ApiService _apiService = ApiService();
  late TabController _tabController;
  List<Tab> myTabs = [];
  List<Widget> myTabViews = [];
  int _refreshKey = 0; // Track refresh state
  int _previousIndex = 0; 
  bool _isInitialized = false; // Track initialization status

  @override
  void initState() {
    super.initState();
    _initializeTabs(); // Start async initialization
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _tabController.dispose();
    super.dispose();
  }

  // Handle route visibility changes
  @override
  void didPush() {
    refreshData();
  }

  @override
  void didPopNext() {
    refreshData();
  }

  void _handleTabSelection() {
    // Check if the current index has changed from the previous
    if (_tabController.index != _previousIndex) {
      refreshData();
      _previousIndex = _tabController.index; // Update previous index
    }
  }

  void refreshData() {
    setState(() {
      _refreshKey++; // Increment to refresh FutureBuilders
    });
  }

 Future<void> _initializeTabs() async {
    // Initialize tabs asynchronously
    myTabs = <Tab>[
      const Tab(text: '♻️ قيد الانتظار '),
      const Tab(text: '♻️ تم الاستلام'),
    ];

    myTabViews = <Widget>[
      createListViewPending(),
      createListViewPicked(),
    ];

    if (widget.showCompleted) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String userType = prefs.getString('role') ?? 'Generator';

      if (userType == 'Generator') {
        myTabs.add(const Tab(text: '♻️ رفض'));
        myTabViews.add(createListViewCancelled());
      }

      myTabs.add(const Tab(text: '♻️ مكتمل'));
      myTabViews.add(createListViewCompleted());
    }

    // Initialize controller AFTER tabs are fully configured
    _tabController = TabController(
      length: myTabs.length,
      vsync: this,
      initialIndex: widget.initialIndex,
    );

    // Add listener only after controller exists
    _tabController.addListener(_handleTabSelection);
    _previousIndex = _tabController.index;

    // Trigger rebuild now that everything is ready
    setState(() => _isInitialized = true);
  }

  Future<ListView> createListView(int status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt('id') ?? 1;
    String userType = prefs.getString('role') ?? 'Generator';

    final collections = await _apiService.getCollections(status, userId: userId, userType: userType);
    return ListView.builder(
      itemCount: collections.length,
      itemBuilder: (context, index) {
        final collection = collections[index];
        return Container(
              margin: EdgeInsets.all(8.0), // Adds vertical margin between cards
              child: WasteCollectionCard(
                role: userType,
                collectionID: collection.collectionID,
                statusID: collection.collectionStatusID,
                status: collection.collectionStatusName ?? '',
                title: collection.wasteTypeName ?? '',
                collectionTypeName: collection.collectionTypeName ?? '',
                name: collection.generator?.name ?? '',
                pickerName: collection.picker?.name ?? '',
                imageUrl: collection.image ?? 'assets/images/default.jpg',
                collectionSize: collection.collectionSize ?? 0.00,
                timeAgo: _formatTimeAgo(collection.createdDate),
                description: collection.description ?? '',
                isInvoiced: collection.isInvoiced ?? false,
                invoiceSize: collection.invoice?.invoiceSize ?? 0.00,
                scarpyardOwner: collection.invoice?.scarpyardOwner ?? '',
                invoiceImage: collection.invoice?.image ?? '',
                generatorPhone: collection.generator?.phone ?? '',
                pickerPhone: collection.picker?.phone ?? '',
              ),
            );
      },
    );
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
    return 'الآن';
  }

  Widget createListViewPending() => RefreshIndicator(
    onRefresh: () async => refreshData(),
    child: FutureBuilder<ListView>(
      key: ValueKey('pending$_refreshKey'), // Unique key for refresh
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
                onPressed: () => refreshData(),
                child: const Text('Retry'),
              ),
            ],
          );
        }
        return snapshot.data ?? const Text('No pending collections');
      },
    ),
  );

  Widget createListViewPicked() => FutureBuilder<ListView>(
    key: ValueKey('picked$_refreshKey'),
    future: createListView(3),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      return snapshot.data ?? const Text('No picked collections');
    },
  );

  Widget createListViewCompleted() => FutureBuilder<ListView>(
    key: ValueKey('completed$_refreshKey'),
    future: createListView(4),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      return snapshot.data ?? const Text('No completed collections');
    },
  );

  Widget createListViewCancelled() => FutureBuilder<ListView>(
    key: ValueKey('cancelled$_refreshKey'),
    future: createListView(2),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      return snapshot.data ?? const Text('No cancelled collections');
    },
  );

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      children: <Widget>[
        TabBar(
          controller: _tabController,
          tabs: myTabs,
          labelColor: Color(0xFF3F9A25), // Active tab text color
          unselectedLabelColor: Colors.grey, // Unselected tab text color
          indicatorColor: Color(0xFF3F9A25), 
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