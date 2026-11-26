"""Build the flat parchment and map glyphs used by the road-room trial."""

from io import BytesIO
from pathlib import Path
from random import Random
from zipfile import ZIP_DEFLATED, ZipFile
import json

from PIL import Image, ImageColor, ImageDraw, ImageFilter

from forest_map_icons import STYLES
from map_icon_preview import GLYPHS, font


INK = {"road": "#866342", "tree": "#526c35", "tree_open": "#477237", "collapse": "#9d4e32"}
RIMS = {"room": "#987450", "seen": "#35666b", "fresh": "#a7742f", "focus": "#efcf90"}


def parchment():
    rng = Random(21691)
    size = 256
    grain = Image.new("L", (size,size))
    grain.putdata([rng.randint(55,202) for _ in range(size*size)])
    clouds = Image.new("L", (32,32))
    clouds.putdata([rng.randrange(256) for _ in range(1024)])
    clouds = clouds.resize((size,size),Image.Resampling.BICUBIC).filter(ImageFilter.GaussianBlur(2.1))
    paper = Image.new("RGBA", (size,size))
    pixels = paper.load()
    detail = grain.load()
    wash = clouds.load()
    edges = []
    for _ in range(4):
        margin = Image.new("L", (24,1))
        margin.putdata([rng.randrange(2,6) for _ in range(24)])
        values = margin.resize((size,1),Image.Resampling.BICUBIC).getdata()
        edges.append([max(0,v+rng.choice((-1,0,0,0,1))) for v in values])
    for y in range(size):
        for x in range(size):
            outer = min(x-edges[0][y],size-1-x-edges[1][y],y-edges[2][x],size-1-y-edges[3][x])
            if outer < 0:
                continue
            edge_shade = max(0,19-outer)*1.85 + max(0,7-outer)*3
            speckle = (detail[x,y]-127)*.065 + (wash[x,y]-127)*.115
            pixels[x,y] = tuple(max(0,min(255,round(c+speckle-edge_shade))) for c in (219,181,129)) + (255,)
    # A few fine fibres bridge the grain, keeping clear space around the map.
    fibres = Image.new("RGBA", paper.size)
    draw = ImageDraw.Draw(fibres)
    for _ in range(140):
        x,y = rng.randrange(11,245),rng.randrange(11,245)
        draw.line((x,y,x+rng.randrange(1,5),y+rng.randrange(-1,2)), fill=(122,74,34,rng.choice((12,17,30))))
    return Image.alpha_composite(paper,fibres)


def glyph(kind):
    index = tuple(key for key,_ in STYLES).index(kind)
    _, palette, pattern = GLYPHS[index]
    colors = palette.split()
    art = Image.new("RGBA", (11,11))
    for y,row in enumerate(pattern,1):
        for x,ink in enumerate(row,1):
            if ink != ".":
                art.putpixel((x,y),ImageColor.getrgb(colors[int(ink)-1])+(255,))
    outline = Image.new("RGBA", art.size, "#543d2d")
    outline.putalpha(art.getchannel("A").filter(ImageFilter.MaxFilter(3)))
    sheet = Image.new("RGBA", (64,64))
    sheet.paste(Image.alpha_composite(outline,art).resize((44,44),Image.Resampling.NEAREST),(10,10))
    return sheet


def assets(kinds):
    art = {"parchment":parchment()}
    for name,color in INK.items():
        art[name] = Image.new("RGBA", (16,16), color)
    for name,color in RIMS.items():
        rim = Image.new("RGBA", (32,32))
        draw = ImageDraw.Draw(rim)
        draw.line(((2,1),(29,1),(30,2),(30,29),(29,30),(2,30),(1,29),(1,2),(2,1)),fill=color,width=2 if name=="focus" else 1)
        art[name] = rim
    for kind in kinds:
        art[f"icon_{kind}"] = glyph(kind)
    return art


def preview(path):
    from route_trial_scenes import EDGES, ROOMS, TREE, MapView, map_segments

    source = assets(kind for _,_,kind,*_ in ROOMS)
    size = 640
    canvas = source["parchment"].resize((size,size),Image.Resampling.NEAREST)
    draw = ImageDraw.Draw(canvas)
    scale = size/MapView.FRAME_SIDE

    def at(x,y):
        return round(size/2+x*scale),round(size/2-y*scale)

    for a,b in EDGES:
        color = INK["tree" if (a,b)==TREE else "road"]
        for start,end in map_segments(a,b,MapView.ROOM_SIDE/2):
            draw.line((at(*start),at(*end)),fill=color,width=round(.22*scale))
    for i, (_,_,kind,x,y) in enumerate(ROOMS):
        rim = "seen" if i==0 else "fresh" if i in (1,4) else "room"
        for art,side in ((rim,MapView.ROOM_SIDE),(f"icon_{kind}",MapView.GLYPH_SIDE)):
            edge = round(side*scale)
            src = source[art].resize((edge,edge),Image.Resampling.NEAREST)
            px,py = at(x,y)
            canvas.alpha_composite(src,(px-edge//2,py-edge//2))
    draw.text(at(0,4.72),"密林",font=font(25,True),anchor="mm",fill="#563b24")
    draw.text(at(4.52,4.74),"收起",font=font(16),anchor="mm",fill="#563b24")
    canvas.save(path)


def stage_resources(world, kinds):
    def write_json(destination, path, value):
        destination.writestr(path,json.dumps(value,ensure_ascii=False,separators=(",",":")))

    world = Path(world)
    with ZipFile(world/"resources.zip","w",ZIP_DEFLATED) as pack:
        write_json(pack,"pack.mcmeta",{"pack":{"pack_format":55,"description":"坠梦 · 密林地图图层"}})
        for name,art in assets(kinds).items():
            pixels = BytesIO()
            art.save(pixels,format="PNG")
            pack.writestr(f"assets/fallenroute/textures/item/panel/{name}.png",pixels.getvalue())
            write_json(pack,f"assets/fallenroute/items/panel/{name}.json",{
                "model":{"type":"minecraft:model","model":f"fallenroute:item/panel/{name}"},
            })
            write_json(pack,f"assets/fallenroute/models/item/panel/{name}.json",{
                "gui_light":"front","ambientocclusion":False,
                "textures":{"surface":f"fallenroute:item/panel/{name}"},
                "elements":[{"from":[0,0,7.997],"to":[16,16,8.003],"shade":False,
                             "faces":{side:{"uv":[0,0,16,16],"texture":"#surface"} for side in ("north","south")}}],
            })
