import 'package:eco_credit/services/api_service.dart';
import 'package:eco_credit/wast_collection_card.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  int _refreshKey = 0;
  int _previousIndex = 0;
  bool _isInitialized = false;
  int pageSize = 5;
  late String _userType;

  Map<int, int> currentPages = {1: 1, 2: 1, 3: 1, 4: 1};
  Map<int, int> totalPagesMap = {1: 1, 2: 1, 3: 1, 4: 1};

  @override
  void initState() {
    super.initState();
    _initializeTabs();
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

  @override
  void didPush() {
    refreshData();
  }

  @override
  void didPopNext() {
    refreshData();
  }

  void _handleTabSelection() {
    if (_tabController.index != _previousIndex) {
      refreshData();
      _previousIndex = _tabController.index;
    }
  }

  void refreshData() {
    setState(() {
      _refreshKey++;
    });
  }

  Future<void> _initializeTabs() async {
    final prefs = await SharedPreferences.getInstance();
    _userType = prefs.getString('role') ?? 'Generator';

    // Initialize pagination for all potential statuses
    currentPages = {1: 1, 2: 1, 3: 1, 4: 1};
    totalPagesMap = {1: 1, 2: 1, 3: 1, 4: 1};

    // Initialize tab controller first
    _tabController = TabController(
      length: _calculateTabCount(),
      vsync: this,
      initialIndex: widget.initialIndex,
    );
    _tabController.addListener(_handleTabSelection);
    _previousIndex = _tabController.index;

    setState(() => _isInitialized = true);
  }

  int _calculateTabCount() {
    int count = 2; // Always have Pending and Picked
    if (widget.showCompleted) {
      count += 1; // Completed
      if (_userType == 'Generator') {
        count += 1; // Cancelled
      }
    }
    return count;
  }

  Future<Widget> createListView(int status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt('id') ?? 1;
    String userType = prefs.getString('role') ?? 'Generator';

    int currentPage = currentPages[status] ?? 1;
    final collections = await _apiService.getCollections(
      status,
      userId: userId,
      userType: userType,
      page: currentPage,
      pageSize: pageSize,
    );

    totalPagesMap[status] = ((collections.rowsCount ?? 0) / pageSize).ceil();

    if (collections.lstData.isEmpty) {
      return Column(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.inbox_outlined,
                          size: 64, color: Colors.grey.withOpacity(0.5)),
                      const SizedBox(height: 16),
                      Text(
                        'لا توجد مجموعات',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'لا توجد أي مجموعات لعرضها في هذا القسم',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          _buildPaginationControls(status),
        ],
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: collections.lstData.length,
            itemBuilder: (context, index) {
              final collection = collections.lstData[index];
              return Container(
                margin: const EdgeInsets.all(8.0),
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
                  invoiceImage: collection.invoice?.image ?? '',
                  generatorPhone: collection.generator?.phone ?? '',
                  pickerPhone: collection.picker?.phone ?? '',
                  invoiceID: collection.invoiceID ?? 1,
                ),
              );
            },
          ),
        ),
        _buildPaginationControls(status),
      ],
    );
  }

  Widget _buildPaginationControls(int status) {
    final currentPage = currentPages[status]!;
    final totalPages = totalPagesMap[status]!;

    if (totalPages <= 1) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: currentPage > 1
                ? () => _updatePage(status, currentPage - 1)
                : null,
          ),
          Text('الصفحة $currentPage من $totalPages',
              style: const TextStyle(fontSize: 16)),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: currentPage < totalPages
                ? () => _updatePage(status, currentPage + 1)
                : null,
          ),
        ],
      ),
    );
  }

  void _updatePage(int status, int newPage) {
    setState(() {
      currentPages[status] = newPage;
      _refreshKey++;
    });
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
        child: FutureBuilder<Widget>(
          key: ValueKey('pending$_refreshKey'),
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

  Widget createListViewPicked() => FutureBuilder<Widget>(
        key: ValueKey('picked$_refreshKey'),
        future: createListView(3),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return snapshot.data ?? const Text('No picked collections');
        },
      );

  Widget createListViewCompleted() => FutureBuilder<Widget>(
        key: ValueKey('completed$_refreshKey'),
        future: createListView(4),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return snapshot.data ?? const Text('No completed collections');
        },
      );

  Widget createListViewCancelled() => FutureBuilder<Widget>(
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
          tabs: _buildTabs(),
          labelColor: const Color(0xFF3F9A25),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF3F9A25),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: _buildTabViews(),
          ),
        ),
      ],
    );
  }

  List<Tab> _buildTabs() {
    final tabs = <Tab>[
      const Tab(text: '♻️ قيد الانتظار'),
      const Tab(text: '♻️ تم الاستلام'),
    ];

    if (widget.showCompleted) {
      if (_userType == 'Generator') {
        tabs.add(const Tab(text: '♻️ رفض'));
      }
      tabs.add(const Tab(text: '♻️ مكتمل'));
    }

    return tabs;
  }

  List<Widget> _buildTabViews() {
    final views = <Widget>[
      createListViewPending(),
      createListViewPicked(),
    ];

    if (widget.showCompleted) {
      if (_userType == 'Generator') {
        views.add(createListViewCancelled());
      }
      views.add(createListViewCompleted());
    }

    return views;
  }
}