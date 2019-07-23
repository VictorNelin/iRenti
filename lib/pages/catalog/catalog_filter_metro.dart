import 'package:flutter/material.dart';
import 'package:irenti/model/metro.dart';
import 'package:irenti/widgets/checkbox.dart';

class CatalogFilterMetroPage extends StatefulWidget {
  final List<String> initial;

  CatalogFilterMetroPage({Key key, this.initial}) : super(key: key);

  @override
  _CatalogFilterMetroPageState createState() => _CatalogFilterMetroPageState();
}

class _CatalogFilterMetroPageState extends State<CatalogFilterMetroPage> {
  final TextEditingController _searcher = TextEditingController(text: '');
  final List<int> _selected = List();

  @override
  void initState() {
    super.initState();
    if (widget.initial != null && widget.initial.isNotEmpty) {
      _selected.addAll(widget.initial.map((s) => kStations.indexWhere((m) => m['title'] == s)));
    }
  }
  
  Widget _buildItem(BuildContext ctx, Map<String, dynamic> data, [bool showHeader = false]) {
    int color = kLines[data['line']]['color'];
    int pos = kStations.indexWhere((m) => m['id'] == data['id']);
    void update([b]) => setState(() {
      if (_selected.contains(pos)) {
        _selected.remove(pos);
      } else {
        _selected.add(pos);
      }
    });
    return Column(
      key: ValueKey(data['id']),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (showHeader)
          ListTile(
            dense: true,
            title: Text(data['title'].toString().substring(0, 1)),
          ),
        ListTile(
          leading: RoundCheckbox(
            value: _selected.contains(pos),
            onChanged: update,
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF000000 + color),
                  border: Border.fromBorderSide(color == 0xffffff ? BorderSide(color: Color(0xfff37753), width: 2) : BorderSide.none),
                ),
                child: const SizedBox(width: 12, height: 12),
              ),
              const SizedBox(width: 16),
              Text(data['title']),
            ],
          ),
          onTap: update,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SafeArea(
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  const SizedBox(width: 16.0, height: kToolbarHeight),
                  Align(child: Text(
                    'Закрыть',
                    style: Theme.of(context).textTheme.subhead.copyWith(
                      fontSize: 14.0,
                    ),
                  )),
                  const SizedBox(width: 16.0),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              'Станции метро',
              style: Theme.of(context).textTheme.headline,
            ),
          ),
          const SizedBox(height: 10.0),
          Padding(
            key: ValueKey('TEXT FIELD PADDING'),
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: TextField(
              key: ValueKey('TEXT FIELD'),
              controller: _searcher,
              textInputAction: TextInputAction.search,
              style: Theme.of(context).textTheme.subhead,
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _searcher,
              builder: (context, data, child) {
                Iterable stations = kStations.where((m) => m['title'].toString().toLowerCase().startsWith(data.text.toLowerCase()));
                return ListView.builder(
                  itemCount: stations.length,
                  itemBuilder: (ctx, i) {
                    bool b = i == 0 || stations.elementAt(i)['title'].codeUnitAt(0) != stations.elementAt(i-1)['title'].codeUnitAt(0);
                    return _buildItem(ctx, stations.elementAt(i), b);
                  },
                );
              }
            ),
          ),
          ButtonTheme(
            height: 60,
            child: FlatButton(
              child: Text('ПРИМЕНИТЬ'),
              color: const Color(0xFFEF5353),
              shape: RoundedRectangleBorder(),
              onPressed: () {
                Navigator.pop(context, _selected.isEmpty ? [] : _selected.map((i) => kStations[i]['title']).toList(growable: false));
              },
            ),
          ),
        ],
      ),
    );
  }
}
