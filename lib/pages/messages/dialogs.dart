import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:irenti/bloc/auth_bloc.dart';
import 'package:irenti/bloc/messages_bloc.dart';
import 'package:irenti/repository/messages_repository.dart';
import 'package:irenti/widgets/title_bar.dart';

class DialogsPage extends StatefulWidget {
  const DialogsPage({Key key}) : super(key: key);

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

  String _getPreviewText(Conversation entry) {
    if (entry.messages.isNotEmpty) {
      Message last = entry.messages.last;
      if (last.fromId == _uid) {
        return last.text != null ? 'Вы: ${last.text}' : 'Вы добавили новую квартиру';
      } else {
        return last.text ?? 'Добавил новую квартиру';
      }
    } else {
      return entry.startedById == _uid
        ? 'Вы создали этот чат'
        : 'Приглашает вас в чат';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverPersistentHeader(delegate: TitleBarDelegate('Общение', MediaQuery.of(context).padding.top, () {}), pinned: true),
          const SliverToBoxAdapter(child: Divider(height: 0)),
          BlocBuilder<MessagesBloc, MessagesState>(
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
                                offstage: entry.messages.isEmpty ? true : entry.messages.every((m) => m.timestamp >= entry.lastReadTime),
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
                              backgroundImage: entry.op(_uid).photoUrl != null ? NetworkImage(entry.op(_uid).photoUrl) : null,
                              radius: 20,
                              child: ClipOval(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: entry.op(_uid).photoUrl == null ? const Icon(Icons.person, size: 40) : null,
                                ),
                              ),
                            ),
                            /*CircleAvatar(
                              backgroundImage: NetworkImage(entry.op(_uid).photoUrl),
                              radius: 20,
                            ),*/
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
                                    _getPreviewText(entry),
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
