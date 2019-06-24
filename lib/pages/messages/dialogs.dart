import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:irenti/bloc/auth_bloc.dart';
import 'package:irenti/bloc/messages_bloc.dart';
import 'package:irenti/repository/messages_repository.dart';

class DialogsPage extends StatefulWidget {
  final MessagesRepository _messagesRepository;

  DialogsPage({Key key, @required MessagesRepository messagesRepository})
      : assert(messagesRepository != null),
        _messagesRepository = messagesRepository,
        super(key: key);

  @override
  _DialogsPageState createState() => _DialogsPageState();
}

class _DialogsPageState extends State<DialogsPage> {
  MessagesBloc _messagesBloc;
  String _uid;

  MessagesRepository get _messagesRepository => widget._messagesRepository;

  @override
  void initState() {
    super.initState();
    _messagesBloc = MessagesBloc(messagesRepository: _messagesRepository);
    var authState = BlocProvider.of<AuthenticationBloc>(context).currentState;
    if (authState is Authenticated) {
      _uid = authState.user.uid;
      _messagesBloc.dispatch(MessagesInitEvent(_uid));
    }
  }

  @override
  void dispose() {
    _messagesBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: SafeArea(
          child: OverflowBox(
            alignment: AlignmentDirectional.centerEnd,
            minWidth: 0.0,
            maxWidth: double.infinity,
            minHeight: kToolbarHeight,
            maxHeight: kToolbarHeight,
            child: IconButton(
              onPressed: () {},//=> Navigator.pop(context),
              icon: const Icon(Icons.search),
            ),
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              decoration: BoxDecoration(
                border: Border(bottom: Divider.createBorderSide(context)),
              ),
              child: Text(
                'Общение',
                style: Theme.of(context).textTheme.headline.copyWith(
                  color: const Color(0xFF272D30),
                ),
              ),
            ),
          ),
          BlocBuilder<MessagesEvent, MessagesState>(
            bloc: _messagesBloc,
            builder: (context, state) {
              if (state is LoadedState) {
                return SliverFixedExtentList(
                  delegate: SliverChildBuilderDelegate((ctx, i) {
                    Conversation entry = state.entries[i];
                    return InkWell(
                      onTap: () => Navigator.pushNamed(context, '/dialog', arguments: {
                        'id': entry.id,
                        'title': entry.op(_uid).displayName,
                        'bloc': _messagesBloc,
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
                                      color: const Color(0xff272d30),
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
                                      color: const Color(0xff272d30).withOpacity(0.7),
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
