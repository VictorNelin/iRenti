import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:irenti/bloc/auth_bloc.dart';
import 'package:irenti/bloc/messages_bloc.dart';
import 'package:irenti/repository/messages_repository.dart';

class DialogsPage extends StatefulWidget {
  @override
  _DialogsPageState createState() => _DialogsPageState();
}

class _DialogsPageState extends State<DialogsPage> {
  String _uid;

  MessagesBloc get _messagesBloc => BlocProvider.of<MessagesBloc>(context);

  @override
  void initState() {
    super.initState();
    _uid = (BlocProvider.of<AuthenticationBloc>(context).currentState as Authenticated).user.uid;
  }

  @override
  void dispose() {
    _messagesBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverPersistentHeader(delegate: TitleBarDelegate(MediaQuery.of(context).padding.top), pinned: true),
          BlocBuilder<MessagesEvent, MessagesState>(
            bloc: _messagesBloc,
            builder: (context, state) {
              if (state is MessagesLoadedState) {
                return SliverFixedExtentList(
                  delegate: SliverChildBuilderDelegate((ctx, i) {
                    Conversation entry = state.entries[i];
                    return InkWell(
                      onTap: () => Navigator.pushNamed(context, '/dialog', arguments: {
                        'id': entry.id,
                        'title': entry.op(_uid).displayName,
                      }),
                      child: Container(
                        height: 60,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          border: Border(bottom: Divider.createBorderSide(context)),
                        ),
                        child: Row(
                          children: <Widget>[
                            Container(
                              width: 20,
                              alignment: Alignment.center,
                              child: Offstage(
                                offstage: entry.messages.isEmpty ? true : entry.messages.where((m) => m.fromId != _uid).every((m) => m.read),
                                child: Container(
                                  width: 4,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFFEF5353),
                                  ),
                                ),
                              ),
                            ),
                            CircleAvatar(
                              backgroundImage: NetworkImage(entry.op(_uid).photoUrl),
                              radius: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    entry.op(_uid).displayName,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    entry.messages.isNotEmpty
                                        ? (entry.messages.last.fromId == _uid ? 'Вы: ${entry.messages.last.text}' : entry.messages.last.text)
                                        : entry.startedById == _uid
                                        ? 'Вы создали этот чат'
                                        : 'Приглашает вас в чат',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              alignment: Alignment.center,
                              child: Icon(Icons.arrow_forward_ios, size: 14, color: const Color(0xff2b2b2b)),
                            ),
                          ],
                        ),
                      ),
                    );
                  }, childCount: state.entries.length),
                  itemExtent: 60,
                );
              } else {
                return SliverToBoxAdapter();
              }
            },
          ),
        ],
      ),
    );
  }
}

class TitleBarDelegate extends SliverPersistentHeaderDelegate {
  final double topPadding;

  const TitleBarDelegate(this.topPadding);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return DefaultTextStyle(
      style: Theme.of(context).textTheme.headline,
      child: Stack(
        children: <Widget>[
          Container(
            color: Theme.of(context).canvasColor,
            height: (maxExtent - shrinkOffset).clamp(minExtent, maxExtent).toDouble(),
            foregroundDecoration: BoxDecoration(
              border: Border(bottom: Divider.createBorderSide(context)),
            ),
          ),
          Positioned(
            top: 4 + topPadding,
            right: 4,
            child: IconButton(
              onPressed: () {},//=> Navigator.pop(context),
              icon: const Icon(Icons.search),
            ),
          ),
          Positioned(
            top: topPadding,
            left: 20,
            bottom: 0,
            child: Align(
              alignment: Alignment(0, 40 / (40 + kToolbarHeight) * ((60 - shrinkOffset.clamp(0.0, 60.0)) / 60)),
              child: const Text('Общение'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => kToolbarHeight + 60 + topPadding;

  @override
  double get minExtent => kToolbarHeight + topPadding;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
