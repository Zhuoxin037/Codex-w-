"""Flat cabinet artwork and low relief stone for the in-room draw."""
import json
from random import Random

from PIL import Image, ImageDraw

from draw_lab_art import octagonal


def bezel(draw, x, y, w, h, r, **style):
    draw.polygon([(x+r,y),(x+w-r,y),(x+w,y+r),(x+w,y+h-r),
                  (x+w-r,y+h),(x+r,y+h),(x,y+h-r),(x,y+r)], **style)


def folio():
    width, height = 512, 242
    image = Image.new("RGBA", (width, height))
    shape = Image.new("L", image.size)
    bezel(ImageDraw.Draw(shape), 4, 4, 503, 233, 14, fill=255)
    random = Random(905)
    image.putdata([
        (22+j,28+j,26+j) + (shape.getpixel((x,y)),)
        for y in range(height) for x in range(width)
        for j in [random.randrange(7)+int(6*(1-abs(y-78)/170))]
    ])
    d = ImageDraw.Draw(image)
    bezel(d, 4, 4, 503, 233, 14, outline="#674d35", width=5)
    bezel(d, 10, 10, 491, 221, 11, outline="#b79059", width=1)
    bezel(d, 15, 15, 481, 211, 9, outline="#685b45", width=1)
    for x in (23,489):
        for y in (24,217):
            d.polygon([(x,y-6),(x+6,y),(x,y+6),(x-6,y)], fill="#9b764f")
            d.point((x,y), fill="#f2d096")
    d.line((28,59,485,59), fill="#74634a")
    d.line((28,204,485,204), fill="#74634a")
    d.line((256,68,256,196), fill="#5c533e")
    d.polygon([(256,117),(260,122),(256,127),(252,122)], fill="#b79059")
    for x in (78,192,320,434):
        weapon = x < 256
        bezel(d,x-49,93,98,104,10,fill="#161c1b",outline="#9b794e" if weapon else "#578176",width=2)
        bezel(d,x-45,97,90,96,7,outline="#544a36" if weapon else "#324b44",width=1)
        d.line((x-10,188,x+10,188), fill="#8d704a" if weapon else "#4b8174", width=2)
    return image


def cabinet_item():
    image = Image.new("RGBA", (32,32))
    d = ImageDraw.Draw(image)
    d.polygon([(3,9),(8,4),(24,4),(29,9),(29,26),(25,29),(7,29),(3,25)],fill="#1c2522")
    d.polygon([(5,10),(9,6),(23,6),(27,10),(27,25),(24,27),(8,27),(5,24)],fill="#714d32")
    d.rectangle((7,11,25,24),fill="#9a6b45")
    d.rectangle((8,20,24,22),fill="#b38053")
    d.rectangle((5,10,27,12),fill="#c29a5e")
    d.line((8,7,23,7),fill="#ebbd76")
    d.rectangle((12,10,19,20),fill="#2c3e37")
    d.rectangle((14,12,17,18),fill="#deb477")
    d.point((16,14),fill="#513b29")
    d.rectangle((7,23,9,25),fill="#d1a367")
    d.rectangle((23,23,25,25),fill="#d1a367")
    return image


def art(pack):
    assets=pack/"assets"
    added=[]

    def save(name, value):
        path=assets/name
        path.parent.mkdir(parents=True,exist_ok=True)
        if isinstance(value, Image.Image):
            value.save(path)
        else:
            path.write_text(json.dumps(value,ensure_ascii=False,indent=2)+"\n",encoding="utf8")
        added.append(path)

    for name, image, model in (
        ("folio",folio(),{"gui_light":"front","ambientocclusion":False,"textures":{"cloth":"fallenrooms:item/folio"},
         "elements":[{"from":[0,0,7.96],"to":[16,16,8.04],"shade":False,
                      "faces":{side:{"uv":[0,0,16,16],"texture":"#cloth"} for side in ("north","south")}}]}),
        ("cabinet",cabinet_item(),{"parent":"minecraft:item/generated","textures":{"layer0":"fallenrooms:item/cabinet"}}),
    ):
        save(f"fallenrooms/items/{name}.json", {"model":{"type":"minecraft:model","model":f"fallenrooms:item/{name}"}})
        save(f"fallenrooms/models/item/{name}.json",model)
        save(f"fallenrooms/textures/item/{name}.png",image)

    rows=[]
    for radius,base,top,material in (
        (21.8,8,10.5,"stone"),(23,10.5,12.1,"stone"),(22,12.1,13,"bronze"),
        (21.0,13,16,"stone"),(21.6,16,16.8,"bronze"),(20.6,16.8,18,"stone"),
    ):
        rows+=octagonal(radius,base,top,material)
    save("drawlab/items/forest_pedestal.json",{"model":{"type":"minecraft:model","model":"drawlab:item/forest_pedestal"}})
    save("drawlab/models/item/forest_pedestal.json",{"ambientocclusion":False,"gui_light":"front","elements":rows,
        "textures":{material:f"drawlab:item/{material}" for material in ("stone","bronze")}})
    return added
