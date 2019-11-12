import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:irenti/bloc/auth_bloc.dart';
import 'package:irenti/image.dart';
import 'package:irenti/model/user.dart';
import 'package:irenti/widgets/radio_group.dart';
import 'package:irenti/widgets/list_tile.dart';
import 'package:irenti/widgets/title_bar.dart';

const List<String> _kTitles = ['Дата рождения', 'Род деятельности', 'График работы', 'Животные', 'Уборка', 'Отношение к курению', 'Вечеринки'];
const List<List<String>> _kData = [
  null,
  null,
  [
    'В дневное время',
    'В вечернее и ночное время',
    'Посменно',
    'Непонятный график',
    'Не работаю',
  ],
  [
    'Есть',
    'Нет, но к животным отношусь хорошо',
    'Нет, животных не люблю',
  ],
  [
    'Убираюсь сам',
    'Нанимаю домработницу',
  ],
  [
    'Не курю и не люблю когда курят',
    'Не курю, но не возражаю когда курят',
    'Курю',
  ],
  [
    'Не против вечеринок',
    'Я против, если дома шумят',
  ],
];

class ProfilePage extends StatefulWidget {
  final UserData user;
  final bool firstRun;

  const ProfilePage({Key key, this.user, this.firstRun = false}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState(firstRun);
}

class _ProfilePageState extends State<ProfilePage> {
  List<dynamic> data;// = List<dynamic>.generate(7, (_) => null);
  bool _firstRun = false;
  bool _isEditing = false;
  bool _canSave = false;

  _ProfilePageState(bool firstRun) : _isEditing = firstRun, _firstRun = firstRun;

  String _toString(int field, value) {
    if (value == null) {
      return widget.user == null ? 'Указать' : 'Не указано';
    }
    if (value is DateTime) {
      return CupertinoLocalizations.of(context).datePickerMediumDate(value);
    }
    if (value is int) {
      return _kData[field][value];
    }
    return value.toString();
  }

  void _onTapEntry(BuildContext ctx, int i) async {
    dynamic value = data[i];
    await showModalBottomSheet(
      context: ctx,
      builder: (ctx) {
        return StatefulBuilder(
            builder: (ctx, setPageState) {
              return Material(
                color: Theme.of(context).canvasColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0),
                )),
                clipBehavior: Clip.hardEdge,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    AppBar(
                      primary: false,
                      backgroundColor: Colors.transparent,
                      elevation: 0.0,
                      centerTitle: false,
                      automaticallyImplyLeading: false,
                      title: Text(_kTitles[i], style: TextStyle(color: const Color(0xFF272D30))),
                      iconTheme: IconThemeData(color: const Color(0xFFEF5353)),
                      actions: <Widget>[
                        IconButton(icon: Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                      ],
                    ),
                    const Divider(color: Color.fromRGBO(0x27, 0x2D, 0x30, 0.08), height: 0.0),
                    _kData[i] == null
                        ? (i == 0
                        ? Container(
                      width: double.infinity,
                      height: 216.0,
                      child: DefaultTextStyle(
                        style: const TextStyle(
                          color: CupertinoColors.black,
                          fontSize: 22.0,
                        ),
                        child: GestureDetector(
                          onTap: () { },
                          child: SafeArea(
                            top: false,
                            child: CupertinoDatePicker(
                              mode: CupertinoDatePickerMode.date,
                              minimumYear: 1900,
                              maximumYear: DateTime.now().year,
                              initialDateTime: DateTime.now(),
                              onDateTimeChanged: (DateTime newDateTime) {
                                value = newDateTime;
                              },
                            ),
                          ),
                        ),
                      ),
                    )
                        : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: TextField(
                        autofocus: true,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                        ),
                        style: Theme.of(ctx).textTheme.body1.copyWith(
                          fontSize: 16.0,
                          fontWeight: FontWeight.normal,
                        ),
                        textCapitalization: TextCapitalization.words,
                        onChanged: (s) => value = s,
                      ),
                    )) : RadioGroup(
                      titles: _kData[i],
                      value: value,
                      onChanged: (b) {
                        setPageState(() {
                          value = b;
                        });
                      },
                      allowNullValue: true,
                      showDividers: true,
                    ),
                    SizedBox(height: MediaQuery.of(ctx).viewInsets.bottom),
                  ],
                ),
              );
            }
        );
      },
    );
    setState(() {
      _canSave = true;
      data = List.generate(7, (j) => j == i ? value : data[j]);
    });
  }

  //user is either FirebaseUser or UserData
  Widget _buildHeader(BuildContext context, dynamic user) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: _isEditing ? () {
              showDialog(
                context: context,
                builder: (ctx) => CupertinoAlertDialog(
                  title: Text('Загрузить аватар'),
                  actions: <Widget>[
                    CupertinoDialogAction(
                      child: Text('Сделать фото'),
                      onPressed: () {
                        BlocProvider.of<AuthenticationBloc>(context).add(UploadAvatar(true));
                      },
                    ),
                    CupertinoDialogAction(
                      child: Text('Выбрать из галереи'),
                      onPressed: () {
                        BlocProvider.of<AuthenticationBloc>(context).add(UploadAvatar(false));
                      },
                    ),
                  ],
                ),
              );
            } : null,
            child: ClipOval(
              child: Stack(
                children: <Widget>[
                  CircleAvatar(
                    radius: 45.0,
                    backgroundColor: const Color(0xFFF2F2F2),
                    child: Visibility(
                      visible: user.photoUrl == null || user.photoUrl.isEmpty,
                      child: const Icon(Icons.add, size: 32.0, color: Color(0xFFEF5353)),
                    ),
                    backgroundImage: user.photoUrl != null && user.photoUrl.isNotEmpty
                        ? CachedNetworkImageProvider(user.photoUrl)
                        : null,
                  ),
                  Positioned.fill(
                    child: Visibility(
                      visible: _isEditing,
                      child: Container(
                        color: Colors.black45,
                        alignment: Alignment.center,
                        child: const Icon(Icons.edit, size: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 20.0),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                user.displayName,
                style: Theme.of(context).textTheme.title.copyWith(
                ),
              ),
              //UserData.email always returns null
              if (user.email != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    user.email,
                    style: Theme.of(context).textTheme.body1,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, dynamic user, List data) {
    return CustomScrollView(
      primary: false,
      slivers: <Widget>[
        SliverPersistentHeader(delegate: TitleBarDelegate('Профиль', 0), pinned: true),
        SliverList(delegate: SliverChildListDelegate([
          if (_firstRun && _isEditing)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 40.0),
              child: Text(
                'Добавьте информацию о себе.\n'
                    'Это поможет точнее подобрать жилье\n'
                    'и познакомить вас с соседями.',
                style: Theme.of(context).textTheme.body1.copyWith(
                  fontWeight: FontWeight.normal,
                  fontSize: 14.0,
                ),
              ),
            ),
          _buildHeader(context, user),
          for (int i = 0; i < 7; ++i)
            ListEntry(
              title: _kTitles[i],
              child: Text(_toString(i, data != null ? data[i] : this.data)),
              padding: 16,
              trailing: _isEditing ? const Icon(Icons.edit, size: 16.0) : null,
              onTap: _isEditing ? () => _onTapEntry(context, i) : null,
            ),
          if (widget.user == null)
            const Divider(color: Color.fromRGBO(0x27, 0x2D, 0x30, 0.08), height: 0.0),
          if (widget.user == null)
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 64.0),
              child: _isEditing ? FlatButton(
                child: const Text('СОХРАНИТЬ'),
                color: const Color(0xFFEF5353),
                onPressed: () {
                  if (_canSave) BlocProvider.of<AuthenticationBloc>(context).add(UpdateProfile(this.data));
                  setState(() {
                    _isEditing = false;
                    _firstRun = false;
                    _canSave = false;
                  });
                },
              ) : FlatButton(
                child: const Text('ИЗМЕНИТЬ'),
                color: const Color(0xFF272D30),
                onPressed: () => setState(() => _isEditing = true),
              ),
            ),
        ])),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: SafeArea(
          child: widget.user == null ? Row(
            children: <Widget>[
              InkWell(
                onTap: () => Navigator.pushNamed(context, '/settings'),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Icon(Icons.settings),
                ),
              ),
              const Expanded(child: SizedBox(height: kToolbarHeight)),
              InkWell(
                onTap: () {
                  BlocProvider.of<AuthenticationBloc>(context).add(LoggedOut());
                  Navigator.of(context, rootNavigator: true).pushReplacementNamed('/');
                },
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Выйти',
                    style: Theme.of(context).textTheme.subhead.copyWith(
                      fontSize: 14.0,
                    ),
                  ),
                ),
              ),
            ],
          ) : InkWell(
            onTap: () => Navigator.pop(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(width: 16.0, height: kToolbarHeight),
                const Icon(Icons.arrow_back_ios, size: 16.0),
                const SizedBox(width: 16.0),
                Align(child: Text(
                  'Назад',
                  style: Theme.of(context).textTheme.subhead.copyWith(
                    fontSize: 14.0,
                  ),
                )),
                const SizedBox(width: 16.0),
              ],
            ),
          ),
        ),
      ),
      body: Theme(
        data: Theme.of(context),//.copyWith(canvasColor: Colors.transparent),
        child: widget.user == null ? BlocBuilder(
          bloc: BlocProvider.of<AuthenticationBloc>(context),
          builder: (ctx, state) {
            if (state is Authenticated) {
              data ??= state.data;
              return _buildBody(ctx, state.user, data);
            } else {
              return Container();
            }
          }
        ) : _buildBody(context, widget.user, widget.user.data),
      ),
    );
  }
}

