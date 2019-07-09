import 'package:flutter/material.dart';

class RoundCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final double size;

  const RoundCheckbox({
    Key key,
    this.value = false,
    this.onChanged,
    this.size = 20.0,
  }) : super(key: key);

  @override
  _RoundCheckboxState createState() => _RoundCheckboxState(value);
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
    if (widget.value != oldWidget?.value) {
      if (widget.value) {
        _checkbox.animateTo(1.0, duration: const Duration(milliseconds: 200));
      } else {
        _checkbox.animateTo(0.0, duration: const Duration(milliseconds: 200));
      }
      _agreed = widget.value;
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
          size: Size.square(widget.size),
          alignment: Alignment.center,
          child: DecoratedBoxTransition(
            decoration: DecorationTween(
              begin: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFEF5353), width: 2),
              ),
              end: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFEF5353), width: widget.size / 2),
              ),
            ).animate(CurvedAnimation(parent: _checkbox.view, curve: Curves.easeOut)),
            child: SizedBox.fromSize(
              size: Size.square(widget.size),
              child: Checkbox(
                value: _agreed,
                activeColor: Colors.transparent,
                onChanged: widget.onChanged,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

