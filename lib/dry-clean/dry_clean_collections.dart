import 'package:eco_credit/dry-clean/dry_clean_collection.dart';
import 'package:eco_credit/services/dry_clean_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Add this in your main app file (e.g., main.dart)
final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();

class DryCleanCollectionTabs extends StatefulWidget {
  final int initialIndex;
  final bool showCompleted;

  const DryCleanCollectionTabs({
    this.initialIndex = 0,
    this.showCompleted = false,
    Key? key,
  }) : super(key: key);

  @override
  State<DryCleanCollectionTabs> createState() => _CollectionTabsState();
}

class _CollectionTabsState extends State<DryCleanCollectionTabs>
  with SingleTickerProviderStateMixin, RouteAware {
  late final DryCleanApiService _apiService = DryCleanApiService();
  late TabController _tabController;
  List<Tab> myTabs = [];
  List<Widget> myTabViews = [];
  int _refreshKey = 0; // Track refresh state

  @override
  void initState() {
    super.initState();
    initializeTabs();
    _tabController.addListener(_handleTabSelection);
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
    _tabController.removeListener(_handleTabSelection);
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

  void refreshData() {
    setState(() {
      _refreshKey++; // Increment to refresh FutureBuilders
    });
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      refreshData();
    }
  }

  void initializeTabs() {
    myTabs = <Tab>[
      const Tab(text: 'بالانتظار'),
      const Tab(text: 'جاهز'),
    ];

    myTabViews = <Widget>[
      createListViewPending(),
      createListViewPicked(),
    ];

    _tabController = TabController(
      length: myTabs.length,
      vsync: this,
      initialIndex: widget.initialIndex,
    );
  }

  Future<ListView> createListView(int status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt('id') ?? 1;
    String userType = prefs.getString('role') ?? 'Donater';

    int? apiUserId = (userType == 'DCAdmin') ? null : userId;

  // Make the API call with conditional userId
  final collections = await _apiService.getAllDonations(status, apiUserId);
    return ListView.builder(
      itemCount: collections.length,
      itemBuilder: (context, index) {
        final collection = collections[index];
        return dryCleanCollectionCard(
          role: userType,
          id: collection.id,
          size: collection.size ?? 0.00,
          locationName: collection.locationName ?? 'Unknown',
          typesNames: collection.typesNames ?? ['Unknown'],
          image: collection.image ?? 'assets/images/default.jpg',
          donationStatusName: collection.donationStatusName ?? 'Unknown',
          donaterName: collection.donater?.name ?? 'Unknown',
          timeAgo: _formatTimeAgo(collection.createdAt),
          description: ' ',
          donaterPhone: collection.donater?.phone ?? ''
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