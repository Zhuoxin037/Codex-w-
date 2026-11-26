"""Furnish only admitted rooms and make the floor map legible from its first frame."""

import gzip
from pathlib import Path

import architecture
import forest_scene
from floor_upgrade import MAP_ID, text, write
from forest_economy import FN
from forest_floors import NEXT_MAP

COLORS = b"\x07\x00\x06colors\x00\x00\x40\x00"
PARCHMENT = 9  # Smooth sandstone at the canvas's flat height.
ROGUE = "sweetdream:rogue/"

# Each mark is nine map pixels square. A dark backing keeps the symbol distinct
# when the visited-room color changes. Ink never has shading details of its own.
ICONS = {
    "entry": ("white", (
        "...###...", "..#####..", ".#######.", "..#####..", "...###...",
        "...###...", "...###...", "...###...", ".........")),
    "combat": ("orange", (
        "##.....##", "###...###", ".###.###.", "..#####..", "...###...",
        "..#####..", ".###.###.", "###...###", "##.....##")),
    "elite": ("yellow", (
        "#...#...#", "##.###.##", "#########", "#########", ".#######.",
        ".#######.", ".#######.", ".........", ".........")),
    "boss": ("red", (
        "..#####..", ".#######.", "#########", "##..#..##", "##..#..##",
        ".#######.", "..#####..", "..#.#.#..", ".........")),
    "safe": ("pink", (
        ".........", ".###.###.", "#########", "#########", ".#######.",
        "..#####..", "...###...", "....#....", ".........")),
    "forge": ("white", (
        ".........", "#########", "#########", ".#######.", "...###...",
        "...###...", "...###...", "...###...", ".........")),
    "merchant": ("yellow", (
        ".........", "..#####..", ".#######.", "#########", ".#.....#.",
        ".#.....#.", ".#.....#.", ".#######.", ".........")),
    "rental": ("light_blue", (
        "......###", ".....####", "....#####", ".#.#####.", ".#####...",
        "..###....", ".#####...", "###..#...", "##.......")),
    "blackmarket": ("magenta", (
        ".........", "..#####..", ".#######.", "#########", "##..#..##",
        "##..#..##", ".#######.", "..#####..", ".........")),
    "astrology": ("light_blue", (
        "....#....", "....#....", "...###...", "..#####..", "#########",
        "..#####..", "...###...", "....#....", "....#....")),
    "gamble": ("lime", (
        ".#######.", "#########", "##..#####", "##..#####", "#########",
        "#####..##", "#####..##", "#########", ".#######.")),
    "event": ("white", (
        "..#####..", ".##...##.", "......##.", ".....##..", "....##...",
        "....##...", ".........", "....##...", "....##...")),
}

VENDORS = (
    ("forge", -4.5, "toolsmith", "铸匠"),
    ("merchant", -3.5, "mason", "林地行商"),
    ("rental", -3.5, "fletcher", "租借商"),
    ("blackmarket", -3.5, "cleric", "黑市商人"),
)
VENDOR_TAGS = ("sd.floor_vendor", "sd.floor_vendor_hitbox")


def prime_map(blob):
    """Fill unsampled pixels without overwriting existing rooms in a live save."""
    raw = gzip.decompress(blob)
    if raw.count(COLORS) != 1:
        raise ValueError("Expected one 128×128 map color array")
    start = raw.index(COLORS) + len(COLORS)
    end = start + 128**2
    colors = raw[start:end].replace(b"\0", bytes((PARCHMENT,)))
    return gzip.compress(raw[:start] + colors + raw[end:], mtime=0)


def icon(ink, rows):
    b = architecture.Build(relative=True)
    b.box((-8, 0, -8), (9, 0, 9), "black_concrete")
    for iz, row in enumerate(rows):
        assert len(row) == 9
        for ix, pixel in enumerate(row):
            if pixel == "#":
                x, z = 2*(ix-4), 2*(iz-4)
                b.box((x, 0, z), (x+1, 0, z+1), f"{ink}_concrete")
    return b.lines


def stage(world):
    world = Path(world)
    home = world/"datapacks/zz_sweetdream_floor/data"
    r = home/"sweetdream/function/rogue"
    f = home/"sweetdream_floor/function"

    for kind in forest_scene.KINDS:
        for variant in range(9 if kind == "event" else 3):
            shell, detail = architecture.room_parts(kind, variant)
            write(r/f"shell/{kind}_{variant}.mcfunction", "\n".join(shell))
            write(r/f"detail/{kind}_{variant}.mcfunction", "\n".join(detail))
    for kind, (ink, rows) in ICONS.items():
        write(r/f"canvas/icon_{kind}.mcfunction", "\n".join(icon(ink, rows)))
    for map_id in (MAP_ID, NEXT_MAP):
        bitmap = world/"data"/f"map_{map_id}.dat"
        bitmap.write_bytes(prime_map(bitmap.read_bytes()))

    # Scan each quadrant before handing off to the floor. Holding the map in the
    # offhand during this phase lets vanilla populate its actual saved colors.
    scan = []
    for i, (x, z) in enumerate(((24, 24), (120, 24), (24, 120), (120, 120))):
        scan.append(f"execute if score @s zx.rg_prept matches {i*16}..{i*16+15} run tp @s {x}.5 320 {z}.5 0 80")
    scan.append("execute if score @s zx.rg_prept matches 64.. run tp @s 72.5 320 72.5 0 80")
    write(r/"prep/scan_canvas.mcfunction", "\n".join(scan))
    for floor in ("forest", "trial"):
        p = r/f"prep/tick_{floor}.mcfunction"
        write(p, text(p).replace("tp @s 72.5 320 72.5 0 80", f"function {ROGUE}prep/scan_canvas")
              .replace("matches 40..", "matches 72.."))
    for file in r.rglob("*.mcfunction"):
        body = text(file)
        if "rg_ver:2" in body:
            write(file, body.replace("rg_ver:2", "rg_ver:3").replace('minecraft:item_model="sweetdream:rogue_map",', ""))

    # Room contents remain lazy. Only actual staffed rooms may spawn a vendor.
    file = f/"scene/furnish.mcfunction"
    hook = f'$function {FN}room/vendor/check with storage zx:rogue floor.cells[$(cell)]'
    staff = [
        f'$execute if data storage zx:rogue floor.cells[{{cell:$(cell),kind:"{kind}"}}] '
        f'positioned $(x) 81 $(z) run return run function {FN}room/vendor/spawn '
        f'{{cell:$(cell),x:{offset},z:{offset},profession:"{job}",name:"{name}"}}'
        for kind, offset, job, name in VENDORS
    ]
    cleanup_event = (
        f'$execute if data storage zx:rogue floor.cells[{{cell:$(cell),kind:"event"}}] '
        f'positioned $(x) 81 $(z) run function {FN}room/vendor/clear_event'
    )
    write(file, text(file).replace(hook, f"{cleanup_event}\n{hook}"))
    write(f/"room/vendor/check.mcfunction", "\n".join(staff))
    write(f/"room/vendor/clear_event.mcfunction", "\n".join(
        f"execute positioned ~-13 78 ~-13 run kill @e[tag={tag},dx=26,dy=19,dz=26]"
        for tag in VENDOR_TAGS
    ))
    file = f/"room/vendor/spawn.mcfunction"
    body = text(file)
    for tag in VENDOR_TAGS:
        body = body.replace(f'Tags:["{tag}"]', f'Tags:["{tag}","sd.vendor_cell.$(cell)"]')
    write(file, body)
    file = f/"room/vendor/interact.mcfunction"
    body = text(file).splitlines()
    # Old vendors from an already running floor keep using their existing hitbox.
    write(file, "\n".join([
        *body[:3], body[4],
        f"execute at @s run function {FN}room/vendor/offer with storage sweetdream_floor:run inspected",
    ]))
    hitbox = "type=minecraft:interaction,tag=sd.floor_vendor_hitbox,distance=..5"
    announce = f"function {FN}room/announce with storage sweetdream_floor:run inspected"
    write(f/"room/vendor/offer.mcfunction", "\n".join((
        *(f'$execute if data storage sweetdream_floor:run inspected{{kind:"{kind}"}} '
          f'if entity @e[{hitbox},tag=sd.vendor_cell.$(cell)] run return run {announce}'
          for kind, *_ in VENDORS),
        f"execute if data storage zx:rogue floor{{polished_scene:1b}} run return 0",
        *(f'execute if data storage sweetdream_floor:run inspected{{kind:"{kind}"}} '
          f'if entity @e[{hitbox}] run return run {announce}' for kind, *_ in VENDORS),
    )))
    file = r/"gen/build_links.mcfunction"
    write(file, text(file).replace("data modify storage zx:rogue built set value 1b",
          "\n".join([*(f"kill @e[tag={tag},distance=0..]" for tag in VENDOR_TAGS),
                    "data modify storage zx:rogue floor.polished_scene set value 1b",
                    "data modify storage zx:rogue built set value 1b"])))
