// สัญลักษณ์: v = หนามเพดาน, ^ = หนามพื้น, c = ขนม, . = ว่าง

class LevelRules {
  static const double col = 64; // ความกว้างต่อ 1 คอลัมน์ (px)
  static const int pad = 3; // คอลัมน์ว่างหัว-ท้ายของทุก chunk
  // หนามคนละฝั่งต้องห่างกันอย่างน้อยกี่คอลัมน์ (เวลาที่ตัวละครใช้ตกข้ามฝั่ง)
  static const int minSwitchCols = 6;
}

class Chunk {
  final String name;
  final List<String> rows; // 3 แถว (รวม padding แล้ว)
  int get width => rows[0].length;

  Chunk(this.name, List<String> body) : rows = _pad(body);

  static List<String> _pad(List<String> body) {
    final p = '.' * LevelRules.pad;
    return body.map((r) => '$p$r$p').toList();
  }
}

/// ตรวจว่า chunk (หรือ chunk ที่ต่อกันแล้ว) ผ่านได้
/// คืนค่า null ถ้าผ่าน ถ้าไม่ผ่านคืนข้อความบอกสาเหตุ
String? checkRows(List<String> rows) {
  if (rows.length != 3) return 'ต้องมี 3 แถว';
  final w = rows[0].length;
  for (final r in rows) {
    if (r.length != w) return 'ความยาวแต่ละแถวไม่เท่ากัน';
  }
  final top = rows[0], mid = rows[1], bot = rows[2];

  int? lastCol;
  String? lastSide;

  for (var i = 0; i < w; i++) {
    if (!'.vc'.contains(top[i])) return 'ตัวอักษรผิดที่แถวบน คอลัมน์ $i';
    if (!'.c'.contains(mid[i])) return 'ตัวอักษรผิดที่แถวกลาง คอลัมน์ $i';
    if (!'.^c'.contains(bot[i])) return 'ตัวอักษรผิดที่แถวล่าง คอลัมน์ $i';

    // หนามทั้งเพดานและพื้นในคอลัมน์เดียวกัน = ผ่านไม่ได้
    if (top[i] == 'v' && bot[i] == '^') {
      return 'คอลัมน์ $i มีหนามทั้งสองฝั่ง';
    }

    // เปลี่ยนฝั่งที่ต้องอยู่ ต้องมีระยะพอ
    final side = top[i] == 'v' ? 'C' : (bot[i] == '^' ? 'F' : null);
    if (side != null) {
      if (lastSide != null &&
          side != lastSide &&
          i - lastCol! < LevelRules.minSwitchCols) {
        return 'หนามคนละฝั่งใกล้เกินไป (คอลัมน์ $lastCol → $i)';
      }
      lastSide = side;
      lastCol = i;
    }

    // ขนมริมเพดาน/พื้น ห้ามติดหนามฝั่งเดียวกัน (เก็บไม่ได้)
    for (var d = -1; d <= 1; d++) {
      final j = i + d;
      if (j < 0 || j >= w) continue;
      if (top[i] == 'c' && top[j] == 'v') return 'ขนมติดหนามเพดาน คอลัมน์ $i';
      if (bot[i] == 'c' && bot[j] == '^') return 'ขนมติดหนามพื้น คอลัมน์ $i';
    }
  }
  return null;
}

// ---------------- Chunk ง่าย ----------------
final easyChunks = <Chunk>[
  Chunk('floor spike, candy above', [
    '.ccc.',
    '.....',
    '..^..',
  ]),
  Chunk('ceiling spike, candy below', [
    '..v..',
    '.....',
    '.ccc.',
  ]),
  Chunk('candy only', [
    'ccc....',
    '..c.c..',
    '....ccc',
  ]),
  Chunk('double floor spike', [
    '.cccc.',
    '......',
    '..^^..',
  ]),
];

// ---------------- Chunk ปานกลาง ----------------
final mediumChunks = <Chunk>[
  Chunk('floor then ceiling', [
    '......v',
    '...c...',
    '^......',
  ]),
  Chunk('zigzag 3', [
    '.......v......',
    '....c.....c...',
    '.^...........^',
  ]),
  Chunk('ceiling pair, floor candy', [
    '..vv....',
    '........',
    '..cccc..',
  ]),
  Chunk('floor spikes apart, candy above', [
    '.cccccc.',
    '........',
    '..^..^..',
  ]),
  Chunk('ceiling-floor-ceiling', [
    'v...........v',
    '...c.....c...',
    '......^......',
  ]),
];

// ---------------- Chunk ยาก ----------------
final hardChunks = <Chunk>[
  Chunk('zigzag 4', [
    '......v...........v',
    '...c.....c.....c...',
    '^...........^......',
  ]),
  Chunk('pairs and switches', [
    '........v.v......',
    '.....c.......c...',
    '^.^.............^',
  ]),
  Chunk('long hold', [
    'cccc.....vvvv',
    '.............',
    '^^^^.....cccc',
  ]),
];

final allChunks = <Chunk>[...easyChunks, ...mediumChunks, ...hardChunks];