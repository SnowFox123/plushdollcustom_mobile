import 'package:flutter/material.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Giao dịch',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Summary cards
            Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.green[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.trending_up,
                            color: Colors.green,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Thu nhập',
                            style: TextStyle(fontSize: 14, color: Colors.green),
                          ),
                          const Text(
                            '15,000,000',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    color: Colors.orange[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.trending_down,
                            color: Colors.orange,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Chi tiêu',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.orange,
                            ),
                          ),
                          const Text(
                            '5,000,000',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Lịch sử giao dịch',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) {
                  final isIncome = index % 3 == 0;
                  final amount = (index + 1) * 1000000;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isIncome
                            ? Colors.green[100]
                            : Colors.orange[100],
                        child: Icon(
                          isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                          color: isIncome ? Colors.green : Colors.orange,
                        ),
                      ),
                      title: Text(
                        isIncome
                            ? 'Thanh toán dự án ${index + 1}'
                            : 'Chi phí dự án ${index + 1}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        DateTime.now().subtract(Duration(days: index)).toString().substring(0, 10),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      trailing: Text(
                        '${isIncome ? '+' : '-'}${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} VNĐ',
                        style: TextStyle(
                          color: isIncome ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
