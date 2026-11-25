import 'package:flutter/material.dart';
import '../data/db_helper.dart';
import '../game/gravity_game.dart';
import '../game/skins.dart';
import 'pixel_ui.dart';

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
    PxTone tone;
    if (equipped) {
      label = 'EQUIPPED';
      onTap = null;
      tone = PxTone.grey;
    } else if (owned) {
      label = 'EQUIP';
      onTap = () => _equip(s);
      tone = PxTone.green;
    } else {
      label = 'BUY ${s.price}';
      onTap = canAfford ? () => _buy(s) : null;
      tone = PxTone.orange;
    }

    return PixelCard(
      width: 140,
      highlight: equipped,
      child: Column(
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: CustomPaint(painter: _SkinPreview(s)),
          ),
          const SizedBox(height: 8),
          Text(
            s.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: pxStyle(size: 13, spacing: 1),
          ),
          const SizedBox(height: 8),
          PixelButton(
            label: label,
            onTap: onTap,
            tone: tone,
            compact: true,
            highlight: equipped,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PixelScreen(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: PixelPanel(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const PixelBanner('SKIN SHOP'),
                  const SizedBox(height: 12),
                  Text(
                    'CANDY: $_balance',
                    style: pxStyle(size: 20, color: pxYellow, spacing: 2),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 20,
                    child: Text(
                      _msg,
                      style: pxStyle(size: 12, color: pxMuted, spacing: 1),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_loading)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(color: pxGold),
                    )
                  else if (_error)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Database not ready.',
                        style: pxStyle(size: 13, color: Colors.redAccent, spacing: 1),
                      ),
                    )
                  else
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children: skins.map(_card).toList(),
                    ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 200,
                    child: PixelButton(
                      label: 'BACK',
                      onTap: widget.game.closeShop,
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