// Alex Hoang

import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Mortgage Calculator V0',
      home: MortgageScreen(),
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

class MortgageScreen extends StatefulWidget {
  const MortgageScreen({super.key});

  @override
  State<MortgageScreen> createState() => _MortgageScreenState();
}

class _MortgageScreenState extends State<MortgageScreen> {
  final MortgageCalculator _mortgage = MortgageCalculator();
  final _amountController = TextEditingController(text: '100000.00');
  final _rateOptions = buildRateOptions();

  bool _userEditingValues = false;
  bool _termsAccepted = false;
  int _selectedYears = 30;
  double _selectedRate = 3.5;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  String _money(double value) {
    return '\$${value.toStringAsFixed(2)}';
  }

  void _modify(){
    setState(() {
      _userEditingValues = true;
    });
  }

  void _setChanges() {
    final double? amount = double.tryParse(_amountController.text);
    if (amount != null) {
      _mortgage.setAmount(amount);
    }
    _mortgage.setYears(_selectedYears);
    _mortgage.setRate(_selectedRate);
    setState(() {
      _userEditingValues = false;
    });
  }

  void _userTermsChanged(bool? value) {
    if (value == true) {
      _showTermsDialog(context);
    }
    else {
      setState(() {
        _termsAccepted = false;
      });
    }
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Terms and Conditions'),
          content: const Text('Please accept the terms and conditions to proceed.'),
          actions: <Widget>[
           TextButton(
              onPressed: () {
                setState(() {
                  _termsAccepted = false;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Decline'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _termsAccepted = true;
                });
                  Navigator.of(context).pop();
              },
              child: const Text('Accept'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDisplayPage() {
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
              Text(_money(_mortgage.getAmount())),
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
              Text('$_selectedYears'),
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
              Text('$_selectedRate%'),
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
              Text(_money(_mortgage.calculateMonthlyPayment()), style: const TextStyle(fontSize: 16)),
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
              Text(_money(_mortgage.calculateTotalPayment()), style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
        CheckboxListTile(
          title: const Text('Terms and Conditions', style: TextStyle(fontSize: 16)),
          value: _termsAccepted,
          onChanged: _userTermsChanged,
        ),
        const SizedBox(height: 16),
        Center(
          child: ElevatedButton(
            onPressed: _modify,
            child: const Text('Modify Data'),
          )
        )
      ]
    );
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
        child: _userEditingValues ? _buildEditingPage() : _buildDisplayPage(),
      )
    );
  }

}


