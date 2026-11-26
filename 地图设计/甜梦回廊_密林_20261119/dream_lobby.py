"""The shared Dream Observatory lobby and its teaching gallery."""
import math
import random


def build_lobby(Build):
    b = Build()
    trim = "polished_blackstone_bricks"
    bright = "calcite"
    floor = "polished_deepslate"
    for lower,upper,x0,x1,z0,z1,m in (
        (84,85,-106,-40,37,59,trim),
        (86,87,-113,-31,29,67,"deepslate_tiles"),
        (88,89,-114,-28,24,72,trim),
    ):
        b.box((x0,lower,z0),(x1,upper,z1),m)
    b.box((-77,89,31),(-31,89,65),floor)
    b.box((-76,89,45),(-31,89,51),"polished_diorite")
    for z in (44,52):
        b.box((-76,89,z),(-31,89,z),"dark_prismarine")
        for x in range(-74,-31,4):
            b.set(x,89,z,"sea_lantern")
    for x in (-74,-64,-54,-44,-34):
        for z in (33,63):
            b.box((x-1,90,z-1),(x+1,91,z+1),trim)
            b.box((x,92,z),(x,105,z),bright)
            beam_end = (39 if z==33 else 57) if x==-74 else 48
            b.box((x,104,min(z,beam_end)),(x,105,max(z,beam_end)),"polished_blackstone")
            b.set(x,104,z+2 if z==33 else z-2,"pearlescent_froglight")
    for z in (33,63):
        b.box((-73,90,z),(-35,92,z),trim)
        for x in (-69,-59,-49,-39):
            b.box((x-3,93,z),(x+3,101,z),"blue_stained_glass")
            b.box((x-3,99,z),(x+3,101,z),"purple_stained_glass")
            b.box((x-3,93,z),(x+3,94,z),"light_blue_stained_glass")
            b.box((x,93,z),(x,101,z),"polished_blackstone")
    for offset in range(17):
        y = 105 + (16-offset)//2
        for side in (-1,1):
            z = 48+side*offset
            b.box((-77,y,z),(-31,y,z), "tinted_glass" if offset<11 else "polished_blackstone")
            if offset%5==0:
                b.box((-77,y+1,z),(-31,y+1,z),"polished_deepslate")
    # The fixed night sky and the translucent vault share the same cool tones.
    rng = random.Random(1601)
    for _ in range(100):
        x,z = rng.randint(-74,-33),rng.randint(37,59)
        y = 105 + (16-abs(z-48))//2
        b.set(x,y,z,rng.choice(("tinted_glass","blue_stained_glass","sea_lantern")))
    b.box((-76,90,33),(-76,109,63),"polished_blackstone")
    for dy in range(-8,9):
        for dz in range(-8,9):
            r = math.hypot(dy,dz)
            if 6.8<r<8.3:
                b.set(-75,100+dy,48+dz, "pearlescent_froglight" if (dy+dz)%4==0 else "quartz_pillar")
            elif r<=6.8:
                color = "blue" if dz+dy<0 else "purple"
                b.set(-75,100+dy,48+dz,color+"_stained_glass")
                if (dy*13+dz*31)%17==0:
                    b.set(-74,100+dy,48+dz,"sea_lantern")
    for d in range(-4,5):
        half=4-abs(d)
        b.box((-73,100+d,48-half),(-73,100+d,48+half),
              "amethyst_block" if abs(d)>1 else "pearlescent_froglight")
    b.label((-71.5,94,48.5),"甜 梦 · 观 测 站","light_purple",2.0)

    for z,pad,label,color,glass in (
        (41,"oxidized_cut_copper","入梦 · 选择职业","aqua","cyan_stained_glass"),
        (55,"amethyst_block","甜梦演示室","light_purple","purple_stained_glass"),
    ):
        b.disk(-55,89,z,5,3,bright)
        b.box((-58,89,z-2),(-53,89,z+2),pad)
        for dz in (-3,3):
            b.box((-58,90,z+dz),(-58,95,z+dz),bright)
            b.set(-57,94,z+dz,"pearlescent_froglight")
        b.box((-58,95,z-3),(-58,97,z+3),glass)
        b.label((-55.5,92.2,z+.5),label,color,1.08)
    # Same lectern and animated stage anchors, inside a dark blue gallery.
    b.box((-112,89,32),(-79,89,64),floor)
    b.box((-108,89,43),(-83,89,53),"polished_diorite")
    b.box((-97,89,43),(-86,89,54),"polished_blackstone")
    b.box((-96,89,45),(-87,89,52),"deepslate_tiles")
    b.shell(-112,-79,90,93,32,64,trim)
    b.shell(-112,-79,94,101,32,64,"blue_stained_glass")
    b.box((-112,102,32),(-79,102,64),"tinted_glass")
    for x in (-110,-104,-98,-92,-86,-80):
        b.box((x,101,33),(x,101,63),"polished_blackstone")
        b.set(x,101,44,"pearlescent_froglight")
        b.set(x,101,52,"pearlescent_froglight")
        for z in (35,61):
            b.box((x,90,z),(x+2,93,z),"bookshelf")
    for x in range(-96,-86,3):
        b.set(x,89,44,"sea_lantern")
        b.set(x,89,53,"sea_lantern")
    b.box((-79,89,44),(-75,89,52),trim)
    for z in (26,70):
        b.box((-112,90,z),(-30,91,z),"polished_blackstone_brick_wall")
    for x in (-112,-30):
        b.box((x,90,26),(x,91,70),"polished_blackstone_brick_wall")
    for x in range(-109,-30,8):
        for z in (29,67):
            b.set(x,90,z,"polished_blackstone_brick_wall")
            b.set(x,91,z,"pearlescent_froglight")
    b.lines += [
        "setworldspawn -48 90 48 90",
        "gamerule spawnRadius 0",
        "gamerule doMobSpawning false",
        "gamerule keepInventory true",
        "gamerule doImmediateRespawn true",
        "gamerule doDaylightCycle false",
        "gamerule doWeatherCycle false",
        "weather clear",
        "time set midnight",
    ]
    return b.lines


def build_concourse(Build):
    b = Build()
    pale = "calcite"
    dark = "polished_blackstone_bricks"
    facing = "polished_deepslate"
    accent = "dark_prismarine"
    lamp = "pearlescent_froglight"
    # Greater concourse, with four broad links to the future wings.
    b.box((-57,76,-39),(57,81,39),dark)
    b.box((-54,82,-36),(54,82,36),facing)
    for xx in (-29,25):
        for side in (-1,1):
            z0,z1=sorted((side*35,side*57))
            b.box((xx-7,79,z0),(xx+7,82,z1),facing)
            for edge in (xx-7,xx+7):
                b.box((edge,83,z0),(edge,83,z1),"polished_blackstone_brick_wall")
                for z in range(z0+1,z1,5):
                    b.set(edge,84,z,"sea_lantern")
            for end in (xx-6,xx+6):
                b.box((end,83,side*53),(end,94,side*53),pale)
            b.box((xx-6,95,side*53),(xx+6,95,side*53),dark)
            b.box((xx-4,94,side*53),(xx+4,94,side*53),accent)
    for z in (-29,29):
        b.box((-53,82,z-3),(53,82,z+3),"polished_diorite")
        for x in range(-49,53,6):
            b.set(x,82,z,"sea_lantern")
        b.box((-53,82,z-4),(53,82,z-4),accent)
        b.box((-53,82,z+4),(53,82,z+4),accent)
    b.box((-52,82,-3),(52,82,3),"polished_diorite")
    for x in range(-51,52,5):
        b.set(x,82,0,"sea_lantern")
    for x in (-28,28):
        b.box((x-3,82,-28),(x+3,82,28),"polished_diorite")
        for z in (-23,-16,-9,9,16,23):
            b.set(x,82,z,"sea_lantern")
    # The roof has a continuous glazed shell. Full inset panels close the window bays.
    for side in (-1,1):
        z=side*36
        b.box((-54,83,z),(54,90,z),dark)
        for level in range(91,110):
            glass=("cyan_stained_glass" if level<96 else
                   "blue_stained_glass" if level<104 else "purple_stained_glass")
            b.box((-54,level,z),(54,level,z),glass)
        for xx in (-29,25):
            b.box((xx-5,83,z),(xx+5,90,z),"air")
        for x in range(-54,55,9):
            upper_only = any(abs(x-j)<=5 for j in (-29,25))
            b.box((x,91 if upper_only else 83,z),(x,111,z),pale)
            if not upper_only:
                b.box((x-1,83,z-side),(x+1,85,z-side),dark)
            b.set(x,92,z-side,lamp)
            b.set(x,101,z-side,"sea_lantern")
        for height in (91,98,109):
            b.box((-54,height,z),(54,height,z),dark)
        b.box((-54,110,z),(54,112,z),"tinted_glass")
    preceding = None
    for z in range(-36,37):
        y=108+round(19*math.sqrt(max(0,1-(z/37)**2)))
        mat="blue_stained_glass" if abs(z)<22 else "tinted_glass"
        bottom = min(y,preceding+1) if preceding is not None else y
        if preceding is not None and preceding>y:
            b.box((-54,y,z),(54,preceding-1,z),mat)
        b.box((-54,bottom,z),(54,y,z),mat)
        preceding=y
        for x in (-54,-45,-30,-15,0,15,30,45,54):
            b.box((x,y-1,z),(x,y+1,z),dark)
        if abs(z) in (15,25,35):
            b.box((-54,y,z),(54,y,z),accent)
    for end in (-54,54):
        for z in range(-35,36):
            limit=107+round(19*math.sqrt(max(0,1-(z/37)**2)))
            start=93
            b.box((end,83,z),(end,92,z),dark)
            if end==54 and abs(z)<=5:
                b.box((end,83,z),(end,92,z),"air")
            b.box((end,start,z),(end,limit,z),"purple_stained_glass" if abs(z)<15 else "blue_stained_glass")
            if z%7==0:
                b.box((end,start,z),(end,limit,z),pale)
    # Dream core over a dark reflecting disk, with a continuous walk around the pool.
    b.disk(0,82,0,22,20,accent)
    b.disk(0,82,0,20,18,"polished_blackstone")
    b.disk(0,82,0,17,15,"blue_stained_glass")
    for angle in range(0,360,20):
        rad=math.radians(angle)
        b.set(round(math.cos(rad)*19),82,round(math.sin(rad)*17),"sea_lantern")
    for y in range(87,113):
        t=1-abs(y-100)/13
        rx=round(max(0,t)*10)
        rz=round(max(0,t)*7)
        for dx in range(-rx,rx+1):
            w=round(rz*(1-abs(dx)/(rx+1)))
            edge = abs(dx)==rx or w<=1
            c = "pearlescent_froglight" if (edge and y%3==0) else (
                "amethyst_block" if dx<=0 else "purple_stained_glass")
            b.box((dx,y,-w),(dx,y,w),c)
    for a in range(360):
        rad=math.radians(a)
        x,z=round(math.cos(rad)*15),round(math.sin(rad)*13)
        y=98+round(math.sin(rad)*3)
        b.set(x,y,z,"quartz_pillar" if (a//15)%2 else "sea_lantern")
    # Game and tutorial access are small waypoints, leaving the galleries available.
    for center,color,label,glass in (
        (-19,"oxidized_cut_copper","入梦","cyan_stained_glass"),
        (19,"amethyst_block","教程","purple_stained_glass"),
    ):
        b.box((31,82,center-1),(33,82,center+1),color)
        b.box((30,83,center-1),(30,84,center+1),pale)
        b.set(30,85,center,glass)
        b.set(30,84,center, "sea_lantern" if center<0 else lamp)
        b.label((32.5,85,center+.5),label,"aqua" if center<0 else "light_purple",1)
    for x in (-46,-36,-12,12,38,46):
        for z in (-29,29):
            b.box((x-2,83,z+(-3 if z<0 else 3)),(x+2,83,z+(-3 if z<0 else 3)),"smooth_quartz_stairs")
    return b.lines


def build_stone_hall(Build):
    b=Build()
    plinth="deepslate_tiles"
    wall="deepslate_bricks"
    panel="polished_blackstone"
    trim="polished_tuff"
    pale="smooth_quartz"
    gold="waxed_exposed_cut_copper"
    glow="pearlescent_froglight"
    # A central sanctuary with four lower axes and side access for later wings.
    b.box((-59,78,-25),(59,82,25),plinth)
    b.box((-33,78,-48),(33,82,48),plinth)
    b.box((-57,82,-23),(57,82,23),trim)
    b.box((-31,82,-46),(31,82,46),trim)
    b.box((-57,82,-4),(57,82,4),"polished_diorite")
    b.box((-4,82,-46),(4,82,46),"polished_diorite")
    for x in range(-53,54,7):
        for z in (-6,6):
            b.set(x,82,z,"ochre_froglight")
    for z in range(-43,44,7):
        for x in (-6,6):
            b.set(x,82,z,"ochre_froglight")
    for x in (-37,37):
        for side in (-1,1):
            inside,outside=sorted((side*20,side*40))
            b.box((x-6,79,inside),(x+6,82,outside),trim)
            for edge in (x-6,x+6):
                b.box((edge,83,inside),(edge,84,outside),"deepslate_brick_wall")
                for z in range(inside+3,outside,6):
                    b.set(edge,85,z,"ochre_froglight")
            for x0 in (x-5,x+5):
                b.box((x0,83,side*37),(x0,91,side*37),wall)
            b.box((x-5,91,side*37),(x+5,92,side*37),plinth)
    # Sleeve passages. Glazing appears only in the recessed, narrow window bays.
    for s in (-1,1):
        x0,x1=sorted((s*28,s*58))
        b.box((x0,97,-19),(x1,97,19),panel)
        b.box((x0,98,-15),(x1,98,15),plinth)
        b.box((x0,99,-10),(x1,99,10),plinth)
        b.box((x0,100,-5),(x1,100,5),"polished_deepslate")
        for z in (-19,19):
            b.box((x0,83,z),(x1,96,z),wall)
            for x in (s*31,s*49,s*56):
                b.box((x,83,z),(x,97,z),trim)
                b.set(x,88,z-(1 if z>0 else -1),"ochre_froglight")
            b.box((s*43-1,90,z),(s*43+1,94,z),"purple_stained_glass")
            b.set(s*43,95,z,"purple_stained_glass")
            gap=(37*s-5,37*s+5)
            b.box((gap[0],83,z),(gap[1],89,z),"air")
            b.box((gap[0],90,z),(gap[1],90,z),plinth)
        z0,z1=sorted((s*29,s*46))
        b.box((-13,96,z0),(13,96,z1),plinth)
        for x in (-13,13):
            b.box((x,83,z0),(x,97,z1),wall)
            atz=38*s
            b.box((x,90,atz-1),(x,94,atz+1),"purple_stained_glass")
            b.set(x,95,atz,"purple_stained_glass")
    # Octagonal chamber. Its corner buttresses carry the tall solid stepped canopy.
    def octagon(r, bevel, y, material, inner=None):
        for x in range(-r,r+1):
            z=min(r,2*r-bevel-abs(x))
            if inner is None:
                b.box((x,y,-z),(x,y,z),material)
                continue
            iz=min(inner,2*inner-bevel-abs(x)) if abs(x)<=inner else -1
            if iz<0:
                b.box((x,y,-z),(x,y,z),material)
            elif iz<z:
                b.box((x,y,-z),(x,y,-iz-1),material)
                b.box((x,y,iz+1),(x,y,z),material)
    for y in range(83,113):
        mt=trim if y in (90,107) else plinth if y in (83,84,111,112) else wall
        octagon(31,11,y,mt,29)
    for y in range(113,137):
        r=max(8,round(31*math.sqrt(max(0,1-((y-111)/27)**2))))
        mt=trim if y in (115,123,132) else plinth
        octagon(r,max(2,r//3),y,mt,r-2)
    for y in range(137,140):
        octagon(11,3,y,panel)
    octagon(8,2,140,trim)
    for x,z in ((-6,-3),(-3,-6),(3,-6),(6,-3),(6,3),(3,6),(-3,6),(-6,3)):
        b.box((x-1,140,z-1),(x+1,148,z+1),trim)
        b.set(x,147,z,"ochre_froglight")
    for y,r in ((149,8),(150,7),(151,6),(152,5),(153,4),(154,3),(155,2)):
        octagon(r,max(1,r//3),y,plinth if y%3 else gold)
    # Carve the four tall passages and finish them with stepped lintels.
    for s in (-1,1):
        for along,across in ((True,False),(False,True)):
            x0,x1,z0,z1=(28,32,-12,12) if along else (-12,12,28,32)
            if s<0:
                if along: x0,x1=-x1,-x0
                else: z0,z1=-z1,-z0
            b.box((x0,83,z0),(x1,96,z1),"air")
            if along:
                b.box((s*30,99,-3),(s*30,103,3),"purple_stained_glass")
                b.box((s*31,99,-3),(s*31,103,3),"purple_stained_glass")
            else:
                b.box((-3,99,s*30),(3,103,s*30),"purple_stained_glass")
                b.box((-3,99,s*31),(3,103,s*31),"purple_stained_glass")
    for x,z in ((-24,-17),(-17,-24),(17,-24),(24,-17),(24,17),(17,24),(-17,24),(-24,17)):
        for width,y0,y1,mat in (
            (2,83,85,plinth),(1,86,106,trim),(2,107,108,gold),(2,109,111,plinth),
        ):
            b.box((x-width,y0,z-width),(x+width,y1,z+width),mat)
        inner_x=x-(2 if x>0 else -2)
        b.set(inner_x,89,z,"ochre_froglight")
        b.set(inner_x,96,z,glow)
        for y in (105,112):
            b.box((x-3,y,z-3),(x+3,y,z+3),panel)
    for side in (-1,1):
        for at in (-18,0,18):
            b.box((at-1,105,31*side),(at+1,108,31*side),"purple_stained_glass")
    for sx in (-1,1):
        for sz in (-1,1):
            for x,z in ((28*sx,22*sz),(22*sx,28*sz)):
                b.box((x-1,83,z-1),(x+1,109,z+1),wall)
                b.box((x-2,85,z-2),(x+2,87,z+2),plinth)
                b.box((x-2,107,z-2),(x+2,109,z+2),trim)
    # Ground the focal object in a raised octagonal plinth with layered steps and lighting.
    b.disk(0,82,0,20,18,panel)
    b.disk(0,83,0,13,12,trim)
    b.disk(0,84,0,10,9,plinth)
    b.disk(0,85,0,7,6,"polished_blackstone")
    for q in range(0,360,30):
        rad=math.radians(q)
        x,z=round(math.cos(rad)*16),round(math.sin(rad)*14)
        b.set(x,82,z,glow)
        if q%90:
            b.box((x,83,z),(x,86,z),wall)
            b.set(x,87,z,"ochre_froglight")
    for y in range(89,115):
        p=max(0,7-abs(101-y)//2)
        offset=(y-101)//5
        for x in range(-p,p+1):
            z=max(0,p-abs(x))
            b.box((x+offset,y,-z),(x+offset,y,z),
                  glow if (abs(x)==p and y%5==0) else "amethyst_block")
    for x,z,h in ((-9,6,101),(-8,-6,97),(8,5,94),(8,-6,100)):
        b.set(x,h,z,"purple_stained_glass")
        b.box((x,h+1,z),(x,h+3,z),"amethyst_block")
        b.set(x,h+4,z,glow)
    for z in (-13,13):
        b.box((43,82,z-1),(45,82,z+1),"oxidized_cut_copper" if z<0 else "amethyst_block")
        b.box((42,83,z-1),(42,83,z+1),trim)
        b.set(42,84,z,"ochre_froglight" if z<0 else glow)
        b.label((44.5,85,z+.5),"入梦" if z<0 else "教程","aqua" if z<0 else "light_purple",1)
    return b.lines
