import 'package:flutter/material.dart';

class WasteCollectionStatisticsCard extends StatelessWidget {
  final int pending;
  final int completed;
  final int inProgress;
  final int cancelled;

  const WasteCollectionStatisticsCard({super.key, 
    required this.pending,
    required this.completed,
    required this.inProgress,
    required this.cancelled,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(4, 1, 4, 2),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _buildStatColumn('في الانتظار ♻️', pending, Colors.amber),
            _buildStatColumn('في الطريق ♻️', inProgress, Colors.blue),
            _buildStatColumn('اكتملت ♻️', completed, Colors.green),
            _buildStatColumn('ألغيت', cancelled, Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, int count, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getIconForLabel(label),
            color: color,
            size: 24,
          ),
        ),
        SizedBox(height: 8),
        Text(
          count.toString(),
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  IconData _getIconForLabel(String label) {
    switch (label) {
      case 'في الانتظار ♻️':
        return Icons.hourglass_empty;
      case 'اكتملت ♻️':
        return Icons.check_circle;
      case 'في الطريق ♻️':
        return Icons.directions_car;
      case 'ألغيت':
        return Icons.cancel;
      default:
        return Icons.error;
    }
  }
}