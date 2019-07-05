import 'package:flutter/material.dart';
import 'package:irenti/model/catalog.dart';
import 'package:irenti/widgets/checkbox.dart';
import 'package:irenti/widgets/list_tile.dart';
import 'package:irenti/widgets/radio_group.dart';

const List<String> _kConditions = [
  'Wi-Fi',
  'Можно курить',
  'Можно с животными',
  'Есть стиральная машина',
  'Есть холодильник',
];

class CatalogFilterPage extends StatefulWidget {
  CatalogFilterPage({Key key}) : super(key: key);

  @override
  _CatalogFilterPageState createState() => _CatalogFilterPageState();
}

class _CatalogFilterPageState extends State<CatalogFilterPage> {
  final List<bool> _conditions = List.generate(5, (_) => false);
  int _type = 0;
  int _rooms;

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
              'Фильтр',
              style: Theme.of(context).textTheme.headline.copyWith(
                color: const Color(0xFF272D30),
              ),
            ),
          ),
          const SizedBox(height: 10.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              'Регион: Москва',
              style: Theme.of(context).textTheme.body1.copyWith(
                color: const Color(0xFF272D30),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          const Divider(height: 0),
          const SizedBox(height: 20.0),
          ListEntry(
            title: 'Тип жилья',
            child: RadioGroup(
              titles: ['Любое жильё', 'Комната', 'Квартира', 'Студия'],
              value: _type,
              onChanged: (i) => setState(() => _rooms = i),
              paddingBetween: 10,
            ),
          ),
          ListEntry(
            title: 'Количество комнат',
            child: RadioGroup(
              titles: ['1', '2', '3', '4 и больше'],
              value: _rooms,
              allowNullValue: true,
              onChanged: (i) => setState(() => _rooms = i),
              paddingBetween: 10,
            ),
          ),
          ListEntry(title: 'Стоимость', child: Text('NYI')),
          ListEntry(
            title: 'Условия',
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (String s in _kConditions)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    height: 30,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        RoundCheckbox(
                          value: _conditions[_kConditions.indexOf(s)],
                          onChanged: (b) => setState(() => _conditions[_kConditions.indexOf(s)] = b),
                        ),
                        const SizedBox(width: 10),
                        Text(s),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 0),
          ListEntry(title: 'Станции метро', child: Text('NYI')),
          const Divider(height: 0),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 64.0),
            child: FlatButton(
              child: Text('ПОКАЗАТЬ ВАРИАНТОВ: XXX'),
              color: const Color(0xFF272D30),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}
