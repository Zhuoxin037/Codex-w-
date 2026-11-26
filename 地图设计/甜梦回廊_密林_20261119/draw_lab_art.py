"""Local resource pack for the draw animation rehearsal."""

from io import BytesIO
from pathlib import Path
from random import Random
from zipfile import ZIP_DEFLATED, ZipFile
import json
import math

from PIL import Image, ImageDraw


ASSETS = Path(__file__).resolve().parents[2]/"fallendream_rp_完整版/assets"
FACES = ("north","south","east","west","up","down")


def texture(color,seed,metal=False):
    rnd=Random(seed)
    canvas=Image.new("RGB",(64,64))
    pixels=canvas.load()
    for y in range(64):
        for x in range(64):
            m=(.91+.10*math.sin(x*.31+y*.21)+.062*math.sin(y*.53-x*.16)
               +rnd.uniform(-.095,.095))
            if metal:
                m+=.09*math.sin(x*.62)+.20*(y<7)
            pixels[x,y]=tuple(int(max(0,min(255,c*m))) for c in color)
    return canvas


def plate(half=None):
    image=Image.new("RGBA",(64,96))
    draw=ImageDraw.Draw(image)

    def cut(x0,y0,x1,y1,r):
        return [(x0+r,y0),(x1-r,y0),(x1,y0+r),(x1,y1-r),
                (x1-r,y1),(x0+r,y1),(x0,y1-r),(x0,y0+r)]

    draw.polygon(cut(0,0,63,95,8),fill="#4b3827")
    draw.polygon(cut(1,1,62,93,8),fill="#c2904d")
    draw.line((8,1,54,1,62,9),fill="#efd39a",width=1)
    draw.polygon(cut(4,5,59,90,5),fill="#161f1e")
    background=texture((45,72,68),81).resize((53,83),Image.Resampling.BILINEAR).convert("RGBA")
    mask=Image.new("L",(53,83))
    ImageDraw.Draw(mask).polygon(cut(0,0,52,82,5),fill=255)
    image.paste(background,(6,7),mask)
    draw.polygon(cut(7,8,56,87,5),outline="#77968a")
    draw.ellipse((13,28,50,66),outline="#557d72")
    for x,y in ((10,13),(53,13),(10,82),(53,82)):
        draw.polygon(((x-2,y),(x,y+2),(x+2,y),(x,y-2)),fill="#d3a966")
    for x in (27,31,35):
        draw.line((x-1,79,x,77,x+1,79),fill="#7fcbb5")
    if half=="left":
        draw.rectangle((32,0,63,95),fill=(0,0,0,0))
    if half=="right":
        draw.rectangle((0,0,31,95),fill=(0,0,0,0))
    return image


def element(start,end,material,sides=FACES):
    return {"from":start,"to":end,"shade":False,
            "faces":{side:{"uv":[0,0,16,16],"texture":"#"+material} for side in sides}}


def octagonal(radius,base,top,material):
    # Clip the four corners using stepped facets. Adjacent strips share their
    # interior faces at the same plane and the top remains level.
    count=9
    rows=[]
    for i in range(count):
        lo=-radius+2*radius*i/count
        hi=-radius+2*radius*(i+1)/count
        x=min(radius,1.57*radius-abs((lo+hi)*.5))
        rows.append(element([round(8-x,4),base,round(8+lo,4)],
                            [round(8+x,4),top,round(8+hi,4)],material,("up","east","west","north","south")))
    return rows


def pedestal():
    rows=[]
    for r,b,t,mat in ((23,8,9.5,"stone"),(24,9.5,12,"stone"),(22.7,12,13,"bronze"),
                      (21.7,13,15,"stone"),(22.3,15,17.1,"jadelike"),(20,17.1,18,"jadelike")):
        rows+=octagonal(r,b,t,mat)
    for i in range(8):
        a=i*math.tau/8+math.pi/8
        x,z=8+21.6*math.cos(a),8+21.6*math.sin(a)
        rows.append(element([round(x-1.25,3),10,round(z-1.25,3)],
                            [round(x+1.25,3),16.2,round(z+1.25,3)],"bronze"))
    for x in (-13,13):
        for z in (-13,13):
            rows.append(element([6.45+x,17.9,6.45+z],[9.55+x,22.2,9.55+z],"stone"))
            rows.append(element([6.25+x,22.2,6.25+z],[9.75+x,22.9,9.75+z],"bronze"))
    return rows


def dial():
    rows=octagonal(5,18.005,18.18,"jade")
    for i in range(28):
        a=i*math.tau/28
        x,z=8+16.6*math.cos(a),8+16.6*math.sin(a)
        half=.45 if i%7 else .85
        rows.append(element([round(x-half,3),18.09,round(z-half,3)],
                            [round(x+half,3),18.29,round(z+half,3)],"jade" if i%2 else "bronze"))
    for i in range(4):
        a=i*math.tau/4 + .13
        x,z=8+8.1*math.cos(a),8+8.1*math.sin(a)
        rows.append(element([round(x-.9,3),18.1,round(z-.9,3)],[round(x+.9,3),18.3,round(z+.9,3)],"bronze"))
    return rows


def stage_resources(world,inventory_models):
    with ZipFile(Path(world)/"resources.zip","w",ZIP_DEFLATED) as pack:
        written=set()

        def write(path,data):
            if path not in written:
                pack.writestr(path,data)
                written.add(path)

        def doc(path,data):
            write(path,json.dumps(data,ensure_ascii=False,separators=(",",":")))

        def include(path):
            source=ASSETS/path
            write("assets/"+path,source.read_bytes())
            return json.loads(source.read_text(encoding="utf8")) if source.suffix==".json" else None

        def ident(kind,identifier,extension):
            space,name=identifier.split(":",1) if ":" in identifier else ("minecraft",identifier)
            return None if space=="minecraft" else f"{space}/{kind}/{name}.{extension}"

        def model(ref):
            path=ident("models",ref,"json")
            if not path or "assets/"+path in written:
                return
            data=include(path)
            if "parent" in data:
                model(data["parent"])
            for material in data.get("textures",{}).values():
                tex=None if material.startswith("#") else ident("textures",material,"png")
                if tex:
                    include(tex)
                    if (ASSETS/(tex+".mcmeta")).exists():
                        include(tex+".mcmeta")

        def item_models(spec):
            if isinstance(spec,dict):
                if spec.get("type") in ("minecraft:model","model"):
                    model(spec["model"])
                for val in spec.values():
                    item_models(val)
            if isinstance(spec,list):
                for val in spec:
                    item_models(val)

        def image(name,value):
            target=BytesIO()
            value.save(target,format="PNG")
            write(f"assets/drawlab/textures/item/{name}.png",target.getvalue())

        def item(name,rows,materials):
            doc(f"assets/drawlab/items/{name}.json",{"model":{"type":"minecraft:model","model":f"drawlab:item/{name}"}})
            doc(f"assets/drawlab/models/item/{name}.json",{"ambientocclusion":False,"gui_light":"front","elements":rows,
                "textures":{key:f"drawlab:item/{value}" for key,value in materials.items()}})

        doc("pack.mcmeta",{"pack":{"pack_format":55,"description":"坠梦 · 转盘试验资源"}})
        materials={"stone":"stone","bronze":"bronze","jadelike":"jadelike","jade":"jade"}
        for name,color,seed in (("stone",(65,73,68),26),("bronze",(146,104,63),27),
                                ("jadelike",(63,84,77),48),("jade",(121,187,169),100)):
            image(name,texture(color,seed,name=="bronze"))
        item("pedestal",pedestal(),materials)
        item("dial",dial(),materials)
        arrow=[element([8-w,7.90,z],[8+w,8.26,z+.8],"bronze")
               for z,w in ((5,.33),(5.8,.63),(6.6,.97),(7.4,1.26))]
        arrow.extend((element([7.58,7.90,8.2],[8.42,8.26,9.32],"bronze"),
                      element([7.82,8.26,6.25],[8.18,8.32,8.8],"jade")))
        item("pointer",arrow,materials)
        for name,half in (("tablet",None),("tablet_left","left"),("tablet_right","right")):
            image(name,plate(half))
            item(name,[element([1.45,-.65,7.82],[14.55,16.65,8.18],"plate",("north","south"))],{"plate":name})
        for ref in inventory_models:
            path=ident("items",ref,"json")
            if path:
                item_models(include(path))
