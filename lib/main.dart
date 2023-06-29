import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hitungbudget/text_input.dart';
import 'package:intl/intl.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:http/http.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hitung Budget',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Hitung Budget Harian Sampai Gajian'),
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
  final DateFormat dateFormat = DateFormat("yyyy-MM-dd");
  late DateTime today;
  late DateTime tanggalGajian;
  final String _selamatDatang = "Selamat datang di penghitung budget :)";
  final Parser _parser = Parser();
  final ContextModel _contextModel = ContextModel();
  final Client _client = Client();
  Map<String, dynamic> holidayData = {};
  double _budgetHarian = 0;
  double _budgetEsokHari = 0;
  String _textResult = "";
  bool _supportOperations = false;
  bool _isAlreadyNextMonth = false;

  String dateFormatHelper(String date) {
    if (date.length < 2) return "0$date";
    return date;
  }

  String tanggalGajianString({String? bulanGajian, String hariGajian = "25"}) {
    String defaultBulanGajian =
        today.day < 25 ? today.month.toString() : (today.month + 1).toString();
    String bulan = bulanGajian ?? defaultBulanGajian;
    bulan = dateFormatHelper(bulan);
    hariGajian = dateFormatHelper(hariGajian);
    return '${today.year}-$bulan-$hariGajian';
  }

  _MyHomePageState() {
    var now = DateTime.now();
    today = dateFormat.parse("${now.year}-${dateFormatHelper(now.month.toString())}-${dateFormatHelper(now.day.toString())}");
    _textResult = _selamatDatang;
    _textResult = "Mohon tunggu ... :)";
    fetchHolidays(_client)
        .then((value) => _handleResponse(value))
        .onError((error, stackTrace) => _handleError(error, stackTrace));
  }

  Future<Response> fetchHolidays(Client client) async {
    return client.get(Uri.parse(
      'https://raw.githubusercontent.com/guangrei/APIHariLibur_V2/main/calendar.min.json',
    ));
  }

  @override
  void initState() {
    super.initState();
    textEditingController.addListener(() {
      if (!_supportOperations) {
        setState(() {
          _calculateBudget();
        });
      }
    });
  }

  void _calculateBudget() {
    int sisaHariMenujuGajian = (tanggalGajian.difference(today)).inDays;
    try {
      if (_supportOperations) {
        double parsedValue = _parser
            .parse(textEditingController.text)
            .evaluate(EvaluationType.REAL, _contextModel);
        setState(() {
          textEditingController.text = parsedValue.toInt().toString();
        });
      }
      _budgetHarian =
          int.parse(textEditingController.text) / sisaHariMenujuGajian;
      int esokHari = sisaHariMenujuGajian - 1;
      _budgetEsokHari = _budgetHarian;
      if (esokHari > 0) {
        _budgetEsokHari = int.parse(textEditingController.text) / esokHari;
      }
      _textResult =
          "Budget hari ini sampai gajian ${_budgetHarian.toInt()}, budget esok hari ${_budgetEsokHari.toInt()} apabila budget hari ini tidak digunakan :D";
    } catch (_) {
      if (textEditingController.text.isEmpty) {
        _textResult = _selamatDatang;
        return;
      }
      _textResult =
          "Inputnya bukan angka / kakak ingin pakai operasi matematika :)";
    }
  }

  void _reset() {
    setState(() {
      textEditingController.clear();
      _budgetHarian = 0;
      _budgetEsokHari = 0;
      _textResult = _selamatDatang;
    });
  }

  void _onChangedOperation(bool? value) {
    setState(() {
      _supportOperations = value!;
      _textResult = _selamatDatang;
    });
  }

  void _onPressedButton() {
    _calculateBudget();
  }

  bool checkWeekend(int weekDay) {
    return weekDay == DateTime.saturday || weekDay == DateTime.sunday;
  }

  _handleResponse(Response response) {
    setState(() {
      _textResult = _selamatDatang;
    });
    holidayData = json.decode(response.body);
    findPaydayDate();
  }

  void findPaydayDate() {
    String tanggalGajianText = _isAlreadyNextMonth
        ? tanggalGajianString(bulanGajian: (today.month + 1).toString())
        : tanggalGajianString();
    int hariGajian = dateFormat.parse(tanggalGajianText).day;
    bool isHoliday = holidayData[tanggalGajianText]?["holiday"] ?? false;
    bool loopPerformed = false;
    while (isHoliday) {
      if (!loopPerformed) loopPerformed = true;
      hariGajian--;
      String tanggalGajianLoop = _isAlreadyNextMonth
          ? tanggalGajianString(
              bulanGajian: (today.month + 1).toString(),
              hariGajian: hariGajian.toString())
          : tanggalGajianString(hariGajian: hariGajian.toString());
      isHoliday = holidayData[tanggalGajianLoop]?["holiday"] ?? false;
      if (!isHoliday) {
        int weekDayLoop = dateFormat.parse(tanggalGajianLoop).weekday;
        isHoliday = checkWeekend(weekDayLoop);
      }
    }
    // check weekend if loop is not performed
    if (!loopPerformed) {
      int weekDay = _isAlreadyNextMonth
          ? dateFormat
              .parse(tanggalGajianString(
                  bulanGajian: (today.month + 1).toString(),
                  hariGajian: hariGajian.toString()))
              .weekday
          : dateFormat
              .parse(tanggalGajianString(hariGajian: hariGajian.toString()))
              .weekday;
      if (weekDay == DateTime.sunday) hariGajian -= 2;
      if (weekDay == DateTime.saturday) hariGajian--;
    }
    tanggalGajian = _isAlreadyNextMonth
        ? tanggalGajian = dateFormat.parse(tanggalGajianString(
            bulanGajian: (today.month + 1).toString(),
            hariGajian: hariGajian.toString()))
        : dateFormat
            .parse(tanggalGajianString(hariGajian: hariGajian.toString()));
    if (today.day >= tanggalGajian.day && !_isAlreadyNextMonth) {
      _isAlreadyNextMonth = true;
      findPaydayDate();
    }
  }

  _handleError(Object? error, StackTrace stackTrace) {
    if (error != null) {
      if (kDebugMode) {
        print(error.toString());
      }
    }
    if (kDebugMode) {
      print(stackTrace.toString());
    }
    setState(() {
      _textResult = "Error mendapatkan data hari libur :(";
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
              "Masukkan uang anda hehehee :), btw inputnya support operasi matematika ya contoh: 100+750-20, tapi kamu harus centang dulu apakah mau support operasi, akan muncul tombol submit atau tekan enter agar operasi diproses",
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 13,
            ),
            const Text(
              "Untuk hasil pecahan kita bulatkan kak :)",
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 13,
            ),
            const Text(
              "Asumsi gajian tanggal 25, kalau tanggal 25 hari libur, gajian dimajukan ke tanggal hari kerja terdekat sebelumnya yaa :)",
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 13,
            ),
            Row(
              children: [
                Checkbox(
                  value: _supportOperations,
                  onChanged: _onChangedOperation,
                ),
                const Flexible(
                  child: Text(
                    "Support operasi",
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            TextInput(
              operationSupport: _supportOperations,
              onSubmitted: (_) => _calculateBudget(),
              textEditingController: textEditingController,
              label: "Total uang anda",
            ),
            if (_supportOperations)
              Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    onPressed: _onPressedButton,
                    child: const Text(
                      "Submit",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            const SizedBox(
              height: 2.5,
            ),
            Text(
              _textResult,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
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
