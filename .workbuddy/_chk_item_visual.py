# -*- coding: utf-8 -*-
"""_chk_item_visual.py —— 140 件装备「外观三层链路」守门（2026-10-18 批 16 新增）。

【守的是什么坑】1.21.5 的物品外观是一条三层链：
    give 里的 item_model="<ns>:<key>"
      -> assets/<ns>/items/<key>.json            （物品定义，决定"哪个模型"）
        -> assets/<ns>/models/…/<模型>.json       （模型，决定"哪张贴图"）
          -> assets/<ns>/textures/…/<贴图>.png    （贴图）
  断**任何一层**的表现都是"物品显示成底材的原版样子"或"紫黑方块"，
  而且**不报错、不进日志**（本包已踩过两次：批 14 全批不挂 item_model、
  `_chk_look` 盯旧路径漏检）。所以必须静态守。

【检查项】
  ① 每个 give 行里的 item_model 值 -> items/<key>.json 必须存在
  ② 该 items 定义最终能走到至少一个**存在**的模型文件
  ③ 该模型链上引用的贴图必须存在（sweetdream 命名空间）
  ④ 盔甲额外：equippable.asset_id -> equipment/<key>.json 必须存在，
     且它的 layers 贴图文件必须存在（头/胸/靴 humanoid，护腿 humanoid_leggings）
  ⑤ 反向：给了 item_model 却没 accompany 的 items 定义不算错，但
     `textures/item/vanilla/` 里存在却没有被任何 items 引用、也不像中间态的要报"孤儿"

【为什么不用 startswith 硬编码】弩是
  select(charge_type)->condition(using_item)->range_dispatch(crossbow/pull) 的分支树，
  盔甲是 select(display_context) 分 GUI/手持两套 —— 所以这里走**递归遍历**，
  把所有分支的模型都收进来，而不是只看顶层 model 字段。

【用法】python .workbuddy/_chk_item_visual.py
  退出码 0 = 全通过；1 = 有问题（逐条打印）
"""
import glob
import io
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ASSETS = os.path.join(ROOT, 'sweetdream_rp_完整版', 'assets')
GIVE_GLOB = os.path.join(ROOT, 'sweetdream', 'data', 'sweetdream', 'function',
                         'equipment', '**', 'give.mcfunction')

errs = []

# ★ 三个"give 里故意不写 item_model"的例外。都有独立的运行时写入者，不是漏接线：
KNOWN_EXEMPT = {
    # 2026-10-26 用户确认：新职业法杖／副手／道具暂用原版追溯指针。
    'dream_waker': '用户确认使用追溯指针原版外观；旧 job_* 模型键兼容为原版指针',
    'grimoire': '用户确认使用追溯指针原版外观；旧 job_* 模型键兼容为原版指针',
    'mana_crystal': '用户确认使用追溯指针原版外观；旧 job_* 模型键兼容为原版指针',
    'foresight': '用户确认使用追溯指针原版外观；旧 job_* 模型键兼容为原版指针',
    'self_mind': '用户确认使用追溯指针原版外观；旧 job_* 模型键兼容为原版指针',
    'indwell': '用户确认使用追溯指针原版外观；旧 job_* 模型键兼容为原版指针',
    'tinder': '两态图标：equipment/sword/tinder/visual/sync 按 zx.td_on 每刻写 tinder_on/off',
    'everlit': '灯灵 GUI 模型：equipment/tool/everlit/model_sync 扫 hotbar/inventory/offhand 写 tool_everlit',
    'anchor': '3D 手持候选（items/anchor.json = 四向静态审阅模型，握姿待用户验收）占着这个 key；'
              '平面图标已画好（textures/item/vanilla/anchor.png + models/item/vanilla/anchor.json）未挂',
    # ---- 批一 10 件（2026-10-20）：用户定"先做 give"，外观留后续批次 ----
    #   give 生成器 `_gen_batch17.py` 里 MODEL=False；补外观时按
    #   _gen_late_icons.py(贴图) -> _gen_late_rp.py(接线) -> MODEL=True 的顺序，再把这几行删掉。
    'yebu':     '批一 give 先行：外观未做（_gen_batch17.py MODEL=False）',
    'xiugou':   '批一 give 先行：外观未做（_gen_batch17.py MODEL=False）',
    'zhuzu':    '批一 give 先行：外观未做（_gen_batch17.py MODEL=False）',
    'gousi':    '批一 give 先行：外观未做（_gen_batch17.py MODEL=False）',
    'lianshi':  '批一 give 先行：外观未做（_gen_batch17.py MODEL=False）',
    'tiejili':  '批一 give 先行：外观未做（_gen_batch17.py MODEL=False）',
    'lvshuang': '批一 give 先行：外观未做（_gen_batch17.py MODEL=False）',
    'dongtu':   '批一 give 先行：外观未做（_gen_batch17.py MODEL=False）',
    'huilan':   '批一 give 先行：外观未做（_gen_batch17.py MODEL=False）',
    'chengxing':'批一 give 先行：外观未做（_gen_batch17.py MODEL=False）',
    # ---- 批二 14 件（2026-10-20）：同上，先 give 后外观 ----
    #   give 生成器 `_gen_batch18.py` 里 MODEL=False。
    'profane':        '批二 give 先行：外观未做（_gen_batch18.py MODEL=False）',
    'grave_tablet':   '批二 give 先行：外观未做（_gen_batch18.py MODEL=False）',
    'burst_bank':     '批二 give 先行：外观未做（_gen_batch18.py MODEL=False）',
    'breathing_soil': '批二 give 先行：外观未做（_gen_batch18.py MODEL=False）',
    'cage_day':       '批二 give 先行：外观未做（_gen_batch18.py MODEL=False）',
    'way_back':       '批二 give 先行：外观未做（_gen_batch18.py MODEL=False）',
    'stop_needle':    '批二 give 先行：外观未做（_gen_batch18.py MODEL=False）',
    'empty_seat':     '批二 give 先行：外观未做（_gen_batch18.py MODEL=False）',
    'bind_ember':     '批二 give 先行：外观未做（_gen_batch18.py MODEL=False）',
    'sunken_weight':  '批二 give 先行：外观未做（_gen_batch18.py MODEL=False）',
    'night_bind':     '批二 give 先行：外观未做（_gen_batch18.py MODEL=False）',
    'sip_frost':      '批二 give 先行：外观未做（_gen_batch18.py MODEL=False）',
    'retro_shine':    '批二 give 先行：外观未做（_gen_batch18.py MODEL=False）',
    'pour_sack':      '批二 give 先行：外观未做（_gen_batch18.py MODEL=False）',
}


def items_dirs():
    """命名空间 -> items 目录下已定义的 key 集合。"""
    out = {}
    for d in glob.glob(os.path.join(ASSETS, '*')):
        p = os.path.join(d, 'items')
        if os.path.isdir(p):
            out[os.path.basename(d)] = set(
                f[:-5] for f in os.listdir(p) if f.endswith('.json'))
    return out


ITEMS = items_dirs()
TEX_PREFIX = {}


_CACHE = {}


def model_path(ns, key):
    return os.path.join(ASSETS, ns, 'models', key + '.json')


def load_model(ref):
    """'ns:path/to/model' -> dict 或 None（外部命名空间不归我们管，按已存在处理）。"""
    if not isinstance(ref, str):
        return None
    ns, _, key = ref.partition(':')
    if not key:
        ns, key = 'minecraft', ns
    # ★ `minecraft:` 一律当外部 —— 原版模型在客户端 jar 里，本包不重定义它们。
    #   （assets/minecraft/items 下确实有 1 份本包物品，但那只影响 items 层，
    #     不影响 models 层；不特判的话 `minecraft:item/generated` 会被报成"文件不存在"。）
    if ns == 'minecraft' or ns not in ITEMS:
        return 'EXTERNAL'
    if ref in _CACHE:                 # ★ 缓存：burst_dawn/apocalypse 那种 1600+ 子模型的
        return _CACHE[ref]            #   3D 件会被反复解引用，不缓存要跑两分钟
    p = model_path(ns, key)
    if not os.path.exists(p):
        _CACHE[ref] = None
        return None
    try:
        with io.open(p, encoding='utf-8') as f:
            d = json.load(f)
    except Exception:
        d = '__BROKEN_JSON__'
    _CACHE[ref] = d
    return d


def walk(nodes, texes, models, seen, tag, ext=None):
    """递归遍历任意模型节点，收集 textures 与"解析失败的模型引用"。"""
    stack = list(nodes)
    while stack:
        m = stack.pop()
        if not isinstance(m, dict):
            continue
        k = json.dumps(m, sort_keys=True)
        if k in seen:
            continue
        seen.add(k)
        t = m.get('type')
        if t == 'minecraft:model':
            ref = m.get('model')
            d = load_model(ref)
            if d == 'EXTERNAL':
                if ext is not None:
                    ext.add(ref)
                continue
            if d is None or d == '__BROKEN_JSON__':
                models.append(ref)
                continue
            # ★ 父模型可能是字符串引用（3D 组件的每一层都是），必须**解引用后递归**：
            #   只把字符串压栈的话会在 isinstance(dict) 那里被丢掉，整条父链丢掉，
            #   于是"子模型都在、贴图在祖父那层"的件会被误报成"走不到任何贴图"
            #   （burst_dawn / apocalypse 这两件 1600+ 子模型的 3D 弩就是这么被抓到的）。
            par = d.get('parent')
            if isinstance(par, dict):
                stack.append(par)
            elif isinstance(par, str) and ':' in par:
                pd = load_model(par)
                if pd in (None, '__BROKEN_JSON__'):
                    models.append(par)
                elif pd == 'EXTERNAL':
                    if ext is not None:
                        ext.add(par)
                else:
                    stack.append(pd)
            for v in (d.get('textures') or {}).values():
                if isinstance(v, str) and ':' in v:
                    texes.add(v)
        elif t == 'minecraft:select':
            for c in m.get('cases') or []:
                stack.append(c.get('model'))
            stack.append(m.get('fallback'))
        elif t == 'minecraft:condition':
            stack += [m.get('on_true'), m.get('on_false')]
        elif t == 'minecraft:range_dispatch':
            stack.append(m.get('fallback'))
            for e in m.get('entries') or []:
                stack.append(e.get('model'))
        elif t == 'minecraft:composite':
            stack += list(m.get('models') or [])
        elif t == 'minecraft:special':
            continue
        elif 'parent' in m or 'textures' in m:      # 老式模型（直接 parent/textures）
            for v in (m.get('textures') or {}).values():
                if isinstance(v, str) and ':' in v:
                    texes.add(v)
            if isinstance(m.get('parent'), dict):
                stack.append(m['parent'])


def tex_exists(ref):
    ns, _, key = ref.partition(':')
    if ns not in ITEMS:
        return True                             # 外部命名空间不管
    p = os.path.join(ASSETS, ns, 'textures', key + '.png')
    return os.path.exists(p)


def main():
    used_items = set()
    n_give = 0
    for g in sorted(glob.glob(GIVE_GLOB, recursive=True)):
        cid_dir = os.path.basename(os.path.dirname(g))
        src = io.open(g, encoding='utf-8', errors='ignore').read()
        lines = [l for l in src.splitlines() if l.startswith('give @s ')]
        if not lines:
            continue
        n_give += 1
        line = lines[0]
        m = re.search(r'item_model="([^"]+)"', line)
        if not m:
            if cid_dir in KNOWN_EXEMPT:
                continue
            errs.append('① %-18s give 没有 item_model（游戏里显示底材原版外观，零日志）'
                        % cid_dir)
            continue
        ref = m.group(1)
        ns, _, key = ref.partition(':')
        used_items.add((ns, key))
        if key not in ITEMS.get(ns, set()):
            errs.append('① %-18s item_model="%s" 找不到 items/%s.json'
                        % (cid_dir, ref, key))
            continue
        with io.open(os.path.join(ASSETS, ns, 'items', key + '.json'), encoding='utf-8') as f:
            try:
                item = json.load(f)
            except Exception:
                errs.append('① %-18s items/%s.json 不是合法 JSON' % (cid_dir, key))
                continue
        texes, broken, ext = set(), [], set()
        walk([item.get('model')], texes, broken, set(), cid_dir, ext)
        for b in broken:
            errs.append('② %-18s 模型链断在 "%s"（文件不存在）' % (cid_dir, b))
        if not texes and not broken and not ext:
            errs.append('③ %-18s 模型链走不到任何贴图' % cid_dir)
        for t in sorted(texes):
            if not tex_exists(t):
                errs.append('③ %-18s 贴图缺失 %s' % (cid_dir, t))
        # ④ 盔甲：equippable 的 asset_id -> equipment 定义 -> 穿戴层贴图
        a = re.search(r'asset_id:"([^"]+)"', line)
        if a:
            ans, _, akey = a.group(1).partition(':')
            ep = os.path.join(ASSETS, ans, 'equipment', akey + '.json')
            if not os.path.exists(ep):
                errs.append('④ %-18s equipment/%s.json 不存在（穿在身上是原版甲）'
                            % (cid_dir, akey))
            else:
                with io.open(ep, encoding='utf-8') as f:
                    eq = json.load(f)
                for layer, lst in (eq.get('layers') or {}).items():
                    for e in lst:
                        t = e.get('texture', '')
                        tns, _, tk = t.partition(':')
                        tp = os.path.join(ASSETS, tns, 'textures', 'entity',
                                          'equipment', layer, tk + '.png')
                        if not os.path.exists(tp):
                            errs.append('④ %-18s 穿戴层贴图缺失 %s/%s.png'
                                        % (cid_dir, layer, tk))
        # ⑤ sameness：盔甲四件套里 item_model 与 asset_id 必须同名（改名时最易漏一处）
        if a and a.group(1) != ref:
            errs.append('④ %-18s item_model 与 asset_id 不同名（%s / %s）'
                        % (cid_dir, ref, a.group(1)))

    # ⑤ 孤儿：**所有** items 定义（不只 give 引用的那些）走过的贴图之外的多余图
    ref_tex = set()
    for ns, keys in ITEMS.items():
        for key in keys:
            p = os.path.join(ASSETS, ns, 'items', key + '.json')
            try:
                with io.open(p, encoding='utf-8') as f:
                    item = json.load(f)
            except Exception:
                continue
            t2, b2 = set(), []
            walk([item.get('model')], t2, b2, set(), key, set())
            for t in t2:
                tns, _, tk = t.partition(':')
                if tns == 'sweetdream':
                    ref_tex.add(tk)
    orphans = []
    for f in sorted(os.listdir(os.path.join(ASSETS, 'sweetdream', 'textures', 'item', 'vanilla'))):
        if not f.endswith('.png'):
            continue
        key = f[:-4]
        if 'item/vanilla/' + key in ref_tex:
            continue
        if re.search(r'_(pulling_[0-2]|arrow|firework|on|off)$', key) or key.endswith('_standby'):
            continue                        # 弩的态、火种两态：由主 key 的分支引用
        if key == 'anchor':
            continue                        # 沉锚：平面图标已画好、等 3D 候选验收后再挂（见 KNOWN_EXEMPT）
        orphans.append(key)
    if orphans:
        errs.append('⑤ 孤儿贴图（没有 items 定义引用，疑似改名后留下的残件）：%s'
                    % ', '.join(orphans))

    print('== 装备 give：%d 件 · 已引用 items 定义 %d 份' % (n_give, len(used_items)))
    if errs:
        print('!! 合计问题 %d 条' % len(errs))
        for e in errs:
            print('   ' + e)
        return 1
    print('合计问题: 0')
    return 0


if __name__ == '__main__':
    sys.exit(main())
