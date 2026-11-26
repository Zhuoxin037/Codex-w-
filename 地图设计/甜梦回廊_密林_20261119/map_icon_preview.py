"""Render the same pixel art at map scale and as enlarged sprites."""

from pathlib import Path
from random import Random



PIXELS = 9
ROOM = 13
BACKGROUNDS = (
    "#463b2f", "#472f2b", "#5d302e", "#5c2732", "#463526", "#303e44", "#534222",
    "#412d55", "#2a3c58", "#345045", "#26463d", "#414141", "#294552",
)

# Characters remain editable pixels so the reviewed art can be transferred to
# the map canvas. Dots leave the room background visible.
GLYPHS = (
    ("入口", "#574335 #9a704c #c29c65 #e5c790 #806047", (
        "..34443..", ".3432243.", "343...243", "34.....23", "34.....23",
        "34.....23", "34.....23", "342...253", ".5333325.",
    )),
    ("普通战", "#3d4140 #829ca2 #c3d5cd #edf1d7 #bb8652 #e2b677 #7b563e", (
        "......134", ".....1342", "....13421", "...13421.", "5.13421..",
        "651421...", ".6565....", ".77665...", "57..65...",
    )),
    ("精英战", "#e1dfce #8b9b98 #565a55 #ffd67b #b2763c #ef9d59 #f7f0d2", (
        "71.....17", "217...712", ".217.712.", "..21712..", "...171...",
        "4.71217.4", "4712.2174", ".445.544.", "54..6..45",
    )),
    ("层主", "#f3e7c7 #d8c2a0 #ac8a73 #634b44 #392d30 #9c5061", (
        "..33333..", ".3111112.", "311111123", "315515523", "315515523",
        "311151123", ".3211123.", "..15152..", "..32323..",
    )),
    ("安全角落", "#614b3a #a46a4d #ec8a4d #ffc875 #ffedb0 #c1ad8e #e2cfaa", (
        "....3....", "....43...", "..3.443..", "..334543.", ".34545543",
        ".34544432", "..234432.", ".6777666.", ".2121212.",
    )),
    ("铸造坊", "#465a5b #798f8c #b0beb0 #dae0c9 #656662 #b38b5a", (
        ".........", "..4444443", "133433332", ".22333321", "..122221.",
        "...321...", "...321...", "..23321..", ".5622221.",
    )),
    ("行商", "#6d4c2a #9d682d #d89b3b #ffdc82 #fff1b3", (
        "..14441..", ".1444441.", "145334431", "144343432", "144344432",
        "144434432", "143334432", ".1444432.", "..12222..",
    )),
    ("黑市", "#372b46 #634976 #9672b5 #c69edb #dab390 #b28571 #46564c", (
        "..34442..", ".3444422.", ".3455562.", ".3475732.", ".3456522.",
        ".3456522.", "..45552..", ".3344422.", "344333222",
    )),
    ("占星室", "#566b91 #729ac1 #a9cbde #dcecdd #fff2ba", (
        "....3....", "....4....", "....4....", "...454...", "344555443",
        "...454...", "....4....", "....4....", "....3....",
    )),
    ("赌博房", "#4a3c30 #746352 #c2ac8a #f5e8ca #fff7df #9d3e44 #8d745e", (
        "..555555.", ".5444443.", "544444433", "546446433", "544444437",
        "544644433", "544444433", "54644643.", ".333333..",
    )),
    ("租借商人", "#355b55 #548981 #79b3a3 #badebc #e7f0cb", (
        ".4553....", "45..43...", "5....3...", "45..43...", ".455442..",
        "....5443.", ".....542.", ".....2443", "......243",
    )),
    ("随机事件", "#645744 #9a8465 #d7c39b #f5e6c1 #fff3d5", (
        "..24442..", ".2455532.", ".243.432.", ".....432.", "....432..",
        "...432...", "...22....", "...44....", "...32....",
    )),
    ("镜房", "#394a55 #557982 #86b2b6 #b7dbcf #e8efdc #75938d", (
        "..45554..", ".4433332.", ".4323432.", ".4325432.", ".4354332.",
        ".4543332.", ".4433332.", ".4323322.", "..34443..",
    )),
)


def font(size, bold=False):
    from PIL import ImageFont
    return ImageFont.truetype(f"C:/Windows/Fonts/{'msyhbd' if bold else 'msyh'}.ttc", size)


def sprite(number):
    from PIL import Image, ImageDraw
    name, colors, pattern = GLYPHS[number]
    palette = colors.split()
    assert len(pattern) == PIXELS and all(len(row) == PIXELS for row in pattern), name
    im = Image.new("RGB", (ROOM, ROOM), BACKGROUNDS[number])
    draw = ImageDraw.Draw(im)
    draw.rectangle((0, 0, ROOM - 1, ROOM - 1), outline="#9b9080")
    margin = (ROOM - PIXELS) // 2
    for y, row in enumerate(pattern):
        for x, color in enumerate(row):
            if color != ".":
                draw.point((margin + x, margin + y), fill=palette[int(color) - 1])
    return im


def map_sample(sprites):
    from PIL import Image, ImageDraw
    seed = Random(25)
    paper = ((194, 174, 133), (197, 177, 136), (191, 171, 131), (196, 176, 134))
    im = Image.new("RGB", (128, 128))
    im.putdata([seed.choice(paper) for _ in range(im.width * im.height)])
    draw = ImageDraw.Draw(im)
    draw.rectangle((7, 7, 120, 120), outline="#a9936a")
    draw.rectangle((9, 9, 118, 118), outline="#d3bd92")
    spots = ((28,64), (46,64), (64,64), (100,64), (46,46), (64,46), (82,46),
             (64,82), (82,82), (46,82), (28,82), (82,64), (100,82))
    for a, b in ((0,1),(1,2),(2,11),(11,3),(1,4),(4,5),(5,6),(2,5),(2,7),(7,8),(1,9),(9,10),(7,9),(8,12)):
        draw.line((*spots[a], *spots[b]), fill="#80705a", width=2)
    for item, (x, y) in zip(sprites, spots):
        im.paste(item, (x - ROOM // 2, y - ROOM // 2))
    return im


def preview(destination):
    from PIL import Image, ImageDraw
    im = Image.new("RGB", (1272, 750), "#212320")
    draw = ImageDraw.Draw(im)
    draw.text((40, 25), "坠梦 · 房间图标", fill="#eee4d0", font=font(39, bold=True))
    sprites = [sprite(i) for i in range(len(GLYPHS))]
    draw.text((42, 103), "地图比例", fill="#d9cbb4", font=font(21, bold=True))
    draw.text((593, 103), "图标细节", fill="#d9cbb4", font=font(21, bold=True))
    draw.text((42, 674), "128 × 128 地图    13 × 13 房间    9 × 9 图标", fill="#c5bcaa", font=font(18))
    im.paste(map_sample(sprites).resize((512, 512), Image.Resampling.NEAREST), (42, 143))
    rows = (range(4), range(4, 9), range(9, 13))
    for row, indices in enumerate(rows):
        left = 593 + (650 - (130 * len(indices) - 12)) // 2
        for column, i in enumerate(indices):
            x, y = left + column * 130, 143 + row * 174
            draw.rounded_rectangle((x, y, x + 118, y + 148), radius=7, fill="#272a26", outline="#42433a")
            im.paste(sprites[i].resize((78, 78), Image.Resampling.NEAREST), (x + 20, y + 17))
            draw.text((x + 59, y + 110), GLYPHS[i][0], fill="#e5ddcb", font=font(18), anchor="mt")
    im.save(destination)


if __name__ == "__main__":
    import sys

    preview(Path(sys.argv[1]))
