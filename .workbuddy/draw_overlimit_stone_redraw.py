"""Hand-authored 16x16 overlimit stones. Review output only; no game assets are written."""
from pathlib import Path
import ast
import hashlib
import itertools
import json
import re
import zipfile
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / '模型设计/超限石_像素重绘_20261010'
RP = ROOT / 'sweetdream_rp_完整版'
SOURCE = ROOT / '.workbuddy/_gen_stone_icons.py'
constants = {}
for node in ast.parse(SOURCE.read_text(encoding='utf-8')).body:
    if isinstance(node, ast.Assign):
        for target in node.targets:
            if isinstance(target, ast.Name) and target.id in ('OL_SPEC', 'CMD'):
                constants[target.id] = ast.literal_eval(node.value)

# Each engraving is drawn by hand. Colours support the symbol, rather than being
# the only distinguishing feature. + marks one or two brighter coloured details.
DESIGNS = [
    ('liuguang', 'sword', '流光', '贯穿流痕', 'eab64c', [
        '.....#...', '....##...', '...##....', '..###....', '.##+##...',
        '..###....', '...##....', '....##...', '.....#...']),
    ('myriad', 'sword', '万念', '双刃交汇', 'ad354e', [
        '.#.....#.', '.##...##.', '..##.##..', '...###...', '....+....',
        '...###...', '..##.##..', '.##...##.', '.#.....#.']),
    ('rogue_star', 'sword', '游星', '星环与星芒', '659adb', [
        '...###...', '..#...#..', '.#..#..#.', '.#.###.#.', '.####+##.',
        '.#.###.#.', '.#..#..#.', '..#...#..', '...###...']),
    ('shadow_blade', 'sword', '影刃', '弯月暗刃', '675080', [
        '....###..', '...##....', '..##.....', '.##......', '.##...+..',
        '.##......', '..##.....', '...##....', '....###..']),
    ('deepsea_echo', 'sword', '深海的回响', '卷浪与水滴', '285fad', [
        '.....###.', '....#..#.', '..###..+.', '.#...#...', '.#....#..',
        '..####...', '.........', '.##...##.', '...###...']),
    ('everfrost', 'sword', '永霜', '六角霜晶', 'a9d5e2', [
        '....#....', '.#..#..#.', '..#.#.#..', '...###...', '####+####',
        '...###...', '..#.#.#..', '.#..#..#.', '....#....']),
    ('flame_brokenbody', 'sword', '烈火残躯', '上涌火舌', 'dc6439', [
        '.....#...', '....##...', '..#.##...', '..####...', '.###.##..',
        '.##..##..', '.##.+##..', '..####...', '...##....']),
    ('sickle_dreams', 'sword', '引梦镰', '镰弧与梦瞳', 'a56bcb', [
        '..####...', '.##...#..', '.#.......', '.#...+...', '.#.......',
        '..##.....', '....##...', '.....##..', '......#..']),
    ('hengdao', 'sword', '横刀', '平直刃锋', 'c6b997', [
        '.........', '.........', '..######.', '.#######.', '.+....#..',
        '......#..', '....###..', '.....#...', '.........']),
    ('red_lotus', 'axe', '红莲', '三瓣火莲', 'd34149', [
        '....#....', '...###...', '.#.###.#.', '.#######.', '..#####..',
        '...###...', '....+....', '..##.##..', '.###.###.']),
    ('charge', 'axe', '超•负•荷', '蓄电断闪', '9794d4', [
        '....###..', '...###...', '..###....', '.####....', '...+###..',
        '....##...', '...##....', '..##.....', '..#......']),
    ('anion', 'axe', '负离子', '双极与负号', '5cc5b4', [
        '..##.....', '.#..#....', '.#..#....', '..##.....', '...+###..',
        '.....##..', '....#..#.', '....#..#.', '.....##..']),
    ('dream_reader', 'axe', '释梦', '翻开梦页', 'ddd1ae', [
        '.........', '.###.###.', '.#.###.#.', '.#..#..#.', '.#..+..#.',
        '.#..#..#.', '.#######.', '....#....', '.........']),
    ('cold_crow', 'bow', '寒鸦', '斜羽刻痕', '69b5ce', [
        '......##.', '.....#+#.', '....###..', '...##.#..', '..####...',
        '.##.#....', '..##.....', '.##......', '.#.......']),
    ('bone_erode', 'bow', '蚀骨', '蚀裂骨片', 'a5aa8a', [
        '..#####..', '.##...##.', '.#.#+#.#.', '.#.#.#.#.', '..##.##..',
        '...###...', '...#.#...', '..#####..', '.........']),
    ('sculk_echo', 'bow', '幽匿残响', '幽匿共振', '438f7e', [
        '.##...##.', '.#.....#.', '.#.....#.', '.#.....#.', '.###+###.',
        '....#....', '....#....', '....#....', '...###...']),
    ('begonia', 'staff', '海棠', '五瓣海棠', 'cf87a8', [
        '...###...', '...#.#...', '.###.###.', '.#.....#.', '..#.+.#..',
        '..#...#..', '..#####..', '....#....', '...#.....']),
    ('polarized_light', 'staff', '偏振光', '分光棱镜', 'd7dde7', [
        '....##...', '...#..#..', '..#....#.', '.#..++..#', '.#..++..#',
        '..#....#.', '...#..#..', '....##...', '.........']),
    ('brain_leech', 'armor', '脑髓蛭', '蜷曲蛭体', 'b95e88', [
        '..###....', '.##+##...', '.######..', '..##.##..', '....###..',
        '.....##..', '....##...', '...##....', '..#......']),
    ('spine_symbiote', 'armor', '脊骨共生', '节状脊骨', '849c96', [
        '...###...', '.###.###.', '...###...', '..##.##..', '...#+#...',
        '..##.##..', '...###...', '.###.###.', '...###...']),
    ('stellar_elegy', 'armor', '群星坠落之挽歌', '坠星与尾迹', '535aa8', [
        '.#.......', '..#......', '.#.#.....', '..#.#....', '...#..#..',
        '.....###.', '....##+##', '.....###.', '......#..']),
    ('dusk_dawn', 'armor', '黄昏黎明之交界', '日月交界', 'e2bd67', [
        '....#....', '..#.#.#..', '...###...', '..#.+.#..', '#########',
        '...#..#..', '...#..#..', '....##...', '.........']),
    ('dionysus_helmet', 'armor', '狄俄尼索斯之桂冠', '酒神冠与葡萄', 'a27db5', [
        '.#..#..#.', '.##.#.##.', '.#######.', '..#####..', '.........',
        '...#.#...', '..#.+.#..', '...#.#...', '....#....']),
    ('furnace_core', 'armor', '炉心', '方炉与熔芯', 'c78146', [
        '..#####..', '..#...#..', '.#######.', '.#..#..#.', '.#.#+#.#.',
        '.#..#..#.', '.#######.', '..#...#..', '..#####..']),
]

CATEGORY = {'sword': '剑', 'axe': '斧', 'bow': '弩', 'staff': '法杖', 'armor': '盔甲'}
MASKS = {
    'sword': [7, 5, 3, 2, 1, 1, 1, 1, 1, 1, 1, 1, 2, 3, 5, 7],
    'axe': [5, 3, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 3, 5],
    'bow': [4, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 3, 5],
    'staff': [4, 3, 3, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 3, 3, 4],
    'armor': [3, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 3],
}


def mix(c, target, amount):
    return tuple(round(a * (1 - amount) + b * amount) for a, b in zip(c, target))


def render(cat, colour, rows):
    main = tuple(bytes.fromhex(colour))
    edge = mix(main, (27, 24, 31), 0.62)
    shade = mix(main, (40, 30, 37), 0.28)
    facet = mix(main, (242, 227, 199), 0.37)
    light = mix(main, (255, 248, 226), 0.76)
    very_light = mix(main, (255, 253, 236), 0.90)
    im = Image.new('RGBA', (16, 16))
    px = im.load()

    def inside(x, y):
        return 0 <= y < 16 and MASKS[cat][y] <= x <= 15 - MASKS[cat][y]

    for y in range(16):
        for x in range(16):
            if not inside(x, y):
                continue
            border = not all(inside(x+dx, y+dy) for dx, dy in ((1,0),(-1,0),(0,1),(0,-1)))
            if border:
                c = mix(edge, facet, 0.23) if x+y < 12 else edge
            elif x+y < 10:
                c = facet
            elif x-y > 8 or x+y > 22:
                c = shade
            elif x <= 2 or y <= 2:
                c = facet
            elif x >= 13 or y >= 13:
                c = shade
            else:
                c = main
            px[x,y] = c + (255,)
    # Deliberate short facet edges instead of a smooth gradient or outer glow.
    for x,y in [(4,2),(5,2),(6,2),(2,4),(2,5)]:
        if inside(x,y):
            px[x,y] = light + (255,)
    luminance = 0.2126*main[0] + 0.7152*main[1] + 0.0722*main[2]
    ink = mix(main, (24,29,38), 0.80) if luminance > 145 else light
    cut = mix(main, (17,20,29), 0.58)
    # One-pixel recess under each rune stroke gives the inset emblem depth.
    for y,row in enumerate(rows):
        for x,ch in enumerate(row):
            if ch != '.' and inside(x+3,y+4) and (y==8 or rows[y+1][x]=='.'):
                px[x+3,y+4] = cut + (255,)
    for y,row in enumerate(rows):
        for x,ch in enumerate(row):
            if ch != '.':
                assert inside(x+3,y+3), (cat,x,y)
                px[x+3,y+3] = (very_light if ch=='+' else ink) + (255,)
    return im


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def files_hash(root):
    return {p.relative_to(root).as_posix(): sha(p) for p in root.rglob('*') if p.is_file()}


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    original_assets = files_hash(RP / 'assets/sweetdream/textures/item/stone')
    original_def = sha(RP / 'assets/minecraft/items/recovery_compass.json')
    expected = {row[0] for row in constants['OL_SPEC']}
    assert len(expected) == 24 and expected == {row[0] for row in DESIGNS}
    entries = json.loads((RP / 'assets/minecraft/items/recovery_compass.json').read_text(encoding='utf-8'))['model']['entries']
    routing = {e['threshold']: e['model']['model'] for e in entries}
    images, originals, report, masks = {}, {}, [], {}
    for cid,cat,name,motif,colour,rows in DESIGNS:
        assert len(rows)==9 and all(len(r)==9 and set(r) <= set('.#+') for r in rows), cid
        masks[cid] = tuple(ch != '.' for row in rows for ch in row)
        assert sum(masks[cid]) >= 15, cid
        give = ROOT / 'sweetdream/data/sweetdream/function/overlimit/item' / (cid+'.mcfunction')
        text = give.read_text(encoding='utf-8')
        cmd = int(re.search(r'custom_model_data=\{floats:\[(\d+)\.0f\]\}',text).group(1))
        assert cmd == constants['CMD']['ol_'+cid]
        assert routing[cmd] == 'sweetdream:item/stone/ol_'+cid
        lore = json.loads(re.search(r'lore=(\[.*\]),custom_data=',text).group(1))
        skill_text = [''.join([row.get('text','')] + [v.get('text','') for v in row.get('extra',[])]) for row in lore]
        im = render(cat,colour,rows)
        assert im.size==(16,16) and set(im.getchannel('A').histogram()[1:255])=={0}
        path = OUT / '贴图' / ('ol_'+cid+'.png')
        path.parent.mkdir(exist_ok=True)
        im.save(path)
        source = RP / 'assets/sweetdream/textures/item/stone' / path.name
        images[cid], originals[cid] = im, Image.open(source).convert('RGBA')
        report.append({'id':cid,'name':name,'category':cat,'motif':motif,'theme_colour':'#'+colour,
                       'cmd':cmd,'file':str(path),'sha256':sha(path),'prior_sha256':sha(source),
                       'current_skill_lore':skill_text})
    assert len({im.tobytes() for im in images.values()}) == 24
    assert len(set(masks.values())) == 24
    distances = [(sum(x != y for x,y in zip(masks[a],masks[b])),a,b) for a,b in itertools.combinations(masks,2)]
    nearest = min(distances)
    assert nearest[0] >= 8, nearest

    font_path='C:/Windows/Fonts/msyh.ttc'
    title=ImageFont.truetype(font_path,30)
    name_font=ImageFont.truetype(font_path,20)
    small=ImageFont.truetype(font_path,16)
    board=Image.new('RGB',(1260,1040),'#23262c');d=ImageDraw.Draw(board)
    d.text((26,18),'超限石 · 24 颗手绘像素重绘',font=title,fill='#eee3ce')
    d.text((26,66),'16×16 实际贴图 / 晶石切面 + 各自的主题刻纹 / 尚未替换游戏资源',font=small,fill='#acb4b9')
    for i,(cid,cat,name,motif,colour,rows) in enumerate(DESIGNS):
        x=20+(i%6)*206;y=110+(i//6)*220
        d.rectangle((x,y,x+197,y+203),fill='#2e333a')
        large=images[cid].resize((128,128),Image.Resampling.NEAREST)
        board.paste(large,(x+34,y+5),large)
        label=name if len(name)<=8 else {'stellar_elegy':'群星坠落之挽歌','dusk_dawn':'黄昏黎明之交界','dionysus_helmet':'狄俄尼索斯之桂冠'}[cid]
        f=name_font if len(label)<=6 else small
        bbox=d.textbbox((0,0),label,font=f)
        d.text((x+(197-bbox[2])//2,y+137),label,font=f,fill='#dedbcf')
        d.text((x+15,y+169),motif,font=small,fill='#adbabc')
    d.text((26,1010),'所有刻纹都不同；颜色相近时仍可以辨识。纹样为静态图标，不改变技能与超限编号。',font=small,fill='#acb4b9')
    board.save(OUT/'超限石_24颗_重绘总览.png')

    # Compare the most easily confused orange and blue sets at both magnified
    # scale and real inventory-slot scale. All images are the actual PNGs.
    selected=['liuguang','flame_brokenbody','red_lotus','furnace_core',
              'rogue_star','deepsea_echo','everfrost','cold_crow']
    pairs=Image.new('RGB',(1100,696),'#23262c');d=ImageDraw.Draw(pairs)
    d.text((24,16),'容易混用的两组 · 原图 → 重绘',font=title,fill='#eee3ce')
    d.text((24,60),'橙色组与青蓝组：主题纹样各自独立，物品栏缩小后仍能区分。',font=small,fill='#acb4b9')
    names={row[0]:row[2] for row in DESIGNS}
    for i,cid in enumerate(selected):
        x=20+(i%4)*270;y=100+(i//4)*280
        d.rectangle((x,y,x+258,y+258),fill='#2e333a')
        d.text((x+16,y+10),names[cid],font=name_font,fill='#ddd9cd')
        for offset,im,label in [(14,originals[cid],'原图'),(142,images[cid],'重绘')]:
            q=im.resize((96,96),Image.Resampling.NEAREST);pairs.paste(q,(x+offset,y+60),q)
            d.text((x+offset+28,y+160),label,font=small,fill='#b4bdc0')
            sx=x+offset+25;sy=y+195
            d.rectangle((sx,sy,sx+39,sy+39),fill='#8b8b8b')
            q=im.resize((32,32),Image.Resampling.NEAREST);pairs.paste(q,(sx+4,sy+4),q)
    pairs.save(OUT/'超限石_橙蓝组_前后对照.png')

    manifest={'phase':'已完成24颗手绘重绘，待审阅','hand_authored':True,'image_generation_used':False,
              'resolution':[16,16],'item_count':24,'distinct_engravings':24,
              'minimum_symbol_pixel_difference':nearest[0],'closest_symbols':list(nearest[1:]),
              'game_bound':False,'number_mapping_unchanged':True,'items':report}
    (OUT/'贴图清单.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    (OUT/'说明.md').write_text('''# 超限石 · 24颗像素重绘

实际16×16透明PNG，以晶石切面、主题刻纹和配色区分24颗超限石。
剑、斧、弩、法杖、盔甲使用五种切面轮廓；各石头中心刻纹逐颗手绘，24种均不同。
例如深海的回响为卷浪水滴，永霜为霜晶，寒鸦为鸦羽，红莲为莲瓣，炉心为方炉熔芯。
颜色相近时可以继续凭刻纹区分，不依赖汉字在16像素里挤占整个图标。

贴图/ 是完整24张实际PNG，贴图清单.json记录原贴图/重绘的校验值、现有技能说明、原超限编号。
总览与前后对照均直接放大真实PNG；物品栏示意以两倍游戏像素显示，没有另行美化概念图。
本阶段供审阅，没有替换资源包或游戏中的贴图，不改超限编号和技能。
''',encoding='utf-8')
    archive=OUT/'超限石_24颗_重绘贴图.zip'
    with zipfile.ZipFile(archive,'w',zipfile.ZIP_DEFLATED) as z:
        for item in report:
            p=Path(item['file']);z.write(p,p.relative_to(OUT).as_posix())
        for name in ['贴图清单.json','说明.md','超限石_24颗_重绘总览.png','超限石_橙蓝组_前后对照.png']:
            z.write(OUT/name,name)
    assert original_assets == files_hash(RP / 'assets/sweetdream/textures/item/stone')
    assert original_def == sha(RP / 'assets/minecraft/items/recovery_compass.json')
    print(json.dumps({'textures':24,'unique_symbols':24,'minimum_symbol_difference':nearest[0],
                      'game_assets_unchanged':True,'preview':str(OUT/'超限石_24颗_重绘总览.png'),
                      'archive':str(archive)},ensure_ascii=False))


if __name__=='__main__':
    main()
