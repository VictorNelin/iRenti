import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:irenti/bloc/auth_bloc.dart';
import 'package:irenti/bloc/messages_bloc.dart';
import 'package:irenti/model/catalog.dart';
import 'package:irenti/model/messages.dart';

const List<String> _months = <String>[
  'января',
  'февраля',
  'марта',
  'апреля',
  'мая',
  'июня',
  'июля',
  'августа',
  'сентября',
  'октября',
  'ноября',
  'декабря',
];

class DialogPage extends StatefulWidget {
  final String dialogId;
  final String title;
  final MessagesBloc messagesBloc;

  const DialogPage({Key key, this.dialogId, this.title, this.messagesBloc}) : super(key: key);

  @override
  _DialogPageState createState() => _DialogPageState();
}

class _DialogPageState extends State<DialogPage> {
  final ScrollController _scrollController = ScrollController();
  int _lastLength;
  Completer _sender;
  String _uid;
  String _startedId;

  @override
  void initState() {
    super.initState();
    var authState = BlocProvider.of<AuthenticationBloc>(context).currentState;
    if (authState is Authenticated) {
      _uid = authState.user.uid;
    }
  }

  String get _desc {
    String desc = 'Обсудите самостоятельно детали оплаты и другие нюансы аренды. '
        'Договоритесь с хозяином о времени осмотра квартиры.';
    if (_startedId != _uid) {
      desc = 'Пользователь ${widget.title} приглашает вас в чат обсудить совместную аредну квартиры.\n$desc';
    }
    return desc;
  }

  String _formatDate(BuildContext context, int timestamp) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    var now = DateTime.now();
    return '${date.day} ${_months[date.month - 1]}${date.year != now.year ? ' ${date.year}' : ''}, ${date.hour}:${date.minute}';
  }

  Widget _buildInfoCard(BuildContext context) {
    return Material(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
      color: const Color(0xff73838c),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        alignment: Alignment.topLeft,
        child: Text(
          _desc,
          style: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildDataCard(BuildContext context, CatalogEntry data) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            'Квартира, которую вы обсуждаете',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 12,
              color: const Color(0xff272d30).withOpacity(0.7),
            ),
          ),
        ),
        Material(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
          clipBehavior: Clip.antiAlias,
          child: Container(
            height: 110,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                AspectRatio(
                  aspectRatio: 1,
                  child: Image.network(data.photos[0], fit: BoxFit.cover),
                ),
                Expanded(child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(data.titleFormatted, style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 14,
                        color: const Color(0xff272d30).withOpacity(0.7),
                      )),
                      Text('Хозяин:\n${data.owner}, ${data.phones[0]}', style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: const Color(0xff272d30),
                      )),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEntry(BuildContext context, Message item) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 8),
      child: Directionality(
        textDirection: item.fromId == _uid ? TextDirection.rtl : TextDirection.ltr,
        child: Row(
          verticalDirection: VerticalDirection.down,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 10),
              child: CircleAvatar(
                backgroundImage: NetworkImage(item.from.photoUrl),
                radius: 18,
              ),
            ),
            Expanded(child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Material(
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadiusDirectional.only(
                    topStart: Radius.circular(4),
                    topEnd: Radius.circular(4),
                    bottomStart: Radius.zero,
                    bottomEnd: Radius.circular(4),
                  )),
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    alignment: Alignment.topLeft,
                    child: Text(
                      item.text,
                      textDirection: Directionality.of(context),
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 14,
                        color: const Color(0xff272d30).withOpacity(0.7),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: RichText(
                    textDirection: Directionality.of(context),
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.normal,
                        color: const Color(0xff272d30).withOpacity(0.7),
                      ),
                      text: '${item.fromId == _uid ? 'Вы' : item.from.displayName}, ${_formatDate(context, item.timestamp)} ',
                      children: [
                        TextSpan(
                          style: TextStyle(fontFamily: 'MaterialIcons', color: const Color(0xff79be63)),
                          text: item.read
                              ? String.fromCharCode(Icons.done_all.codePoint)
                              : String.fromCharCode(Icons.done.codePoint),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffe7e7e7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: const Color(0xff2b2b2b)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          widget.title,
          style: Theme.of(context).textTheme.body1.copyWith(
            fontSize: 14,
            color: const Color(0xff272d30),
          ),
        ),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.more_vert, color: const Color(0xff2b2b2b)), onPressed: () {
            showCupertinoModalPopup(context: context, builder: (ctx) {
              return CupertinoActionSheet(
                title: Text('Выберите действие'),
                actions: <Widget>[
                  CupertinoActionSheetAction(
                    child: Text('Добавить другие квартиры', style: TextStyle(color: const Color(0xffef5353))),
                    onPressed: () {},
                  ),
                  CupertinoActionSheetAction(
                    child: Text('Пожаловаться', style: TextStyle(color: const Color(0xffef5353))),
                    onPressed: () {},
                  ),
                ],
                cancelButton: CupertinoActionSheetAction(
                  child: Text(
                    MaterialLocalizations.of(ctx).cancelButtonLabel,
                    style: TextStyle(color: const Color(0xffef5353)),
                  ),
                  isDefaultAction: true,
                  onPressed: () => Navigator.pop(ctx),
                ),
              );
            });
          })
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: BlocBuilder<MessagesEvent, MessagesState>(
              bloc: widget.messagesBloc,
              builder: (ctx, state) {
                if (state is LoadedState) {
                  Conversation chat = state.entries.singleWhere((c) => c.id == widget.dialogId);
                  _startedId = chat.startedById;
                  if ((_lastLength ?? 0) != chat.messages.length) {
                    _lastLength = chat.messages.length;
                    _sender?.complete();
                    _sender = null;
                  }
                  return CustomScrollView(
                    controller: _scrollController,
                    reverse: true,
                    slivers: <Widget>[
                      const SliverToBoxAdapter(child: SizedBox(height: 20)),
                      SliverList(delegate: SliverChildBuilderDelegate((ctx, i) {
                        return _buildEntry(ctx, chat.messages[chat.messages.length - 1 - i]);
                      }, childCount: chat.messages.length)),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                          child: Text(
                            'Пользователи ${chat.op(_uid).displayName} и вы в этом чате',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 12,
                              color: const Color(0xff272d30).withOpacity(0.7),
                            ),
                          ),
                        ),
                      ),
                      if (_startedId == _uid)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
                            child: _buildInfoCard(ctx),
                          ),
                        ),
                      if (chat.data != null && chat.data.isNotEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: _buildDataCard(ctx, chat.data[0]),
                          ),
                        ),
                      if (_startedId != _uid)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20, top: 16),
                            child: _buildInfoCard(ctx),
                          ),
                        ),
                    ],
                  );
                } else {
                  return Container();
                }
              },
            ),
          ),
          _ReplyField(
            onMessage: (msg) {
              _sender = Completer();
              widget.messagesBloc.dispatch(MessagesSendEvent(_uid, widget.dialogId, msg));
              return _sender.future;
            },
          ),
        ],
      ),
    );
  }
}

typedef Future SendCallback(String message);

class _ReplyField extends StatefulWidget {
  final SendCallback onMessage;

  const _ReplyField({Key key, this.onMessage}) : super(key: key);

  @override
  _ReplyFieldState createState() => _ReplyFieldState();
}

class _ReplyFieldState extends State<_ReplyField> with SingleTickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocus = FocusNode();
  AnimationController _controller;
  bool _canSend = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        FocusScope.of(context).requestFocus(_inputFocus);
      } else if (status == AnimationStatus.reverse) {
        _inputFocus.unfocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AnimatedBuilder(
            animation: _controller,
            builder: (ctx, child) {
              return SizedOverflowBox(
                size: Size.fromHeight(50 * _controller.value),
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: child,
                ),
              );
            },
            child: FadeTransition(
              opacity: _controller,
              child: TextField(
                controller: _inputController,
                focusNode: _inputFocus,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Сообщение...',
                ),
                onChanged: (s) {
                  bool b = s != null && s.trim().isNotEmpty;
                  if (b != _canSend) {
                    setState(() {
                      _canSend = b;
                    });
                  }
                },
              ),
            ),
          ),
          FadeTransition(opacity: _controller, child: Divider(height: 0)),
          SizedBox(
            height: 50,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: RotationTransition(
                    turns: Tween<double>(begin: 0, end: 0.625).animate(_controller),
                    child: Icon(Icons.add),
                  ),
                  color: const Color(0xFFEF5353),
                  onPressed: () {
                    if (_controller.value == 0) {
                      _controller.animateTo(1, curve: Curves.easeOut);
                    } else if (_controller.value == 1) {
                      _controller.animateBack(0, curve: Curves.easeIn);
                    }
                  },
                ),
                const Expanded(child: SizedBox.shrink()),
                FlatButton(
                  child: Text('Отправить'),
                  textColor: const Color(0xff272d30),
                  shape: const RoundedRectangleBorder(),
                  onPressed: _canSend ? () async {
                    if (widget.onMessage == null || !_canSend) return;
                    setState(() => _canSend = false);
                    await widget.onMessage(_inputController.text);
                    _controller.animateBack(0, curve: Curves.easeIn).then((_) {
                      _inputController..clearComposing()..clear();
                    });
                  } : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}