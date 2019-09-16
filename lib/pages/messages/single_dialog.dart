import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:irenti/bloc/auth_bloc.dart';
import 'package:irenti/bloc/messages_bloc.dart';
import 'package:irenti/image.dart';
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

  const DialogPage({Key key, this.dialogId, this.title}) : super(key: key);

  @override
  _DialogPageState createState() => _DialogPageState();
}

class _DialogPageState extends State<DialogPage> {
  final ScrollController _scrollController = ScrollController();
  int _lastLength;
  Completer _sender;
  String _uid;
  String _startedId;

  MessagesBloc get _messagesBloc => BlocProvider.of<MessagesBloc>(context);

  @override
  void initState() {
    super.initState();
    _uid = (BlocProvider.of<AuthenticationBloc>(context).currentState as Authenticated).user.uid;
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
    return '${date.day} ${_months[date.month - 1]}'
        '${date.year != DateTime.now().year ? ' ${date.year}' : ''}, '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
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

  Widget _buildDataCard(BuildContext context, CatalogEntry data, [bool showCaption = false]) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (showCaption)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'Квартира, которую вы обсуждаете',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ),
        Material(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => Navigator.pushNamed(context, '/catalog/single', arguments: data),
            child: Container(
              height: 110,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  AspectRatio(
                    aspectRatio: 1,
                    child: Image(image: CachedNetworkImageProvider(data.photos[0]), fit: BoxFit.cover),
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
                        )),
                        Text(
                          '${data.owner != null ? 'Хозяин:\n${data.owner}, ' : ''}${data.phones[0]}',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEntry(BuildContext context, Message item, Conversation chat) {
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
                radius: 18,
                backgroundImage: item.from.photoUrl != null ? CachedNetworkImageProvider(item.from.photoUrl) : null,
                child: ClipOval(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: item.from.photoUrl == null ? const Icon(Icons.person, size: 36) : null,
                  ),
                ),
              ),
            ),
            Expanded(child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (item.data == null && item.text != null)
                  Material(
                    type: MaterialType.card,
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
                        item.text ?? 'NULL',
                        textDirection: Directionality.of(context),
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                if (item.data != null && item.text == null)
                  _buildDataCard(context, chat.data[item.data]),
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: RichText(
                    textDirection: Directionality.of(context),
                    text: TextSpan(
                      style: Theme.of(context).textTheme.caption.copyWith(
                        fontSize: 12.0,
                        fontWeight: FontWeight.normal,
                      ),
                      text: '${item.fromId == _uid ? 'Вы' : item.from.displayName}, ${_formatDate(context, item.timestamp)} ',
                      children: [
                        TextSpan(
                          style: TextStyle(fontFamily: 'MaterialIcons', color: const Color(0xff79be63)),
                          text: item.timestamp < chat.lastReadTime
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
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          widget.title,
          style: Theme.of(context).textTheme.body1.copyWith(
            fontSize: 14,
          ),
        ),
        actions: <Widget>[
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {
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
            child: BlocBuilder<MessagesBloc, MessagesState>(
              bloc: _messagesBloc,
              builder: (ctx, state) {
                if (state is MessagesLoadedState) {
                  Conversation chat = state.entries.singleWhere((c) => c.id == widget.dialogId, orElse: () {
                    Navigator.pop(context);
                    return null;
                  });
                  if (chat == null) return const SizedBox();
                  _startedId = chat.startedById;
                  if ((_lastLength ?? 0) != chat.messages.length) {
                    _lastLength = chat.messages.length;
                    _sender?.complete();
                    _sender = null;
                  }
                  if (chat.messages.isNotEmpty && !chat.messages.last.out(_uid) && (chat.lastReadTime ?? 0) <= chat.messages.last.timestamp) {
                    _messagesBloc.dispatch(MessagesReadEvent(chat.id));
                  }
                  return CustomScrollView(
                    controller: _scrollController,
                    reverse: true,
                    slivers: <Widget>[
                      const SliverToBoxAdapter(child: SizedBox(height: 20)),
                      SliverList(delegate: SliverChildBuilderDelegate((ctx, i) {
                        return _buildEntry(ctx, chat.messages[chat.messages.length - 1 - i], chat);
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
                            child: _buildDataCard(ctx, chat.data[0], true),
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
              _messagesBloc.dispatch(MessagesSendEvent(_uid, widget.dialogId, msg));
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

  _ReplyField({Key key, this.onMessage}) : super(key: key);

  @override
  _ReplyFieldState createState() => _ReplyFieldState();
}

class _ReplyFieldState extends State<_ReplyField> {
  final TextEditingController _inputController = TextEditingController();
  final ValueNotifier<bool> _canSend = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.card,
      shape: const RoundedRectangleBorder(),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: 50,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            PopupMenuButton(
              icon: const Icon(Icons.add, color: const Color(0xFFEF5353)),
              itemBuilder: (ctx) => [
                PopupMenuItem(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        WidgetSpan(
                          child: Icon(Icons.image, color: Theme.of(ctx).iconTheme.color),
                          alignment: PlaceholderAlignment.middle,
                        ),
                        const WidgetSpan(child: SizedBox(width: 16)),
                        TextSpan(
                          text: 'Изображение',
                          style: Theme.of(ctx).textTheme.subhead,
                        ),
                      ],
                    ),
                  ),
                ),
                PopupMenuItem(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        WidgetSpan(
                          child: Icon(Icons.contacts, color: Theme.of(ctx).iconTheme.color),
                          alignment: PlaceholderAlignment.middle,
                        ),
                        const WidgetSpan(child: SizedBox(width: 16)),
                        TextSpan(
                          text: 'Контакт',
                          style: Theme.of(ctx).textTheme.subhead,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: TextField(
                controller: _inputController,
                textCapitalization: TextCapitalization.sentences,
                minLines: 1,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Сообщение...',
                ),
                onChanged: (s) => _canSend.value = s != null && s.trim().isNotEmpty,
              ),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: _canSend,
              builder: (context, data, _) {
                return FlatButton(
                  child: const Text('Отправить'),
                  textColor: const Color(0xff272d30),
                  shape: const RoundedRectangleBorder(),
                  onPressed: data ? () async {
                    if (widget.onMessage == null || !data) return;
                    widget.onMessage(_inputController.text);
                    _inputController..clearComposing()..clear();
                    _canSend.value = false;
                  } : null,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
