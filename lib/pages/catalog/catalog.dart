import 'dart:async' show Completer;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:irenti/bloc/auth_bloc.dart';
import 'package:irenti/bloc/catalog_bloc.dart';
import 'package:irenti/repository/catalog_repository.dart';
import 'package:irenti/widgets/catalog_cover.dart';

class CatalogPage extends StatefulWidget {
  final bool favorites;

  const CatalogPage({
    Key key,
    this.favorites: false,
  }) :  assert(favorites != null),
        super(key: key);

  @override
  _CatalogPageState createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> with SingleTickerProviderStateMixin {
  final ScrollController _scroller = ScrollController();
  Completer _refresher;
  String _uid;
  List<dynamic> _profile;
  CatalogBloc _bloc;
  int _count = 0;
  bool _canFetch = false;
  String _selectedId;

  CatalogRepository get _catalogRepository => RepositoryProvider.of<CatalogRepository>(context);

  @override
  void initState() {
    super.initState();
    final authBloc = BlocProvider.of<AuthenticationBloc>(context);
    authBloc.state.listen((state) {
      if (state is Authenticated) {
        _profile = state.data;
      }
    });
    final authState = authBloc.currentState;
    if (authState is Authenticated) {
      _uid = authState.user.uid;
      _profile = authState.data;
    }
    _bloc = CatalogBloc(catalogRepository: _catalogRepository, userId: _uid);
    _bloc.dispatch(CatalogFetch(profile: _profile, ids: widget.favorites ? (authState as Authenticated).fave : null));
    if (!widget.favorites) {
      _scroller.addListener(() {
        if (_canFetch && (_scroller.offset / MediaQuery.of(context).size.height) >= _count * 0.8) {
          _canFetch = false;
          _bloc.dispatch(CatalogFetch(profile: _profile));
        }
      });
    }
    SharedPreferences.getInstance().then((prefs) {
      if (prefs.getBool('firstRunDone') != true) {
        prefs.setBool('firstRunDone', true);
        ShowCaseWidget.startShowCase(context, [keyOne]);
      }
    });
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
          _refresher?.complete();
          _refresher = null;
          if (state.entries.isEmpty) {
            return Center(
              child: Opacity(
                opacity: 0.5,
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: Theme.of(context).textTheme.subhead,
                    children: const [
                      TextSpan(text: '👀\n\n', style: TextStyle(fontSize: 48)),
                      TextSpan(text: 'Здесь ничего нет'),
                    ],
                  ),
                ),
              ),
            );
          }
          _count = state.entries.length;
          _canFetch = state.hasMore;
          return Stack(
            children: <Widget>[
              PrimaryScrollController(
                controller: _scroller,
                child: RefreshIndicator(
                  displacement: 120,
                  onRefresh: () {
                    _refresher = Completer();
                    _bloc.dispatch(CatalogFetch(profile: _profile, reload: true));
                    return _refresher.future;
                  },
                  notificationPredicate: (_) => !widget.favorites,
                  child: ListView.builder(
                    controller: _scroller,
                    physics: _selectedId == null
                        ? const PageScrollPhysics(parent: ClampingScrollPhysics())
                        : const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    //itemCount: state.entries.length < 1 ? 1 : state.entries.length,
                    itemBuilder: (ctx, i) {
                      if (i >= _count) return null;
                      CatalogEntry e = state.entries[i];
                      return CatalogCover(key: ValueKey(i), uid: _uid, entry: e);
                    },
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Material(
                    type: MaterialType.transparency,
                    child: SizedOverflowBox(
                      alignment: AlignmentDirectional.centerStart,
                      size: Size.fromHeight(kToolbarHeight),
                      child: InkWell(
                        onTap: () => Navigator.pushNamed(context, '/catalog/filter', arguments: _bloc),
                        child: const Icon(Icons.settings, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        return const Center(child: CupertinoActivityIndicator());
      },
    );
  }
}
