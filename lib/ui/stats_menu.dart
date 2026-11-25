import 'package:flutter/material.dart';
import '../data/db_helper.dart';
import '../game/gravity_game.dart';
import 'pixel_ui.dart';

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
    return PixelCard(
      width: 150,
      child: Column(
        children: [
          Text(value, style: pxStyle(size: 18, color: color, spacing: 0)),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: pxStyle(size: 10, color: pxMuted, spacing: 1),
          ),
        ],
      ),
    );
  }

  Widget _runRow(RunRecord r) {
    final s = pxStyle(size: 12, spacing: 0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            child: Text(_fmt(r.playedAt),
                style: pxStyle(size: 11, color: pxMuted, spacing: 0)),
          ),
          Expanded(child: Text('${r.distance} m', style: s)),
          Expanded(
            child: Text('Candy ${r.candies}',
                style: pxStyle(size: 12, color: pxYellow, spacing: 0)),
          ),
          Text('${r.score} pts', style: s),
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
          spacing: 10,
          runSpacing: 10,
          children: [
            _card('BEST DISTANCE', '${s.bestDistance} m', Colors.white),
            _card('BEST SCORE', '${s.bestScore}', pxOrange),
            _card('GAMES PLAYED', '${s.runs}', Colors.white),
            _card('TOTAL DISTANCE', '${s.totalDistance} m', Colors.white),
            _card('TOTAL CANDY', '${s.totalCandies}', pxYellow),
            _card('CANDY BALANCE', '${s.balance}', pxYellow),
          ],
        ),
        const SizedBox(height: 20),
        Text('RECENT RUNS', style: pxStyle(size: 14, color: pxGold, spacing: 3)),
        const SizedBox(height: 6),
        Container(height: 3, color: pxGoldDark),
        const SizedBox(height: 4),
        if (s.recent.isEmpty)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text('No runs yet. Go play!',
                style: pxStyle(size: 13, color: pxMuted, spacing: 1)),
          )
        else
          ...s.recent.map(_runRow),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PixelScreen(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: PixelPanel(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const PixelBanner('STATISTICS'),
                  const SizedBox(height: 16),
                  FutureBuilder<StatsSummary>(
                    future: _future,
                    builder: (context, snap) {
                      if (snap.hasError) {
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Database not ready.\nOn web, run: dart run sqflite_common_ffi_web:setup',
                            textAlign: TextAlign.center,
                            style: pxStyle(size: 12, color: Colors.redAccent, spacing: 0),
                          ),
                        );
                      }
                      if (!snap.hasData) {
                        return const Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(color: pxGold),
                        );
                      }
                      return _content(snap.data!);
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 200,
                    child: PixelButton(
                      label: 'BACK',
                      onTap: widget.game.closeStats,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}