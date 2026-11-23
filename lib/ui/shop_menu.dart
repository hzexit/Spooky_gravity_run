import 'package:flutter/material.dart';
import '../data/db_helper.dart';
import '../game/gravity_game.dart';
import '../game/skins.dart';
import 'menu_button.dart';

class _SkinPreview extends CustomPainter {
  final SkinDef skin;
  _SkinPreview(this.skin);

  @override
  void paint(Canvas canvas, Size size) =>
      paintSkin(canvas, size.width, size.height, skin);

  @override
  bool shouldRepaint(covariant _SkinPreview old) => old.skin != skin;
}

class ShopMenu extends StatefulWidget {
  final GravityGame game;
  const ShopMenu({super.key, required this.game});

  @override
  State<ShopMenu> createState() => _ShopMenuState();
}

class _ShopMenuState extends State<ShopMenu> {
  int _balance = 0;
  Set<String> _owned = {'classic'};
  String _selected = 'classic';
  bool _loading = true;
  bool _error = false;
  String _msg = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final db = DbHelper.instance;
      final b = await db.getBalance();
      final o = await db.getOwnedSkins();
      final s = await db.getSelectedSkin();
      if (!mounted) return;
      setState(() {
        _balance = b;
        _owned = o;
        _selected = s;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = true;
        _loading = false;
      });
    }
  }

  Future<void> _equip(SkinDef s) async {
    await DbHelper.instance.selectSkin(s.id);
    widget.game.currentSkin = s;
    if (!mounted) return;
    setState(() {
      _selected = s.id;
      _msg = '${s.name} equipped';
    });
  }

  Future<void> _buy(SkinDef s) async {
    final ok = await DbHelper.instance.buySkin(s.id, s.price);
    if (!mounted) return;
    if (!ok) {
      setState(() => _msg = 'Not enough candy');
      return;
    }
    await _equip(s); // ซื้อแล้วใส่ให้เลย
    await _load();
    if (mounted) setState(() => _msg = 'Bought ${s.name}!');
  }

  Widget _card(SkinDef s) {
    final owned = _owned.contains(s.id);
    final equipped = _selected == s.id;
    final canAfford = _balance >= s.price;

    String label;
    VoidCallback? onTap;
    Color color;
    if (equipped) {
      label = 'EQUIPPED';
      onTap = null;
      color = Colors.white24;
    } else if (owned) {
      label = 'EQUIP';
      onTap = () => _equip(s);
      color = const Color(0xFF2E7D32);
    } else {
      label = 'BUY ${s.price}';
      onTap = canAfford ? () => _buy(s) : null;
      color = canAfford ? const Color(0xFFFF9800) : Colors.white12;
    }

    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: equipped ? const Color(0xFFFF9800) : Colors.white24,
          width: equipped ? 2.5 : 1.5,
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: CustomPaint(painter: _SkinPreview(s)),
          ),
          const SizedBox(height: 10),
          Text(
            s.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                disabledBackgroundColor: color,
                foregroundColor: Colors.white,
                disabledForegroundColor: Colors.white60,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xF20B1B26),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'SKIN SHOP',
                  style: TextStyle(
                    color: Color(0xFFFF9800),
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Candy: $_balance',
                  style: const TextStyle(
                    color: Color(0xFFFFEB3B),
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 22,
                  child: Text(
                    _msg,
                    style: const TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                ),
                const SizedBox(height: 10),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  )
                else if (_error)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Database not ready.',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  )
                else
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 14,
                    runSpacing: 14,
                    children: skins.map(_card).toList(),
                  ),
                const SizedBox(height: 24),
                MenuButton(
                  label: 'BACK',
                  selected: true,
                  onTap: widget.game.closeShop,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}