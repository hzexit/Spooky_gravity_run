import 'package:flutter/material.dart';
import '../data/db_helper.dart';
import '../game/gravity_game.dart';
import 'menu_button.dart';

class StatsMenu extends StatefulWidget {
  final GravityGame game;
  const StatsMenu({super.key, required this.game});

  @override
  State<StatsMenu> createState() => _StatsMenuState();
}

class _StatsMenuState extends State<StatsMenu> {
  late final Future<StatsSummary> _future;

  @override
  void initState() {
    super.initState();
    _future = DbHelper.instance.getSummary();
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  String _fmt(DateTime t) =>
      '${_two(t.day)}/${_two(t.month)} ${_two(t.hour)}:${_two(t.minute)}';

  Widget _card(String label, String value, Color color) {
    return Container(
      width: 170,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24, width: 1.5),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _runRow(RunRecord r) {
    const style = TextStyle(color: Colors.white, fontSize: 15);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(_fmt(r.playedAt),
                style: const TextStyle(color: Colors.white60, fontSize: 14)),
          ),
          Expanded(child: Text('${r.distance} m', style: style)),
          Expanded(
            child: Text(
              'Candy ${r.candies}',
              style: const TextStyle(color: Color(0xFFFFEB3B), fontSize: 15),
            ),
          ),
          Text('${r.score} pts', style: style),
        ],
      ),
    );
  }

  Widget _content(StatsSummary s) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: [
            _card('BEST DISTANCE', '${s.bestDistance} m', Colors.white),
            _card('BEST SCORE', '${s.bestScore}', const Color(0xFFFF9800)),
            _card('GAMES PLAYED', '${s.runs}', Colors.white),
            _card('TOTAL DISTANCE', '${s.totalDistance} m', Colors.white),
            _card('TOTAL CANDY', '${s.totalCandies}', const Color(0xFFFFEB3B)),
            _card('CANDY BALANCE', '${s.balance}', const Color(0xFFFFEB3B)),
          ],
        ),
        const SizedBox(height: 22),
        const Text(
          'RECENT RUNS',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 3,
          ),
        ),
        const Divider(color: Colors.white24),
        if (s.recent.isEmpty)
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text('No runs yet. Go play!',
                style: TextStyle(color: Colors.white60)),
          )
        else
          ...s.recent.map(_runRow),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xF20B1B26),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'STATISTICS',
                  style: TextStyle(
                    color: Color(0xFFFF9800),
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 5,
                  ),
                ),
                const SizedBox(height: 18),
                FutureBuilder<StatsSummary>(
                  future: _future,
                  builder: (context, snap) {
                    if (snap.hasError) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Database not ready.\nOn web, run: dart run sqflite_common_ffi_web:setup',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      );
                    }
                    if (!snap.hasData) {
                      return const Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(),
                      );
                    }
                    return _content(snap.data!);
                  },
                ),
                const SizedBox(height: 22),
                MenuButton(
                  label: 'BACK',
                  selected: true,
                  onTap: widget.game.closeStats,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}