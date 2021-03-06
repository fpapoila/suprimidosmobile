import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:suprimidospt/constants/locations.dart';
import 'package:suprimidospt/constants/endpoints.dart';
import 'package:suprimidospt/models/delayed.dart';

class Delays extends StatefulWidget {
  _DelaysState createState() => _DelaysState();
}

class _DelaysState extends State<Delays> {
  List list = [];
  bool _isLoaded = false;
  bool _hasError = false;
  String _errorMessage = '';

  _getListItems() async {
    list.clear();
    _isLoaded = false;
    _hasError = false;
    _errorMessage = '';

    setState(() {});

    try {
      for (Map location in locations) {
        String url = '${endpoints['delayedEndpoint']}${location['key']}';
        final response = await http.get(url);
        final responseData = json.decode(response.body);
        if (responseData != null) {
          final data = [responseData];
          list.addAll(data.map((model) => Delayed.fromJson(model)));
          list.sort((a, b) {
            if (a.time < b.time) {
              return 1;
            } else if (a.time > b.time) {
              return -1;
            } else {
              return 0;
            }
          });
          setState(() {});
        }
      }
      _isLoaded = true;
      _hasError = false;
      _errorMessage = '';
      setState(() {});
    } catch (error) {
      _isLoaded = true;
      _hasError = true;
      _errorMessage = 'Ocorreu um erro. Por favor tenta novamente.';

      // Necessary to check ´mounted´ to avoid accessing the widget after disposed
      if (this.mounted) {
        setState(() {});
      }
    }
  }

  _getBody() {
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (BuildContext context, index) {
        MaterialColor _color = Colors.grey;
        bool _selected = false;

        if (list[index].vendor == 'FERTAGUS') {
          _color = Colors.red;
          _selected = true;
        }

        if (list[index].vendor == 'SOFLUSA') {
          _color = Colors.blue;
          _selected = true;
        }

        if (list[index].vendor.startsWith('CP')) {
          _color = Colors.green;
          _selected = true;
        }

        return ListTileTheme(
          selectedColor: _color,
          child: ListTile(
            selected: _selected,
            title: Column(
              children: <Widget>[
                Text(
                  'de ${list[index].begin}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'até ${list[index].end}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(locationNames[list[index].line]),
              ],
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
            trailing: Text(list[index].vendor),
            isThreeLine: false,
            subtitle: Text(
              'Atrasado ${list[index].delay} minutos',
            ),
            onTap: () {},
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _getListItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text(
          'Atrasos',
          style: TextStyle(color: Color(0xFFe9ecef)),
        ),
        backgroundColor: Color(0xFF343a40),
        actions: <Widget>[
          Container(
            child: _isLoaded
                ? IconButton(
                    icon: Icon(
                      Icons.refresh,
                      color: Color(0xFFe9ecef),
                    ),
                    onPressed: () {
                      _getListItems();
                    },
                  )
                : Center(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: CircularProgressIndicator(
                        strokeWidth: 3.0,
                      ),
                    ),
                  ),
          ),
        ],
      ),
      body: list.length > 0
          ? _getBody()
          : Center(
              child:
                  _hasError ? Text(_errorMessage) : CircularProgressIndicator(),
            ),
    );
  }
}
