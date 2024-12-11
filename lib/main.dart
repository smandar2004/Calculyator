import 'package:flutter/material.dart';

void main() => runApp(CalculatorApp());

class CalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Calculator(),
    );
  }
}

class Calculator extends StatefulWidget {
  @override
  _CalculatorState createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  String output = "0";
  String _output = "0";
  String expression = "";
  bool shouldResetOutput = false;

  void buttonPressed(String buttonText) {
    if (buttonText == "AC") {
      _output = "0";
      expression = "";
      shouldResetOutput = false;
    } else if (buttonText == "+/-") {
      if (_output != "0") {
        if (_output.startsWith("-")) {
          _output = _output.substring(1);
        } else {
          _output = "-" + _output;
        }
      }
    } else if (buttonText == "+" ||
        buttonText == "-" ||
        buttonText == "×" ||
        buttonText == "÷") {
      if (shouldResetOutput) {
        expression += " " + buttonText + " ";
      } else {
        expression += _output + " " + buttonText + " ";
        shouldResetOutput = true;
      }
      _output = "0";
    } else if (buttonText == "=") {
      expression += _output;
      try {
        expression = expression.replaceAll("×", "*").replaceAll("÷", "/");
        final parsedExpression = expression.replaceAll(",", "");
        final result = _evaluateExpression(parsedExpression);
        _output = result.toString();
        expression = "";
      } catch (e) {
        _output = "Error";
      }
      shouldResetOutput = true;
    } else if (buttonText == ",") {
      if (!_output.contains('.')) {
        _output += ".";
      }
    } else if (buttonText == "%") {
      // Now allow user to input the percentage they want to calculate
      _showPercentageDialog();
    } else {
      if (shouldResetOutput) {
        _output = buttonText;
        shouldResetOutput = false;
      } else {
        if (_output == "0") {
          _output = buttonText;
        } else {
          _output += buttonText;
        }
      }
    }

    setState(() {
      output = _formatNumber(_output);
    });
  }

  void _showPercentageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String percentage = '';
        return AlertDialog(
          title: Text("Enter percentage"),
          content: TextField(
            keyboardType: TextInputType.number,
            onChanged: (value) {
              percentage = value;
            },
            decoration: InputDecoration(hintText: "Enter percentage value"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                if (percentage.isNotEmpty) {
                  double percentageValue = double.parse(percentage) / 100;
                  _output =
                      (double.parse(_output) * percentageValue).toString();
                  setState(() {
                    output = _formatNumber(_output);
                  });
                }
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String _formatNumber(String number) {
    if (number == "Error") return number;

    List<String> parts = number.split('.');
    String integerPart = parts[0];
    String decimalPart = parts.length > 1 ? parts[1] : "";

    integerPart = integerPart.replaceAll(',', '');
    String formattedInteger = integerPart.replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]},");

    return decimalPart.isEmpty
        ? formattedInteger
        : "$formattedInteger.$decimalPart";
  }

  double _evaluateExpression(String expression) {
    final tokens = expression.split(' ');
    final stack = <double>[];
    final operators = <String>[];

    for (final token in tokens) {
      if (_isOperator(token)) {
        while (operators.isNotEmpty &&
            _precedence(operators.last) >= _precedence(token)) {
          final op = operators.removeLast();
          final b = stack.removeLast();
          final a = stack.removeLast();
          stack.add(_applyOperator(op, a, b));
        }
        operators.add(token);
      } else {
        stack.add(double.parse(token));
      }
    }

    while (operators.isNotEmpty) {
      final op = operators.removeLast();
      final b = stack.removeLast();
      final a = stack.removeLast();
      stack.add(_applyOperator(op, a, b));
    }

    return stack.last;
  }

  bool _isOperator(String token) {
    return token == "+" || token == "-" || token == "*" || token == "/";
  }

  int _precedence(String operator) {
    if (operator == "*" || operator == "/") {
      return 2;
    } else if (operator == "+" || operator == "-") {
      return 1;
    }
    return 0;
  }

  double _applyOperator(String operator, double a, double b) {
    switch (operator) {
      case "+":
        return a + b;
      case "-":
        return a - b;
      case "*":
        return a * b;
      case "/":
        if (b != 0) {
          return a / b;
        } else {
          throw Exception("Division by zero");
        }
    }
    throw Exception("Unknown operator");
  }

  Widget buildButton(String buttonText, Color color, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Container(
        margin: EdgeInsets.all(1.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.all(24.0),
            backgroundColor: color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
          ),
          child: Text(
            buttonText,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          onPressed: () => buttonPressed(buttonText),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Calculator'),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 24),
              child: Text(
                output,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  buildButton("AC", Colors.grey),
                  buildButton("+/-", Colors.grey),
                  buildButton("%", Colors.grey),
                  buildButton("÷", Colors.orange),
                ],
              ),
              Row(
                children: [
                  buildButton("7", Colors.grey.shade800),
                  buildButton("8", Colors.grey.shade800),
                  buildButton("9", Colors.grey.shade800),
                  buildButton("×", Colors.orange),
                ],
              ),
              Row(
                children: [
                  buildButton("4", Colors.grey.shade800),
                  buildButton("5", Colors.grey.shade800),
                  buildButton("6", Colors.grey.shade800),
                  buildButton("-", Colors.orange),
                ],
              ),
              Row(
                children: [
                  buildButton("1", Colors.grey.shade800),
                  buildButton("2", Colors.grey.shade800),
                  buildButton("3", Colors.grey.shade800),
                  buildButton("+", Colors.orange),
                ],
              ),
              Row(
                children: [
                  buildButton("0", Colors.grey.shade800, flex: 2),
                  buildButton(",", Colors.grey.shade800),
                  buildButton("=", Colors.orange),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
