import 'package:eco_credit/dry-clean/dry_clean_collection.dart';
import 'package:eco_credit/services/dry_clean_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  int _refreshKey = 0;
  int pageSize = 5;

  // Pagination state per status (1: pending, 3: picked)
  Map<int, int> currentPages = {1: 1, 3: 1};
  Map<int, int> totalPagesMap = {1: 1, 3: 1};

  @override
  void initState() {
    super.initState();
    initializeTabs();
    _tabController.addListener(_handleTabSelection);
  }

  @override
  void didPush() => refreshData();
  @override
  void didPopNext() => refreshData();

  void refreshData() {
    setState(() {
      _refreshKey++;
    });
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) refreshData();
  }

  void initializeTabs() {
    myTabs = const [Tab(text: 'قيد الإنتظار'), Tab(text: 'جاهز')];
    myTabViews = [createListViewPending(), createListViewPicked()];
    _tabController = TabController(
      length: myTabs.length,
      vsync: this,
      initialIndex: widget.initialIndex,
    );
  }

  Future<List<DonationResource>> _fetchDonations(int status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt('id') ?? 1;
    String userType = prefs.getString('role') ?? 'Donater';
    int? apiUserId = (userType == 'DCAdmin') ? null : userId;

    final collections = await _apiService.getAllDonations(
      status,
      apiUserId,
      currentPages[status]!,
      pageSize,
    );

    // Update total pages for current status
    totalPagesMap[status] = ((collections.rowsCount ?? 0) / pageSize).ceil();

    return collections.lstData; // Directly return the list of DonationResource
  }

  Future<Widget> createListView(int status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt('id') ?? 1;
    String userType = prefs.getString('role') ?? 'Donater';
    int? apiUserId = (userType == 'DCAdmin') ? null : userId;

    final collections = await _apiService.getAllDonations(
      status,
      apiUserId,
      currentPages[status]!,
      pageSize,
    );

    totalPagesMap[status] = ((collections.rowsCount ?? 0) / pageSize).ceil();

    return Column(
      children: [
        if (collections.lstData.isEmpty)
          _buildEmptyState()
        else
          Expanded(
            child: ListView.builder(
              itemCount: collections.lstData.length,
              itemBuilder: (context, index) => dryCleanCollectionCard(
                role: userType,
                id: collections.lstData[index].id,
                size: collections.lstData[index].size ?? 0.00,
                locationName: collections.lstData[index].locationName ?? 'Unknown',
                typesNames: collections.lstData[index].typesNames ?? ['Unknown'],
                image: collections.lstData[index].image ?? 'assets/images/default.jpg',
                donationStatusName: collections.lstData[index].donationStatusName ?? 'Unknown',
                donaterName: collections.lstData[index].donater?.name ?? 'Unknown',
                timeAgo: _formatTimeAgo(collections.lstData[index].createdAt),
                description: ' ',
                donaterPhone: collections.lstData[index].donater?.phone ?? '',
              ),
            ),
          ),
        _buildPaginationControls(status),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.withOpacity(0.5)),
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
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationControls(int status) {
    final currentPage = currentPages[status]!;
    final totalPages = totalPagesMap[status]!;

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
          Text('الصفحة $currentPage من $totalPages', style: const TextStyle(fontSize: 16)),
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
      _refreshKey++; // Force FutureBuilder refresh with new page
    });
  }

  String _formatTimeAgo(DateTime? date) {
    if (date == null) return 'Unknown time';
    final difference = DateTime.now().difference(date);

    if (difference.inDays > 0) return 'من ${difference.inDays} يوم';
    if (difference.inHours > 0) return 'من ${difference.inHours} ساعة';
    if (difference.inMinutes > 0) return 'من ${difference.inMinutes} دقيقة';
    return 'الآن';
  }

  Widget createListViewPending() => RefreshIndicator(
    onRefresh: () async {
      setState(() => currentPages[1] = 1);
      refreshData();
    },
    child: FutureBuilder<Widget>(
      key: ValueKey('pending${_refreshKey}_page${currentPages[1]}'),
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
                onPressed: refreshData,
                child: const Text('Retry'),
              ),
            ],
          );
        }
        return snapshot.data ?? const Text('No pending collections');
      },
    ),
  );

  Widget createListViewPicked() => RefreshIndicator(
    onRefresh: () async {
      setState(() => currentPages[3] = 1);
      refreshData();
    },
    child: FutureBuilder<Widget>(
    key: ValueKey('picked${_refreshKey}_page${currentPages[3]}'),
      future: createListView(3),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        return snapshot.data ?? const Text('No picked collections');
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(controller: _tabController, tabs: myTabs),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [createListViewPending(), createListViewPicked()],
          ),
        ),
      ],
    );
  }
}