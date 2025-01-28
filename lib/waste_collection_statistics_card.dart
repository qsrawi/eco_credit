import 'package:flutter/material.dart';

class WasteCollectionStatisticsCard extends StatelessWidget {
  final int pending;
  final int completed;
  final int inProgress;
  final int cancelled;

  WasteCollectionStatisticsCard({
    required this.pending,
    required this.completed,
    required this.inProgress,
    required this.cancelled,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _buildStatColumn('Pending', pending),
            _buildStatColumn('Completed', completed),
            _buildStatColumn('In Progress', inProgress),
            _buildStatColumn('Cancelled', cancelled),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
