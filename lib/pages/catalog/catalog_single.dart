import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:irenti/bloc/auth_bloc.dart';
import 'package:irenti/repository/catalog_repository.dart';
import 'package:irenti/widgets/catalog_cover.dart';

class CatalogSinglePage extends StatefulWidget {
  final CatalogEntry entry;

  const CatalogSinglePage({
    Key key,
    @required this.entry,
  }) :  assert(entry != null),
        super(key: key);

  @override
  _CatalogSinglePageState createState() => _CatalogSinglePageState();
}

class _CatalogSinglePageState extends State<CatalogSinglePage> with SingleTickerProviderStateMixin {
  Future<CatalogEntry> _loader;
  String _uid;

  @override
  void initState() {
    super.initState();
    List<dynamic> profile;
    final authBloc = BlocProvider.of<AuthenticationBloc>(context);
    authBloc.listen((state) {
      if (state is Authenticated) {
        profile = state.data;
      }
    });
    final authState = authBloc.state;
    if (authState is Authenticated) {
      _uid = authState.user.uid;
      profile = authState.data;
    }
    _loader = RepositoryProvider.of<CatalogRepository>(context).loadFull(widget.entry, _uid, profile);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        FutureBuilder<CatalogEntry>(
          future: _loader,
          initialData: widget.entry,
          builder: (context, snapshot) {
            return CatalogCover(uid: _uid, entry: snapshot.data, single: true);
          }
        ),
        SafeArea(
          child: Material(
            type: MaterialType.transparency,
            child: SizedOverflowBox(
              alignment: AlignmentDirectional.centerStart,
              size: Size.fromHeight(kToolbarHeight),
              child: InkWell(
                onTap: () => Navigator.pop(context),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const SizedBox(width: 16.0, height: kToolbarHeight),
                    const Icon(Icons.arrow_back_ios, size: 16.0, color: Colors.white),
                    const SizedBox(width: 16.0),
                    Align(child: Text(
                      'Назад',
                      style: Theme.of(context).textTheme.subhead.copyWith(
                        fontSize: 14.0,
                        color: Colors.white,
                      ),
                    )),
                    const SizedBox(width: 16.0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
