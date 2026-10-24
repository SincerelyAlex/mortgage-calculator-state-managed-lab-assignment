// Alex Hoang

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => MortgageProvider(),
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Mortgage Calculator V0',
      home: DisplayScreen(),
    );
  }
}

class MortgageCalculator {
  double amount = 100000;
  int years = 30;
  double rate = 0.035;

  void setAmount (double newAmountInput) {
    if (newAmountInput >= 0) {
      amount = newAmountInput;
    }
  }

  void setYears(int newYearInput) {
    if (newYearInput >= 0) {
      years = newYearInput;
    }
  }

  void setRate(double newRateInput) {
    if (newRateInput >= 0) {
      rate = newRateInput / 100;
    }
  }

  double getAmount() {
    return amount;
  }

  int getYears() {
    return years;
  }

  double getRate() {
    return rate;
  }

  double calculateMonthlyPayment() {
    double principal = double.parse(amount.toStringAsFixed(2));
    double monthlyRate = rate / 12;
    int totalPayments = years * 12;
    double monthlyPayment = (principal * monthlyRate * pow((1 + monthlyRate), totalPayments))
    / (pow(1 + monthlyRate, totalPayments) - 1);
    return monthlyPayment;
  }
  
  double calculateTotalPayment() {
    return calculateMonthlyPayment() * 12 * years;
  }

}

List<double> buildRateOptions() {
  var rates = <double>[];
  for (double rate = 2.0; rate <= 15.0; rate += 0.25) {
    rates.add(rate);
  }
  return rates;
}

class MortgageProvider extends ChangeNotifier {
  static const String amountKey = 'amount';
  static const String yearsKey = 'years';
  static const String rateKey = 'rate';

  final MortgageCalculator _mortgage = MortgageCalculator();
  double _ratePercent = 3.5;
  bool _termsAccepted = false;

  MortgageProvider() {
    _loadSavedInputs();
  }

  double get amount => _mortgage.getAmount();
  int get years => _mortgage.getYears();
  double get ratePercent => _ratePercent;
  double get monthlyPayment => _mortgage.calculateMonthlyPayment();
  double get totalPayment => _mortgage.calculateTotalPayment();
  bool get termsAccepted => _termsAccepted;

  Future<void> _loadSavedInputs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _mortgage.setAmount(prefs.getDouble(amountKey) ?? amount);
    _mortgage.setYears(prefs.getInt(yearsKey) ?? years);
    _ratePercent = prefs.getDouble(rateKey) ?? _ratePercent;
    _mortgage.setRate(_ratePercent);
    notifyListeners();
  }

  void setTermsAccepted(bool accepted) {
    _termsAccepted = accepted;
    notifyListeners();
  }

  Future<void> setChanges(double? newAmount, int newYears, double newRatePercent) async {
    if (newAmount != null) {
      _mortgage.setAmount(newAmount);
    }
    _mortgage.setYears(newYears);
    _mortgage.setRate(newRatePercent);
    _ratePercent = newRatePercent;
    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(amountKey, amount);
    await prefs.setInt(yearsKey, years);
    await prefs.setDouble(rateKey, _ratePercent);
  }
}

class DisplayScreen extends StatelessWidget {
  const DisplayScreen({super.key});

  String _money(double value) {
    return '\$${value.toStringAsFixed(2)}';
  }

  void _modify(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const EditingScreen()),
    );
  }

  void _userTermsChanged(BuildContext context, bool? value) {
    if (value == true) {
      _showTermsDialog(context);
    }
    else {
      context.read<MortgageProvider>().setTermsAccepted(false);
    }
  }

  void _showTermsDialog(BuildContext context) {
    final MortgageProvider mortgage = context.read<MortgageProvider>();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Terms and Conditions'),
          content: const Text('Please accept the terms and conditions to proceed.'),
          actions: <Widget>[
           TextButton(
              onPressed: () {
                mortgage.setTermsAccepted(false);
                Navigator.of(context).pop();
              },
              child: const Text('Decline'),
            ),
            TextButton(
              onPressed: () {
                mortgage.setTermsAccepted(true);
                  Navigator.of(context).pop();
              },
              child: const Text('Accept'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDisplayPage(BuildContext context, MortgageProvider mortgage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              const SizedBox(
                width: 150,
                child: Text('Amount:', style: TextStyle(fontSize: 16)),
              ),
              Text(_money(mortgage.amount)),
            ],
          )
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              const SizedBox(
                width: 150,
                child: Text('Years:', style: TextStyle(fontSize: 16)),
              ),
              Text('${mortgage.years}'),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              const SizedBox(
                width: 150,
                child: Text('Interest Rate:', style: TextStyle(fontSize: 16)),
              ),
              Text('${mortgage.ratePercent}%'),
            ]
          )

        ),
        const Divider(color: Colors.black),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              const SizedBox(
                width: 150,
                child: Text('Monthly Payment:', style: TextStyle(fontSize: 16)),
              ),
              Text(_money(mortgage.monthlyPayment), style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              const SizedBox(
                width: 150,
                child: Text('Total Payment:', style: TextStyle(fontSize: 16)),
              ),
              Text(_money(mortgage.totalPayment), style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
        CheckboxListTile(
          title: const Text('Terms and Conditions', style: TextStyle(fontSize: 16)),
          value: mortgage.termsAccepted,
          onChanged: (bool? value) => _userTermsChanged(context, value),
        ),
        const SizedBox(height: 16),
        Center(
          child: ElevatedButton(
            onPressed: () => _modify(context),
            child: const Text('Modify Data'),
          )
        )
      ]
    );
  }

  @override
  Widget build(BuildContext context) {
    final MortgageProvider mortgage = context.watch<MortgageProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mortgage Calculator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildDisplayPage(context, mortgage),
      )
    );
  }

}

class EditingScreen extends StatefulWidget {
  const EditingScreen({super.key});

  @override
  State<EditingScreen> createState() => _EditingScreenState();
}

class _EditingScreenState extends State<EditingScreen> {
  final _rateOptions = buildRateOptions();
  late final TextEditingController _amountController;
  late int _selectedYears;
  late double _selectedRate;

  @override
  void initState() {
    super.initState();
    final MortgageProvider mortgage = context.read<MortgageProvider>();
    _amountController = TextEditingController(text: mortgage.amount.toStringAsFixed(2));
    _selectedYears = mortgage.years;
    _selectedRate = mortgage.ratePercent;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _setChanges() {
    final double? amount = double.tryParse(_amountController.text);
    context.read<MortgageProvider>().setChanges(amount, _selectedYears, _selectedRate);
    Navigator.of(context).pop();
  }

  Widget _yearsOptions(int years) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<int>(value: years),
        Text('$years', style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _buildEditingPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RadioGroup<int>(
          groupValue: _selectedYears,
          onChanged: (int? value) {
            setState(() {
              _selectedYears = value!;
            });
          },
          child: Row(
            children: [
              const SizedBox(
                width: 150,
                child: Text('Years:', style: TextStyle(fontSize: 16)),
              ),
              _yearsOptions(10),
              _yearsOptions(15),
              _yearsOptions(30),
            ],
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top:12),
              child: SizedBox(
                width: 150,
                child: Text('Amount', style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            Expanded(
              child: TextField(
                controller: _amountController,
                style: const TextStyle(fontSize: 16),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Enter loan amount',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: SizedBox(
                  width: 150,
                  child: Text('Interest Rate', style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  children: _rateOptions.map((double rate) {
                    final bool isSelected = rate == _selectedRate;
                    return ListTile(
                      title: Text('$rate%',
                      style: const TextStyle(fontSize: 16),
                      ),
                      selected: isSelected,
                      onTap: () {
                        setState(() {
                          _selectedRate = rate;
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ],

          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: ElevatedButton(
            onPressed: _setChanges,
            child: const Text('Done'),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mortgage Calculator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildEditingPage(),
      )
    );
  }

}


