import 'package:flutter/material.dart';
import 'package:irenti/model/catalog.dart';
import 'package:irenti/widgets/list_tile.dart';

class CatalogInfoPage extends StatelessWidget {
  final CatalogEntry entry;

  CatalogInfoPage({Key key, @required this.entry})
      : assert(entry != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    CatalogEntry e = entry;
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
              e.titleFormatted,
              style: Theme.of(context).textTheme.headline.copyWith(
                color: const Color(0xFF272D30),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              '${e.costFormatted} руб./месяц',
              style: Theme.of(context).textTheme.title.copyWith(
                color: const Color(0xFF272D30),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              e.address,
              style: Theme.of(context).textTheme.body1.copyWith(
                color: const Color(0xFF272D30),
              ),
            ),
          ),
          const SizedBox(height: 20.0),
          ListEntry(title: 'Метро', child: Text('NYI')),
          ListEntry(title: 'Тип', child: Text('Квартира')),
          ListEntry(title: 'Кол-во комнат', child: Text(e.rooms.toString())),
          if (e.description != null && e.description.isNotEmpty)
            ListEntry(title: 'Описание', child: Text(e.description)),
          if (e.conditions != null && e.conditions.isNotEmpty)
            ListEntry(title: 'Условия', child: Text(e.conditions)),
          ListEntry(
            title: 'Связаться с хозяином',
            child: Text('NYI'),
          ),
        ],
      ),
    );
  }
}
