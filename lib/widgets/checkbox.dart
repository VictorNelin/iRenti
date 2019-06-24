import 'package:flutter/material.dart';

class RoundCheckbox extends StatefulWidget {
  final bool initial;
  final ValueChanged<bool> onChanged;
  final double outerSize;
  final double innerSize;

  const RoundCheckbox({
    Key key,
    this.initial = false,
    this.onChanged,
    this.outerSize = 28.0,
    this.innerSize = 28.0,
  }) : super(key: key);

  @override
  _RoundCheckboxState createState() => _RoundCheckboxState(initial);
}

class _RoundCheckboxState extends State<RoundCheckbox> with SingleTickerProviderStateMixin {
  AnimationController _checkbox;
  bool _agreed;

  _RoundCheckboxState(this._agreed);

  @override
  void initState() {
    super.initState();
    _checkbox = AnimationController(
      value: _agreed ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(RoundCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initial != oldWidget?.initial) {
      if (widget.initial) {
        _checkbox.animateTo(1.0, duration: const Duration(milliseconds: 200));
      } else {
        _checkbox.animateTo(0.0, duration: const Duration(milliseconds: 200));
      }
      _agreed = widget.initial;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        unselectedWidgetColor: Colors.transparent,
      ),
      child: ClipOval(
        child: SizedOverflowBox(
          size: Size.square(widget.outerSize),
          alignment: Alignment.center,
          child: DecoratedBoxTransition(
            decoration: DecorationTween(
              begin: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFEF5353), width: 2.0),
              ),
              end: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFEF5353), width: 28),
              ),
            ).animate(CurvedAnimation(parent: _checkbox.view, curve: Curves.easeOut)),
            child: Checkbox(
              value: _agreed,
              activeColor: Colors.transparent,
              onChanged: (b) {
                if (b) {
                  _checkbox.animateTo(1.0, duration: const Duration(milliseconds: 200));
                } else {
                  _checkbox.animateTo(0.0, duration: const Duration(milliseconds: 200));
                }
                setState(() => _agreed = b);
                if (widget.onChanged != null) {
                  widget.onChanged(b);
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

