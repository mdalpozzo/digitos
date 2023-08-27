import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class NumberOption {
  const NumberOption(
      {required this.id, required this.value, required this.selected});

  final String id;
  final int value;
  final bool selected;
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<NumberOption> options = [
    const NumberOption(id: '1', value: 1, selected: false),
    const NumberOption(id: '2', value: 2, selected: false),
    const NumberOption(id: '3', value: 3, selected: false),
    const NumberOption(id: '4', value: 4, selected: false),
    const NumberOption(id: '5', value: 5, selected: false),
    const NumberOption(id: '6', value: 6, selected: false)
  ];

  _selectNumber({required String id, required int number}) {
    void innerSelect(bool? selected) {
      setState(() {
        options = options.map((option) {
          if (option.id == id) {
            return NumberOption(
              id: option.id,
              value: option.value,
              selected: selected == true,
            );
          } else {
            return option;
          }
        }).toList();
      });
    }

    return innerSelect;
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 120),
          child: Column(
            // Column is also a layout widget. It takes a list of children and
            // arranges them vertically. By default, it sizes itself to fit its
            // children horizontally, and tries to be as tall as its parent.
            //
            // Column has various properties to control how it sizes itself and
            // how it positions its children. Here we use mainAxisAlignment to
            // center the children vertically; the main axis here is the vertical
            // axis because Columns are vertical (the cross axis would be
            // horizontal).
            //
            // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
            // action in the IDE, or press "p" in the console), to see the
            // wireframe for each widget.
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Select numbers...',
              ),
              for (var numberOption in options)
                // Checkbox(
                //   value: numberOption.selected,
                // onChanged: _selectNumber(
                //   id: numberOption.id,
                //   number: numberOption.value,
                // ),
                // )
                CheckboxListTile(
                  title: Text(numberOption.value.toString()),
                  value: numberOption.selected,
                  onChanged: _selectNumber(
                    id: numberOption.id,
                    number: numberOption.value,
                  ),
                  // controlAffinity:
                  //     ListTileControlAffinity.leading, //  <-- leading Checkbox
                )
            ],
          ),
        ),
      ),
    );
  }
}
