import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:irenti/bloc/auth_bloc.dart';
import 'package:irenti/widgets/checkbox.dart';

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
    'Не курю',
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
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<dynamic> data;// = List<dynamic>.generate(7, (_) => null);
  bool _canSave = false;

  String _toString(int field, value) {
    if (value == null) {
      return 'Указать';
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
                    ))
                        : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: _kData[i].map((s) {
                        return ListTile(
                          leading: RoundCheckbox(
                            initial: _kData[i].indexOf(s) == value,
                            onChanged: (b) {
                              setPageState(() {
                                value = b ? _kData[i].indexOf(s) : null;
                              });
                            },
                          ),
                          title: Text(s),
                        );
                      }).toList(growable: false),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: SafeArea(
          child: Row(
            children: <Widget>[
              InkWell(
                onTap: () {},
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Icon(Icons.settings),
                ),
              ),
              const Expanded(child: SizedBox(height: kToolbarHeight)),
              InkWell(
                onTap: () {
                  BlocProvider.of<AuthenticationBloc>(context).dispatch(LoggedOut());
                  Navigator.of(context, rootNavigator: true).pushReplacementNamed('/');
                  //Navigator.of(context, rootNavigator: true).popUntil((r) => r.settings.name == '/');
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
          ),
        ),
      ),
      body: Theme(
        data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
        child: BlocBuilder(
          bloc: BlocProvider.of<AuthenticationBloc>(context),
          builder: (ctx, state) {
            if (state is Authenticated) {
              data ??= state.data;
              return ListView(
                padding: EdgeInsets.zero,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 32),
                    child: Text(
                      'Профиль',
                      style: Theme.of(context).textTheme.headline.copyWith(
                        color: const Color(0xFF272D30),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40.0),
                    child: Text(
                      'Добавьте информацию о себе.\n'
                          'Это поможет точнее подобрать жилье\n'
                          'и познакомить вас с соседями.',
                      style: Theme.of(context).textTheme.body1.copyWith(
                        color: const Color(0xFF272D30),
                        fontWeight: FontWeight.normal,
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    child: Row(
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: ctx,
                              builder: (ctx) => CupertinoAlertDialog(
                                title: Text('Загрузить аватар'),
                                actions: <Widget>[
                                  CupertinoDialogAction(
                                    child: Text('Сделать фото'),
                                    onPressed: () {
                                      BlocProvider.of<AuthenticationBloc>(context).dispatch(UploadAvatar(true));
                                    },
                                  ),
                                  CupertinoDialogAction(
                                    child: Text('Выбрать из галереи'),
                                    onPressed: () {
                                      BlocProvider.of<AuthenticationBloc>(context).dispatch(UploadAvatar(false));
                                    },
                                  ),
                                ],
                              )
                            );
                          },
                          child: CircleAvatar(
                            radius: 45.0,
                            backgroundColor: const Color(0xFFF2F2F2),
                            child: Visibility(
                              visible: state.user.photoUrl == null || state.user.photoUrl.isEmpty,
                              child: const Icon(Icons.add, size: 32.0, color: Color(0xFFEF5353)),
                            ),
                            backgroundImage: state.user.photoUrl != null && state.user.photoUrl.isNotEmpty
                                ? NetworkImage(state.user.photoUrl)
                                : null,
                          ),
                        ),
                        const SizedBox(width: 20.0),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              state.user.displayName,
                              style: Theme.of(context).textTheme.title.copyWith(
                                color: const Color.fromRGBO(0x27, 0x2D, 0x30, 1),
                              ),
                            ),
                            const SizedBox(height: 6.0),
                            Text(
                              state.user.email,
                              style: Theme.of(context).textTheme.body1.copyWith(
                                color: const Color.fromRGBO(0x27, 0x2D, 0x30, 0.7),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Color.fromRGBO(0x27, 0x2D, 0x30, 0.08), height: 0.0),
                  for (int i = 0; i < 7; ++i)
                    Column(
                      children: <Widget>[
                        InkWell(
                          child: Container(
                            height: 80.0,
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    //mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        _kTitles[i],
                                        style: Theme.of(context).textTheme.body1.copyWith(
                                          color: const Color.fromRGBO(0x27, 0x2D, 0x30, 0.7),
                                          fontWeight: FontWeight.normal,
                                          fontSize: 14.0,
                                        ),
                                      ),
                                      Text(
                                        _toString(i, data[i]),
                                        style: Theme.of(context).textTheme.body2.copyWith(
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF272D30),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.edit, size: 16.0),
                              ],
                            ),
                          ),
                          onTap: () => _onTapEntry(ctx, i),
                        ),
                        const Divider(color: Color.fromRGBO(0x27, 0x2D, 0x30, 0.08), height: 0.0),
                      ],
                    ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 64.0),
                    child: FlatButton(
                      child: Text('СОХРАНИТЬ'),
                      color: const Color(0xFF272D30),
                      onPressed: _canSave ? () {
                        BlocProvider.of<AuthenticationBloc>(context).dispatch(UpdateProfile(data));
                        setState(() {
                          _canSave = false;
                        });
                      } : null,
                    ),
                  ),
                ],
              );
            } else {
              return Container();
            }
          }
        ),
      ),
    );
  }
}

