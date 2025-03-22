import 'package:eco_credit/services/dry_clean_service.dart';
import 'package:flutter/material.dart';

class OrderStatusPage extends StatefulWidget {
  const OrderStatusPage({super.key});

  @override
  State<OrderStatusPage> createState() => _OrderStatusPageState();
}

class _OrderStatusPageState extends State<OrderStatusPage> {
  final TextEditingController _orderNumberController = TextEditingController();
  final DryCleanApiService _apiService = DryCleanApiService();
  OrderStatusResource? _orderStatus;
  bool _isLoading = false;

  Future<void> _checkStatus() async {
    final orderNumber = _orderNumberController.text;
    
    if (orderNumber.isEmpty) {
      _showError('الرجاء إدخال رقم الطلب');
      return;
    }
    
    final parsedNumber = int.tryParse(orderNumber);
    if (parsedNumber == null) {
      _showError('رقم الطلب غير صحيح');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _apiService.getOrderStatusByoOrderNumber(parsedNumber);
      
      setState(() {
        _orderStatus = response;
        if (_orderStatus?.id == 0) {
          _showInfo('هذا الرقم غير موجود');
        }
      });
    } catch (e) {
      _showError('حدث خطأ: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('حالة الطلب'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _orderNumberController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'ادخل رقم الحساب',
                border: OutlineInputBorder(),
                hintText: 'مثال: 564',
              ),
            ),
            const SizedBox(height: 40),

            if (_orderStatus != null)
              _buildStatusIndicator(),

            const Spacer(),

            ElevatedButton.icon(
              onPressed: _isLoading ? null : _checkStatus,
              icon: _isLoading 
                  ? const CircularProgressIndicator()
                  : const Icon(Icons.refresh),
              label: Text(_isLoading ? 'جاري التحميل...' : 'تحديث'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    final status = _orderStatus!;
    
    if (status.id == 0) {
      return Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 100),
          const SizedBox(height: 20),
          const Text(
            'غير موجود',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          Text(
            'الرقم: ${_orderNumberController.text}',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 10),
          const Text(
            'هذا الرقم غير موجود في النظام',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      );
    }

    final isApproved = status.orderStatusID == 2;
    
    return Column(
      children: [
        Icon(
          isApproved ? Icons.check_circle : Icons.pending_actions,
          color: isApproved ? Colors.green : Colors.orange,
          size: 100,
        ),
        const SizedBox(height: 20),
        Text(
          isApproved ? 'جاهز' : 'قيد الإنتظار',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isApproved ? Colors.green : Colors.orange,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'رقم الطلب: ${status.orderNumber ?? _orderNumberController.text}',
          style: const TextStyle(fontSize: 18),
        ),
      ],
    );
  }
}