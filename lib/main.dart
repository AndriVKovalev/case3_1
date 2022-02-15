import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(
      home:  Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Counter(),
                SizedBox(height: 30,),
                CounterSecond(storage: CounterStorage()),
          ]
          ),
        ),
        appBar: AppBar(title: Text("Test")),)
  ));
}
class Counter extends StatefulWidget{
  Counter({ Key? key}) : super(key: key);
  @override
  _CounterState createState() => _CounterState();
}
class _CounterState extends State<Counter>{
  late SharedPreferences _prefs;
  int _value = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadVoluePref();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text ("Save into local storage"),
        Text("Count plus and minus $_value "),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                child: const Text("Plus", style: TextStyle(fontSize: 22)),
                onPressed: _setVoluePrefInc
            ),
            const SizedBox(width: 15),
            ElevatedButton(
                child: const Text("Minus", style: TextStyle(fontSize: 22)),
                onPressed:_setVoluePrefDec,
            ),
          ],
        ),
      ],
    );
  }
  void _setVoluePrefInc() async{
    final prefs = await SharedPreferences.getInstance();
    setState(() {
    _value = (prefs.getInt("Count") ?? 0 ) + 1 ;
    prefs.setInt("Count", _value);
    });
  }

  void _setVoluePrefDec() async{
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _value = (prefs.getInt("Count") ?? 0 ) - 1 ;
      prefs.setInt("Count", _value);
    });
  }


  void _loadVoluePref() async{
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _value = (prefs.getInt("Count") ?? 0);
    });
  }
}

class CounterSecond extends StatefulWidget{
  CounterSecond({ Key? key, required this.storage}) : super(key: key);

  final CounterStorage storage;

  @override
  _CounterSecondState createState() => _CounterSecondState();
}

class _CounterSecondState extends State<CounterSecond>{

  int _valueother = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.storage.readCounter().then((int value){
      setState(() {
        _valueother = value;
      });
    });
  }

   Future<File> _incrementCounter(){
    setState(() {
      _valueother++;
    });

    return widget.storage.writeCounter(_valueother);
   }

  Future<File> _decrementCounter(){
    setState(() {
      _valueother--;
    });

    return widget.storage.writeCounter(_valueother);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("Save into file"),
        Text("Count plus and minus $_valueother "),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                child: const Text("Plus", style: TextStyle(fontSize: 22)),
                onPressed: _incrementCounter
            ),
            const SizedBox(width: 15),
            ElevatedButton(
                child: const Text("Minus", style: TextStyle(fontSize: 22)),
                onPressed: _decrementCounter
            ),
          ],
        ),
      ],
    );
  }
}


class CounterStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/counter.txt');
  }


  Future<int> readCounter() async {
    try {
      final file = await _localFile;
      final contents = await file.readAsString();
      return int.parse(contents);
    } catch (e) {
      return 0;
    }
  }

  Future<File> writeCounter(int counter) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString('$counter');
  }
}

