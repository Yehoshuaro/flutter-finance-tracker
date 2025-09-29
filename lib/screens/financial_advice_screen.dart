import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../services/financial_advice_service.dart';
import '../main.dart';

class FinancialAdviceScreen extends StatefulWidget {
  const FinancialAdviceScreen({super.key});

  @override
  State<FinancialAdviceScreen> createState() => _FinancialAdviceScreenState();
}

class _FinancialAdviceScreenState extends State<FinancialAdviceScreen> {
  String _advice = '';
  bool _isLoading = false;

  Future<void> _getAdvice() async {
    setState(() {
      _isLoading = true;
    });

    final transactionProvider = context.read<TransactionProvider>();
    final transactions = transactionProvider.transactions;

    final spendingData = {
      'transactions': transactions.map((t) => {
        'amount': t.amount,
        'category': t.category ?? 'Без категории',
        'date': t.date.toIso8601String(),
      }).toList(),
      'total_spending': transactions.fold(0.0, (sum, t) => sum + t.amount),
      'spending_by_category': transactions.fold<Map<String, double>>(
        {},
        (map, t) {
          final category = t.category ?? 'Без категории';
          map[category] = (map[category] ?? 0) + t.amount;
          return map;
        },
      ),
    };

    final financialService = FinancialAdviceService();
    final advice = await financialService.getFinancialAdvice(spendingData);

    setState(() {
      _advice = advice;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _getAdvice();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Финансовый советник'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _getAdvice,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Персональный финансовый совет:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _advice,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}