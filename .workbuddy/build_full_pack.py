# -*- coding: utf-8 -*-
"""
合并老包、原版风覆盖层、8 张法杖与5把六状态像素弩，产出自包含完整版。

合并规则（唯一真相来源）：
  - 基底 = sweetdream_rp 全量逐字节复制
  - 覆盖 = sweetdream_rp_原版风 的 39 件 items 定义 + 它们引用的 models/textures
           （4 件替换已有 3D 模型 + 35 件新增：12 件剑 + 火种两态 + 14 件斧
            + 25 件盔甲图标 + 7 件副手道具）
           ★ 崩裂的模型键是 fissure_axe（sweetdream:fissure 已被地面裂缝模型占用）
  - 法杖 = 共鸣等 8 件新绑定；风行/启示录/调色盘/风帆保留
  - 弩 = 幽匿残响/蚀骨/清醒梦/虹彩/电弧；寒鸦保留
  - pack.mcmeta / pack.png 用合并版自己的

用法：
    python build_full_pack.py            # 只生成到 OUT
    python build_full_pack.py --deploy   # 生成后再同步到游戏实例 resourcepacks/
    python build_full_pack.py --zip      # 生成后再打一个可分发 zip
不变量（verify 里逐条断言，失败即 sys.exit）：
  1. OUT 文件集 = 基底 + 覆盖层 + 8 件法杖各3文件 + 5把弩各13文件
  2. OVERLAY_ITEMS 里每条 items 定义 == 覆盖层版本（字节一致）
  3. OUT 里除这些定义 + pack.mcmeta 外，每个文件都与老包字节一致
  4. 每条定义都带 hand_animation_on_swap: false，且 model→模型→贴图 可达（贴图 16x16）
"""
import os, sys, json, shutil, hashlib
from pathlib import Path

sys.path.insert(0, r'D:\数据包\.workbuddy')
from build_vanilla_armor import P as ARMOR_P                    # 盔甲 25 件（单件真相来源）
ARMOR_IDS = [p['id'] for p in ARMOR_P]
from build_offhand_icons import ICONS as TOOL_ICONS             # 副手 7 件（单件真相来源）
TOOL_IDS = [pid for pid, _cn, _motif, _fn in TOOL_ICONS]

ROOT    = r'D:\数据包'
BASE    = os.path.join(ROOT, 'sweetdream_rp')            # 老包（7 件保留 3D）
OVERLAY = os.path.join(ROOT, 'sweetdream_rp_原版风')      # 覆盖层（4 件原版风）
OUT     = os.path.join(ROOT, 'sweetdream_rp_完整版')       # 合并产物
DEPLOY  = r'D:\PCL 正式版 2.10.0\.minecraft\versions\1.21.5-Fabric 0.16.10\resourcepacks\sweetdream_rp_完整版'

# 覆盖层接管的那些 items 定义（相对 assets/ 的路径）
# ★ 这里**必须列全**：不变量 2（定义 == 覆盖层）与不变量 4（字段 + model→贴图可达）
#   只遍历这个清单。漏一件 ⇒ 那件在合并包里坏掉也不会被发现。
OVERLAY_ITEMS = [
    'angelcore/items/axe.json',
    'sail/items/staff.json',
    'sweetdream/items/aurora_dream.json',
    'sweetdream/items/look.json',
] + ['sweetdream/items/%s.json' % n for n in (
    'everfrost', 'hengdao', 'hush', 'liaoyuan', 'liuguang', 'myriad',
    'qiansan', 'rebound', 'remelt', 'rogue_star', 'shadow_blade', 'verdict',
    'tinder_off', 'tinder_on',
)] + ['sweetdream/items/%s.json' % n for n in (
    'agony', 'anion', 'azure_star', 'ballad', 'charge', 'chenyuan', 'draught',
    'dream_reader', 'fissure_axe', 'meteor', 'pyre', 'red_lotus', 'skyvault',
    'thunderclap',
)] + ['sweetdream/items/armor_%s.json' % n for n in ARMOR_IDS
] + ['sweetdream/items/tool_%s.json' % n for n in TOOL_IDS]
# 合并时允许与老包不同的文件（其余必须逐字节一致）
ALLOW_DIFF = set('assets/' + p for p in OVERLAY_ITEMS) | {'pack.mcmeta'}

STAFF_ART = Path(ROOT) / '模型设计/原版风_法杖像素试绘_20261010/贴图'
STAFF_ICONS = {
    'chime': '共鸣', 'polarized_light': '偏振光', 'delusion': '惑梦',
    'fallen_dream': '堕梦', 'begonia': '海棠', 'gu_poison': '蛊毒',
    'twilight': '暮光', 'final_revelation': '终末天启',
}

DESC = ('sweetdream 武器模型 · 完整版（原版风物品 + 13 件剑图标（含火种两态）'
        ' + 14 件斧图标 + 8 张手绘法杖 + 5 把六状态像素弩 + 盔甲 25 件（图标 + 穿戴层）'
        ' + 副手 7 件图标，保留独立 3D 模型，自包含）')

CROSSBOW_ART = Path(ROOT) / '模型设计/原版风_弩像素试绘_20261010'
CROSSBOW_ICONS = {
    'sculk_echo': '幽匿残响', 'bone_erode': '蚀骨', 'lucid_dream': '清醒梦',
    'rainbow': '虹彩', 'arc': '电弧',
}
CROSSBOW_STATES = ('standby', 'pulling_0', 'pulling_1', 'pulling_2', 'arrow', 'firework')

# O04 裁剪掉的文件集(相对路径), 由 prune_unused() 填充, 不变量 1 用它核对文件集
_PRUNED = set()


def crossbow_paths(cid):
    return ['assets/sweetdream/items/crossbow_' + cid + '.json'] + [
        'assets/sweetdream/' + folder + '/item/vanilla/crossbow_' + cid + '_' + state + ext
        for state in CROSSBOW_STATES
        for folder, ext in (('models', '.json'), ('textures', '.png'))
    ]


def crossbow_definition(cid):
    # Minecraft 1.21.5's native state tree: charge type, using_item, normalized pull.
    data = json.loads((CROSSBOW_ART / '原版参考/crossbow_item_1.21.5.json').read_text(encoding='utf-8'))
    refs = {'minecraft:item/crossbow' + ('' if state == 'standby' else '_' + state):
            'sweetdream:item/vanilla/crossbow_' + cid + '_' + state for state in CROSSBOW_STATES}

    def replace(node):
        if isinstance(node, dict):
            return {k: refs.get(v, v) if k == 'model' and isinstance(v, str) else replace(v)
                    for k, v in node.items()}
        if isinstance(node, list):
            return [replace(v) for v in node]
        return node

    data = replace(data)
    data['hand_animation_on_swap'] = False
    return data


def build_crossbow_icons():
    for cid, name in CROSSBOW_ICONS.items():
        write_json(Path(OUT) / crossbow_paths(cid)[0], crossbow_definition(cid))
        for state in CROSSBOW_STATES:
            model = 'sweetdream:item/vanilla/crossbow_' + cid + '_' + state
            write_json(Path(OUT) / ('assets/sweetdream/models/item/vanilla/crossbow_' + cid + '_' + state + '.json'),
                       {'parent': 'minecraft:item/crossbow', 'textures': {'layer0': model}})
            source = CROSSBOW_ART / '贴图' / name / (state + '.png')
            target = Path(OUT) / ('assets/sweetdream/textures/item/vanilla/crossbow_' + cid + '_' + state + '.png')
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(source, target)
    print('5 把像素弩 / 30 张六状态贴图；寒鸦保留现有模型')


def verify_crossbows():
    from PIL import Image
    manifest = json.loads((CROSSBOW_ART / '贴图清单.json').read_text(encoding='utf-8'))
    approved = {item['id']: {s['state']: s['sha256'] for s in item['states']} for item in manifest['items']}
    for cid, name in CROSSBOW_ICONS.items():
        assert json.loads((Path(OUT) / crossbow_paths(cid)[0]).read_text(encoding='utf-8')) == crossbow_definition(cid), cid
        for state in CROSSBOW_STATES:
            suffix = 'item/vanilla/crossbow_' + cid + '_' + state
            model = json.loads((Path(OUT) / ('assets/sweetdream/models/' + suffix + '.json')).read_text(encoding='utf-8'))
            texture = Path(OUT) / ('assets/sweetdream/textures/' + suffix + '.png')
            assert model == {'parent': 'minecraft:item/crossbow', 'textures': {'layer0': 'sweetdream:' + suffix}}
            assert sha(texture) == approved[cid][state] == sha(CROSSBOW_ART / '贴图' / name / (state + '.png'))
            im = Image.open(texture).convert('RGBA')
            alpha = im.getchannel('A').histogram()
            assert im.size == (16, 16) and alpha[0] > 0 and alpha[255] > 0 and sum(alpha[1:255]) == 0
    print('5 把弩：原版拉弦/箭矢/烟花路由与批准贴图 ✓')


def staff_paths(cid):
    return ('sweetdream:' + cid, 'assets/sweetdream/items/' + cid + '.json',
            'assets/sweetdream/models/item/vanilla/staff_' + cid + '.json',
            'assets/sweetdream/textures/item/vanilla/staff_' + cid + '.png')


def write_json(path, data):
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')


def require_target(path, expected):
    if Path(path).resolve() != Path(expected).resolve():
        sys.exit('✗ 构建/部署路径不符合预期: ' + str(path))


def build_staff_icons():
    for cid, name in STAFF_ICONS.items():
        mid, ip, mp, tp = staff_paths(cid)
        source = STAFF_ART / (name + '_16x16.png')
        if not source.is_file():
            sys.exit('✗ 缺少已批准的贴图: ' + str(source))
        model = 'sweetdream:item/vanilla/staff_' + cid
        write_json(Path(OUT) / ip, {'hand_animation_on_swap': False,
                   'model': {'type': 'minecraft:model', 'model': model}})
        write_json(Path(OUT) / mp, {'parent': 'minecraft:item/handheld',
                   'textures': {'layer0': model}})
        target = Path(OUT) / tp
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, target)
    print('用户批准的法杖贴图: 8 张；风行/启示录/调色盘/风帆保留')


_SKIP_DIR = {'tools'}


def skip_work_file(rel):
    """创作工作文件不进发布产物(审查报告 O07)。
    命中: *.bak / *.bak-xxx / *.broken-xxx 这类备份与坏版本, 以及 tools/ 下的构建脚本。
    它们不影响资源解析, 但没必要给最终使用者 —— 报告实测老包里混进了 6 个备份 + 1 个脚本,
    并随"基底全量复制"一起进了完整版。正常资源名不会含 .bak/.broken, 也不会叫 tools。"""
    parts = rel.split('/')
    if any(p in _SKIP_DIR for p in parts[:-1]):
        return True
    low = parts[-1].lower()
    return '.bak' in low or '.broken' in low


def rel_files(root):
    out = {}
    for dp, dns, fns in os.walk(root):
        dns[:] = [d for d in dns if d not in _SKIP_DIR]
        for fn in fns:
            p = os.path.join(dp, fn)
            rel = os.path.relpath(p, root).replace('\\', '/')
            if skip_work_file(rel):
                continue
            out[rel] = p
    return out


def sha(p):
    with open(p, 'rb') as f:
        return hashlib.sha256(f.read()).hexdigest()


def build():
    if not os.path.isdir(BASE):
        sys.exit('✗ 找不到老包: ' + BASE)
    if not os.path.isdir(OVERLAY):
        sys.exit('✗ 找不到覆盖层: ' + OVERLAY)
    for name in STAFF_ICONS.values():
        if not (STAFF_ART / (name + '_16x16.png')).is_file():
            sys.exit('✗ 缺少已批准的法杖贴图: ' + name)
    if os.path.isdir(OUT):
        require_target(OUT, Path(ROOT) / 'sweetdream_rp_完整版')
        shutil.rmtree(OUT)

    # 1) 基底全量复制 —— 走 rel_files 过滤(跳过 .bak/.broken 备份与 tools/ 脚本, 见 O07)。
    #    老包的整目录 copytree 会把这些创作工作文件一并带进发布产物, 所以这里逐文件铺。
    os.makedirs(OUT, exist_ok=True)
    for rel, src in rel_files(BASE).items():
        dst = os.path.join(OUT, rel.replace('/', os.sep))
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        shutil.copy2(src, dst)
    print('基底复制完成: %d 个文件' % len(rel_files(OUT)))

    # 2) 覆盖层逐文件铺上去（items 定义 + models + textures，覆盖同名）
    ov = rel_files(OVERLAY)
    n_ov = 0
    for rel, src in ov.items():
        # pack.mcmeta 单独写；README 是覆盖层自己的说明，不进合并包（内容会误导）
        if rel in ('pack.mcmeta', 'README.md'):
            continue
        if rel == 'pack.png':
            dst = os.path.join(OUT, 'pack.png')
        else:
            dst = os.path.join(OUT, rel.replace('/', os.sep))
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        shutil.copy2(src, dst)
        n_ov += 1
    print('覆盖层铺入: %d 个文件' % n_ov)

    build_staff_icons()
    build_crossbow_icons()

    # 3) pack.mcmeta（沿用老包的 format 55 结构，换描述）
    mcmeta = {
        "pack": {
            "pack_format": 55,
            "supported_formats": {"min_inclusive": 55, "max_inclusive": 55},
            "description": DESC,
        }
    }
    with open(os.path.join(OUT, 'pack.mcmeta'), 'w', encoding='utf-8') as f:
        json.dump(mcmeta, f, ensure_ascii=False, indent=2)
        f.write('\n')

    # 4) O04(2026-10-11): 裁剪未被引用的 models/textures —— 审查报告估 ~20.6MB/22.3%。
    #    【引用图】根 = 全部 assets/*/items/*.json(物品定义入口) + equipment/ + font/
    #    + lang/ + minecraft 命名空间(整体保留); 从定义递归收集 "model" 引用 ->
    #    模型文件 -> parent 链 + textures 里全部非 # 值; 被引用贴图连 .png.mcmeta 一起保。
    #    【为什么敢删】引用不达的模型 = 历次改版淘汰的旧版(用户 2026-10-11 定案:
    #    斧/杖/极光梦等 3D 大模型是"废弃模型"), 它们不被任何 items 定义指向,
    #    进了包也只是占体积。源(老包/覆盖层)永远不动, 重跑构建即可找回。
    #    【保险】--no-prune 可关闭; verify 的不变量 1/4/5 会在裁剪后的 OUT 上复核。
    if '--no-prune' in sys.argv:
        print('O04 裁剪: 已用 --no-prune 跳过')
    else:
        prune_unused()


def prune_unused():
    files = rel_files(OUT)

    def always_keep(rel):
        return (rel in ('pack.mcmeta', 'pack.png')
                or ('/items/' in rel and rel.endswith('.json'))
                or '/equipment/' in rel
                or '/textures/entity/' in rel
                or '/font/' in rel or '/lang/' in rel
                or rel.startswith('assets/minecraft/'))

    def model_path(mid):
        ns, _, name = mid.partition(':')
        return 'assets/%s/models/%s.json' % (ns, name)

    def tex_path(t):
        ns, _, name = t.partition(':')
        return 'assets/%s/textures/%s.png' % (ns, name)

    def collect_model_refs(node, acc):
        if isinstance(node, dict):
            for k, v in node.items():
                if k == 'model' and isinstance(v, str):
                    acc.add(v)
                collect_model_refs(v, acc)
        elif isinstance(node, list):
            for v in node:
                collect_model_refs(v, acc)

    keep = {rel for rel in files if always_keep(rel)}
    queue = []
    for rel, p in files.items():
        if rel.endswith('.json') and '/items/' in rel:
            try:
                d = json.load(open(p, encoding='utf-8'))
            except Exception:
                continue
            refs = set()
            collect_model_refs(d, refs)
            queue.extend(model_path(m) for m in refs)
    while queue:
        mrel = queue.pop()
        if mrel in keep or mrel not in files:
            continue
        keep.add(mrel)
        try:
            d = json.load(open(files[mrel], encoding='utf-8'))
        except Exception:
            continue
        par = d.get('parent')
        if isinstance(par, str):
            queue.append(model_path(par))
        texs = d.get('textures', {})
        if isinstance(texs, dict):
            for v in texs.values():
                if isinstance(v, str) and not v.startswith('#'):
                    tp = tex_path(v)
                    keep.add(tp)
                    if tp + '.mcmeta' in files:
                        keep.add(tp + '.mcmeta')

    pruned = {rel: p for rel, p in files.items() if rel not in keep}
    _PRUNED.update(pruned)
    sz = sum(os.path.getsize(p) for p in pruned.values())
    print('O04 裁剪: 删除 %d 个未引用文件, 省 %.1f MB' % (len(pruned), sz / 1048576))
    for rel in sorted(pruned):
        os.remove(pruned[rel])
    # 清掉空目录(不然 deploy 的 copytree 会留下空壳)
    for dp, dns, fns in os.walk(OUT, topdown=False):
        if not dns and not fns and dp != OUT:
            os.rmdir(dp)


def verify():
    ok = True
    base = rel_files(BASE)
    over = rel_files(OVERLAY)
    out  = rel_files(OUT)

    # 不变量 1: 文件数 = 老包全集 + 覆盖层新增（不含 README/pack.mcmeta）
    over_provided = [r for r in over if r not in ('pack.mcmeta', 'README.md')]
    news = [r for r in over_provided if r not in base]
    staff_provided = {p for cid in STAFF_ICONS for p in staff_paths(cid)[1:]}
    crossbow_provided = {p for cid in CROSSBOW_ICONS for p in crossbow_paths(cid)}
    expected_files = set(base) | set(over_provided) | staff_provided | crossbow_provided
    if _PRUNED:
        unexpected_pruned = _PRUNED - expected_files
        if unexpected_pruned:
            print('  ✗ 裁到了不该裁的文件(不在合并集里): %s' % sorted(unexpected_pruned)[:5]); ok = False
        expected_kept = expected_files - _PRUNED
        print('文件数: OUT=%d  期望=%d (O04 已裁 %d)' % (len(out), len(expected_kept), len(_PRUNED)))
        if set(out) != expected_kept:
            print('  ✗ 文件集不符'); ok = False
    else:
        expect = len(expected_files)
        print('文件数: OUT=%d  期望=%d' % (len(out), expect))
        if set(out) != expected_files:
            print('  ✗ 文件集不符'); ok = False

    # 不变量 2: OVERLAY_ITEMS 里每条定义 == 覆盖层
    def out_item(rel):
        return os.path.join(OUT, 'assets', rel.replace('/', os.sep))

    def ov_item(rel):
        return os.path.join(OVERLAY, 'assets', rel.replace('/', os.sep))

    for rel in OVERLAY_ITEMS:
        a, b = out_item(rel), ov_item(rel)
        if not os.path.isfile(a):
            print('  ✗ 缺定义 assets/' + rel); ok = False; continue
        if sha(a) != sha(b):
            print('  ✗ 定义与覆盖层不一致 assets/' + rel); ok = False
    print('%d 件定义 == 覆盖层: %s' % (len(OVERLAY_ITEMS), '✓' if ok else '✗'))

    # 不变量 3: 其余文件与老包逐字节一致
    bad = []
    for rel, p in out.items():
        if rel in ALLOW_DIFF:
            continue
        if rel not in base:
            continue                       # 覆盖层新增的 models/textures
        if sha(p) != sha(base[rel]):
            bad.append(rel)
    # 覆盖层新增的文件（不在老包里）= 允许存在
    added = sorted(r for r in out if r not in base)
    print('覆盖层新增文件: %d' % len(added))
    print('与老包不一致的保留文件: %d %s' % (len(bad), '✓' if not bad else '✗ ' + str(bad[:5])))
    if bad: ok = False

    # 不变量 4: 字段 + model→模型→贴图 可达
    for rel in OVERLAY_ITEMS:
        p = out_item(rel)
        d = json.load(open(p, encoding='utf-8'))
        tag = 'assets/' + rel
        if d.get('hand_animation_on_swap') is not False:
            print('  ✗ %s 缺 hand_animation_on_swap: false —— 游戏里会在手上一直抽搐' % tag); ok = False
        mid = d.get('model', {}).get('model')
        if not mid:
            print('  ✗ %s 没有静态 model 指向' % tag); ok = False; continue
        ns, _, name = mid.partition(':')
        mp = os.path.join(OUT, 'assets', ns, 'models', name + '.json')
        if not os.path.isfile(mp):
            print('  ✗ %s → %s 模型文件缺失' % (tag, mid)); ok = False; continue
        m = json.load(open(mp, encoding='utf-8'))
        tex = m.get('textures', {}).get('layer0', '')
        tns, _, tname = tex.partition(':')
        tp = os.path.join(OUT, 'assets', tns, 'textures', tname + '.png')
        if not os.path.isfile(tp):
            print('  ✗ %s → 贴图缺失 %s' % (tag, tex)); ok = False; continue
        try:
            from PIL import Image
            w, h = Image.open(tp).size
            if (w, h) != (16, 16):
                print('  ✗ %s 贴图尺寸 %dx%d（应为 16x16）' % (tag, w, h)); ok = False
        except ImportError:
            pass
    print('%d 件字段/模型/贴图: %s' % (len(OVERLAY_ITEMS), '✓' if ok else '✗'))

    # 不变量 5: 25 件盔甲的**穿戴层**（装备定义 + 64×32 层贴图）也要在 OUT 里可达。
    #   这一组不在 items 定义里（走 equippable.asset_id），漏检的话"穿上还是原版外观"
    #   不会有任何报错。
    from PIL import Image as _Im
    for p in ARMOR_P:
        key = 'armor_' + p['id']
        ldir = 'humanoid_leggings' if p['slot'] == 'leggings' else 'humanoid'
        ep = Path(OUT) / 'assets/sweetdream/equipment' / (key + '.json')
        lp = Path(OUT) / 'assets/sweetdream/textures/entity/equipment' / ldir / (key + '.png')
        if not ep.is_file():
            print('  ✗ 缺装备定义 equipment/%s.json' % key); ok = False; continue
        if not lp.is_file():
            print('  ✗ 缺穿戴层贴图 %s/%s.png' % (ldir, key)); ok = False; continue
        ej = json.loads(ep.read_text(encoding='utf-8'))
        if ej.get('layers', {}).get(ldir) != [{'texture': 'sweetdream:' + key}]:
            print('  ✗ %s: layers.%s 指向不对' % (key, ldir)); ok = False
        if _Im.open(lp).size != (64, 32):
            print('  ✗ %s: 穿戴层尺寸应为 64×32' % key); ok = False
    print('%d 件盔甲穿戴层（装备定义/层贴图）: %s' % (len(ARMOR_P), '✓' if ok else '✗'))

    # 新法杖不使用 3D 元素；逐张确认是用户批准的 PNG，且定义链可达。
    from PIL import Image
    for cid, name in STAFF_ICONS.items():
        mid, ip, mp, tp = staff_paths(cid)
        d = json.loads((Path(OUT) / ip).read_text(encoding='utf-8'))
        m = json.loads((Path(OUT) / mp).read_text(encoding='utf-8'))
        model = mp[len('assets/'):].split('/models/')
        tex = tp[len('assets/'):].split('/textures/')
        good = (d.get('hand_animation_on_swap') is False
                and d.get('model') == {'type': 'minecraft:model', 'model': model[0] + ':' + model[1][:-5]}
                and m.get('parent') == 'minecraft:item/handheld'
                and not m.get('elements')
                and m.get('textures', {}).get('layer0') == tex[0] + ':' + tex[1][:-4]
                and Image.open(Path(OUT) / tp).size == (16, 16)
                and sha(Path(OUT) / tp) == sha(STAFF_ART / (name + '_16x16.png')))
        if not good:
            print('  ✗ 法杖绑定/贴图不符: ' + mid); ok = False
    print('8 张法杖绑定/手绘贴图: %s' % ('✓' if ok else '✗'))
    verify_crossbows()

    # 附带统计：合并结果体量
    print()
    print('== 合并结果 ==')
    print('  %s  →  %d 文件 / %.1f MB' % (OUT, len(out), dir_size(OUT) / 1048576))
    return ok


def dir_size(p):
    t = 0
    for dp, _, fns in os.walk(p):
        for fn in fns:
            try:
                t += os.path.getsize(os.path.join(dp, fn))
            except OSError:
                pass
    return t


def main():
    if '--update-crossbows' in sys.argv:
        # Add just this approved set; keep existing user edits and other assets in place.
        require_target(OUT, Path(ROOT) / 'sweetdream_rp_完整版')
        if not Path(OUT).is_dir():
            sys.exit('✗ 增量接入需要已有完整版')
        build_crossbow_icons()
        meta_path = Path(OUT) / 'pack.mcmeta'
        meta = json.loads(meta_path.read_text(encoding='utf-8'))
        meta['pack']['description'] = DESC
        write_json(meta_path, meta)
    else:
        build()
    if not verify():
        sys.exit('✗ 自检未通过')
    if '--deploy' in sys.argv:
        if os.path.isdir(DEPLOY):
            require_target(DEPLOY, r'D:\PCL 正式版 2.10.0\.minecraft\versions\1.21.5-Fabric 0.16.10\resourcepacks\sweetdream_rp_完整版')
            shutil.rmtree(DEPLOY)
        shutil.copytree(OUT, DEPLOY)
        a, b = rel_files(OUT), rel_files(DEPLOY)
        same = len(a) == len(b) and all(sha(a[k]) == sha(b[k]) for k in a)
        print('部署 →', DEPLOY, '| 源↔游戏 逐字节一致:', '✓' if same else '✗')
        if not same:
            sys.exit('✗ 部署不一致')
    if '--zip' in sys.argv:
        import zipfile
        z = os.path.join(ROOT, 'sweetdream_rp_完整版.zip')
        temporary_zip = z + '.tmp'
        n = 0
        with zipfile.ZipFile(temporary_zip, 'w', zipfile.ZIP_DEFLATED) as zf:
            for dp, _, fns in os.walk(OUT):
                for fn in sorted(fns):
                    p = os.path.join(dp, fn)
                    arc = os.path.relpath(p, OUT).replace('\\', '/')
                    if skip_work_file(arc):
                        continue
                    zf.write(p, os.path.relpath(p, OUT))
                    n += 1
        os.replace(temporary_zip, z)
        print('zip →', z, '|', n, '文件 |', '%.1f MB' % (os.path.getsize(z) / 1048576))
    print('完成 ✓')


if __name__ == '__main__':
    main()
