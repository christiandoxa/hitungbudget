import 'package:flutter/material.dart';
import 'package:hitungbudget/text_input.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Hitung Budget',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Hitung Budget'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController textEditingController = TextEditingController();
  final DateFormat dateFormat = DateFormat("dd-MM-yyyy");
  final DateTime today = DateTime.now();
  late DateTime tanggalGajian;
  final String _selamatDatang = "Selamat datang di penghitung budget :)";
  double _budgetHarian = 0;
  String _textResult = "";


  _MyHomePageState() {
    _textResult = _selamatDatang;
    tanggalGajian = dateFormat.parse('25-${today.day < 25 ? today.month : today.month + 1}-${today.year}');
  }

  @override
  void initState() {
    super.initState();
    textEditingController.addListener(() {
      setState(() {
        _calculateBudget();
      });
    });
  }

  void _calculateBudget() {
    int sisaHariMenujuGajian = (tanggalGajian.difference(today)).inDays + 1; // hanya bisa tepat apabila dilakukan jam 12 pas
    try {
      _budgetHarian = int.parse(textEditingController.text) / sisaHariMenujuGajian;
      _textResult = "Budget harian sampai gajian ${_budgetHarian.toInt()}";
    } catch (_) {
      if (textEditingController.text.isEmpty) {
        _textResult = _selamatDatang;
        return;
      }
      _textResult = "Inputnya bukan angka kakak :)";
    }
  }

  void _reset() {
    setState(() {
      textEditingController.clear();
      _budgetHarian = 0;
      _textResult = _selamatDatang;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              "Masukkan uang anda hehehee :)",
            ),
            TextInput(
              textEditingController: textEditingController,
              label: "Total uang anda",
            ),
            Text(
              _textResult,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _reset,
        child: const Icon(Icons.restart_alt),
      ),
    );
  }
}
