import 'package:flutter/material.dart';

String timeAgoShort(DateTime date, {DateTime? now}) {
  final n = now ?? DateTime.now();
  final diff = n.difference(date);

  if (diff.inSeconds < 45) return 'adesso';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min fa';
  if (diff.inHours < 24) return '${diff.inHours} h fa';
  if (diff.inDays < 7) return '${diff.inDays} g fa';

  final weeks = (diff.inDays / 7).floor();
  if (weeks < 5) return '$weeks sett. fa';

  final months = (diff.inDays / 30).floor();
  if (months < 12) return months == 1 ? '1 mese fa' : '$months mesi fa';

  final years = (diff.inDays / 365).floor();
  if (years > 5) return 'tanto tempo fa';
  return years == 1 ? '1 anno fa' : '$years anni fa';
}


class TimeAgoText extends StatefulWidget {
  final DateTime date;
  final TextStyle? style;
  const TimeAgoText(this.date, {super.key, this.style});

  @override
  State<TimeAgoText> createState() => _TimeAgoTextState();
}

class _TimeAgoTextState extends State<TimeAgoText> {
  @override
  void initState() {
    super.initState();
    // Aggiorna ogni 60s
    Future.doWhile(() async {
      if (!mounted) return false;
      await Future.delayed(const Duration(minutes: 1));
      if (mounted) setState(() {});
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      timeAgoShort(widget.date),
      style: widget.style,
    );
  }
}
