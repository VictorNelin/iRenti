import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flushbar/flushbar.dart';
import 'package:irenti/bloc/auth_bloc.dart';
import 'package:irenti/bloc/catalog_bloc.dart';
import 'package:irenti/repository/catalog_repository.dart';

class CatalogPage extends StatefulWidget {
  @override
  _CatalogPageState createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> with SingleTickerProviderStateMixin {
  final CatalogBloc _bloc = CatalogBloc(catalogRepository: CatalogRepository());

  @override
  void initState() {
    super.initState();
    _bloc.dispatch(CatalogEvent());
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _bloc,
      builder: (context, state) {
        if (state is LoadedState) {
          return Stack(
            children: <Widget>[
              ListView.builder(
                physics: const PageScrollPhysics(parent: BouncingScrollPhysics()),
                padding: EdgeInsets.zero,
                itemCount: state.entries.length,
                itemBuilder: (ctx, i) {
                  CatalogEntry e = state.entries[i];
                  return SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.bottom,
                    child: DefaultTabController(
                      length: e.photos.length,
                      child: Stack(
                        alignment: Alignment.centerRight,
                        children: <Widget>[
                          TabBarView(
                            children: <Widget>[
                              for (String s in e.photos)
                                Image.network(
                                  s,
                                  fit: BoxFit.cover,
                                ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              const SizedBox(height: kToolbarHeight + 32.0),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                child: Text(
                                  '${e.rooms}-к квартира, '
                                      '${e.space.toStringAsFixed(1)} м², '
                                      '${e.floor}/${e.maxFloor} этаж',
                                  style: Theme.of(context).textTheme.headline.copyWith(
                                    color: const Color(0xFFFFFFFF),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                child: Text(
                                  '${e.cost.toStringAsFixed(2)} руб./месяц',
                                  style: Theme.of(context).textTheme.title.copyWith(
                                    color: const Color(0xFFFFFFFF),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                child: Text(
                                  e.address,
                                  style: Theme.of(context).textTheme.body1.copyWith(
                                    color: const Color(0xFFFFFFFF),
                                  ),
                                ),
                              ),
                              const Expanded(child: SizedBox()),
                              Builder(builder: (ctx) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(e.photos.length, (i) {
                                    TabController _tabs = DefaultTabController.of(ctx);
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
                                );
                              }),
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
                                  children: [
                                    for (UserData user in e.neighbors)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: <Widget>[
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.pushNamed(context, '/catalog/profile', arguments: user);
                                              },
                                              child: CircleAvatar(
                                                radius: 25.0,
                                                backgroundImage: NetworkImage(user.photoUrl),
                                              ),
                                            ),
                                            const SizedBox(height: 6.0),
                                            Text(
                                              user.displayName,
                                              style: Theme.of(context).textTheme.body1.copyWith(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
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
                                  onPressed: () {
                                    Navigator.of(context).pushNamed('/catalog/info', arguments: e);
                                  },
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
                                StatefulBuilder(
                                  builder: (ctx, setBtnState) {
                                    Authenticated auth = BlocProvider.of<AuthenticationBloc>(context).currentState is Authenticated
                                        ? BlocProvider.of<AuthenticationBloc>(context).currentState
                                        : null;
                                    return FloatingActionButton(
                                      child: Icon(Icons.star, color: auth?.fave?.contains(e.id) == true ? Colors.amber : Colors.black),
                                      elevation: 0,
                                      highlightElevation: 0,
                                      backgroundColor: Colors.white,
                                      mini: true,
                                      heroTag: null,
                                      onPressed: () {
                                        StreamSubscription _stateSub;
                                        _stateSub = BlocProvider.of<AuthenticationBloc>(context).state.skip(1).listen((state) {
                                          if (state is Authenticated) {
                                            Flushbar(
                                              message: state.fave.contains(e.id) ? 'Добавлено в избранное' : 'Удалено из избранного',
                                              borderRadius: 8.0,
                                              aroundPadding: const EdgeInsets.all(8.0),
                                              dismissDirection: FlushbarDismissDirection.HORIZONTAL,
                                              duration: const Duration(seconds: 3),
                                              animationDuration: const Duration(milliseconds: 100),
                                            ).show(ctx);
                                            _stateSub.cancel();
                                            setBtnState(() {});
                                          }
                                        });
                                        BlocProvider.of<AuthenticationBloc>(context).dispatch(ToggleFave(e.id));
                                      },
                                    );
                                  }
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Material(
                    type: MaterialType.transparency,
                    child: SizedOverflowBox(
                      alignment: AlignmentDirectional.centerStart,
                      size: Size.fromHeight(kToolbarHeight),
                      child: InkWell(
                        onTap: () {},
                        child: const Icon(Icons.settings, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        return Container();
      },
    );
  }
}
