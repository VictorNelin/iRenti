import 'package:flutter/material.dart';
import 'package:irenti/model/catalog.dart';
import 'package:irenti/model/metro.dart';
import 'package:irenti/widgets/list_tile.dart';

class CatalogInfoPage extends StatelessWidget {
  final CatalogEntry entry;

  CatalogInfoPage({Key key, @required this.entry})
      : assert(entry != null),
        super(key: key);

  Widget _buildMetroText(TextStyle style) {
    if (entry.undergrounds == null) return const SizedBox.shrink();
    List<InlineSpan> content = List();
    int cnt = 0;
    for (String ug in entry.undergrounds.map((s) => s.replaceAll('ё', 'е'))) {
      Iterable<int> lines = kStations.where((m) => m['title'].toLowerCase() == ug.toLowerCase()).map((m) => m['line']);
      for (int id in lines) {
        int color = kLines[id]['color'];
        content.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Container(
            width: 14,
            padding: const EdgeInsets.only(right: 4.0),
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF000000 + color),
                border: Border.fromBorderSide(color == 0xffffff ? BorderSide(color: Color(0xfff37753), width: 2) : BorderSide.none),
              ),
              child: const SizedBox(width: 10, height: 10),
            ),
          ),
        ));
      }
      content.add(TextSpan(text: ' $ug${cnt == entry.undergrounds.length - 1 ? '' : '\n'}'));
      ++cnt;
    }
    return RichText(text: TextSpan(style: style.copyWith(height: 1.25), children: content));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          SafeArea(
            child: InkWell(
              onTap: () => Navigator.pop(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const SizedBox(width: 16.0, height: kToolbarHeight),
                  const Icon(Icons.arrow_back_ios, size: 16.0),
                  const SizedBox(width: 16.0),
                  Align(child: Text(
                    'Назад',
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
              entry.titleFormatted,
              style: Theme.of(context).textTheme.headline,
            ),
          ),
          const SizedBox(height: 16.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              '${entry.costFormatted} руб./месяц',
              style: Theme.of(context).textTheme.title,
            ),
          ),
          const SizedBox(height: 16.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              entry.address,
              style: Theme.of(context).textTheme.body1,
            ),
          ),
          const SizedBox(height: 20.0),
          if (entry.undergrounds != null)
            ListEntry(title: 'Метро', child: _buildMetroText(Theme.of(context).textTheme.body1)),
          ListEntry(title: 'Тип', child: Text('Квартира')),
          ListEntry(title: 'Кол-во комнат', child: Text(entry.rooms.toString())),
          if (entry.description != null && entry.description.isNotEmpty)
            ListEntry(title: 'Описание', child: Text(entry.description)),
          if (entry.conditions != null && entry.conditions.isNotEmpty)
            ListEntry(title: 'Условия', child: Text(entry.conditions)),
          ListEntry(
            title: 'Связаться с хозяином',
            child: Text('${entry.owner != null ? '${entry.owner ?? ''}: ' : ''}${entry.phones != null ? entry.phones[0] : ''}'),
          ),
        ],
      ),
    );
  }
}
