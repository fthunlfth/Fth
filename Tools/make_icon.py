"""Hira'nın Macerası için 1024x1024 uygulama simgesi üretir.

Saf Python: harici kütüphane yok. Bütün şekiller poligona çevrilip
tarama satırı (scanline) ile alfa örtüşmesi hesaplanarak doldurulur.
Renkler oyunun Palette.swift dosyasından birebir alınmıştır.
"""
import math, zlib, struct

S = 1024
buf = bytearray(S * S * 3)

C = {
    "skyTop": (0x8C, 0xC9, 0xED), "skyBottom": (0xE6, 0xED, 0xD9),
    "seaTop": (0x4A, 0xAD, 0xC7), "seaDeep": (0x0F, 0x4D, 0x70),
    "sun": (0xFF, 0xF0, 0xB8), "foam": (0xFF, 0xFF, 0xFF),
    "hull": (0x9E, 0x61, 0x33), "rail": (0xCC, 0x8F, 0x54), "hullDark": (0x57, 0x30, 0x17),
    "skin": (0xF0, 0xC9, 0xA6), "skinShade": (0xDB, 0xAD, 0x87), "blush": (0xF2, 0x9E, 0x8F),
    "hair": (0x3B, 0x2B, 0x21), "hairShine": (0x5C, 0x45, 0x36), "eye": (0x6B, 0x4A, 0x2E),
    "top": (0xFA, 0xFA, 0xF7), "topShade": (0xDE, 0xDE, 0xD6),
    "vest": (0xFF, 0xAD, 0x33), "shorts": (0xD6, 0xEB, 0x4A),
    "teddy": (0xA8, 0xA8, 0xB0), "teddyDark": (0x70, 0x70, 0x7A),
    "white": (0xFF, 0xFF, 0xFF),
}


def put(x, y, rgb, a):
    if a <= 0 or x < 0 or y < 0 or x >= S or y >= S:
        return
    i = (y * S + x) * 3
    if a >= 1:
        buf[i], buf[i + 1], buf[i + 2] = rgb
    else:
        ia = 1 - a
        buf[i] = int(buf[i] * ia + rgb[0] * a)
        buf[i + 1] = int(buf[i + 1] * ia + rgb[1] * a)
        buf[i + 2] = int(buf[i + 2] * ia + rgb[2] * a)


def fill_polygon(pts, rgb=None, alpha=1.0, color_fn=None):
    """Dikeyde 4 alt satır örnekleyip yatayda kesirli örtüşme biriktirir."""
    if len(pts) < 3:
        return
    ys = [p[1] for p in pts]
    y0 = max(0, int(math.floor(min(ys))))
    y1 = min(S, int(math.ceil(max(ys))) + 1)
    n = len(pts)
    SS = 4
    for y in range(y0, y1):
        cov = {}
        for s in range(SS):
            sy = y + (s + 0.5) / SS
            xs = []
            for i in range(n):
                ax, ay = pts[i]
                bx, by = pts[(i + 1) % n]
                if (ay <= sy < by) or (by <= sy < ay):
                    xs.append(ax + (sy - ay) / (by - ay) * (bx - ax))
            xs.sort()
            for i in range(0, len(xs) - 1, 2):
                xa, xb = xs[i], xs[i + 1]
                if xb <= 0 or xa >= S:
                    continue
                xa = max(xa, 0.0)
                xb = min(xb, float(S))
                ia, ib = int(xa), int(xb)
                if ia == ib:
                    cov[ia] = cov.get(ia, 0.0) + (xb - xa) / SS
                else:
                    cov[ia] = cov.get(ia, 0.0) + (ia + 1 - xa) / SS
                    for x in range(ia + 1, ib):
                        cov[x] = cov.get(x, 0.0) + 1.0 / SS
                    if ib < S:
                        cov[ib] = cov.get(ib, 0.0) + (xb - ib) / SS
        for x, c in cov.items():
            color = color_fn(y) if color_fn else rgb
            put(x, y, color, alpha * min(1.0, c))


def ellipse_pts(cx, cy, rx, ry, rot=0.0, segments=72):
    out = []
    for i in range(segments):
        a = i / segments * math.tau
        px, py = math.cos(a) * rx, math.sin(a) * ry
        if rot:
            ca, sa = math.cos(rot), math.sin(rot)
            px, py = px * ca - py * sa, px * sa + py * ca
        out.append((cx + px, cy + py))
    return out


def circle(cx, cy, r, rgb, alpha=1.0):
    fill_polygon(ellipse_pts(cx, cy, r, r), rgb, alpha)


def ellipse(cx, cy, rx, ry, rgb, rot=0.0, alpha=1.0):
    fill_polygon(ellipse_pts(cx, cy, rx, ry, rot), rgb, alpha)


def quad_pts(p0, p1, p2, n=28):
    out = []
    for i in range(n + 1):
        t = i / n
        u = 1 - t
        out.append((u * u * p0[0] + 2 * u * t * p1[0] + t * t * p2[0],
                    u * u * p0[1] + 2 * u * t * p1[1] + t * t * p2[1]))
    return out


def stroke(points, width, rgb, alpha=1.0):
    """Yol boyunca disk basarak yuvarlak uçlu çizgi."""
    r = width / 2
    step = max(1.0, r * 0.5)
    for i in range(len(points) - 1):
        ax, ay = points[i]
        bx, by = points[i + 1]
        dist = math.hypot(bx - ax, by - ay)
        count = max(1, int(dist / step))
        for k in range(count + 1):
            t = k / count
            circle(ax + (bx - ax) * t, ay + (by - ay) * t, r, rgb, alpha)


# ---------------------------------------------------------------- gökyüzü

HORIZON = 700

for y in range(0, HORIZON + 40):
    t = min(1.0, y / HORIZON)
    col = tuple(int(C["skyTop"][i] + (C["skyBottom"][i] - C["skyTop"][i]) * t) for i in range(3))
    row = bytes(col) * S
    buf[y * S * 3:(y + 1) * S * 3] = row

# Güneş: yumuşak hale + disk.
sun_x, sun_y, sun_r = 800, 205, 118
for y in range(max(0, sun_y - sun_r * 3), min(S, sun_y + sun_r * 3)):
    for x in range(max(0, sun_x - sun_r * 3), min(S, sun_x + sun_r * 3)):
        d = math.hypot(x - sun_x, y - sun_y)
        if d < sun_r * 3:
            put(x, y, C["sun"], 0.42 * (1 - d / (sun_r * 3)) ** 2)
circle(sun_x, sun_y, sun_r, C["sun"])

# ------------------------------------------------------------------ deniz


def wave_top(x):
    return HORIZON + math.sin(x / 190 * math.tau) * 14 + math.sin(x / 84 * math.tau) * 6


sea_top = [(x, wave_top(x)) for x in range(-8, S + 9, 8)]
sea_poly = sea_top + [(S + 8, S + 8), (-8, S + 8)]


def sea_color(y):
    t = min(1.0, max(0.0, (y - HORIZON) / (S - HORIZON)))
    return tuple(int(C["seaTop"][i] + (C["seaDeep"][i] - C["seaTop"][i]) * t) for i in range(3))


fill_polygon(sea_poly, color_fn=sea_color)
stroke(sea_top, 7, C["foam"], 0.5)

# ------------------------------------------------------- kayığın küpeştesi

GUNWALE = 872
rail_top = quad_pts((-40, GUNWALE + 34), (S / 2, GUNWALE - 26), (S + 40, GUNWALE + 34), 40)
fill_polygon(rail_top + [(S + 40, S + 8), (-40, S + 8)], C["hull"])
stroke(rail_top, 30, C["rail"])
stroke([(x, y + 30) for x, y in rail_top], 8, C["hullDark"], 0.45)

# ------------------------------------------------------------------- Tedi

tx, ty, tr = 258, 762, 84
circle(tx - tr * 0.72, ty - tr * 0.82, tr * 0.42, C["teddy"])
circle(tx + tr * 0.72, ty - tr * 0.82, tr * 0.42, C["teddy"])
circle(tx, ty, tr, C["teddy"])
ellipse(tx, ty + tr * 0.30, tr * 0.42, tr * 0.30, C["skin"])
circle(tx, ty + tr * 0.18, tr * 0.17, C["teddyDark"])
circle(tx - tr * 0.34, ty - tr * 0.14, tr * 0.12, C["teddyDark"])
circle(tx + tr * 0.34, ty - tr * 0.14, tr * 0.12, C["teddyDark"])

# ------------------------------------------------------- Hira'nın omuzları

cx, cy, r = 512, 452, 192

fill_polygon([(cx - r * 0.95, GUNWALE), (cx - r * 0.62, cy + r * 0.98),
              (cx + r * 0.62, cy + r * 0.98), (cx + r * 0.95, GUNWALE)], C["top"])
circle(cx - r * 0.62, cy + r * 0.98, r * 0.17, C["top"])
circle(cx + r * 0.62, cy + r * 0.98, r * 0.17, C["top"])
fill_polygon([(cx - r * 0.80, GUNWALE), (cx - r * 0.55, cy + r * 1.18),
              (cx + r * 0.55, cy + r * 1.18), (cx + r * 0.80, GUNWALE)], C["vest"])

# --------------------------------------------------------- Hira'nın başı

# At kuyruğu.
tail = quad_pts((cx + r * 0.70, cy + r * 0.10), (cx + r * 1.62, cy + r * 0.95),
                (cx + r * 1.24, cy + r * 1.95))
tail += quad_pts((cx + r * 1.24, cy + r * 1.95), (cx + r * 0.82, cy + r * 1.15),
                 (cx + r * 0.58, cy + r * 0.32))
fill_polygon(tail, C["hair"])
circle(cx + r * 0.80, cy + r * 0.26, r * 0.16, C["shorts"])

circle(cx, cy - r * 0.08, r * 1.14, C["hair"])
circle(cx - r * 1.02, cy + r * 0.10, r * 0.17, C["skin"])
circle(cx + r * 1.02, cy + r * 0.10, r * 0.17, C["skin"])
circle(cx, cy, r, C["skin"])

# Kâkül: yana savrulan perçem. HiraNode.swift ve önizleme sayfasındaki
# çizimle birebir aynı eğri — üç yerde aynı yüz çıksın diye.
bangs = quad_pts((cx - r * 1.03, cy - r * 0.06), (cx, cy - r * 1.62), (cx + r * 1.00, cy - r * 0.50))
bangs += quad_pts((cx + r * 1.00, cy - r * 0.50), (cx - r * 0.10, cy + r * 0.06), (cx - r * 1.03, cy - r * 0.06))
fill_polygon(bangs, C["hair"])
ellipse(cx - r * 0.30, cy - r * 0.72, r * 0.31, r * 0.10, C["hairShine"], rot=-0.22)

# Kaşlar, gözler, burun, yanaklar, gülümseme.
for side in (-1, 1):
    stroke(quad_pts((cx + side * r * 0.20, cy - r * 0.30),
                    (cx + side * r * 0.40, cy - r * 0.42),
                    (cx + side * r * 0.60, cy - r * 0.30)), r * 0.09, C["hair"])
    ex, ey = cx + side * r * 0.40, cy - r * 0.04
    ellipse(ex, ey, r * 0.21, r * 0.23, C["white"])
    circle(ex, ey + r * 0.01, r * 0.16, C["eye"])
    circle(ex, ey + r * 0.01, r * 0.08, C["hair"])
    circle(ex + r * 0.07, ey - r * 0.08, r * 0.05, C["white"])
    ellipse(cx + side * r * 0.58, cy + r * 0.36, r * 0.17, r * 0.10, C["blush"], alpha=0.5)

stroke(quad_pts((cx - r * 0.05, cy + r * 0.26), (cx + r * 0.02, cy + r * 0.34),
                (cx + r * 0.07, cy + r * 0.28)), r * 0.07, C["skinShade"])
stroke(quad_pts((cx - r * 0.24, cy + r * 0.52), (cx, cy + r * 0.76),
                (cx + r * 0.24, cy + r * 0.52)), r * 0.09, C["hair"])

# --------------------------------------------------------------------- PNG


def write_png(path):
    raw = bytearray()
    for y in range(S):
        raw.append(0)
        raw += buf[y * S * 3:(y + 1) * S * 3]
    comp = zlib.compress(bytes(raw), 9)

    def chunk(tag, data):
        body = tag + data
        return struct.pack(">I", len(data)) + body + struct.pack(">I", zlib.crc32(body) & 0xFFFFFFFF)

    png = b"\x89PNG\r\n\x1a\n"
    png += chunk(b"IHDR", struct.pack(">IIBBBBB", S, S, 8, 2, 0, 0, 0))
    png += chunk(b"IDAT", comp)
    png += chunk(b"IEND", b"")
    with open(path, "wb") as handle:
        handle.write(png)


import sys
write_png(sys.argv[1])
print("yazıldı:", sys.argv[1])
