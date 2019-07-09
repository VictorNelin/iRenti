import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:irenti/bloc/catalog_bloc.dart';
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

double posToVal(double pos, double minVal, double maxVal) {
  if (pos == null) return null;
  if (pos == 0) return minVal;
  if (pos == 1) return maxVal;
  return math.exp(math.log(minVal) + (math.log(maxVal) - math.log(minVal)) * pos);
}

double valToPos(double val, double minVal, double maxVal) {
  if (val == null) return null;
  if (val == minVal) return 0;
  if (val == maxVal) return 1;
  return (math.log(val) - math.log(minVal)) / (math.log(maxVal) - math.log(minVal));
}

String fmtStr(double val) {
  String result = val.toStringAsFixed(0);
  result = String.fromCharCodes(
    String.fromCharCodes(
      result.codeUnits.reversed,
    ).replaceAllMapped(RegExp('[0-9][0-9][0-9]'), (m) => '${m.group(0)},').codeUnits.reversed,
  );
  return result.startsWith(',') ? result.substring(1) : result;
}

class CatalogFilterPage extends StatefulWidget {
  final CatalogBloc bloc;

  CatalogFilterPage({Key key, this.bloc}) : super(key: key);

  @override
  _CatalogFilterPageState createState() => _CatalogFilterPageState();
}

class _CatalogFilterPageState extends State<CatalogFilterPage> {
  final List<bool> _conditions = List.generate(5, (_) => false);
  double _minPrice;
  double _maxPrice;
  int _type = 2;
  int _rooms;
  double _priceLow = 0;
  double _priceHigh = 1;

  CatalogBloc get _bloc => widget.bloc;

  @override
  void initState() {
    super.initState();
    _rooms = _bloc.roomsFilter;
  }

  @override
  Widget build(BuildContext context) {
    if (_minPrice == null || _maxPrice == null) {
      _bloc.minMaxPrice.then((l) => setState(() {
        _minPrice = l[0];
        _maxPrice = l[1];
        _priceLow = valToPos(_bloc.priceLowFilter, l[0], l[1]) ?? 0;
        _priceHigh = valToPos(_bloc.priceHighFilter, l[0], l[1]) ?? 1;
      }));
    } else {
      _bloc.dispatch(CatalogCountWith(
        rooms: _rooms,
        priceLow: posToVal(_priceLow, _minPrice, _maxPrice),
        priceHigh: posToVal(_priceHigh, _minPrice, _maxPrice),
      ));
    }
    return Scaffold(
      body: ListView(
        children: <Widget>[
          SafeArea(
            child: InkWell(
              onTap: () {
                _bloc.clearFilters();
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
              'Фильтр',
              style: Theme.of(context).textTheme.headline.copyWith(
                //color: const Color(0xFF272D30),
              ),
            ),
          ),
          const SizedBox(height: 10.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              'Регион: Москва',
              style: Theme.of(context).textTheme.body1.copyWith(
                //color: const Color(0xFF272D30),
              ),
            ),
          ),
          const SizedBox(height: 32.0),
          ListEntry(
            title: 'Тип жилья',
            child: RadioGroup(
              titles: ['Любое жильё', 'Комната', 'Квартира', 'Студия'],
              value: _type,
              onChanged: (_) {},//(i) => setState(() => _rooms = i),
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
          ListEntry(
            title: 'Стоимость',
            child: StatefulBuilder(
              builder: (context, setSliderState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    if (_minPrice != null && _maxPrice != null)
                      Text(
                        'Диапазон цен: '
                        '${fmtStr(posToVal(_priceLow, _minPrice, _maxPrice))}'
                        ' - '
                        '${fmtStr(posToVal(_priceHigh, _minPrice, _maxPrice))}',
                      ),
                    if (_minPrice == null || _maxPrice == null)
                      Text('Диапазон цен: ...'),
                    RangeSlider(
                      values: RangeValues(_priceLow, _priceHigh),
                      onChanged: _minPrice == null || _maxPrice == null ? null : (v) => setSliderState(() {
                        _priceLow = v.start;
                        _priceHigh = v.end;
                      }),
                      onChangeEnd: _minPrice == null || _maxPrice == null ? null : (v) => setState(() {
                        _priceLow = v.start;
                        _priceHigh = v.end;
                      }),
                    ),
                    if (_minPrice != null && _maxPrice != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(fmtStr(_minPrice)),
                          Text(fmtStr(_maxPrice)),
                        ],
                      ),
                  ],
                );
              }
            ),
          ),
          ListEntry(
            title: 'Условия',
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (String s in _kConditions)
                  Container(
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
          ListEntry(title: 'Станции метро', child: Text('NYI')),
          const Divider(height: 0),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 64.0),
            child: BlocBuilder<CatalogEvent, CatalogState>(
              bloc: _bloc,
              builder: (ctx, state) {
                if (state is LoadedState) {
                  return FlatButton(
                    child: Text(state.countLoading ? 'ЗАГРУЗКА...' : 'ПОКАЗАТЬ ВАРИАНТОВ${state.count == null ? '' : ': ${state.count}'}'),
                    color: const Color(0xFFEF5353),
                    onPressed: state.count == null || state.countLoading ? null : () {
                      _bloc.dispatch(CatalogReload());
                      Navigator.pop(context);
                    },
                  );
                }
                return Container();
              }
            ),
          ),
        ],
      ),
    );
  }
}
