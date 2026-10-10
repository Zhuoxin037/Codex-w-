# -*- coding: utf-8 -*-
"""把第五批 15 件装备的 give 渲染成一张预览页(离线核对描述用)。

为什么: 描述(lore)是天天要看的东西, 但改完只能进游戏 /give 才能看一眼。
这个脚本直接读 give.mcfunction -> 抽出 item_name / lore 的 JSON ->
按 Minecraft 的 16 色渲染成 tooltip 卡片, 不开游戏就能逐字核对。

用法: python .workbuddy/_gen_batch5_preview.py
"""
import io, os, re, json, html

BASE = r'D:\数据包\sweetdream\data\sweetdream\function\equipment'
OUT = r'D:\数据包\.workbuddy\mc_model_lab\out\preview\第五批装备_描述预览.html'

NEW = [('sword', 'myriad', '剑', 'iron_sword'),
       ('sword', 'qiansan', '剑', 'iron_sword'),
       ('axe', 'agony', '斧', 'netherite_axe'),
       ('staff', 'polarized_light', '杖', 'recovery_compass'),
       ('staff', 'delusion', '杖', 'recovery_compass'),
       ('staff', 'fallen_dream', '杖', 'recovery_compass'),
       ('staff', 'apocalypse', '杖', 'recovery_compass'),
       ('bow', 'sculk_echo', '弩', 'crossbow'),
       ('bow', 'bone_erode', '弩', 'crossbow'),
       ('bow', 'lucid_dream', '弩', 'crossbow'),
       ('bow', 'rainbow', '弩', 'crossbow'),
       ('armor', 'withered_garden', '腿', 'netherite_leggings'),
       ('armor', 'lightless_sea', '靴', 'netherite_boots'),
       ('armor', 'furnace_core', '胸', 'netherite_chestplate'),
       ('armor', 'resonance', '胸', 'iron_chestplate')]

MC_COLORS = {
    'black': '#000000', 'dark_blue': '#0033AA', 'dark_green': '#00AA00',
    'dark_aqua': '#00AAAA', 'dark_red': '#AA0000', 'dark_purple': '#AA00AA',
    'gold': '#FFAA00', 'gray': '#AAAAAA', 'dark_gray': '#555555',
    'blue': '#5555FF', 'green': '#55FF55', 'aqua': '#55FFFF',
    'red': '#FF5555', 'light_purple': '#FF55FF', 'yellow': '#FFFF55',
    'white': '#FFFFFF',
}


def esc(t):
    return html.escape(t, quote=True)


def render_comp(c, inherit=None):
    """把一个文本组件(可能带 extra)渲染成 HTML。inherit = 父级继承下来的样式"""
    st = dict(inherit or {})
    for k in ('color', 'bold', 'italic'):
        if k in c:
            st[k] = c[k]
    txt = c.get('text', '')
    col = MC_COLORS.get(st.get('color', 'white'), '#FFFFFF')
    css = 'color:%s' % col
    if st.get('bold'):
        css += ';font-weight:700'
    if st.get('italic') is False:
        css += ';font-style:normal'
    span = '<span style="%s">%s</span>' % (css, esc(txt)) if txt else ''
    for e in c.get('extra', []) or []:
        span += render_comp(e, st)
    return span


def parse_name(g):
    """item_name 是 SNBT(键不带引号), 不能 json.loads —— 直接抽字段。

    ★ 注意: 游戏里 item_name 默认**不是斜体**(custom_name 才是), 所以这里
      不加 italic:false, 和真实显示一致。
    """
    m = re.search(r'item_name=\{text:"([^"]*)"([^}]*)\}', g)
    if not m:
        raise SystemExit('item_name 没抽出来: %s' % g[:120])
    comp = {'text': m.group(1)}
    rest = m.group(2)
    c = re.search(r'color:([a-z_]+)', rest)
    if c:
        comp['color'] = c.group(1)
    if 'bold:true' in rest:
        comp['bold'] = True
    return comp


def parse(path):
    t = io.open(path, encoding='utf-8').read()
    g = [l for l in t.split('\n') if l.startswith('give ')][0]
    base = re.match(r'give @s ([a-z_]+)\[', g).group(1)
    name = parse_name(g)
    lore = json.loads(re.search(r'lore=(\[.*?\]),unbreakable', g).group(1))
    zx = re.search(r'custom_data=\{zx:(\[.*?\])\}', g).group(1)
    return base, name, lore, zx, g


cards = []
for cat, cid, cat_cn, base in NEW:
    p = os.path.join(BASE, cat, cid, 'give.mcfunction')
    b, name, lore, zx, g = parse(p)
    title = render_comp(name)
    body = '\n'.join(render_comp(c) for c in lore)
    has_skill = 'skill:' in g
    has_consume = 'consumable=' in g
    meta = []
    meta.append('<span class="chip">%s</span>' % cat_cn)
    meta.append('<code>%s</code>' % cid)
    meta.append('<span class="dim">底材 %s</span>' % b)
    meta.append('<span class="dim">zx %s</span>' % esc(zx))
    if has_skill:
        meta.append('<span class="chip g">有冷却</span>')
    if has_consume:
        meta.append('<span class="chip b">右键触发</span>')
    cards.append("""  <div class="card">
    <div class="head">%(title)s</div>
    <div class="meta">%(meta)s</div>
    <div class="tip">%(body)s</div>
    <details><summary>完整 give 命令</summary><pre>%(cmd)s</pre></details>
  </div>""" % dict(title=title, meta=' '.join(meta), body=body or '&nbsp;', cmd=esc(g)))

CSS = """
:root{--bg:#0b111e;--panel:#141c2e;--panel2:#1b2439;--line:#2a3550;--fg:#e8ecf6;
      --dim:#93a0bd;--accent:#ff9a3c;--accent2:#ffd166;--good:#5ad07a;}
*{box-sizing:border-box}
body{margin:0;background:var(--bg);color:var(--fg);
     font:14px/1.75 -apple-system,"Segoe UI","Microsoft YaHei",sans-serif;}
.wrap{max-width:1240px;margin:0 auto;padding:34px 22px 80px}
h1{font-size:25px;margin:0 0 6px;letter-spacing:.5px}
h1 small{font-size:13px;color:var(--dim);font-weight:400;margin-left:10px}
.note{background:var(--panel2);border-left:3px solid var(--accent);
      padding:12px 16px;border-radius:8px;color:var(--dim);margin:16px 0 6px}
.note b{color:var(--fg)}
.grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(370px,1fr));gap:16px;margin-top:22px}
.card{background:var(--panel);border:1px solid var(--line);border-radius:12px;padding:16px 16px 12px}
.head{font-size:17px;margin-bottom:6px}
.meta{display:flex;flex-wrap:wrap;gap:7px;align-items:center;margin-bottom:11px}
.meta code{font:12px Consolas,Menlo,monospace;color:var(--accent2);background:#101828;
           padding:1px 6px;border-radius:5px}
.dim{color:var(--dim);font-size:12px}
.chip{display:inline-block;padding:1px 8px;border-radius:20px;font-size:11.5px;
      background:#223052;color:#b9c7e6;border:1px solid var(--line)}
.chip.g{background:#12351f;color:#7fe0a0;border-color:#245c38}
.chip.b{background:#2a2246;color:#c3b0ff;border-color:#4a3d78}
.tip{background:#100818;border:1px solid #3a2f52;border-radius:8px;padding:11px 13px;
     font:13.5px/1.65 "Minecraftia","Segoe UI","Microsoft YaHei",sans-serif;
     white-space:pre-wrap;word-break:break-word}
details{margin-top:10px}
summary{cursor:pointer;color:var(--dim);font-size:12.5px;outline:none}
pre{background:#0d1322;border:1px solid var(--line);border-radius:7px;padding:9px 11px;
    font:11.5px/1.55 Consolas,Menlo,monospace;color:#9fb0d0;overflow-x:auto;white-space:pre-wrap;
    word-break:break-all}
"""

HTML = """<!DOCTYPE html><html lang="zh-CN"><head><meta charset="utf-8">
<title>第五批 15 件装备 · 描述预览</title>
<style>%(css)s</style></head><body><div class="wrap">
<h1>第五批 15 件装备 · 描述预览<small>只读核对，未实装任何效果</small></h1>
<div class="note">
本页直接读 <code>give.mcfunction</code> 渲染，颜色 = 游戏内真实颜色。<br>
<b>目前只做了 give</b>：拿得到、看得见描述，但<b>右键 / 射击 / 被动一个都没接</b>——
效果按你说的"后面再分批做"。<br>
底材 / <code>custom_data.zx</code> / 冷却字段已按包里既有 28 件的惯例对齐。
</div>
<div class="grid">
%(cards)s
</div>
</div></body></html>
""" % dict(css=CSS, cards='\n'.join(cards))

io.open(OUT, 'w', encoding='utf-8').write(HTML)
print('已写出: %s (%d 件, %.0f KB)' % (OUT, len(cards), len(HTML.encode('utf-8')) / 1024.0))
