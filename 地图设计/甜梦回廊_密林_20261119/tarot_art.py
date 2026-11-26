"""Original pixel illustrations for the first three floor cards."""
from pathlib import Path
from random import Random
import json

from PIL import Image, ImageDraw


COLORS = {"back":"#dcb981","fool":"#e4bf72","lovers":"#e5a3a5","tower":"#a9c1e8"}


def paint(name):
    image = Image.new("RGBA", (64,96))
    d = ImageDraw.Draw(image)
    edge = [(5,1),(58,1),(62,5),(62,90),(58,94),(5,94),(1,90),(1,5)]
    d.polygon(edge, fill="#171721", outline=COLORS[name], width=2)
    d.rectangle((5,5,58,90), outline="#6f5763")
    rng = Random(name)
    for i in range(420):
        x,y = rng.randrange(7,57),rng.randrange(7,90)
        d.point((x,y), fill=rng.choice(("#211e2c","#25202f","#2b2530","#3a2e3b")))
    d.rectangle((8,9,55,86), outline="#44394d")
    for x,y in ((9,10),(54,10),(9,85),(54,85)):
        d.polygon([(x-2,y),(x,y-3),(x+2,y),(x,y+3)],fill=COLORS[name])
    for y in (18,77):
        d.line((12,y,51,y),fill="#5e485b")
    c = COLORS[name]
    if name=="back":
        for r in (8,16,22):
            d.ellipse((31-r,48-r,31+r,48+r),outline="#846571" if r!=16 else c)
        for x,y in ((31,25),(31,71),(8,48),(54,48)):
            d.polygon([(x-3,y),(x,y-5),(x+3,y),(x,y+5)],fill=c)
        d.polygon([(31,36),(40,48),(31,60),(22,48)],fill="#543c5a",outline=c)
        d.ellipse((26,45,36,51),fill="#e2c9a1")
        d.rectangle((30,46,32,50),fill="#221827")
    elif name=="fool":
        d.polygon([(10,67),(21,62),(26,64),(31,62),(30,76),(9,76)],fill="#595068")
        d.ellipse((32,23,50,41),fill="#5e473c",outline=c)
        d.line((19,51,47,31),fill="#b28668",width=2)
        d.polygon([(42,29),(50,31),(52,37),(46,40),(42,36)],fill="#9c6b72")
        d.polygon([(24,37),(33,37),(33,47),(27,49),(23,45)],fill="#ede0a4")
        d.polygon([(20,37),(36,34),(35,38),(22,40)],fill=c)
        d.polygon([(24,48),(33,45),(36,54),(32,57),(20,56)],fill="#9a778a")
        d.line((25,55,22,65,17,65),fill="#dcc0a1",width=3)
        d.line((29,55,35,61,39,59),fill="#dcc0a1",width=3)
        d.line((30,50,37,47,39,41),fill=c,width=2)
        d.polygon([(44,66),(51,61),(56,64),(55,67),(51,66),(47,70)],fill="#dbc6a2")
    elif name=="lovers":
        for x,col in ((21,"#c48596"),(42,"#927fc4")):
            d.ellipse((x-5,35,x+5,45),fill="#e2c6bf")
            d.polygon([(x-4,44),(x+4,44),(x+8,66),(x-8,66)],fill=col,outline=c)
            d.line((x-7,70,x+7,70),fill=col,width=2)
        d.line((20,52,27,56,35,56,44,51),fill="#fbd0c2",width=2)
        d.polygon([(32,57),(25,51),(25,47),(29,45),(32,48),(35,45),(39,47),(39,51)],fill="#c55c79")
        d.line((17,29,31,24,46,29),fill=c,width=2)
        d.polygon([(31,20),(34,25),(31,30),(28,25)],fill=c)
    else:
        d.polygon([(12,75),(19,69),(22,44),(20,41),(22,36),(29,37),(31,34),(37,35),(42,33),(43,39),(40,43),(45,72),(51,75)],
                  fill="#57546b",outline=c)
        for x,y in ((28,49),(35,59),(27,66)):
            d.rectangle((x,y,x+3,y+5),fill="#201e34")
        d.polygon([(43,20),(34,32),(39,32),(32,43),(49,29),(43,29),(49,20)],fill="#f1cf8a")
        d.polygon([(46,41),(53,43),(50,50),(44,47)],fill="#b59bbc")
        d.polygon([(14,50),(18,45),(20,52),(16,54)],fill="#847ca9")
        d.line((26,44,32,45,29,54,34,55,31,68),fill="#d9a2ac",width=2)
    symbols={"fool":"0","lovers":"VI","tower":"XVI","back":"*"}
    d.text((31,82),symbols[name],fill=c,anchor="mm")
    return image


def card_assets(master: Path):
    out=[]
    asset=master/"assets/fallentarot"

    def doc(path,data):
        target=asset/path
        target.parent.mkdir(parents=True,exist_ok=True)
        target.write_text(json.dumps(data,ensure_ascii=False,indent=2)+"\n",encoding="utf8")
        out.append(target)

    for name in COLORS:
        tex=asset/f"textures/item/{name}.png"
        tex.parent.mkdir(parents=True,exist_ok=True)
        paint(name).save(tex)
        out.append(tex)
        doc(f"models/item/{name}.json",{"ambientocclusion":False,"gui_light":"front",
            "textures":{"card":f"fallentarot:item/{name}"},"elements":[{
            "from":[0,0,7.95],"to":[16,16,8.05],"shade":False,
            "faces":{face:{"uv":[0,0,16,16],"texture":"#card"} for face in ("north","south")}}]})
        doc(f"items/{name}.json",{"model":{"type":"minecraft:model","model":f"fallentarot:item/{name}"}})
    return out
