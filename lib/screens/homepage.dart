import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

final fb = FirebaseDatabase.instance;

class _HomepageState extends State<Homepage> {
  final refer = fb.ref().child('cities');
  List<bool?> isChecked = [];
  Map citiesSelected = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              child: FirebaseAnimatedList(
                  query: refer,
                  itemBuilder: (context, snapshot, animation, index) {
                    isChecked.add(false);
                    return Container(
                      padding: const EdgeInsets.all(5),
                      child: CheckboxListTile(
                          value: isChecked[index],
                          onChanged: (value) {
                            setState(() {
                              isChecked[index] = value;
                              if (value == true) {
                                citiesSelected.addAll({
                                  '$index': {'name': snapshot.value.toString()}
                                });
                                print(citiesSelected);
                              } else {
                                citiesSelected.remove('$index');
                              }
                            });
                          },
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          tileColor: Colors.indigo[100],
                          title: Text(
                            snapshot.value.toString(),
                            style: const TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                    );
                  })),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                if (citiesSelected.isEmpty)
                  _showDialog(context);
                else
                  deleteCities();
              },
              icon: const Icon(Icons.delete),
              label: const Text('Delete City'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                addCity(context);
              },
              icon: const Icon(Icons.add),
              label: const Text('Add City'),
            )
          ],
        ),
      )),
    );
  }

  Future deleteCities() async {
    var citiesDup = citiesSelected;
    for (var k in citiesDup.keys) {
      DatabaseEvent eventsnap =
          await refer.orderByValue().equalTo(citiesDup[k]['name']).once();
      Map data = eventsnap.snapshot.value as Map;
      for (var k in data.keys) {
        refer.child(k.toString()).remove();
      }
    }
    citiesSelected.clear();
    for (int i = 0; i < isChecked.length; i++) {
      isChecked[i] = false;
    }
  }

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Alert!"),
          content: const Text("No city selected"),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future addCity(BuildContext context) async {
    String cityName = '';

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("New City"),
            content: TextField(
              onChanged: (value) {
                cityName = value;
              },
              decoration: InputDecoration(hintText: 'City'),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text("Add"),
                onPressed: () {
                  refer.push().set(cityName).asStream();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }
}
