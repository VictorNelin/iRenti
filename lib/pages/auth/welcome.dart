import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(flex: 5, child: GestureDetector(onTap: () => Navigator.pushNamed(context, '/profile'))),
            Text(
              'Добро пожаловать!',
              style: Theme.of(context).textTheme.headline.copyWith(
                color: const Color(0xFFEF5353),
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Айренти помогает найти квартиру\n'
                  'и соседей для совместного\n'
                  'проживания.',
              style: Theme.of(context).textTheme.subhead.copyWith(
                color: const Color(0xFFEF5353),
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Зарегистрируйтесь или авторизуйтесь,\n'
                  'чтобы начать.',
              style: Theme.of(context).textTheme.body1.copyWith(
                color: const Color(0xFFEF5353),
              ),
            ),
            Expanded(flex: 3, child: GestureDetector(onTap: () => Navigator.pushNamed(context, '/catalog'))),
            FlatButton(
              child: Text('РЕГИСТРАЦИЯ'),
              color: const Color(0xFFEF5353),
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
            ),
            const SizedBox(height: 8.0),
            FlatButton(
              child: Text('АВТОРИЗАЦИЯ'),
              color: const Color(0xFF272D30),
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}

