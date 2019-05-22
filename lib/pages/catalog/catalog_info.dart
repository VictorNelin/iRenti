import 'package:flutter/material.dart';
import 'package:irenti/repository/catalog_repository.dart';

class CatalogInfoPage extends StatefulWidget {
  final CatalogEntry entry;

  CatalogInfoPage({Key key, @required this.entry})
      : assert(entry != null),
        super(key: key);

  @override
  _CatalogInfoPageState createState() => _CatalogInfoPageState();
}

class _CatalogInfoPageState extends State<CatalogInfoPage> {
  Widget _buildListEntry({BuildContext context, String title, Widget content}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Divider(color: Color.fromRGBO(0x27, 0x2D, 0x30, 0.08), height: 0.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Text(
            title,
            style: Theme.of(context).textTheme.body1.copyWith(
              color: const Color.fromRGBO(0x27, 0x2D, 0x30, 0.7),
              fontWeight: FontWeight.normal,
              fontSize: 14.0,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 20),
          child: DefaultTextStyle(
            style: Theme.of(context).textTheme.body2.copyWith(
              fontWeight: FontWeight.w500,
              color: const Color(0xFF272D30),
            ),
            child: content,
          ),
        ),
      ],
    );
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
              '${widget.entry.rooms}-к квартира, '
                  '${widget.entry.space.toStringAsFixed(1)} м², '
                  '${widget.entry.floor}/${widget.entry.maxFloor} этаж',
              style: Theme.of(context).textTheme.headline.copyWith(
                color: const Color(0xFF272D30),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              '${widget.entry.cost.toStringAsFixed(2)} руб./месяц',
              style: Theme.of(context).textTheme.title.copyWith(
                color: const Color(0xFF272D30),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              widget.entry.address,
              style: Theme.of(context).textTheme.body1.copyWith(
                color: const Color(0xFF272D30),
              ),
            ),
          ),
          const SizedBox(height: 20.0),
          _buildListEntry(context: context, title: 'Метро', content: Text('NYI')),
          _buildListEntry(context: context, title: 'Тип', content: Text('Квартира')),
          _buildListEntry(context: context, title: 'Кол-во комнат', content: Text(widget.entry.rooms.toString())),
          _buildListEntry(context: context, title: 'Описание', content: Text(widget.entry.description)),
          _buildListEntry(context: context, title: 'Условия', content: Text(widget.entry.conditions)),
          _buildListEntry(
            context: context,
            title: 'Связаться с хозяином',
            content: Text('NYI'),
          ),
        ],
      ),
    );
  }
}

