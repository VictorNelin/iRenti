import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flushbar/flushbar.dart';
import 'package:showcaseview/showcase.dart';
import 'package:irenti/bloc/auth_bloc.dart';
import 'package:irenti/bloc/messages_bloc.dart';
import 'package:irenti/model/catalog.dart';
import 'package:irenti/model/user.dart';
import 'package:irenti/widgets/checkbox.dart';

const GlobalKey keyOne = GlobalObjectKey('name');
bool _addKey = true;

class CatalogCover extends StatelessWidget {
  final ValueNotifier<String> _selectedId = ValueNotifier(null);
  final ValueNotifier<OverlayEntry> _dialogOverlay = ValueNotifier(null);
  final ValueNotifier<LocalHistoryEntry> _selection = ValueNotifier(null);

  CatalogCover({Key key, this.uid, this.entry}) : super(key: key);

  final String uid;
  final CatalogEntry entry;

  void _selectId(BuildContext context, UserData user, CatalogEntry entry) {
    if (_selectedId.value == user.id || user == null) {
      _selection.value.remove();
      _selection.value = null;
    } else {
      if (_dialogOverlay.value == null) {
        bool _creating = false;
        _dialogOverlay.value = OverlayEntry(builder: (ctx) => Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 50,
          child: Material(
            color: _creating ? CupertinoColors.inactiveGray : const Color(0xFFEF5353),
            child: InkWell(
              onTap: _creating ? null : () async {
                _creating = true;
                _dialogOverlay.value.markNeedsBuild();
                await BlocProvider.of<MessagesBloc>(context).createChat(uid, user.id, entry.toMap());
                _creating = false;
                _dialogOverlay.value.remove();
                _dialogOverlay.value = null;
                showModalBottomSheet(
                  context: context,
                  builder: (ctx) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text(
                          '«ПРИВЕТ!»',
                          style: Theme.of(context).textTheme.headline,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Создан новый чат\nс пользователем ${user.displayName}',
                          style: Theme.of(context).textTheme.title,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Вы обсуждаете:\n"${entry.titleFormatted}"',
                          style: Theme.of(context).textTheme.body1.copyWith(
                            color: const Color(0xff272d30).withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        FlatButton(
                          color: const Color(0xFFEF5353),
                          onPressed: () {
                            Navigator.pop(ctx);
                            _selection.value?.remove();
                            _selection.value = null;
                          },
                          shape: StadiumBorder(),
                          child: Text('ПРОДОЛЖИТЬ ПОИСК'),
                        ),
                        FlatButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _selection.value?.remove();
                            _selection.value = null;
                            Navigator.pushNamed(context, '/dialog', arguments: {
                              'id': entry.id,
                              'title': user.displayName,
                            });
                          },
                          child: Text('ПЕРЕЙТИ В ЧАТ'),
                        ),
                      ],
                    ),
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                  ),
                );
              },
              child: Align(
                alignment: Alignment.center,
                child: Text('СКАЗАТЬ «ПРИВЕТ!»', style: Theme.of(context).textTheme.button),
              ),
            ),
          ),
        ));
        Overlay.of(context).insert(_dialogOverlay.value);
      }
      if (_selection.value == null) {
        _selection.value = LocalHistoryEntry(onRemove: () {
          _dialogOverlay.value?.remove();
          _dialogOverlay.value = null;
          _selectedId.value = null;
        });
      }
      ModalRoute.of(context).addLocalHistoryEntry(_selection.value);
      _selectedId.value = user.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height - 50,
      child: DefaultTabController(
        length: entry.photos.length,
        child: Stack(
          alignment: Alignment.centerRight,
          children: <Widget>[
            TabBarView(
              children: <Widget>[
                for (String s in entry.photos)
                  Image.network(
                    s,
                    fit: BoxFit.cover,
                    frameBuilder: (ctx, child, frame, _) {
                      return Container(color: const Color(0xff272d30), child: child);
                    },
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
                    entry.titleFormatted,
                    style: Theme.of(context).textTheme.headline.copyWith(
                      color: const Color(0xFFFFFFFF),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    '${entry.costFormatted} руб./месяц',
                    style: Theme.of(context).textTheme.title.copyWith(
                      color: const Color(0xFFFFFFFF),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    entry.address,
                    style: Theme.of(context).textTheme.body1.copyWith(
                      color: const Color(0xFFFFFFFF),
                    ),
                  ),
                ),
                const Expanded(child: SizedBox()),
                Builder(builder: (ctx) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(entry.photos.length.clamp(0, 20), (i) {
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
                      for (UserData user in entry.neighbors)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                height: 50,
                                child: GestureDetector(
                                  onTap: () {
                                    _selectId(context, user, entry);
                                  },
                                  child: Stack(
                                    alignment: Alignment.center,
                                    fit: StackFit.loose,
                                    children: <Widget>[
                                      SizedBox(width: 50, height: 50),
                                      ValueListenableBuilder<String>(
                                        valueListenable: _selectedId,
                                        builder: (context, data, child) {
                                          return CircleAvatar(
                                            radius: data == user.id ? 20 : 25,
                                            backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl) : null,
                                            child: child,
                                          );
                                        },
                                        child: ClipOval(
                                          child: Padding(
                                            padding: const EdgeInsets.only(top: 10),
                                            child: user.photoUrl == null ? const Icon(Icons.person, size: 48) : null,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: ValueListenableBuilder<String>(
                                          valueListenable: _selectedId,
                                          builder: (context, data, child) {
                                            return AnimatedOpacity(
                                              opacity: _selectedId.value == user.id ? 1.0 : 0.0,
                                              duration: kThemeChangeDuration,
                                              child: child,
                                            );
                                          },
                                          child: IgnorePointer(
                                            child: Material(
                                              type: MaterialType.transparency,
                                              child: RoundCheckbox(
                                                value: true,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6.0),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, '/catalog/profile', arguments: user);
                                },
                                child: Builder(
                                  builder: (ctx) {
                                    bool addKey = entry.neighbors.indexOf(user) == 0;
                                    GlobalKey key;
                                    if (_addKey && addKey) {
                                      key = keyOne;
                                      _addKey = false;
                                    }
                                    Widget w = Text(
                                      user.displayName,
                                      style: Theme.of(context).textTheme.body1.copyWith(
                                        color: Colors.white,
                                      ),
                                    );
                                    return key == null ? w : Showcase.withWidget(
                                      key: key,
                                      container: Padding(
                                        padding: const EdgeInsets.only(bottom: 24.0),
                                        child: Material(
                                          color: const Color(0xffef5353),
                                          elevation: 6,
                                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  'Профиль',
                                                  style: Theme.of(context).textTheme.title
                                                      .merge(TextStyle(color: Colors.white)),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'Чтобы посмотреть информацию\nо пользователе, нажмите на его имя',
                                                  style: Theme.of(context).textTheme.subtitle
                                                      .merge(TextStyle(color: Colors.white)),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      width: MediaQuery.of(context).size.width,
                                      height: 72,
                                      animationDuration: const Duration(seconds: 10),
                                      child: w,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom),
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
                      Navigator.of(context).pushNamed('/catalog/info', arguments: entry);
                    },
                  ),
                  FloatingActionButton(
                    child: Icon(Icons.place, color: Colors.black),
                    elevation: 0,
                    highlightElevation: 0,
                    backgroundColor: Colors.white,
                    mini: true,
                    heroTag: null,
                    onPressed: () => Navigator.of(context).pushNamed('/catalog/map', arguments: entry),
                  ),
                  StatefulBuilder(
                    builder: (ctx, setBtnState) {
                      Authenticated auth = BlocProvider.of<AuthenticationBloc>(context).currentState is Authenticated
                          ? BlocProvider.of<AuthenticationBloc>(context).currentState
                          : null;
                      return FloatingActionButton(
                        child: Icon(Icons.star, color: auth?.fave?.contains(entry.id) == true ? Colors.amber : Colors.black),
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
                                message: state.fave.contains(entry.id) ? 'Добавлено в избранное' : 'Удалено из избранного',
                                borderRadius: 8.0,
                                margin: EdgeInsets.only(
                                  bottom: MediaQuery.of(context).padding.bottom,
                                ),
                                dismissDirection: FlushbarDismissDirection.HORIZONTAL,
                                duration: const Duration(seconds: 3),
                                animationDuration: const Duration(milliseconds: 100),
                              ).show(ctx);
                              _stateSub.cancel();
                              setBtnState(() {});
                            }
                          });
                          BlocProvider.of<AuthenticationBloc>(context).dispatch(ToggleFave(entry.id));
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
