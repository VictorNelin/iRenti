import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class CatalogPage extends StatefulWidget {
  @override
  _CatalogPageState createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> with SingleTickerProviderStateMixin {
  TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 7, vsync: this);
  }

  @override
  void dispose() {
    _tabs?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      //fit: StackFit.expand,
      alignment: Alignment.centerRight,
      children: <Widget>[
        TabBarView(
          controller: _tabs,
          children: <Widget>[
            Container(color: Colors.red),
            Container(color: Colors.orange),
            Container(color: Colors.yellow),
            Container(color: Colors.green),
            Container(color: Colors.lightBlue),
            Container(color: Colors.indigo),
            Container(color: Colors.purple),
          ],
        ),
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Material(
                  type: MaterialType.transparency,
                  child: SizedOverflowBox(
                    alignment: AlignmentDirectional.centerStart,
                    size: Size.fromHeight(kToolbarHeight),
                    child: InkWell(
                      onTap: () {},//=> Navigator.of(context, rootNavigator: true).pop(),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          //const SizedBox(width: 16.0),
                          const Icon(Icons.settings, color: Colors.white),
                          /*const SizedBox(width: 16.0),
                          Align(child: Text(
                            'Назад',
                            style: Theme.of(context).textTheme.subhead.copyWith(
                              fontSize: 14.0,
                            ),
                          )),
                          const SizedBox(width: 16.0),*/
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  '2-к квартира, 55.9 м², 6/26 этаж',
                  style: Theme.of(context).textTheme.headline.copyWith(
                    color: const Color(0xFFFFFFFF),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  '30,000 руб./месяц',
                  style: Theme.of(context).textTheme.title.copyWith(
                    color: const Color(0xFFFFFFFF),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Московская область, Одинцово, Можайское шоссе, 80А',
                  style: Theme.of(context).textTheme.body1.copyWith(
                    color: const Color(0xFFFFFFFF),
                  ),
                ),
              ),
              const Expanded(child: SizedBox()),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(7, (i) {
                  return AnimatedBuilder(
                    animation: _tabs.animation,
                    builder: (ctx, child) {
                      double value = 1.0 - (_tabs.animation.value - i).abs().clamp(0.0, 1.0);
                      return Container(
                        width: 10.0,
                        height: 10.0,
                        margin: EdgeInsets.symmetric(horizontal: 2.5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.0 + 3.0 * value),
                          color: Color.lerp(
                            Colors.transparent,
                            Colors.white,
                            value,
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
              const SizedBox(height: 16.0),
              const Divider(height: 0.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Text(
                  'Начните чат с возможными соседями',
                  style: Theme.of(context).textTheme.body1.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                height: 80.0,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: List.generate(20, (i) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          CircleAvatar(radius: 25.0),
                          const SizedBox(height: 6.0),
                          Text(
                            i.toString().padLeft(8, '0'),
                            style: Theme.of(context).textTheme.body1.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              FloatingActionButton(
                child: Icon(Icons.more_vert, color: Colors.black),
                elevation: 0,
                highlightElevation: 0,
                backgroundColor: Colors.white,
                mini: true,
                heroTag: null,
                onPressed: () {},
              ),
              FloatingActionButton(
                child: Icon(Icons.place, color: Colors.black),
                elevation: 0,
                highlightElevation: 0,
                backgroundColor: Colors.white,
                mini: true,
                heroTag: null,
                onPressed: () {},
              ),
              FloatingActionButton(
                child: Icon(Icons.star, color: Colors.black),
                elevation: 0,
                highlightElevation: 0,
                backgroundColor: Colors.white,
                mini: true,
                heroTag: null,
                onPressed: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}

