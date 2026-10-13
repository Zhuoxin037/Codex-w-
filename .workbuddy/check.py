# -*- coding: utf-8 -*-
"""
数据包静态自检 (D:\\数据包)
用法: python .workbuddy/check.py
检查项:
  1) function 引用目标是否存在
  2) 函数标签引用是否有对应 json
  3) 含 $(变量) 的行是否以 $ 开头
  4) data get/modify/remove entity 选择器是否有 limit=1
  5) 进度奖励函数首行是否 revoke 自己那条进度
  6) 所有 JSON 能否解析
  7) 资源包内 model 引用 / 数据包 item_model 引用是否指向存在的文件
  8) schedule 同名重复(默认 replace 模式会互相顶掉)
  9) 老式 dust 粒子写法 (particle minecraft:dust 0.9 0.8 1.0 1.2 ...)
     —— 1.21.5 必须写 {color:[...],scale:...}。写错不是"少个粒子", 而是
        整个函数加载失败(见 latest.log "Failed to load function ...")。
 10) tellraw / title 的 JSON 组件能否解析
     —— 字符串里混进未转义的 ASCII 双引号(比如 会"一起没伤害"。)会让整行
        解析失败, 同样导致**整个函数加载失败**。
 11) 命令流里**紧挨着的两条相同命令**(中间只有注释/空行)
     —— 复制粘贴事故的典型形态: 想替换某一行, 结果旧的没删, 新的写在下面,
        两条命令前后脚都跑一遍。
        最惨的一次是 internal/damage/go 里 `run damage @s $(num_str) $(type)`
        出现了两遍 —— **全包所有伤害都打了两倍**, 而且两遍都带 store success,
        看 #dbg_dmg 完全正常、界面上也看不出问题。这类错误不报错、不写日志,
        只能静态抓。
     ⚠️ 判据刻意收得很窄(只抓"相邻重复")。曾试过"同文件出现多次"的宽判据,
        结果 132 条全是误报 —— UUID 逐字节展开、formation/mana 的 driver 循环
        本来就是一串同样的调用。要放宽这条规则, 先想清楚怎么排除这两类。
     豁免: 在重复的那一行【上面】加一行注释写明 `dup-ok: 理由`。
        (Minecraft 里 `#` 只有整行注释, 行尾写 `#` 会被当成命令内容, 所以只能另起一行)
 12) **只认玩家的命令**配了可能落到非玩家身上的选择器
     —— tellraw / title / clear / give / xp / advancement / gamemode ... 的
        "目标"参数在命令树里是 players-only(EntityArgument.players())。
        写 `tellraw @e[tag=xxx]` 不是"运行时找不到人", 而是**解析期直接失败**:
          Whilst parsing command on line N: 只有玩家会受此命令的影响,
          但提供的选择器包括其他实体 at position 0: <--[HERE]
        → 整个函数加载不出来(一条命令都不跑)。
        真实案例: debug/cold_crow_probe 里对箭说话(此刻 @s 是箭)用了
        `tellraw @e[tag=zx.cc_dbg]`, 整个诊断函数加载失败(2026-10-03)。
        合法写法: @a / @p / @r / @s, 或 @e[type=player]。
 13) 12 的连带版: 被 `as @e[...]` / `as @r` 调用的函数里用了 `tellraw @s` 之类
     —— 这是**运行时**才失败(不是加载失败), 表现是"函数跑了但什么都不显示",
     比 12 更隐蔽。跨函数, 只能静态猜, 算是提醒不算铁证。
 14) `matches` 用了**逗号列表** (matches 0,1)
     —— MC 的 matches 参数是"最小..最大"区间类型, **不接受逗号分隔的多值**。
        能写逗号列表的是选择器里的 scores={obj=1,2,3}, 两回事, 很容易混。
        后果和 9)/10) 一样: **整个函数加载失败**(一条命令都不跑)。
        真实案例: deepsea_echo/anim/fx 第 28 行, 2026-10-03 ——
        表现是"技能放了但一个粒子都没有", 日志:
          Whilst parsing command on line 28: 参数后应有空格分隔 ...
          ... matches 0<--[HERE]
        正确写法: matches 0..1 (语义完全相同)。
 15) 物品定义按 custom_model_data 逐帧切换, 却没写 hand_animation_on_swap:false
     —— `assets/<ns>/items/<id>.json` 里一旦用 range_dispatch(custom_model_data),
        就说明有数据包在**每 tick 调 item_modify 改组件**。
        而 hand_animation_on_swap 默认 true, 语义是"物品槽的类型/数量/**组件**
        变化时, 第一人称播放一次下落-抬起动画" —— 每 tick 改组件 = 每 tick 触发,
        物品被永久钉在动画的"下落"位置, 玩家描述为"剑一直卡在屏幕偏下方、
        像刚用了物品"。加一个 "hand_animation_on_swap": false 即可。
        真实案例: deepseaecho/items/sword.json, 2026-10-03。
        (参照物: naturewind/items/staff.json 一开始就写了这个字段。)
     ★ 判据(2026-10-10 加宽): 不只是"定义里写了 custom_model_data"这一种形态 ——
        **任何覆盖层资源包**整份替换 `items/<id>.json` 时, 只要那个 id 被数据包的
        `item_modifier/*.json`(`set_components` 写 `item_model`)驱动, 就必须照带这个字段。
        覆盖层内部通常是纯 `minecraft:model`、且不在 `sweetdream_rp` 目录下 ⇒ 旧判据漏检。
        真实案例: `sweetdream_rp_原版风` 的 4 件(天使核心 / 风帆 / 极光与幻梦 / 观测镜)
        第一次生成时只写了 `model`, 表现为"换上去之后在手上一直抽搐"; 用户连报两次
        (先极光与幻梦、后天使核心), 因为改好的版本一直没被游戏重载 ⇒ 看的一直是旧表现。
 16) 行首有 $ 但不含 $(变量) —— 3) 反过来那一条, 一样会让**整个函数作废**
     —— Minecraft 的宏规则: 只有"含 $(...) 的行"才能加 $ 前缀。
        加了 $ 却没有变量, 加载时报 "Macro without variables" 并作废整个函数。
        真实案例: debug/stats_macro 里把一行普通命令写成了 `$execute ...`, 2026-10-03。
     ⚠️ 反向的坑同样致命: 带 $(...) 却**忘**了 $, 那行会带着字面量 "$(uuid)"
        去执行(路径永远找不到), 静默失效 —— 由 3) 负责抓。两条要一起看。
 17) 通用数值注册表(lib/reg/build)的表行数超过 cap
     —— debug/reg_unroll 是按 cap 生成的固定槽数, 表比槽长的话多出来的行
        永远不会被显示(check.py 是在这里补的提醒)。
        加行的同时: 改 build 里的 cap -> 改 .workbuddy/gen_reg_unroll.py 的常量
        -> 跑一次那个脚本。
 18) 注册表引用的 zx 计分项没有被建出来
     —— 表里写了 o:"zx.xxx" 却没人 `scoreboard objectives add zx.xxx`,
        表现是那一行永远显示 0/不显示, 而且**不报错**。加了新装备最容易漏这个。
 19) give 出去的装备 id 没有登记中文名
     —— debug/worn 是拿 item 的 custom_data.zx[0] 去查 zx:reg names 的;
        漏登记就只打出英文 id(不报错, 但看起来像坏了)。
 29) 装备逻辑被 `execute as @a` 广播调用, 函数体内却没有 `if items entity @s`
     —— "没穿也生效"。真实事故: 黄昏黎明之交界脱掉后, 魔力低于一半照样每秒 +20。
        确实不需要判装备的, 在调用行上方写 `# no-equip-check-ok: 理由` 豁免。
 30) "只平A"契约: 攻击回魔的进度没限定 `damage.type.tags = minecraft:is_player_attack`
     —— 不写就会把技能伤害也算进去(技能伤害是 sweetdream:skill 类型)。
"""
import json, re, sys, io, struct
from collections import defaultdict
from pathlib import Path

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
ROOT = Path(r'D:\数据包')
PACKS = ['manacore-1.0.0', 'sweetdream']
# 【老包 sweetdream_rp/ 已经不在了】(2026-10-12 发现时只剩构建产物
#   sweetdream_rp_完整版/) ⇒ 依次回退; 一个都找不到时 RP 为 None,
#   下面所有跟资源包有关的检查会**跳过并明确报告**(绝不静默丢检查)。
RP = None
for _cand in ('sweetdream_rp', 'sweetdream_rp_完整版', 'sweetdream_rp_原版风'):
    _p2 = ROOT / _cand
    if (_p2 / 'assets').exists():
        RP = _p2
        break
if RP is None:
    print('[WARN] 找不到任何资源包目录(sweetdream_rp* —— 资源包相关检查被跳过)')

functions, nsdirs = {}, []
for pack in PACKS:
    d = ROOT / pack / 'data'
    for nsdir in [x for x in d.iterdir() if x.is_dir()]:
        nsdirs.append(nsdir)
        fdir = nsdir / 'function'
        if not fdir.exists():
            continue
        for f in fdir.rglob('*.mcfunction'):
            functions[f"{nsdir.name}:{f.relative_to(fdir).as_posix()[:-len('.mcfunction')]}"] = f

tagfiles = {}
for pack in PACKS:
    for nsdir in (ROOT / pack / 'data').iterdir():
        if not nsdir.is_dir() or not (nsdir / 'tags').exists():
            continue
        for f in (nsdir / 'tags').rglob('*.json'):
            rel = f.relative_to(nsdir / 'tags').as_posix()
            tagfiles[f"#{nsdir.name}:{rel.split('/', 1)[1][:-5]}"] = f

fn_call = re.compile(r'function\s+([#\w:.\-/]+)')
tag_call = re.compile(r'function\s+#([\w:.\-/]+)')
macro_var = re.compile(r'\$\([^)]*\)')
dataent = re.compile(r'^\s*data\s+(get|modify|remove)\s+entity\s+(?!@s\b|@p\b)(@[a-z](?:\[[^\]]*\])?)')
# 43) items 命令的裸 hotbar 槽位(未知槽位名, 整个函数加载失败; 合法是 hotbar.0..8)
hbslot = re.compile(r'\bitems\s+entity\s+\S+\s+hotbar\b(?!\.)')
# 44) execute store result/success entity 的目标是多实体(只收单实体, 整个函数加载失败)
storeent = re.compile(r'\bstore\s+(?:result|success)\s+entity\s+(@e\[[^\]]*\])')
# 45) {"nbt":"<节点>","storage":"<id>","interpret":true} 引用的节点被初始化成空表 [] ——
#     空列表是**非法文本组件**(不是字符串 / 不是有内容的列表 / 不是 map) → 原版每次读
#     都抛 "Failed to parse component: []"。开面板时就是**每刻一条** WARN,
#     几分钟就能把 latest.log 刷到 8M, 真正的报错全被埋掉(2026-10-05 观测镜实测)。
#     修法: 初值给 [{"text":""}] 这种"非空但渲染为空"的表。
emptyseed = re.compile(r'\bdata\s+modify\s+storage\s+([A-Za-z0-9_:.]+)\s+([A-Za-z0-9_.]+)\s+set\s+value\s*\[\s*\]')
nbtinterp = re.compile(r'\{[^{}]*"nbt"\s*:\s*"([A-Za-z0-9_.]+)"[^{}]*"storage"\s*:\s*"([A-Za-z0-9_:.]+)"'
                       r'[^{}]*"interpret"\s*:\s*true[^{}]*\}')
# 46) 计分项"用了但没在 core/load 里建" —— 该命令运行时直接失败(不报错到聊天栏,
#     只是这条命令没生效), 表现为"某个机制永远不触发"(2026-10-05 真实事故两条:
#     幽匿残响的箭 zx.se_t 永不过期、天穹俯冲 zx.sv_step 保护永不生效)。
obj_add_re = re.compile(r'scoreboard\s+objectives\s+add\s+([A-Za-z0-9_.]+)')
obj_use_re = re.compile(r'scoreboard\s+players\s+(?:set|add|remove|reset|get|enable|operation)\s+\S+\s+([A-Za-z0-9_.]+)')
obj_use_sel = re.compile(r'scores?\s*=\s*\{\s*([A-Za-z0-9_.]+)\s*=')
obj_use_json = re.compile(r'"objective"\s*:\s*"([A-Za-z0-9_.]+)"')
obj_use_tbl = re.compile(r'\{o\s*:\s*"([A-Za-z0-9_.]+)"')
model_ref = re.compile(r'"model"\s*:\s*"([\w:.\-/]+)"')

# 38) 粒子白名单(1.21.5) + "必须带选项"的粒子集合
#     写错名字 / 忘了选项 -> 整个函数加载失败, 而且只在日志里报一行。
KNOWN_PARTICLES = {
    'minecraft:ambient_entity_effect', 'minecraft:angry_villager', 'minecraft:ash',
    'minecraft:block',
    'minecraft:block_crumble', 'minecraft:block_marker', 'minecraft:bubble',
    'minecraft:bubble_column_up', 'minecraft:bubble_pop', 'minecraft:campfire_cosy_smoke',
    'minecraft:campfire_signal_smoke', 'minecraft:cherry_leaves', 'minecraft:cloud',
    'minecraft:composter', 'minecraft:crit', 'minecraft:current_down', 'minecraft:damage_indicator',
    'minecraft:dolphin', 'minecraft:dragon_breath', 'minecraft:dripping_dripstone_lava',
    'minecraft:dripping_dripstone_water', 'minecraft:dripping_honey', 'minecraft:dripping_lava',
    'minecraft:dripping_obsidian_tear', 'minecraft:dripping_water', 'minecraft:dust',
    'minecraft:dust_color_transition', 'minecraft:dust_pillar', 'minecraft:dust_plume',
    'minecraft:effect', 'minecraft:egg_crack', 'minecraft:electric_spark',
    'minecraft:elder_guardian', 'minecraft:enchanted_hit', 'minecraft:enchant',
    'minecraft:end_rod', 'minecraft:entity_effect', 'minecraft:explosion',
    'minecraft:explosion_emitter', 'minecraft:falling_dust', 'minecraft:falling_dripstone_lava',
    'minecraft:falling_dripstone_water', 'minecraft:falling_dust', 'minecraft:falling_honey',
    'minecraft:falling_lava', 'minecraft:falling_nectar', 'minecraft:falling_obsidian_tear',
    'minecraft:falling_spore_blossom', 'minecraft:falling_water', 'minecraft:firework',
    'minecraft:fishing', 'minecraft:flame', 'minecraft:flash', 'minecraft:glow',
    'minecraft:glow_squid_ink', 'minecraft:gust', 'minecraft:gust_emitter_large',
    'minecraft:gust_emitter_small', 'minecraft:happy_villager', 'minecraft:heart',
    'minecraft:infested', 'minecraft:instant_effect', 'minecraft:item',
    'minecraft:item_cobweb', 'minecraft:item_slime', 'minecraft:item_snowball',
    'minecraft:landing_honey', 'minecraft:landing_lava', 'minecraft:landing_obsidian_tear',
    'minecraft:large_smoke', 'minecraft:lava', 'minecraft:mycelium', 'minecraft:nautilus',
    'minecraft:note', 'minecraft:ominous_spawning', 'minecraft:pale_oak_leaves',
    'minecraft:poof', 'minecraft:portal', 'minecraft:raid_omen', 'minecraft:rain',
    'minecraft:reverse_portal', 'minecraft:sculk_charge', 'minecraft:sculk_charge_pop',
    'minecraft:sculk_soul', 'minecraft:shriek', 'minecraft:small_flame', 'minecraft:small_gust',
    'minecraft:smoke', 'minecraft:sneeze', 'minecraft:snowflake', 'minecraft:sonic_boom',
    'minecraft:soul', 'minecraft:soul_fire_flame', 'minecraft:spore_blossom_air',
    'minecraft:splash', 'minecraft:squid_ink', 'minecraft:sweep_attack', 'minecraft:tinted_leaves',
    'minecraft:totem_of_undying', 'minecraft:trail', 'minecraft:trial_omen',
    'minecraft:trial_spawner_detection', 'minecraft:trial_spawner_detection_ominous',
    'minecraft:underwater', 'minecraft:vault_connection', 'minecraft:vibration',
    'minecraft:witch', 'minecraft:wax_off', 'minecraft:wax_on', 'minecraft:white_ash',
    'minecraft:white_smoke',
}
# 存放"组件列表"(会被 {"nbt":...} 引用的文本组件数组)的 storage 路径 —— 查规则 39。
#   目前只有观测镜的"层数段" zx:look.xline(接在冷却后面、同一行)。
COMPONENT_LIST_PATHS = {'xline'}

# 这些粒子**必须**带 {...} 选项, 不给就解析失败("No key xxx")
# ★ 2026-10-05 实测: "简写"(particle minecraft:item minecraft:bone) **不生效** ——
#   1.21.5 的命令解析器把 minecraft:item 当粒子 id 后, 选项块默认取 {} ,
#   于是报 "No key item in MapLike[{}]", 整个函数加载失败。
#   必须写成完整形式: particle minecraft:item{item:"minecraft:bone"} /
#                    particle minecraft:block{block_state:"minecraft:bone_block"}
#   (wiki 说 1.20.5-pre1 起支持字符串简写, 但那只在 biome/enchantment 的粒子定义里,
#    命令里不吃这一套 —— 以游戏实测为准。)
NEED_OPTION_PARTICLES = {
    'minecraft:block', 'minecraft:block_crumble', 'minecraft:block_marker',
    'minecraft:dust', 'minecraft:dust_color_transition', 'minecraft:dust_pillar',
    'minecraft:entity_effect', 'minecraft:falling_dust', 'minecraft:item',
    'minecraft:sculk_charge', 'minecraft:trail', 'minecraft:vibration', 'minecraft:shriek',
}

R = {k: [] for k in ['fn', 'tag', 'macro', 'sel', 'adv', 'json', 'rp', 'sched', 'dust', 'nbtsp',
                     'comp', 'dup', 'ply', 'ply2', 'mcomma', 'swap',
                     'dollar', 'regcap', 'regobj', 'regname', 'rege',
                     'selfmacro', 'dspace', 'storescale', 'opnum',
                     'floatz', 'base', 'oldname', 'rearm', 'const',
                     'equip', 'melee', 'lorestyle', 'glint',
                     'chanhack', 'chandef', 'olchan', 'olvcache',
                     'smwind', 'regsent', 'numloss', 'shulker', 'posnbt', 'obnode',
                     'dstore', 'pname', 'nbtint', 'scorelive', 'nowith', 'crossgate',
                     'hbslot', 'strent', 'nbtempty', 'objmiss', 'asnoat',
                     'animdata', 'attrleave', 'ttl',
                     'ctrlmul', 'dimflag', 'enemysrc', 'reloadttl', 'dimsel',
                     'equipgate', 'storid', 'braceval', 'dmgch', 'dmgord', 'panelrow',
                     'beamoff', 'scoreeq', 'scorelit', 'guardclob', 'retabort', 'atkonce', 'upreq', 'nbtrange',
                     'boltseen', 'selfclr', 'mqgate', 'modelrot', 'storpath', 'attrprefix', 'cdstop',
                     'freezegate', 'olfit', 'eyedist', 'tgvocab', 'regress',
                     'datarm', 'datapath', 'mergelist', 'noexecute', 'intovf',
                     'norun', 'placeholder', 'selfield', 'airpred', 'itempath', 'criterion',
                     'resetset', 'tagmacro', 'dmgseg', 'creative', 'pldur', 'fdsnap', 'upfield',
                     'crossshot', 'ddpair', 'embertop']}

# 技能倍率的三条通道(manacore/internal/damage/calc) —— 字段名 -> 口径表里的标记
CH_FIELD = {'max_mana_mul': 'mm', 'attack_mul': 'atk', 'other_mul': 'oth',
            'skill_multiplier': 'atk'}
CH_LABEL = {'mm': '最大魔力值技能倍率', 'atk': '基础攻击力倍率', 'oth': '其他倍率'}

# 14) matches 逗号列表 —— matches 是区间类型, 逗号会让整个函数加载失败(见文件头)
matches_comma = re.compile(r'\bmatches\s+\S*,\S*')

# 12) 目标参数 players-only 的命令(命令树里写的是 EntityArgument.players())
#     后面必须跟"一定是玩家"的选择器。@s 放行(解析期无法判断, 玩家上下文里是合法的)。
ply_cmd = re.compile(r'(?:^|\brun\s+)(tellraw|title|subtitle|actionbar|clear|give|xp|experience|'
                     r'gamemode|recipe|advancement|spawnpoint|spectate)\s+(@[aeprs])(\[[^\]]*\])?')
# 13) 被 as 到非玩家实体上的函数
as_nonplayer = re.compile(r'\bas\s+(@e(?:\[[^\]]*\])?|@r(?:\[[^\]]*\])?)\s')
_ftext = {}


def ftext(fnk):
    if fnk not in _ftext:
        try:
            _ftext[fnk] = functions[fnk].read_text(encoding='utf-8')
        except Exception:
            _ftext[fnk] = ''
    return _ftext[fnk]


def players_only_selector(sel, br):
    """sel 一定是玩家吗?"""
    if sel in ('@a', '@p', '@s'):
        return True
    if not br:
        return False
    m = re.search(r'\btype\s*=\s*(!?)((?:minecraft:)?players?)\b', br)
    return bool(m) and m.group(1) == ''

# 老式 dust: particle minecraft:dust <数字> ...  (花括号写法才是对的)
old_dust = re.compile(r'particle\s+(?:minecraft:)?dust\s')
# JSON 组件: tellraw <sel> <json>  /  title <sel> <action> <json>
json_cmd = re.compile(r'^\$?\s*(?:tellraw\s+\S+|title\s+\S+\s+(?:title|subtitle|actionbar))\s+(.*)$')
# 说明文字清理: tellraw/title 后面那一大坨 JSON 里, 经常写着"用 /function foo:bar 这样打"
# 之类的**帮助文本** —— 那是字符串, 不是真调用, 但 fn_call 正则会把它当成引用,
# 报一条并不存在的 "sweetdream:前缀"。所以扫函数/标签引用之前, 先把这段砍掉。
# (只影响"引用检查"这一项; tellraw 的 JSON 解析本身另有 comp 那一项在管。)
_text_tail = re.compile(r'(?:^|\brun\s+)(?:tellraw\s+\S+|title\s+\S+\s+(?:title|subtitle|actionbar))\s+.*$')
# 命令里的文本组件其实是 SNBT: {text:"x",color:"red"} 这种"键名不带引号"是合法的。
# 所以判定放宽: 先把裸键名补上引号再试一次, 两次都解析不了才算错。
_bare_key = re.compile(r'([{,]\s*)([A-Za-z_][A-Za-z0-9_]*)(\s*:)')


def comp_ok(text):
    try:
        json.loads(text)
        return True
    except Exception:
        pass
    try:
        json.loads(_bare_key.sub(r'\1"\2"\3', text))
        return True
    except Exception:
        return False

_empty_nodes = set()    # 规则 45: 被 `set value []` 初始化成空表的 storage 节点 (文件, id, 路径)
_interp_uses = []       # 规则 45: 用 {"nbt":...,"interpret":true} 引用节点的地方
_obj_add = set()        # 规则 46: 被 `scoreboard objectives add` 建出来的计分项
_obj_use = {}           # 规则 46: 被写/读的计分项 -> 用到它的文件

for fnk, fp in functions.items():
    try:
        lines = fp.read_text(encoding='utf-8').split('\n')
    except Exception as e:
        R['fn'].append((str(fp), 0, 'READ FAIL %s' % e)); continue
    cmds = []
    pending_ok = False   # 紧邻上方的注释里带 dup-ok -> 这行允许与上一行重复(有意为之)
    empty_ok_pending = False   # 紧邻上方的注释里带 empty-ok -> 规则 45 放行
    for i, line in enumerate(lines, 1):
        s = line.strip()
        if not s:
            pending_ok = False
            empty_ok_pending = False
            continue
        if s.startswith('#'):
            if 'dup-ok' in s:
                pending_ok = True
            if 'empty-ok' in s:
                empty_ok_pending = True
            continue
        cmds.append((i, s, pending_ok))
        pending_ok = False
        if macro_var.search(s) and not line.lstrip().startswith('$'):
            R['macro'].append((str(fp), i, s))
        # 16) 反过来: 带了 $ 却没有 $(变量) —— 同样让整个函数作废
        if line.lstrip().startswith('$') and not macro_var.search(s):
            R['dollar'].append((str(fp), i, s))
        if old_dust.search(s):
            R['dust'].append((str(fp), i, s))
        if matches_comma.search(s):
            R['mcomma'].append((str(fp), i, matches_comma.search(s).group(0)[:60]
                                + '  <- matches 不吃逗号列表, 写成 A..B'))
        m2 = json_cmd.match(s)
        if m2:
            if not comp_ok(m2.group(1)):
                try:
                    json.loads(m2.group(1))
                except Exception as e:
                    err = str(e)[:60]
                else:
                    err = 'SNBT 也解析不了'
                R['comp'].append((str(fp), i, '%s <- %s' % (err, m2.group(1)[:70])))
        cmd_part = _text_tail.sub('', s)

        # 20) 宏参数直接传 zx:data self
        #     实测(2026-10-03): 被调用的宏函数**一条命令都不跑**, 而且日志里
        #     一个字都不报 —— 屏幕上只剩上一层的标题。stats / wind / diff
        #     三个入口同时中招。全项目能正常工作的调用都是
        #     `with storage zx:work <临时节点>` 或 `with storage zx:reg <表项>`。
        if re.search(r'\bwith storage zx:data self\b', s):
            R['selfmacro'].append((str(fp), i, s[:100]
                                   + '  <- 改成先把 uuid 抄进 zx:work, 再 with storage zx:work <节点>'))

        # 21) 参数之间出现连续两个空格
        #     解析器读 count 这种整型参数时不会先跳空白, 直接报 "应为整型" 并让
        #     **整个函数加载失败**(deepsea anim/fx 的 `0  9` 2026-10-03 栽过)。
        #     先把字符串字面量挖空, 免得把 tellraw 文案里的排版空格 / NBT 里
        #     带空格的标签名算进来。
        nq = re.sub(r'"[^"]*"', '""', s)
        nq = re.sub(r"'[^']*'", "''", nq)
        md = re.search(r'\S {2,}\S', nq)
        if md:
            R['dspace'].append((str(fp), i, s[:100] + '  <- 连续空格: ' + repr(md.group(0))))

        # 21.5) data 的路径参数与 NBT 过滤器之间带了空格: `... updef."x" {req:""}` --
        #   过滤器是路径参数的一部分, 必须紧贴(`updef."x"{req:""}` / `Items[{Slot:0b}]`)。
        #   带空格 = 多出一个参数 = 整条命令解析失败 = **整个函数加载失败**,
        #   日志只有一行 Whilst parsing, 不给行号(2026-10-07 fit 槽位改版真实踩到)。
        #   只对 data 命令判(字符串字面量已挖空), 找 "路径 空格 {" 的形态。
        mn = re.search(r'\bdata (?:(?:get|modify|remove|merge) )?(?:storage|block|entity) \S+ ([\w.\[\]"]+) \{', nq)
        if mn:
            R['nbtsp'].append((str(fp), i, s[:100] + '  <- NBT 过滤器要紧贴路径: ' + repr(mn.group(0))))

        # 22) `execute store result score <目标> <计分项>` **没有 scale 参数**
        #     (只有 `store result storage <目标> <路径> <类型> <scale>` 才带)。
        #     把 storage 形式的那个数字抄到 score 后面 -> 整个函数加载失败,
        #     而且解析器只报第一处, 剩下的同样写法要自己找齐。
        ms = re.search(r'\bstore result score \S+ \S+ +[-0-9]', s)
        if ms:
            R['storescale'].append((str(fp), i, s[:100]
                                    + '  <- score 形式不带 scale, 把那个数字删掉'))

        # 24) `scoreboard players operation <目标> <计分项> <op> <数字>` ——
        #     operation 的运算数必须是"源玩家 + 源计分项", **不能是数字字面量**
        #     (数字会被当成目标名, 缺 objective -> "未知或不完整的命令")。
        #     常数要放在假玩家里, 例如 #k1000。
        #   ★ 宏版同罪, 而且**更阴**: `players operation … += $(pct)` 在加载期
        #     $(pct) 被当成合法宏参数放过(日志一个字都不报), 运行时替换成 `+= 10`
        #     才非法 -> 该行静默失败。宏行是**运行时**才解析的, 所以现象是
        #     "函数明明在跑, 就是没效果"(按 RULES 4 的"解析不了 = 整个函数不可用"
        #     在宏行上会漏判)。正解: `players add <目标> <计分项> $(pct)`
        #     (add 的 count 本来就吃整数)。2026-10-08 真实事故: lib/dmg_add_put
        #     一行让 愿景/共振/漫步冥河/炽天使/mm_add 全部"加算"加成一起失效,
        #     而当时 check.py 0 报告 —— 所以这条不仅要认字面量, 还要认"宏运算数"。
        mo = re.search(r'\bscoreboard players operation \S+ \S+ +(?:[+\-*/%]=|=|<|>|><) '
                       r'(?:[-0-9.]+(?:\s|$)|\$\(\w+\)\s*(?:$|#))', s)
        if mo:
            R['opnum'].append((str(fp), i, s[:100]
                               + '  <- operation 的运算数不能是数字(宏展开成数字同罪); '
                                 '常数放进假玩家(如 #k1000), 宏值改用 players add'))

        # 37) `data <get|remove|modify> storage <id>.<路径>` —— storage id 后面
        #     必须**用空格**分隔路径, 不能写成 `zx:look.line2`。
        #     这种写法解析器报 "...look.line2<--[HERE] 未知或不完整的命令",
        #     **整个函数加载失败**(2026-10-05 观测镜第二行栽过)。
        #   ★ 2026-10-10 补: 漏掉过"`.` 后面跟**引号**"那一半 —— 引号也会终止
        #     resource location(location 的字符集只有 [a-z0-9_.:/-]), 于是
        #     `storage manacore:players."$(uuid)".stats.mana` 被解析成
        #     **id = `manacore:players.`**(多一个尾点)+ path = `"$(uuid)".stats.mana`
        #     ⇒ 静默地读写**另一个存储**: 函数照常加载、不报错, 只是永远取不到值。
        #     实测遇害: uuid/migrate(旧键迁移整段空转)、debug/snap_save + diff_go
        #     (zx.dbg_diff 的 7 项属性全部读不到)。所以判定放宽到"任意 id 后紧跟 ."。
        mp = re.search(r'\bstorage\s+([a-z_0-9]+:[a-z_0-9/]*)\.(?=[A-Za-z_"$])', s)
        if mp:
            R['dstore'].append((str(fp), i, s[:100]
                                + '  <- storage 后路径要用空格分隔, 写成 `... storage %s <路径>`' % mp.group(1)))

        # 90) `data remove storage <id>`(不带 path) —— `/data remove <target> <path>`
        #     的 <path> 是**必填**参数, 少写就是"命令不完整", **整个函数加载失败**:
        #       Whilst parsing command on line N: 未知或不完整的命令
        #         at position 36: ...re:players<--[HERE]
        #     (2026-10-10 manacore:debug/reset_all 栽过: 想"不带路径删掉整个根"。)
        #   ★ 同族误解一并说明: **命令存储的"根"在纯命令层面删不掉**(没有 {} 之类的
        #     特殊路径可删根), 想清空只能逐个键删或改成"可遍历清单 + 逐个删"
        #     (见 manacore/internal/debug/purge_registry)。别再试这种写法。
        if re.search(r'\bdata\s+remove\s+storage\s+\S+\s*$', s):
            R['datarm'].append((str(fp), i, s[:100]
                                + '  <- `data remove` 的 <path> 必填: 不带路径 = 整个函数加载失败;'
                                  ' 存储根删不掉, 只能逐个键删'))

        # 91) `data modify storage <id> set|merge|append|prepend value|from|string …`
        #     —— 少了 <targetPath>, 操作符被当成路径(它正好是合法路径名)⇒ **能加载**
        #     但静默写错键: `data modify storage zx:work set value {}` 会在 zx:work 下
        #     建一个名为 `set` 的键, 而本意是"清空整个存储/某个节点"。
        #     判定要求"操作符后面紧跟来源关键字(value/from/string)", 正常路径不可能
        #     同时满足, 所以不误伤。insert 后面跟的是 <index>, 也一道判。
        mp2 = re.search(r'\bdata\s+modify\s+storage\s+\S+\s+'
                        r'(?:set|merge|append|prepend)\s+(?:value|from|string)\b'
                        r'|\bdata\s+modify\s+storage\s+\S+\s+insert\s+-?\d', s)
        if mp2:
            R['datapath'].append((str(fp), i, s[:100]
                                  + '  <- `data modify` 的 <targetPath> 必填: 这里把 `%s` '
                                    '当成了路径名(静默建出错误键), 而不是"缺少路径"的报错'
                                    % s.split()[4]))

        # 92) `data merge storage <id> {…[…]…}` —— NBT merge 对**列表是整体替换**,
        #     不是"保留/追加"。于是 `data merge storage manacore:free_slots {list:[]}`
        #     看着像"保证池子存在", 实际是**每次执行都把池子清空**。
        #     2026-10-10 事故: core/boot 每 reload 清一次槽位回收池, 而 #next_slot
        #     只增不减 ⇒ 槽位只出不进 ⇒ 撑满 #max_slots 后 slot/new 永远拒分配
        #     ⇒ 没人能注册 ⇒ manacore:index 恒空 ⇒ **整包静默失效**(不报错,
        #     技能/观测镜/提示全死; 现场 #next_slot=64=#max_slots、#slot_overflow=52)。
        #     正解: 只 `data merge storage X {}` 保证存在, 内容另写 "不存在才建" 或
        #     像 internal/slot/rebuild 那样按 index 反推重建。
        mp3 = re.search(r'\bdata\s+merge\s+storage\s+\S+\s+(\{[^}]*\[)', s)
        if mp3:
            R['mergelist'].append((str(fp), i, s[:100]
                                   + '  <- merge 对列表是**整体替换**: `%s` 会把已有列表清空; '
                                     '只想"保证存在"就写 `data merge storage <id> {}` '
                                     '(再配 `unless data … run data modify … set value []`)' % mp3.group(1)))

        # 93) 行首直接是 execute 的**子命令**(store / if / unless / as / at / positioned /
        #     aligned / anchored / rotated / facing / on / run), 但没有 execute ——
        #     这类行在**宏函数(带 $ 的行)里加载时不解析**, 所以不会变成
        #     "Failed to load function", 只在运行时炸 ⇒ 极其隐蔽。
        #     2026-10-10 事故: internal/join/register 第 14 行被手滑写成
        #     `$store result storage manacore:players "$(uuid)".slot int 1 run …`(少 execute)
        #     ⇒ `store` 不是命令 ⇒ 宏函数在这一行中断 ⇒ 索引写不进去、manacore.gen 不写
        #     ⇒ tick_self 每秒判定"未注册" ⇒ 每秒重走 join(每秒弹走一格槽位: 实测 64→55)
        #     ⇒ self_uuid 恒空 ⇒ sweetdream 整包静默失效, **日志零报错**。
        #     判定: 行首(可带 $ 与缩进)命中子命令关键字, 且整行不含 execute。
        mne = re.match(r'\s*\$?\s*(store|if|unless|as|at|positioned|aligned|anchored|'
                       r'rotated|facing|on|run)\s', s)
        if mne and not re.search(r'\bexecute\b', s):
            R['noexecute'].append((str(fp), i, s[:100]
                                   + '  <- `%s` 只是 execute 的**子命令**, 不能单独成行; '
                                     '漏写 execute ⇒ 宏函数在这一行运行时中断(加载期不报错, '
                                     '日志也看不到)⇒ 后面整段不执行' % mne.group(1)))

        # 94) `if/unless score … matches <范围>` 后面**漏写 run** ——
        #     `matches 1..` 后面必须接 execute 的子命令(run / store / if / unless / as …),
        #     不能直接接 scoreboard/data 这些真命令。
        #     2026-10-10 事故: R05 批量加固时用脚本生成了 8 处
        #       `execute if score #ol_p zx.meta matches 1.. scoreboard players operation …`
        #     (少一个 run) ⇒ **8 个函数全部 Failed to load function**(含 overlimit 五件套、
        #       debug/stats、out_mul_tag、stg_mul)⇒ 超限改数值与调试面板整块废掉。
        #     判定: 范围后面紧跟的词若不是 execute 的子命令即报。
        _EXSUB = {'run', 'store', 'if', 'unless', 'as', 'at', 'positioned', 'aligned',
                  'anchored', 'rotated', 'facing', 'on', 'summon', 'in'}
        # 两种范围形态: 闭区间/开区间 `1..5` / `1..` / `..5`, 以及单值 `5`。
        # ★ 两个正则的**捕获组都必须只有"范围后面的那个词"** —— 写成
        #   `(-?\d+)\s+([a-z_]+)` 时 group(1) 取到的是数字, 会把 `matches 5 run …`
        #   也判成漏 run(第一版就这样误伤了 792 条)。
        _nr = None
        _m1 = re.search(r'\bmatches\s+-?\d*\.\.-?\d*\s+([a-z_]+)', s)
        if _m1:
            _nr = _m1.group(1)
        else:
            _m2 = re.search(r'\bmatches\s+-?\d+\s+([a-z_]+)', s)
            if _m2:
                _nr = _m2.group(1)
        if _nr is not None and _nr not in _EXSUB:
            R['norun'].append((str(fp), i, s[:100]
                               + '  <- `matches <范围>` 后面漏了 `run`: `%s` 不是 execute 的子命令; '
                                 '范围本身不是命令, 后面必须接 `run`/`store`/`if`/… '
                                 '(`… matches 1.. run <命令>`), 漏写 ⇒ 整函数 Failed to load function'
                               % _nr))

        # 95) 命令里残留**模板占位符** `{xxx}` —— 通常是批量生成脚本的 format 漏了替换。
        #     2026-10-10 事故: R05 的批量脚本把 `{cap}/{mul}/{acc}` 原样写进了 8 个文件,
        #     于是那 8 处"溢出保护"全是非法的假玩家名(同时叠加上一条的漏 run)。
        #     ★ 判据: 花括号里**只有一个裸标识符**(NBT 复合标签必然带 `:` 或 `"`,
        #       空标签是 `{}`, 所以不误伤 `set value {uuid:""}` 这类正常写法)。
        if not s.lstrip().startswith('#'):
            _mph = re.search(r'\{[A-Za-z_][A-Za-z_0-9]{0,20}\}', s)
            if _mph:
                R['placeholder'].append((str(fp), i, s[:100]
                                         + '  <- 残留模板占位符 `%s`: 批量脚本的占位符没被替换就写进了文件, '
                                           '它不是合法假玩家名/路径 ⇒ 该处命令直接失败' % _mph.group(0)))

        # 96) 玩家快捷栏下标的字段名是 **SelectedItemSlot**, 不是 SelectedSlot。
        #     `data get entity @s SelectedSlot` 会因为字段不存在而抛错 ⇒
        #     **函数从这一行起中断**(非宏行: 运行时错误、不进 latest.log)。
        #     2026-10-10 事故: internal/itembackup/effect_1 的记账行写成 SelectedSlot
        #     ⇒ 后面的 backup 与 `schedule … return 1t` 全没跑 ⇒ 消耗型武器被吃掉后
        #     再也没人还(玩家反馈"消耗型武器右键没有正常回手")。
        #     先例: equipment/sword/sickle_dreams/sweep/start 第 14 行。
        #     ★ 同理: **任何 NBT 字段名都要先找库内先例**, 不要凭印象编。
        if re.search(r'\bSelectedSlot\b', s):
            R['selfield'].append((str(fp), i, s[:100]
                                  + '  <- 字段名是 Selected**Item**Slot: `SelectedSlot` 不存在 ⇒ '
                                    'data get/modify 抛错 ⇒ 函数从这一行起中断(不进日志)。'
                                    '先例: sickle_dreams/sweep/start 第 14 行'))

        # 97) `items … air` 判空 —— **恒假**, 2026-10-10 玩家实测:
        #     `execute if items entity @s weapon.mainhand air` 在空手和拿着东西时**都不触发**。
        #     ⇒ 空槽压根不是一个物品栈(它不在 Inventory 里), 物品谓词匹配不到它。
        #     判空一律用 **unless items … \***(通配物品谓词: 没栈 ⇒ 任何谓词都不成立)。
        #     误用 air 的后果是"这个条件永远不成立"—— 静默失效, 不报错、不进日志。
        if not s.lstrip().startswith('#'):
            #    判据里要跳过的参数个数不同: entity 后面是 <目标> <槽>, block 后面是 <xyz> <槽>。
            _ap = re.search(r'\bitems\s+(?:entity\s+\S+\s+|block\s+(?:\S+\s+){3})\S+\s+'
                            r'(?:minecraft:)?air\b', s)
            if _ap:
                R['airpred'].append((str(fp), i, s[:100]
                                     + '  <- 用 `air` 当物品谓词判空是**恒假**: 空槽不是一个物品栈, '
                                       '任何物品谓词都匹配不到它(2026-10-10 实测: 空手/持有都不触发)。'
                                       '判空请用 `unless items … *`'))

        # 98) 物品谓词槽位名混进 NBT 路径 —— 静默失败, 2026-10-11 O03 回手事故:
        #     backup.mcfunction 写 `data modify storage … set from entity @s weapon.mainhand`
        #     —— `weapon.mainhand` 是**物品谓词槽位语法**(只有 item replace / if items 认),
        #     不是 NBT 路径 ⇒ data modify 静默失败、零日志 ⇒ 快照从未写入 ⇒ 永不回手。
        #     NBT 路径的正解是 equipment.mainhand / equipment.offhand / Inventory 等
        #     (全仓先例: debug/raw、station/api/lore_refresh、cold_crow/model/offhand)。
        #     ★ 匹配必须**锚定在路径位置**, 不能行内乱扫 —— `if items … weapon.mainhand …
        #       run data get …`、NBT 过滤器/值里的字符串 "weapon.offhand"、
        #       `item replace … from … weapon.mainhand` 都是合法的, 全仓有 7+ 处。
        _ip_data = re.search(r'\bdata\s+(?:get|merge|remove|modify)\b|\b(?:if|unless)\s+data\b', s)
        _ip_modify = re.search(r'\bdata modify\b', s)
        if _ip_data or _ip_modify:
            _ip_tail = (r'(?:entity\s+\S+|block\s+(?:\S+\s+){3}|storage\s+\S+)'
                        r'\s*(?:\{[^}]*\}\s*)?([^\s{}]+)')
            _ip_hit = None
            if _ip_data:
                for _m in re.finditer(r'(?:\bdata\s+(?:get|merge|remove|modify)|'
                                      r'\b(?:if|unless)\s+data)\s+' + _ip_tail, s):
                    if re.match(r'(?:weapon|armor)\.(?:mainhand|offhand|head|chest|legs|feet)\b'
                                r'|(?:hotbar|container)\.', _m.group(1)):
                        _ip_hit = _m
            if _ip_hit is None and _ip_modify:
                # data modify 的源端(set from / modify … from)同样要查
                for _m in re.finditer(r'\bfrom\s+' + _ip_tail, s):
                    if re.match(r'(?:weapon|armor)\.(?:mainhand|offhand|head|chest|legs|feet)\b'
                                r'|(?:hotbar|container)\.', _m.group(1)):
                        _ip_hit = _m
            if _ip_hit:
                R['itempath'].append((str(fp), i, s[:100]
                                      + '  <- 路径位置出现 `%s`: 这是物品谓词槽位语法'
                                        '(仅 item replace / if items 认), 不是 NBT 路径 ⇒ '
                                        'data 命令静默失败、零日志。NBT 路径用 '
                                        'equipment.mainhand / Inventory 等(找先例)。'
                                        '★ 玩家例外见坑 95: equipment.* 对玩家只有盔甲, '
                                        '拷玩家主/副手物品走 snap 中转实体'
                                      % _ip_hit.group(1)))

        # 99) scoreboard objectives add 的准则名带命名空间 —— 2026-10-11 双连事故:
        #     `objectives add zx.hp_c minecraft.health` ⇒ "未知的准则 minecraft.health";
        #     改成 minecraft:health **还是** "未知的准则 minecraft:health"。
        #     1.21.5 jar 反查铁证(bkc/fhk 类常量池): 只读属性准则只有**裸名**
        #     health/food/air/armor/level/xp/deathCount(1.13 起从来没有命名空间);
        #     点号/冒号只属于统计类准则 minecraft.custom:minecraft.deaths 之类。
        #     ⇒ 属性名前面带 minecraft. 或 minecraft: 一律报。
        _cr_add = re.search(r'\bscoreboard\s+objectives\s+add\s+\S+\s+([A-Za-z0-9_.:]+)', s)
        if _cr_add and re.fullmatch(r'minecraft[.:](?:health|food|air|armor|level|xp|deathCount)',
                                    _cr_add.group(1)):
            R['criterion'].append((str(fp), i, s[:100]
                                   + '  <- 准则名 `%s` 带了命名空间 —— 只读属性准则只有**裸名** '
                                     '`health` 等形式(点号/冒号都是"未知的准则"), 声明它的 load/init '
                                     '会整函数加载失败 ⇒ 全包静默死'
                                   % _cr_add.group(1)))

        # 38) 粒子: 名字必须存在, 且"带选项的粒子"必须写 {...} 选项块。
        #     · 未知粒子名(如 minecraft:item_bone) -> "未知的粒子" 整个函数加载失败
        #     · entity_effect 必须带 color / sculk_charge 必须带 roll /
        #       dust / block / item / block_marker / falling_dust / dust_pillar /
        #       block_crumble 必须带各自选项
        #       缺了 -> "无法解析粒子选项: No key xxx" 整个函数加载失败
        for mp2 in re.finditer(r'\bparticle\s+([a-z_0-9]+:[a-z_0-9]+)(\{)?', s):
            pid = mp2.group(1)
            has_opts = bool(mp2.group(2))
            if pid in NEED_OPTION_PARTICLES:
                if not has_opts:
                    R['pname'].append((str(fp), i, s[:100]
                                       + '  <- %s 必须带 {...} 选项(如 {color:[...]} / {roll:0.0} / '
                                         '{item:"minecraft:bone"}); 命令里**不能**用"紧跟资源位置"的简写' % pid))
            elif pid not in KNOWN_PARTICLES:
                R['pname'].append((str(fp), i, s[:100] + '  <- 未知粒子名 %s' % pid))

        # 39) {"nbt":"<组件列表路径>",...} 少了 "interpret":true —— 会**把整份组件当 SNBT 原样
        #     打印**(屏幕上直接吐 JSON 文本), 而不是渲染出来。
        #     1.21.5 起: nbt 组件 interpret=true 才会"直接按该 nbt 解析成文本组件"。
        #     我们包里的组件列表只有 zx:look.xline 这一处(观测镜层数段), 所以按路径白名单查。
        #     (2026-10-05 栽过: xline 没带 interpret, 屏幕吐一串 {"text":"\n"},…)
        #     【豁免】debug 里故意"看原始 SNBT"的那行(文字含「原始结构」)不算 —— 它就是要看原文。
        for mn in re.finditer(r'\{"nbt":"([^"]+)"[^}]*\}', s):
            path = mn.group(1)
            frag = mn.group(0)
            if '原始结构' in s:
                continue
            if path in COMPONENT_LIST_PATHS and '"interpret":true' not in frag:
                R['nbtint'].append((str(fp), i, s[:100]
                                    + '  <- %s 是组件列表, nbt 组件必须带 "interpret":true, 否则原样打 SNBT' % path))

        for m in fn_call.finditer(cmd_part):
            tgt = m.group(1)
            if tgt.startswith('#') or macro_var.search(tgt):
                continue
            # 动态函数名(宏拼路径, 如 $function sweetdream:upgrade/item/$(id)):
            # fn_call 的字符类吃不到 '$', 目标会被截成 "…/item/" —— 静态解析不了, 豁免。
            if cmd_part[m.end():m.end() + 2] == '$(':
                continue
            ns = tgt.split(':')[0] if ':' in tgt else fnk.split(':')[0]
            if ':' not in tgt:
                tgt = ns + ':' + tgt
            if tgt not in functions:
                R['fn'].append((str(fp), i, tgt))
        for m in tag_call.finditer(cmd_part):
            t = '#' + m.group(1)
            if t not in tagfiles:
                R['tag'].append((str(fp), i, t))
        m = dataent.match(line)
        if m and 'limit=1' not in m.group(2):
            R['sel'].append((str(fp), i, s))
        # 43) 裸 hotbar 槽位(2026-10-05 真实报错: 未知的槽位"hotbar")
        for mh in hbslot.finditer(s):
            R['hbslot'].append((str(fp), i, s[:110] + '  <- 裸 hotbar 槽位非法(要 hotbar.0..8 或 weapon.mainhand)'))
        # 44) store result/success entity 多实体(2026-10-05 真实报错: 只允许一个实体)
        for ms in storeent.finditer(s):
            if 'limit=1' not in ms.group(1):
                R['strent'].append((str(fp), i, s[:110] + '  <- store result/success entity 只收单实体(多目标要 as 循环)'))
        # 45) 收集两侧: 被初始化成空表的 storage 节点 / 用 interpret:true 引用的节点
        for mz in emptyseed.finditer(s):
            _empty_nodes.add((str(fp), mz.group(1), mz.group(2)))
        for mz in nbtinterp.finditer(s):
            _interp_uses.append((str(fp), i, mz.group(2), mz.group(1), s[:110], empty_ok_pending))
        empty_ok_pending = False
        # 46) 计分项: 建 / 用 两侧都收, 循环结束后对账
        for mo in obj_add_re.finditer(s):
            _obj_add.add(mo.group(1))
        for pat in (obj_use_re, obj_use_sel, obj_use_json, obj_use_tbl):
            for mo in pat.finditer(s):
                _obj_use.setdefault(mo.group(1), set()).add(str(fp))
        for m3 in ply_cmd.finditer(s):
            if not players_only_selector(m3.group(2), m3.group(3)):
                R['ply'].append((str(fp), i, '%s %s%s <- 只认玩家, 改成 @a / @p / @s / @e[type=player]'
                                 % (m3.group(1), m3.group(2), m3.group(3) or '')))

    # 11) 命令流里紧挨着的两条相同命令 —— 复制粘贴事故(见文件头说明)
    #     cmds 只收非注释、非空行, 所以"中间隔了几行注释"也算相邻。
    #     诚心想打两遍(文案写的就是"两次")的地方, 在重复的那行上面加一行注释
    #     写明 `dup-ok: 理由` 即可豁免。
    for j in range(1, len(cmds)):
        if cmds[j][1] == cmds[j - 1][1] and not (cmds[j][2] or cmds[j - 1][2]):
            R['dup'].append((str(fp), '第 %d / %d 行相邻重复' % (cmds[j - 1][0], cmds[j][0]), cmds[j][1]))

# 46) 用了但没建的计分项(那条命令运行时直接失败 -> 对应机制永远不触发)
for _n in sorted(n for n in _obj_use if n not in _obj_add):
    _w = sorted(_obj_use[_n])[:3]
    R['objmiss'].append((_w[0], 0, '计分项 %s 没被 scoreboard objectives add 过, 用到它的: %s'
                         % (_n, ', '.join(x.replace(str(ROOT) + '\\', '') for x in _w))))

# 47) `execute ... as @e/@a[...] run function X` 整条链上却没有 at / positioned
#     —— `as` 只换执行者、**不换坐标**。X 里一旦出现 `~` 或 dx=/distance=,
#     范围就落在"外层继承来的坐标"上(挂在 #minecraft:tick 上时 = 世界原点)。
#     真实事故 2026-10-05: 清醒梦的漫彩范围真伤
#       `execute in ... as @e[tag=zx.ld_mark] run ... hit_extra`
#     -> hit_extra_dmg 里 `dx=5,dy=5,dz=5` 的方框取在原点 -> 大效果触发了、
#        术阵也出来了, 但范围真伤一次都打不到人(玩家报"梦回触发后不生效")。
as_run_fn = re.compile(r'^\s*execute\b(?P<chain>.*?)\brun\s+function\s+(?P<fid>[A-Za-z0-9_.:/#-]+)')
as_entity = re.compile(r'\bas\s+@[ea](\[[^\]]*\])?')
has_pos = re.compile(r'\b(at\s+@|\bpositioned\b)')
#   ★ `~` 必须排除 NBT 部分匹配符 ★ 包里到处是 `custom_data~{zx:["xxx"]}`,
#     直接搜 `~` 会全表误报。坐标的 `~` 前面一定是空格/行首, 后面也不是 `{`/`[`。
coord_eat = re.compile(r'(?<![A-Za-z0-9_])~(?![{\[])|(?<![A-Za-z0-9_])(?:dx|dy|dz|distance)=')

for fnk in functions:
    for i, line in enumerate(ftext(fnk).split('\n'), 1):
        s = line.strip()
        if not s or s.startswith('#'):
            continue
        m = as_run_fn.match(line.lstrip().lstrip('$'))
        if not m or m.group('fid').startswith('#'):
            continue
        chain = m.group('chain')
        if not as_entity.search(chain) or has_pos.search(chain):
            continue
        fid = m.group('fid')
        tgt = fid if ':' in fid else fnk.split(':')[0] + ':' + fid
        if tgt not in functions:
            continue
        body = [l for l in ftext(tgt).split('\n')
                if l.strip() and not l.strip().startswith('#')]
        # 被调函数自己会先 at/positioned 一次的话, 坐标是它自己定的 -> 放行
        if any(has_pos.search(l) for l in body):
            continue
        hit = [l for l in body if coord_eat.search(l)]
        if hit:
            R['asnoat'].append((str(functions[fnk]), i,
                                s[:110] + '  <- as 不换坐标, 而 %s 里用了 %s '
                                '(例: %s); 补 at @s(或 positioned)' % (tgt, '~ / dx= / distance=',
                                                                       hit[0].strip()[:70])))

# 45) interpret:true 引用的节点被初始化成空表 —— 空列表不是合法组件, 每次渲染刷一条 WARN
#     (按**同一个文件**配对; 确实有别的守卫挡住空表的, 在上一行注释里写 `empty-ok: 理由`)
for _fp, _i, _st, _path, _src, _ok in _interp_uses:
    if _ok:
        continue
    if (_fp, _st, _path) in _empty_nodes:
        R['nbtempty'].append((_fp, _i, _src
                              + '  <- %s %s 在同文件里被 set value [] 过: 空表不是合法组件, 每读一次'
                                '刷一条 "Failed to parse component: []"(初值给 [{"text":""}])'
                                % (_st, _path)))

# 40) 把 {"score":{"name":"#<假玩家>"}} **存进 storage 组件列表** —— 危险!
#     组件是"渲染那一刻"才读值的, 而假玩家是**全局共享**的: 如果同一个函数里
#     又有别的地方 set/operation 同一个 #假玩家(典型: 逐行循环里反复赋值),
#     那先存进去的那些组件, 最后全都读到**最后一次**的值 —— 表现就是
#     "燃灰永远显示 x/0"(它的上限 10 被后面 max=0 的行覆盖成了 0)。
#     常数就该写成 {"text":"..."}; 真要动态, 用各人自己的计分项(@s 目标)或
#     先快照到独立节点再引用。玩家自己的 @s 计分项不受影响(不是共享的)。
#     ★ 只查"**写进** storage"的行(data modify ... set/append value {...});
#       tellraw/title 里直接用 {"score":...} 是"当场渲染", 没有延迟读值问题, 不算。
#     (2026-10-05 观测镜层数段栽过。)
_fp_write = re.compile(r'scoreboard players (?:set|add|remove|reset|operation)\s+(#\S+)')
_store_score_fp = re.compile(r'\{\s*"score"\s*:\s*\{\s*"name"\s*:\s*"(#\S+?)"')
_store_write = re.compile(r'\bdata\s+modify\s+storage\s+\S+(?:\s+\S+)*?\s+(?:set|append|insert|merge)\s+value\b')
for fnk, fp in functions.items():
    win = _fp_write.findall(ftext(fnk))
    if not win:
        continue
    for i, line in enumerate(ftext(fnk).split('\n'), 1):
        s = line.strip()
        if s.startswith('#') or not _store_write.search(s):
            continue
        for m in _store_score_fp.finditer(s):
            who = m.group(1)
            if who in win:
                R['scorelive'].append((str(fp), i, s[:100]
                                       + '  <- 把共享假玩家 %s 存进组件: 渲染时会读到最后一次的值'
                                         '(常数请写 {"text":...})' % who))

# 13) 被 as 到非玩家实体上的函数, 里面却用 tellraw @s 之类 —— 运行时静默失效
#     (@s 在解析期无法判断是不是玩家, 所以 12) 抓不到; 只能顺着调用边看一层。)
ply_s = re.compile(r'(?:^|\brun\s+)(tellraw|title|subtitle|actionbar|clear|give|xp|experience|'
                   r'gamemode|recipe|advancement|spawnpoint|spectate)\s+@s(?![\w:])')
edges = []
for fnk in functions:
    for i, line in enumerate(ftext(fnk).split('\n'), 1):
        s = line.strip()
        if s.startswith('#') or 'function' not in s:
            continue
        ma = as_nonplayer.search(s)
        if not ma:
            continue
        for m in fn_call.finditer(s[ma.end():]):
            tgt = m.group(1)
            if tgt.startswith('#') or macro_var.search(tgt):
                continue
            ns = tgt.split(':')[0] if ':' in tgt else fnk.split(':')[0]
            if ':' not in tgt:
                tgt = ns + ':' + tgt
            edges.append((fnk, i, tgt))
for fnk, i, tgt in edges:
    if tgt in functions and ply_s.search(ftext(tgt)):
        R['ply2'].append((functions[tgt].relative_to(ROOT).as_posix(),
                          '第 %d 行被 %s 以 as 非玩家调用, 但里面有只认玩家 + @s 的命令'
                          % (i, fnk)))

# 41) 调用了**宏函数**(函数体里有 $( )) 却忘了给宏参数 ——
#     宏参数不会被绑定, 那个函数一条命令都不跑(静默; 或整段调用失败)。
#     真实事故 2026-10-05: sculk_echo 的 clear_cry 是宏函数 {u0..u3}, 但
#     roll_triple / path_roll 调它时没传 with storage -> 「悲鸣」永远清不掉
#     (玩家只能看到"悲鸣不会自己消除")。
#     【合法的传参方式(任一即可)】
#       · function foo with storage <id> <path>   / with entity / with block
#       · function foo {a:1,b:"x"}                (行内复合标签, 包里最常用)
#       · run function 里的嵌套调用同样按这条判。
_macro_fns = set()
for fnk in functions:
    for ln in ftext(fnk).split('\n'):
        s = ln.strip()
        if s.startswith('#'):
            continue
        if macro_var.search(s):
            _macro_fns.add(fnk)
            break
if _macro_fns:
    for fnk, fp in functions.items():
        for i, ln in enumerate(ftext(fnk).split('\n'), 1):
            s = ln.strip()
            if s.startswith('#') or 'function' not in s:
                continue
            for m in fn_call.finditer(s):
                tgt = m.group(1)
                if tgt.startswith('#'):
                    continue
                ns = tgt.split(':')[0] if ':' in tgt else fnk.split(':')[0]
                full = tgt if ':' in tgt else ns + ':' + tgt
                if full not in _macro_fns:
                    continue
                tail = s[m.end():]
                # with storage/entity/block, 或行内复合标签 {...}
                if re.match(r'\s+with\s+(?:storage|entity|block)\b', tail):
                    continue
                if re.match(r'\s*\{', tail):
                    continue
                R['nowith'].append((str(fp), i, s[:100]
                                    + '  <- %s 是宏函数, 调用要么带 "with storage/entity/block", '
                                      '要么跟一个 {…} 复合标签' % full))

# 42) 弩(crossbow)的 post_attack 附魔必须有 damaging_entity 门控 ——
#     minecraft:post_attack 对"拿弩近战敲人"也会触发, 且此时
#     affected=attacker / victim 两边都照跑 => 近战会误触发整个技能
#     (不耗魔力 + 用上一发快照的层数)。判据:
#       弩(primary_items/supported_items = #minecraft:enchantable/crossbow)
#       的 post_attack 效果表里, 必须有一条 "affected":"damaging_entity"
#       (由它对应的 hook_arrow 判断"这一击是不是箭打的", hook_victim 再据此拦近战)。
#     真实事故 2026-10-05: 5 把弩(含寒鸦)近战敲人也触发, 花/层数全错。
_crossbow_post = False
for f in (ROOT / 'sweetdream' / 'data' / 'sweetdream' / 'enchantment').glob('*.json'):
    try:
        j = json.loads(f.read_text(encoding='utf-8'))
    except Exception:
        continue
    eff = (j.get('effects') or {}).get('minecraft:post_attack')
    if not eff:
        continue
    sup = j.get('supported_items') or j.get('primary_items') or ''
    if 'crossbow' not in str(sup):
        continue
    aff = {e.get('affected') for e in eff if isinstance(e, dict)}
    if 'damaging_entity' not in aff:
        R['crossgate'].append((str(f.relative_to(ROOT).as_posix()),
                               '这是弩的 post_attack 附魔, 效果表里没有 "damaging_entity" 条目 '
                               '-> 拿弩近战敲人也会触发技能(不耗魔力 + 用上一发快照的层数)。'
                               '补一条 affected=damaging_entity 的 run_function(hook_arrow), '
                               'hook_victim 开头 "unless 有 _arr 标签 return 0" 拦掉近战'))

# 42b) 弩的"射击扣蓝"契约 —— 有 post_attack 附魔的弩必须有配套射击进度 + shot, 且真扣蓝。
#   真实事故 2026-10-12(用户实测): 「电弧」发射**不消耗魔力**。根因 = 它是唯一一把
#   **只有附魔回调**、没有"射击进度 / shot"的弩 —— 其余 5 把都是
#     advancement(shot_crossbow) -> rewards.function = equipment/bow/<id>/shot -> 扣蓝;
#   电弧 lore 上写着「魔力 30」却从来没扣过, 属"整整漏掉一环"的实现遗漏, 加载期零日志。
#   判据(以弩附魔 <id>.json 为锚, supported_items 含 crossbow):
#     ① advancement/equipment/bow/<id>.json 存在, 且 trigger = shot_crossbow;
#     ② 它的 rewards.function = sweetdream:equipment/bow/<id>/shot;
#     ③ 那个 shot 里调了 manacore:api/mana/consume(真的扣蓝)。
for f in (ROOT / 'sweetdream' / 'data' / 'sweetdream' / 'enchantment').glob('*.json'):
    try:
        j = json.loads(f.read_text(encoding='utf-8'))
    except Exception:
        continue
    eff = (j.get('effects') or {}).get('minecraft:post_attack')
    if not eff:
        continue
    sup = j.get('supported_items') or j.get('primary_items') or ''
    if 'crossbow' not in str(sup):
        continue
    cid = f.stem
    rel = f.relative_to(ROOT).as_posix()
    advf = (ROOT / 'sweetdream' / 'data' / 'sweetdream' / 'advancement' / 'equipment' / 'bow'
            / (cid + '.json'))
    shotf = (ROOT / 'sweetdream' / 'data' / 'sweetdream' / 'function' / 'equipment' / 'bow'
             / cid / 'shot.mcfunction')
    if not advf.exists():
        R['crossshot'].append((rel,
                               '弩附魔「%s」没有配套射击进度 equipment/bow/%s.json -> 没有 shot 就'
                               '永远不扣魔力(lore 写着「魔力 N」却从不扣; 2026-10-12 电弧事故)' % (cid, cid)))
        continue
    try:
        aj = json.loads(advf.read_text(encoding='utf-8'))
    except Exception as e:
        R['crossshot'].append((str(advf.relative_to(ROOT).as_posix()), '进度 JSON 解析失败: %s' % e))
        continue
    trig = {c.get('trigger') for c in (aj.get('criteria') or {}).values() if isinstance(c, dict)}
    rw = (aj.get('rewards') or {}).get('function')
    want_rw = 'sweetdream:equipment/bow/%s/shot' % cid
    if 'shot_crossbow' not in trig:
        R['crossshot'].append((str(advf.relative_to(ROOT).as_posix()),
                               '射击进度的触发器必须是 shot_crossbow(现在: %s)' % (sorted(trig) or '无')))
    if rw != want_rw:
        R['crossshot'].append((str(advf.relative_to(ROOT).as_posix()),
                               '射击进度的 rewards.function 应为 %s(现在: %s)' % (want_rw, rw)))
    if not shotf.exists():
        R['crossshot'].append((str(shotf.relative_to(ROOT).as_posix()),
                               '弩的 shot 函数不存在 -> 射击不扣蓝'))
    else:
        # 只看**非注释行** —— 否则把 `function manacore:api/mana/consume` 注释掉
        # (行首加 #)时, 子串仍在, 规则会被"假满足"放过去。
        body = [l for l in shotf.read_text(encoding='utf-8').splitlines()
                if l.strip() and not l.strip().startswith('#')]
        if not any('manacore:api/mana/consume' in l for l in body):
            R['crossshot'].append((str(shotf.relative_to(ROOT).as_posix()),
                                   'shot 里没有调用 manacore:api/mana/consume -> 射击不消耗魔力'
                                   '(2026-10-12 电弧事故)'))

# 42c) 升级字段的"减旧/加回成对 + 累加器归零"契约 (2026-10-12 批 9 神经衰弱)
#   背景: bonus_take 的"同系取最高 tier"靠三段 ①减旧贡献 ②整条换进桶 ③加回新贡献。
#   给一个新数值字段(如 aspd)时, 必须同时做两件事:
#     (a) 在 ①③ 两段**各恰好**出现一次 —— 少一遍就静默算错: 只加不减 -> 反复换高阶时
#         旧值减不掉(越加越多); 只减不加 -> 敲上去反而变弱;
#     (b) bonus_held / bonus_armor 里把它的累加器 `#up_<x>` 归零 —— 不归零则每调用
#         一次就攒一次, 数值无限增长(武器向的 bonus_held 每秒跑一次, 秒秒变大)。
#   这两类加载期都**零日志**。真源 = bonus_take 里 `data get storage zx:work
#   up_val."$(series)".<field>` 这一句(字段是它说了算, 不是注释/文档), 累加器取紧随
#   其后那行的 `scoreboard players operation #up_<acc> …`。
_bt = functions.get('sweetdream:upgrade/api/bonus_take')
if _bt is not None:
    # 只看**非注释行** —— 否则把某段(比如 ① 的 -= )注释掉时子串仍在, 规则会被"假满足"。
    _bt_lines = [l for l in _bt.read_text(encoding='utf-8').splitlines()
                 if l.strip() and not l.lstrip().startswith('#')]
    _re_get = re.compile(r'data\s+get\s+storage\s+zx:work\s+up_val\."\$\(series\)"\.([\w.]+)')
    _re_op = re.compile(r'scoreboard\s+players\s+operation\s+#up_(\w+)\s+zx\.meta\s+(-=|\+=)\s+#up_o\s+zx\.meta')
    _f_cnt = {}       # field -> {'-=': n, '+=': n}  (只收"配得上累加器"的字段)
    _acc_of = {}      # 累加器名 -> 字段
    for _i, _l in enumerate(_bt_lines):
        _mg = _re_get.search(_l)
        if not _mg:
            continue
        _fd = _mg.group(1)
        # 紧跟其后那行必须是 `scoreboard players operation #up_<acc> … #up_o`;
        # 没有(如 `tier` 这种只用来比较、不进账本的字段) => 不是"数值贡献字段", 跳过。
        for _j in (_i + 1, _i + 2):
            if _j >= len(_bt_lines):
                break
            _mo = _re_op.search(_bt_lines[_j])
            if _mo:
                _f_cnt.setdefault(_fd, {'-=': 0, '+=': 0})[_mo.group(2)] += 1
                _acc_of[_mo.group(1)] = _fd
                break
    _rel_bt = _bt.relative_to(ROOT).as_posix()
    for _fd in sorted(_f_cnt):
        _c = _f_cnt[_fd]
        if _c['-='] != 1 or _c['+='] != 1:
            R['upfield'].append((_rel_bt,
                                 '升级字段 "%s" 的"减旧/加回"不成对(现在 -=%d / +=%d, 各要 1) '
                                 '-> 同系换高阶时账本算错(静默, 无日志)'
                                 % (_fd, _c['-='], _c['+='])))
    _bh = functions.get('sweetdream:upgrade/api/bonus_held')
    if _bh is not None:
        _t = '\n'.join(l for l in _bh.read_text(encoding='utf-8').splitlines()
                       if l.strip() and not l.lstrip().startswith('#'))
        for _acc in sorted(_acc_of):
            if not re.search(r'scoreboard\s+players\s+set\s+#up_%s\s+zx\.meta\s+0'
                             % re.escape(_acc), _t):
                R['upfield'].append((_bh.relative_to(ROOT).as_posix(),
                                     'bonus_take 会累加 #up_%s(字段 %s), 但 bonus_held 没把它归零 '
                                     '-> 每调用一次攒一次, 数值无限增长(静默)'
                                     % (_acc, _acc_of[_acc])))
    _ba = functions.get('sweetdream:upgrade/api/bonus_armor')
    if _ba is not None:
        _t = '\n'.join(l for l in _ba.read_text(encoding='utf-8').splitlines()
                       if l.strip() and not l.lstrip().startswith('#'))
        _outs = set(re.findall(r'run\s+scoreboard\s+players\s+get\s+#up_(\w+)', _t))
        _zero = set(re.findall(r'scoreboard\s+players\s+set\s+#up_(\w+)\s+zx\.meta\s+0', _t))
        for _acc in sorted(_outs - _zero):
            R['upfield'].append((_ba.relative_to(ROOT).as_posix(),
                                 'bonus_armor 输出了 #up_%s 却没在开头归零 -> 残留上一件盔甲的值(静默)'
                                 % _acc))

# 进度 / JSON / 资源包
self_rev = {}   # 自撤销型进度 -> 其奖励函数(判据同 5): 奖励函数首行 revoke 自己那条
for pack in PACKS:
    for nsdir in (ROOT / pack / 'data').iterdir():
        if not nsdir.is_dir():
            continue
        for f in (nsdir / 'advancement').rglob('*.json') if (nsdir / 'advancement').exists() else []:
            try:
                j = json.loads(f.read_text(encoding='utf-8'))
            except Exception as e:
                R['json'].append((str(f), str(e))); continue
            rw = (j.get('rewards') or {}).get('function')
            if not rw:
                continue
            key = f"{nsdir.name}:{f.relative_to(nsdir/'advancement').as_posix()[:-5]}"
            if rw not in functions:
                R['adv'].append((key, '奖励函数不存在 ' + rw)); continue
            body = [l.strip() for l in functions[rw].read_text(encoding='utf-8').split('\n') if l.strip() and not l.strip().startswith('#')]
            m = re.match(r'advancement\s+revoke\s+@s\s+only\s+([\w:.\-/]+)', body[0] if body else '')
            if not (m and m.group(1) == key):
                R['adv'].append((key, '首行未 revoke 自己 -> %s' % (body[0][:60] if body else '(空)')))
            else:
                self_rev[key] = rw

# ---- 27) 一次性进度的"防卡死"契约 ----
#   背景(2026-10-04 真实事故): 一次性进度靠奖励函数自己 revoke 才能再次触发;
#   奖励函数一旦被整段跳过(该刻命令预算 65536 打满), revoke 就不执行, 进度永久卡在
#   "已授予" -> 对应效果静默失效, 一个字都不报。当时 upgrade/attack 被卡住,
#   魔力增殖 α/β/Ω 的攻击回魔全死, 玩家只看到"升级突然没用了"。
#   (a) 所有自撤销型进度都必须被 lib/rearm 覆盖(每刻兜底撤销一遍);
#   (b) 任何函数里 advancement revoke 都不能排在 return 之后(那个分支永远走不到)。
rearm_f = functions.get('sweetdream:lib/rearm')
if rearm_f is None:
    R['rearm'].append(('(缺少 sweetdream:lib/rearm)',
                       '安全网函数不存在 -> 任何一次性进度一旦被预算截断就永久卡死'))
else:
    listed = {}
    for i, l in enumerate(rearm_f.read_text(encoding='utf-8').splitlines(), 1):
        s = l.strip()
        if not s or s.startswith('#'):
            continue
        m = re.match(r'advancement\s+revoke\s+@a\s+only\s+([\w:.\-/]+)', s)
        if not m:
            R['rearm'].append((str(rearm_f), '第 %d 行不是标准的 revoke 行: %s' % (i, s[:70])))
            continue
        listed.setdefault(m.group(1), i)
    for k in sorted(set(self_rev) - set(listed)):
        R['rearm'].append((str(rearm_f),
                           '自撤销型进度 %s 没列进 rearm -> 奖励函数被跳过一次就永久卡死(静默), '
                           '奖励函数 %s' % (k, self_rev[k])))
    for k in sorted(set(listed) - set(self_rev)):
        R['rearm'].append((str(rearm_f),
                           '%s 列在 rearm 里, 但它不是自撤销型进度(多半写错了, 确认后可删)' % k))
    # 光有清单没人调用也没用 —— 必须挂在 core/tick 上(每刻)
    if not re.search(r'function\s+sweetdream:lib/rearm\b',
                     (ROOT / 'sweetdream' / 'data' / 'sweetdream' / 'function'
                      / 'core' / 'tick.mcfunction').read_text(encoding='utf-8')
                     if (ROOT / 'sweetdream' / 'data' / 'sweetdream' / 'function'
                         / 'core' / 'tick.mcfunction').exists() else ''):
        R['rearm'].append((str(rearm_f), '没有任何地方调用它 -> 必须挂到 core/tick(每刻)'))

# ---- 28) operation 里用的"数字常数假玩家"必须被 set 过 ----
#   `scoreboard players operation #a zx.meta /= #20 zx.meta` 里如果 #20 从没被 set,
#   它的值就是 0 -> **除以 0** -> 命令报错并**中断整个函数**(那一行之后全不跑)。
#   现象极具误导性, 而且不一定写日志(真实案例: 焚舟的 #20/#30 —— 表现是"烈空在涨,
#   但上限不加、buff 也不倒计时")。
#   只查纯数字名的假玩家(#100 / #5000 这类, 本项目约定了这个写法); #up_pct 那种
#   变量是用 `store result score` 赋值的, 不能按"必须 set"来要求。
const_set, const_used = set(), []
for fnk, fp in functions.items():
    for i, l in enumerate(fp.read_text(encoding='utf-8', errors='ignore').split('\n'), 1):
        s = l.strip()
        if not s or s.startswith('#'):
            continue
        nq = re.sub(r'"[^"]*"', '""', s)
        for m in re.finditer(r'scoreboard players set (#[0-9]+)\s', nq):
            const_set.add(m.group(1))
        if 'scoreboard players operation' in nq:
            for m in re.finditer(r'#[0-9]+\b', nq):
                const_used.append((str(fp), i, m.group(0), s))
for fp, i, c, s in const_used:
    if c not in const_set:
        R['const'].append((fp, '第 %d 行用了常数假玩家 %s, 但全包没有任何地方 set 它 -> '
                               '它的值是 0, 一旦参与 /= 会除以 0 并中断整个函数: %s'
                           % (i, c, s[:80])))

# ---- 29) 装备被动"漏判穿着" ----
#   装备逻辑被 `execute as @a`(无 tag/score 过滤)**广播**调用时, 函数体内必须自己
#   先判"穿没穿" —— 否则**没穿也生效**。这类错误不报错、不影响别人, 玩家只能靠手感发现。
#   真实事故 2026-10-04: dusk_dawn/second 第 14 行 `execute as @a at @s run function
#   .../low_mana`, 而 low_mana 直接读魔力就回 20 -> 脱掉「黄昏黎明之交界」,
#   魔力低于一半照样每秒涨 20(玩家: "不论有没有穿上都会触发被动效果")。
#   判据刻意收窄: 只查"调用点完全没有任何过滤 + 目标是 sweetdream:equipment/*"。
#   (liaoyuan/second_one 那种由 `@a[scores={zx.ly_aura=1..}]` 门控的不会被误伤。)
#   确实不需要判装备的(比如把手部动画帧号复位), 在调用行上方写
#   `# no-equip-check-ok: 理由` 豁免。
noequip = re.compile(r'\bexecute\s+as\s+@a(?![\[a-zA-Z0-9_])'
                     r'(?:\s+at\s+@[a-z])?\s+run\s+function\s+([\w:.\-/]+)')
for fnk in functions:
    pend = False
    for i, line in enumerate(ftext(fnk).split('\n'), 1):
        s = line.strip()
        if not s:
            pend = False
            continue
        if s.startswith('#'):
            if 'no-equip-check-ok' in s:
                pend = True
            continue
        m = noequip.search(re.sub(r'"[^"]*"', '""', s))
        if m:
            tgt = m.group(1)
            if ':' not in tgt:
                tgt = fnk.split(':')[0] + ':' + tgt
            if tgt.startswith('sweetdream:equipment/') and tgt in functions:
                # 判"穿没穿"用 if 或 unless 都算(unless ... run return 0 是常见写法)
                if not pend and 'items entity @s' not in ftext(tgt):
                    R['equip'].append((
                        str(functions[fnk]),
                        '第 %d 行 以 @a 广播调用 %s, 但那个函数体内没有 "items entity @s" '
                        '-> 没穿也生效(静默): %s' % (i, tgt, s[:80])))
        pend = False

# ---- 31) 消耗标签链上的装备被动必须自带装备门控 ----
#   lib/mark_take 用 `as $(by)` 把执行者换成"消耗者"再调装备被动 —— 调用方**不会**
#   替它判"他穿没穿"。这类函数"没穿也生效"的代价比 equip 规则那条更狠: 不只是白拿
#   收益, 还会**白扣魔力**。
#   真实事故 2026-10-06: eternity/reclaim 与 lib/mark_ember 初版都漏了门控 ⇒ 任何
#   魔力 > 50 的玩家消耗标签都被扣 50 蓝并把标签刷回 / 白拿 50·100 魔力 + 力量。
#   判据: mark_take 里 `run function <X>` 的每个 X, 函数体必须含 "items entity @s";
#   确实不需要的(公共件如 tag/unmark) 在调用行**正上方**写 `# no-equip-check-ok: 理由` 豁免。
_MT = 'sweetdream:lib/mark_take'
if _MT in functions:
    _mtcall = re.compile(r'run\s+function\s+([\w:.\-/]+)')
    _mtpend = False
    for _i, _line in enumerate(ftext(_MT).split('\n'), 1):
        _s = _line.strip()
        if not _s:
            _mtpend = False
            continue
        if _s.startswith('#'):
            if 'no-equip-check-ok' in _s:
                _mtpend = True
            continue
        _m = _mtcall.search(re.sub(r'"[^"]*"', '""', _s))
        if _m:
            _t = _m.group(1)
            if ':' not in _t:
                _t = 'sweetdream:' + _t
            if _t in functions and not _mtpend and 'items entity @s' not in ftext(_t):
                R['equipgate'].append((
                    str(functions[_MT]),
                    '第 %d 行 调 %s, 但那个函数体内没有 "items entity @s" —— 它被 '
                    'as $(by) 换身份调用, 调用方不会替它判穿着 -> 没穿的人也生效/被白扣(静默): %s'
                    % (_i, _t, _s[:70])))
        _mtpend = False

# ---- 30) "只平A"契约 ----
#   攻击回魔的进度 upgrade/attack 必须把伤害类型限定成玩家近战
#   (原版标签 minecraft:is_player_attack = [player_attack, mace_smash])。
#   不写这条条件时, **技能伤害也算数** —— 本包所有技能伤害都是 sweetdream:skill 类型
#   (api/damage 的默认 type, 见 zx:config damage_type), 于是"放个技能顺手把魔力回满"
#   (2026-10-04 玩家反馈, 已修)。写条件用的是原版 damage 谓词, 格式取自原版
#   adventure/overoverkill.json: conditions.damage.type.tags=[{id,expected}]。
#   想让别的"攻击命中"效果也只认平A, 往这张表里加一条即可。
MELEE_ONLY = {
    'sweetdream:upgrade/attack': 'minecraft:is_player_attack',        # 魔力增殖: 攻击回魔
    'sweetdream:equipment/armor/mirage_attack': 'minecraft:is_player_attack',    # 幻昼: 铺白昼梦
    'sweetdream:equipment/armor/immolate_hurt': 'minecraft:is_player_attack',    # 焚舟: 攒/泄烈空
    'sweetdream:equipment/axe/charge_hit': 'minecraft:is_player_attack',         # 超载: 命中追加闪电
    'sweetdream:equipment/armor/brain_leech_attack': 'minecraft:is_player_attack',  # 超限·脑髓蛭: 攻击叠「蛊虫」
    'sweetdream:equipment/armor/mirage_hit_dream': 'minecraft:is_player_attack',    # 幻昼: 攻击带「白昼梦」生物 +2
}
for pack in PACKS:
    for nsdir in (ROOT / pack / 'data').iterdir():
        if not nsdir.is_dir():
            continue
        adir = nsdir / 'advancement'
        if not adir.exists():
            continue
        for f in adir.rglob('*.json'):
            key = f"{nsdir.name}:{f.relative_to(adir).as_posix()[:-5]}"
            want = MELEE_ONLY.get(key)
            if not want:
                continue
            try:
                j = json.loads(f.read_text(encoding='utf-8'))
            except Exception:
                continue
            got = []
            for crit in (j.get('criteria') or {}).values():
                dmg = ((crit.get('conditions') or {}).get('damage') or {})
                for t in (((dmg.get('type') or {}).get('tags')) or []):
                    if isinstance(t, dict):
                        got.append((t.get('id'), t.get('expected')))
            if (want, True) not in got:
                R['melee'].append((
                    str(f), '没有限定 damage 条件 %s=true -> 技能伤害(sweetdream:skill)也会'
                            '触发, 变成"放技能就回魔"。当前 tags=%s' % (want, got)))

# ---- 31) 物品描述的版式契约 ----
#   包里所有物品描述统一成"横刀 / 流光"那套(数字两侧留白、乘号写 ×、等级写罗马
#   数字、按 37 半角宽折行), 规范器在 .workbuddy/lore_fmt.py。
#   判据很硬: 文件里那段 lore 必须**逐字等于**规范器的输出 —— 手改过、写过
#   旧写法(`*0.1` / `迅捷3` / `上限+200`)、或者忘了重排, 都会在这里冒出来。
#   修法就是跑一次 python .workbuddy/lore_fmt.py --write。
try:
    import importlib.util as _ilu
    _spec = _ilu.spec_from_file_location('lore_fmt', str(ROOT / '.workbuddy' / 'lore_fmt.py'))
    LF = _ilu.module_from_spec(_spec)
    _spec.loader.exec_module(LF)
except Exception as _e:            # 规范器不在就算了, 不影响其余检查
    LF = None

if LF is not None:
    for pack in PACKS:
        for f in (ROOT / pack / 'data').rglob('*.mcfunction'):
            try:
                src = f.read_text(encoding='utf-8')
            except Exception:
                continue
            try:
                new, n = LF.patch_text(src)
            except Exception as e:
                R['lorestyle'].append((str(f), 'lore 解析失败(整段会被当成字符串): %s' % e))
                continue
            if n and new != src:
                msg = 'lore 不是 lore_fmt 的输出 -> 跑 .workbuddy/lore_fmt.py --write'
                ob, nb = src.split('lore', 1)[1], new.split('lore', 1)[1]
                for i, (a, b) in enumerate(zip(ob.split(','), nb.split(',')), 1):
                    if a != b:
                        msg += ' | 首个差异: %s -> %s' % (a[:48], b[:48])
                        break
                R['lorestyle'].append((str(f), msg))

ret_only = re.compile(r'(?:^|\brun\s+)return\b')
for fnk, fp in functions.items():
    first_ret = None
    for i, line in enumerate(fp.read_text(encoding='utf-8', errors='ignore').split('\n'), 1):
        s = line.strip()
        if not s or s.startswith('#'):
            continue
        # 先把字符串字面量挖空, 免得 tellraw 文案里的 "return" 被当成真的 return
        nq = re.sub(r'"[^"]*"', '""', s)
        nq = re.sub(r"'[^']*'", "''", nq)
        if first_ret is None and ret_only.search(nq):
            first_ret = i
        if first_ret is not None and i > first_ret and re.search(r'\badvancement\s+revoke\b', nq):
            R['rearm'].append((str(fp),
                               '第 %d 行的 advancement revoke 排在 return(第 %d 行)之后 -> '
                               '走那个分支时永远撤不掉, 进度会永久卡住(静默)'
                               % (i, first_ret)))

# 完整版可独立增加物品；覆盖层可以引用基底，索引应涵盖所有本项目资源包。
RP_DIRS = sorted(p for p in ROOT.glob('sweetdream_rp*') if (p / 'assets').is_dir())
for base in [ROOT / p for p in PACKS] + RP_DIRS:
    if not base.exists():
        continue
    for f in base.rglob('*.json'):
        try:
            json.loads(f.read_text(encoding='utf-8'))
        except Exception as e:
            R['json'].append((str(f), str(e)))

rp_models, rp_items = set(), set()
for pack in RP_DIRS:
    for ns in (pack / 'assets').iterdir():
        if not ns.is_dir():
            continue
        for sub, tgt in (('models', rp_models), ('items', rp_items)):
            p = ns / sub
            if p.exists():
                for f in p.rglob('*.json'):
                    tgt.add(f"{ns.name}:{f.relative_to(p).as_posix()[:-5]}")
for pack, f in [(pack, f) for pack in RP_DIRS for f in (pack / 'assets').rglob('*.json')]:
    t = f.read_text(encoding='utf-8', errors='ignore')
    for m in model_ref.finditer(t):
        ref = m.group(1)
        pre = ref.split(':')[0] if ':' in ref else f.relative_to(pack / 'assets').parts[0]
        # minecraft: 命名空间的模型由本体 jar 提供, 资源包里当然没有 —— 跳过, 否则全是误报
        if pre == 'minecraft':
            continue
        if f"{pre}:{ref.split(':')[-1]}" not in rp_models:
            R['rp'].append(('RP ' + str(f), ref))
for f in (ROOT / 'sweetdream' / 'data').rglob('*.mcfunction'):
    # ★ 只看**正文**: 注释行里的 `item_model="ns:<id>"` 是**占位说明**, 不是真引用。
    #   2026-10-10 假阳性事故: visual/sword_icon_held 的头注释写了
    #   `item_model="sweetdream:<id>"` 当占位符, 被这条规则读成 id = "sweetdream:" ⇒
    #   报一条"模型引用缺失", 全量自检从 0 变 1。注释不参与加载, 一律跳过。
    _txt = '\n'.join(l for l in f.read_text(encoding='utf-8', errors='ignore').split('\n')
                     if not l.lstrip().startswith('#'))
    for m in re.finditer(r'item_model="?([a-z0-9_:.]+)', _txt):
        if m.group(1) not in rp_items:
            R['rp'].append(('DP ' + str(f), m.group(1)))

# ---- 76) modelrot: 资源包模型元素不合法 —— 整份模型加载失败, 游戏里只能看到"紫黑方块" ----
#   ★★ MC 1.21.5 的元素 `rotation.angle` **只接受 -45 / -22.5 / 0 / 22.5 / 45 五个离散值**,
#      不是"±45 以内任意值"。越界 -> `Invalid rotation X found, only ... allowed` ->
#      **整份模型 Failed to load** -> missing model -> 玩家看到的是一坨紫黑方块(与"贴图丢了"
#      长得几乎一样, 但其实是整个模型没加载)。
#   真实事故 2026-10-08: domain.json 写了 60/120/180/240/300(想"每 60° 摆一片符文"),
#      meteor_rock.json 写了 22/14/38/12/-20/-16(以为 ±45 以内随便写) —— 陨石与领域
#      两个 item_display 在游戏里都是紫黑方块, 而 check.py 当时 **0 报告**
#      (模型路径存在、贴图也存在, 只有离线跑一次游戏才看得出来)。
#   连带看: ② from 必须严格小于 to(退化的元素会被静默丢弃)、③ 取值域 [-16,32]、
#   ④ uv 必须是 4 个数。
LEGAL_ROT = {-45.0, -22.5, 0.0, 22.5, 45.0}
for ns in ((RP / 'assets').iterdir() if RP else []):
    if not ns.is_dir() or not (ns / 'models').exists():
        continue
    for f in (ns / 'models').rglob('*.json'):
        try:
            _j = json.loads(f.read_text(encoding='utf-8'))
        except Exception:
            continue                      # JSON 坏了由 R['json'] 报
        for _i, _el in enumerate((_j or {}).get('elements') or []):
            # MC 1.21.5 gsu$a rejects {} with
            # "Expected between 1 and 6 unique faces, got 0".
            # Removing hidden faces must remove the whole empty element.
            _faces = _el.get('faces')
            if not isinstance(_faces, dict) or not (1 <= len(_faces) <= 6):
                R['modelrot'].append(('%s' % f, '第 %d 个元素 faces 必须包含 1–6 个面；'
                                      '空面元素会让整份模型加载失败' % _i))
            elif not set(_faces).issubset({'north', 'south', 'east', 'west', 'up', 'down'}):
                R['modelrot'].append(('%s' % f, '第 %d 个元素含非法面方向' % _i))
            _frm, _to = _el.get('from'), _el.get('to')
            if not (isinstance(_frm, list) and isinstance(_to, list)
                    and len(_frm) == 3 and len(_to) == 3):
                R['modelrot'].append(('%s' % f, '第 %d 个元素 from/to 不是三元组' % _i))
                continue
            if not all(_frm[k] < _to[k] for k in range(3)):
                R['modelrot'].append(('%s' % f, '第 %d 个元素 from %s 不严格小于 to %s '
                                      '-> 该元素被静默丢弃(正体积)' % (_i, _frm, _to)))
            _out = [v for v in list(_frm) + list(_to) if v < -16 or v > 32]
            if _out:
                R['modelrot'].append(('%s' % f, '第 %d 个元素 from/to 越界 %s(须在 [-16,32])'
                                      % (_i, _out)))
            _rot = _el.get('rotation')
            if _rot is not None and _rot.get('angle') not in LEGAL_ROT:
                R['modelrot'].append(('%s' % f, '第 %d 个元素 rotation.angle=%s —— 只接受 '
                                      '-45/-22.5/0/22.5/45, 越界会让**整份模型加载失败**'
                                      '(游戏里是紫黑方块)' % (_i, _rot.get('angle'))))
            for _fn, _fd in (_el.get('faces') or {}).items():
                _uv = _fd.get('uv')
                if _uv is not None and (len(_uv) != 4
                                        or any(v < 0 or v > 16 for v in _uv)):
                    R['modelrot'].append(('%s' % f, '第 %d 个元素 %s 面的 uv=%s 非法'
                                          '(须 4 个数、都在 0..16)' % (_i, _fn, _uv)))

# 15) 物品定义按 custom_model_data 逐帧切换 / 被数据包 item_modify 驱动,
#     却没关 hand_animation_on_swap (见文件头)
# ★ 2026-10-10 补漏: 覆盖层资源包(sweetdream_rp_原版风)同样是**整份替换** items/<id>.json。
#   它内部是纯 minecraft:model、又不在 RP 目录下 ⇒ 旧版规则两条都沾不上, 连漏两次
#   (极光与幻梦、天使核心 都是"覆盖定义漏了字段 -> 在手上一直抽搐", 用户报了两回)。
#   改法: 先由数据包 item_modifier 反推出"被驱动的模型 id"集合, 再扫**每个**
#   sweetdream_rp* 资源包 —— 命中(id 被驱动, 或自己写了 custom_model_data)就必须带
#   "hand_animation_on_swap": false。且必须是 false, 只写字段名(或写 true)不算数。
RP_DIRS = sorted(p for p in ROOT.glob('sweetdream_rp*') if (p / 'assets').is_dir())
DRIVEN_MODELS = set()
_IM_MODEL = re.compile(r'"minecraft:item_model"\s*:\s*"([^"]+)"')
for _pk in PACKS:
    _d = ROOT / _pk / 'data'
    if not _d.exists():
        continue
    for f in _d.rglob('*.json'):
        if 'item_modifier' not in f.as_posix():
            continue
        DRIVEN_MODELS.update(_IM_MODEL.findall(f.read_text(encoding='utf-8', errors='ignore')))

for _rp in RP_DIRS:
    for ns in (_rp / 'assets').iterdir():
        if not ns.is_dir() or not (ns / 'items').exists():
            continue
        for f in (ns / 'items').rglob('*.json'):
            t = f.read_text(encoding='utf-8', errors='ignore')
            mid = '%s:%s' % (ns.name, f.relative_to(ns / 'items').as_posix()[:-5])
            driven = mid in DRIVEN_MODELS
            if not driven and 'custom_model_data' not in t:
                continue
            try:
                j = json.loads(t)
            except Exception:
                continue
            if not isinstance(j, dict) or j.get('hand_animation_on_swap') is not False:
                _why = ('数据包 item_modifier 每刻改写它的组件' if driven
                        else 'range_dispatch(custom_model_data) 逐帧切换')
                R['swap'].append(('%s  [%s]' % (f, _rp.name),
                                  '%s, 但没写 "hand_animation_on_swap": false -> '
                                  '每 tick 改组件会重放第一人称下落-抬起动画, 在手上一直抽搐' % _why))

# schedule 同名 (默认 replace)
seen = defaultdict(set)
for fnk, fp in functions.items():
    for line in fp.read_text(encoding='utf-8', errors='ignore').split('\n'):
        if 'schedule' in line and 'clear' not in line:
            m = re.search(r'schedule\s+function\s+([\w:.\-/]+)\s+\S+(\s+(append|replace))?', line)
            if m and (m.group(3) or 'replace') == 'replace':
                seen[m.group(1)].add(str(fp))
for k, v in seen.items():
    if len(v) > 1:
        R['sched'].append((k, '%d 处: %s' % (len(v), ', '.join(sorted(Path(x).as_posix() for x in v)))))

# ---- 17) ~ 19) 通用数值注册表(lib/reg/build) ----
#   这三条都是"表驱动"体系特有的坑: 表是**数据**, 写错了不报错, 只会静默少一行,
#   或者引用了根本没建过的计分项。所以只能静态比对。
regbuild = (ROOT / 'sweetdream' / 'data' / 'sweetdream' / 'function'
            / 'lib' / 'reg' / 'build.mcfunction')
if regbuild.exists():
    rtxt = regbuild.read_text(encoding='utf-8')
    rlines = [l for l in rtxt.split('\n') if not l.lstrip().startswith('#')]

    # 17) 表行数不能超过 cap; cap 还要和生成器脚本的常量一致
    mcap = re.search(r'cap set value \{b:(\d+),a:(\d+),menu:(\d+),layer:(\d+)\}', rtxt)
    if not mcap:
        R['regcap'].append((str(regbuild), '找不到 cap 行(gen_reg_unroll.py 靠它对齐槽数)'))
    else:
        cap = {'b': int(mcap.group(1)), 'a': int(mcap.group(2)),
               'menu': int(mcap.group(3)), 'layer': int(mcap.group(4))}
        cnt = {'b': 0, 'a': 0, 'menu': 0, 'layer': 0}
        for l in rlines:
            m = re.search(r'storage zx:reg ([ab]) append value', l)
            if m:
                cnt[m.group(1)] += 1
            if 'storage zx:reg menu append value' in l:
                cnt['menu'] += 1
            if 'storage zx:reg layer append value' in l:
                cnt['layer'] += 1
        for t in ('b', 'a', 'menu', 'layer'):
            if cnt[t] > cap[t]:
                R['regcap'].append((str(regbuild),
                                    '%s 表 %d 行 > cap %d —— 多出来的行不会被 reg_unroll 渲染'
                                    % (t, cnt[t], cap[t])))
        gen = ROOT / '.workbuddy' / 'gen_reg_unroll.py'
        if gen.exists():
            gt = gen.read_text(encoding='utf-8')
            for t, cn in (('b', 'CAP_B'), ('a', 'CAP_A'), ('menu', 'CAP_MENU'), ('layer', 'CAP_LAYER')):
                mg = re.search(r'^%s = (\d+)' % cn, gt, re.M)
                if mg and int(mg.group(1)) != cap[t]:
                    R['regcap'].append((str(gen), '%s=%s 与 build 的 cap.%s=%d 不一致'
                                        % (cn, mg.group(1), t, cap[t])))

    # 18) 表里引用的计分项必须真的被建出来过
    objs = set()
    for f in (ROOT / 'sweetdream' / 'data').rglob('*.mcfunction'):
        for m in re.finditer(r'objectives add (\S+)', f.read_text(encoding='utf-8', errors='ignore')):
            objs.add(m.group(1))
    for l in rlines:
        # b/a 表: {l:"...",o:"..."}; layer 表: {o:"...",l:"..."}(字段顺序不同)
        m = re.search(r'storage zx:reg [ab] append value \{l:"([^"]*)",o:"([^"]*)"', l)
        if m and m.group(2) not in objs:
            R['regobj'].append((str(regbuild), '%s -> 引用了没建过的计分项 %s'
                                % (m.group(1), m.group(2))))
        m2 = re.search(r'storage zx:reg layer append value \{o:"([^"]*)"', l)
        if m2 and m2.group(1) not in objs:
            R['regobj'].append((str(regbuild), 'layer 行 -> 引用了没建过的计分项 %s' % m2.group(1)))

    # 19) give 出去的装备 id 都该登记中文名(debug/worn 要用)
    names = set(re.findall(r'storage zx:reg names\.([A-Za-z_0-9]+) set value', rtxt))
    for f in (ROOT / 'sweetdream' / 'data').rglob('give.mcfunction'):
        for m in re.finditer(r'zx:\["([a-z_0-9]+)"', f.read_text(encoding='utf-8', errors='ignore')):
            if m.group(1) not in names:
                R['regname'].append((str(f), 'id "%s" 没登记 zx:reg names -> debug/worn 只会显示英文 id'
                                     % m.group(1)))

    # 23) b/a 表每一行都必须有 e 字段(属于哪件装备 / all 全局)
    #     漏写的行在 debug/stats 里**永远不显示, 而且不报错** —— 只能静态抓。
    #     e 的值必须是 names 里登记过的装备 id, 或 "all"。
    for l in rlines:
        m = re.search(r'storage zx:reg ([ab]) append value \{(.*)\}\s*$', l)
        if m:
            row = m.group(2)
            me = re.search(r',e:"([A-Za-z_0-9]+)"', row)
            lab = re.match(r'l:"([^"]*)"', row)
            lab = lab.group(1) if lab else '?'
            if not me:
                R['rege'].append((str(regbuild), '「%s」这行没有 e 字段 -> debug/stats 里永远不显示(静默)' % lab))
            elif me.group(1) != 'all' and me.group(1) not in names:
                R['rege'].append((str(regbuild), '「%s」的 e:"%s" 不是已登记的装备 id(也不该写 all) -> 这行永远不显示'
                                  % (lab, me.group(1))))
        # layer 表: 字段顺序 {o,l,c,e,n,max}; e 同样必须有(否则观测镜第二行永远不显示)
        ml = re.search(r'storage zx:reg layer append value \{(.*)\}\s*$', l)
        if ml:
            row = ml.group(1)
            me = re.search(r',e:"([A-Za-z_0-9]+)"', row)
            lab = re.search(r',l:"([^"]*)"', row)
            lab = lab.group(1) if lab else '?'
            if not me:
                R['rege'].append((str(regbuild), 'layer「%s」这行没有 e 字段 -> 观测镜第二行永远不显示(静默)' % lab))
            elif me.group(1) != 'all' and me.group(1) not in names:
                R['rege'].append((str(regbuild), 'layer「%s」的 e:"%s" 不是已登记的装备 id -> 这行永远不显示'
                                  % (lab, me.group(1))))

    # 32) "全局行"哨兵表(gsent)必须齐, 且渲染器必须认它
    #   e:"all" 的行(套装合计 / 回魔账本 / 升级合计)不属于单件装备, 不该显示装备名。
    #   渲染器靠 zx:reg gsent.<e> 区分"全局行"和"e 写错了":
    #     缺 gsent 表, 或 stat_row/stat_row_a 没写这个分支 ->
    #     所有 e:"all" 的行都会红着打 "all(没登记中文名!)"(假警报)。
    #   真实事故 2026-10-04: 静脉泵的"回魔 · 装备额外"那一行。
    gsent_keys = set()
    for blk in re.findall(r'storage zx:reg gsent set value \{([^}]*)\}', rtxt):
        gsent_keys |= set(re.findall(r'([A-Za-z_0-9]+)\s*:', blk))
    if not gsent_keys:
        R['regsent'].append((str(regbuild),
                             '没有 zx:reg gsent 哨兵表 -> 所有 e:"all" 的行都会打 "(没登记中文名!)"'))
    for l in rlines:
        m = re.search(r'storage zx:reg ([ab]) append value \{(.*)\}\s*$', l)
        if not m:
            continue
        me = re.search(r',e:"([A-Za-z_0-9]+)"', m.group(2))
        ml = re.match(r'l:"([^"]*)"', m.group(2))
        lab = ml.group(1) if ml else '?'
        if me and me.group(1) not in names and me.group(1) not in gsent_keys:
            R['regsent'].append((str(regbuild),
                                 '「%s」的 e:"%s" 既不在 names 也不在 gsent -> stats 里会打红字'
                                 ' "(没登记中文名!)"(e 写错了, 或该进 gsent 的全局行漏了)'
                                 % (lab, me.group(1))))
    for fn in ('stat_row', 'stat_row_a'):
        fp = (ROOT / 'sweetdream' / 'data' / 'sweetdream' / 'function' / 'debug'
              / (fn + '.mcfunction'))
        if not fp.exists():
            R['regsent'].append((str(fp), '找不到 %s.mcfunction' % fn))
        elif 'if data storage zx:reg gsent.$(e) run tellraw' not in fp.read_text(encoding='utf-8',
                                                                               errors='ignore'):
            R['regsent'].append((str(fp),
                                 '没有认 gsent 哨兵的分支(缺 "if data storage zx:reg '
                                 'gsent.$(e) run tellraw") -> 所有 e:"all" 的行会打 '
                                 '"(没登记中文名!)"(假警报)'))

    # 24) 造型类组件的 NBT 必须带类型后缀: custom_model_data={floats:[2]} 是**整型列表**,
    #     而 component 的 floats 是 Float 列表 -> codec 拒收, 物品直接 missing texture。
    #     必须写 {floats:[2.0f]} / {floats:2f}。
    for f in (ROOT / 'sweetdream' / 'data').rglob('*.mcfunction'):
        for i, l in enumerate(f.read_text(encoding='utf-8', errors='ignore').splitlines(), 1):
            if l.lstrip().startswith('#'):
                continue
            for m in re.finditer(r'custom_model_data=\{\s*floats:\s*\[([^\]]*)\]', l):
                inner = m.group(1)
                badt = [t.strip() for t in inner.split(',')
                        if t.strip() and not t.strip()[-1] in 'fF']
                if badt:
                    R['floatz'].append((str(f), '第 %d 行 custom_model_data 的 floats 里 %s 缺 f 后缀 '
                                               '-> component 的 floats 是 Float 列表, 给整型会丢模型'
                                       % (i, badt)))

    # 25) 强化材料 / 一次性道具的底座不能是"会被合成吃掉的"物品。
    #     这条是踩过两次才立的: nether_star(信标) -> *_smithing_template(锻造台)。
    #     选底座第一原则: 它不是任何配方的被消耗者。追溯指针只有"被造出来"这一个方向。
    BAD_BASE = {
        'nether_star': '信标',
        'amethyst_shard': '紫水晶相关合成',
        'echo_shard': '追溯指针',
        'prismarine_crystals': '海晶灯', 'prismarine_shard': '海晶系列方块',
        'heart_of_the_sea': '潮涌核心',
        'netherite_scrap': '下界合金锭',
        'diamond': '钻石套/工具', 'emerald': '绿宝石块', 'gold_ingot': '金锭系列',
        'iron_ingot': '铁锭系列', 'lapis_lazuli': '青金石块',
    }
    for d in ('upgrade/item', 'overlimit/item'):
        for f in (ROOT / 'sweetdream' / 'data' / 'sweetdream' / 'function' / d).rglob('*.mcfunction'):
            t = f.read_text(encoding='utf-8', errors='ignore')
            for m in re.finditer(r'^\s*give @s ([a-z_]+)', t, re.M):
                base = m.group(1)
                if base.endswith('_smithing_template'):
                    R['base'].append((str(f), '底座 %s 是锻造模板 -> 原版会在 tooltip 追加锻造介绍(改不掉), '
                                              '而且它本身在锻造台会被消耗' % base))
                elif base in BAD_BASE:
                    R['base'].append((str(f), '底座 %s 会被合成吃掉(%s) -> 玩家会把它用掉' % (base, BAD_BASE[base])))

# ---- 26) 超限定义表(oldef)必须把 name / label / lore 写全 ----
#   这几个字段都是**数据**, 写漏了不报错, 只能靠静态抓:
#     · 漏 name  -> 敲完超限物品**名字不变**(还叫「流光」), 玩家根本看不出这是超限版;
#     · 漏 lore  -> lore_seed 把它清成一个空列表, 物品变成"没有描述"的东西(比不改还糟);
#     · name.text 与 label 不一致 -> 名字和文档 / 提示对不上。
overdef = (ROOT / 'sweetdream' / 'data' / 'sweetdream' / 'function'
           / 'overlimit' / 'def' / 'load.mcfunction')
if overdef.exists():
    for i, l in enumerate(overdef.read_text(encoding='utf-8', errors='ignore').splitlines(), 1):
        if l.lstrip().startswith('#') or 'oldef.' not in l or ' set value ' not in l:
            continue
        mid = re.search(r'oldef\."([^"]+)"', l)
        who = mid.group(1) if mid else '?'
        lab = re.search(r'label:"([^"]*)"', l)
        nm = re.search(r'name:\{"text":"([^"]*)"', l)
        if not lab:
            R['oldname'].append((str(overdef), '第 %d 行 超限 "%s" 没有 label' % (i, who)))
        if not nm:
            R['oldname'].append((str(overdef),
                                 '第 %d 行 超限 "%s" 没有 name -> 敲完不改名(静默)' % (i, who)))
        elif lab and nm.group(1) != lab.group(1):
            R['oldname'].append((str(overdef), '第 %d 行 超限 "%s" 的 name.text(%s) 与 label(%s) 不一致'
                                 % (i, who, nm.group(1), lab.group(1))))
        # ★ 2026-10-10 新增: 超限名的**颜色**必须 = 该装备本名的颜色。
        #   用户要求"超限后保留原来的装备颜色, 不要统一成一个色" —— 原实现 19 条全写
        #   light_purple, 敲完超限一屋子装备全长一个紫色, 分不清手里是哪把。
        #   本名颜色的真源 = equipment/**/<id>/give.mcfunction 的 item_name.color。
        #   (改色跑 `python .workbuddy/_fix_oldef_colors.py`, 别手改。)
        Q = chr(34)
        nmc = re.search(r'name:\{' + Q + 'text' + Q + ':' + Q + '[^' + Q + ']*' + Q
                        + ',' + Q + 'bold' + Q + ':true,' + Q + 'color' + Q + ':'
                        + Q + '?([a-z_]+)' + Q + '?\}', l)
        if nmc:
            _eqroot = (ROOT / 'sweetdream' / 'data' / 'sweetdream' / 'function'
                       / 'equipment')
            _gives = sorted(_eqroot.glob('**/%s/give.mcfunction' % who))
            if not _gives:
                R['oldname'].append((str(overdef),
                                     '第 %d 行 超限 "%s" 找不到 equipment/**/%s/give.mcfunction, '
                                     '没法核对本名颜色' % (i, who, who)))
            else:
                _gtxt = _gives[0].read_text(encoding='utf-8', errors='ignore')
                _gm = re.search(r'item_name=\{text:' + Q + '[^' + Q + ']*' + Q
                                + ',bold:true,color:' + Q + '?([a-z_]+)' + Q + '?\}', _gtxt)
                if not _gm:
                    R['oldname'].append((str(overdef),
                                         '第 %d 行 超限 "%s": %s 里找不到 item_name 的颜色'
                                         % (i, who, _gives[0].name)))
                elif _gm.group(1) != nmc.group(1):
                    R['oldname'].append((str(overdef),
                                         '第 %d 行 超限 "%s" 的 name.color(%s) 与该装备本名颜色(%s) 不一致 '
                                         '—— 超限后要沿用原装备颜色(改色跑 _fix_oldef_colors.py)'
                                         % (i, who, nmc.group(1), _gm.group(1))))
        if 'lore:[' not in l:
            R['oldname'].append((str(overdef),
                                 '第 %d 行 超限 "%s" 没有 lore -> 描述会被整段清空' % (i, who)))

# ---- 26b) 弩的 give 必须显式关掉附魔光效 ----
#   2026-10-10 用户: "我希望弩的附魔不显示光效"。6 把弩为了拿到"命中生物"的
#   post_attack 回调, 物品上必须挂附魔(enchantments={...}); 而附魔会让物品自带
#   紫色 shimmer(enchantment glint)。想不闪只能显式写
#   `enchantment_glint_override=false`(1.21.5 里这个组件是 **boolean**)。
#   漏了不报错 —— 只是玩家手里那把弩一直在闪紫光, 而且再 /give 一百次都不会变。
for k in sorted(functions):
    for i, l in enumerate(ftext(k).splitlines(), 1):
        if l.lstrip().startswith('#'):
            continue
        if ('give @s crossbow[' in l and 'enchantments=' in l
                and 'enchantment_glint_override=false' not in l):
            R['glint'].append(
                (functions[k],
                 '第 %d 行 弩的 give 带了附魔却没关光效 —— 补上 '
                 'enchantment_glint_override=false(否则物品一直闪紫光, 静默)' % i))

# ---- 27) 技能倍率三通道: 禁止再把面板读数塞进 base_attack(旧口径 hack) ----
#   拆通道之前, "最大魔力结算 / 当前魔力结算"是靠"先读 stats、把结果塞进
#   base_attack"来表达的。同一个字段既当基数又当口径开关 —— 现在有了
#   max_mana_mul / attack_mul / other_mul, 那样写就是回退, 面板也没法归类。
#   这个签名(base_attack set from storage manacore:out r.value)只会出现在旧写法里。
hack_re = re.compile(r'manacore:in\s+arg\.base_attack\s+set\s+from\s+storage\s+manacore:out\s+r\.value')
for k in sorted(functions):
    for i, l in enumerate(ftext(k).splitlines(), 1):
        if l.lstrip().startswith('#'):
            continue
        if hack_re.search(l):
            R['chanhack'].append((functions[k],
                                  '第 %d 行 又把面板读数塞进 base_attack —— 口径该由 '
                                  'max_mana_mul / attack_mul / other_mul 三条通道表达' % i))

# ---- 28) 技能倍率三通道: 口径表(lib/skill_mul/def)必须和技能文件对得上 ----
#   面板要把"装备给这条通道加了多少"分列显示, 靠的是这张表把装备归类。
#   结算以技能文件里写的通道为准 —— 所以一旦技能换了通道而表没跟着改,
#   面板就会把那件装备的超限伤害**归错列或干脆不显示**(静默)。
#   这里用"反向校验": 扫技能文件实际用到的通道, 要求表里对得上。
smdef = (ROOT / 'sweetdream' / 'data' / 'sweetdream' / 'function'
         / 'lib' / 'skill_mul' / 'def.mcfunction')
wchan = {}
if smdef.exists():
    for i, l in enumerate(smdef.read_text(encoding='utf-8', errors='ignore').splitlines(), 1):
        if l.lstrip().startswith('#') or 'wchan' not in l or ' set value ' not in l:
            continue
        m = re.search(r'wchan\.([A-Za-z_][A-Za-z0-9_]*)\s+set value \{', l)
        if not m:
            continue
        eid = m.group(1)
        blk = l[l.index('{', l.index('wchan')):]
        got = set()
        for f in ('mm', 'atk', 'oth'):
            fm = re.search(f + r':(0b|1b)', blk)
            if not fm:
                R['chandef'].append((smdef, '第 %d 行 "%s" 缺字段 %s —— 三个都要写全(mm/atk/oth)'
                                     % (i, eid, f)))
            elif fm.group(1) == '1b':
                got.add(f)
        wchan[eid] = got
    # 表里的 id 都要在 names 里登记(否则面板只会显示英文 id)
    nbuild = (ROOT / 'sweetdream' / 'data' / 'sweetdream' / 'function'
              / 'lib' / 'reg' / 'build.mcfunction')
    ntext = nbuild.read_text(encoding='utf-8', errors='ignore') if nbuild.exists() else ''
    for eid in sorted(wchan):
        if ('names.%s ' % eid) not in ntext:
            R['chandef'].append((smdef, '口径表里的 "%s" 没在 lib/reg/build 的 names 里登记' % eid))
else:
    R['chandef'].append((str(ROOT), '找不到 lib/skill_mul/def.mcfunction(面板会少三条倍率显示)'))

eqdir = ROOT / 'sweetdream' / 'data' / 'sweetdream' / 'function' / 'equipment'
for f in eqdir.rglob('*.mcfunction'):
    rel = f.relative_to(eqdir).parts
    if len(rel) < 3:
        continue
    eid = rel[1]
    for i, l in enumerate(f.read_text(encoding='utf-8', errors='ignore').splitlines(), 1):
        if l.lstrip().startswith('#'):
            continue
        for fld, tag in CH_FIELD.items():
            if fld in l and tag not in wchan.get(eid, set()):
                R['chandef'].append((f, '第 %d 行 "%s" 的技能用了 %s(%s), 但 lib/skill_mul/def '
                                        '没给它标 %s:1b —— 面板会漏显示/归错列'
                                     % (i, eid, fld, CH_LABEL[tag], tag)))

# ---- 29) 超限伤害必须三条通道都派发 ----
#   overlimit/api/mod 是"哪个通道字段存在就乘哪个"。漏一条 -> 走那条通道的技能
#   静默少吃超限伤害(数值对不上 lore, 还不报错)。
olmod = (ROOT / 'sweetdream' / 'data' / 'sweetdream' / 'function'
         / 'overlimit' / 'api' / 'mod.mcfunction')
if olmod.exists():
    otext = olmod.read_text(encoding='utf-8', errors='ignore')
    for fld, sub in (('max_mana_mul', 'mm'), ('attack_mul', 'sm'), ('other_mul', 'om')):
        if 'in arg.%s run function sweetdream:overlimit/api/mod/%s' % (fld, sub) not in otext:
            R['olchan'].append((str(olmod), '没有派发 %s -> mod/%s(走这条通道的技能会静默少吃超限伤害)'
                                 % (fld, sub)))

# ---- 30) 读 zx:work olv.mana 的函数, 自己必须先写一次基准值 ----
#   olv.mana = "这一次实际要扣多少蓝", 由 overlimit/api/mod/mana 抄写。
#   ⚠️ 但 mod 在"没敲超限"时会**开头就 return**(省三次乘除), 那一步根本不写它 ——
#   于是读它的人要么读到"读不到"(提示显示「需要 0」), 要么读到上一轮超限留下的
#   陈旧值(按旧价扣蓝, 且不报错)。所以调用点必须"先抄基准值 -> 再让 mod 覆盖"。
#   真实事故 2026-10-04: 风行技能提示「魔力不足(需要 0)」, 实际文案是 550。
OLV_R = 'data get storage zx:work olv.mana'
OLV_W = 'data modify storage zx:work olv.mana set'
for k in sorted(functions):
    if OLV_R not in ftext(k):
        continue
    if OLV_W not in ftext(k):
        R['olvcache'].append((functions[k],
                              '读了 zx:work olv.mana 却没在自己这里先写一次基准值 —— '
                              '没敲超限时 overlimit/api/mod 会提前 return, 这里会读到 0 '
                              '或上一轮的陈旧值(提示显示「需要 0」/ 扣错蓝, 都不报错)'))

# ---- 31) 面板的三条技能倍率要把「最大魔力值技能倍率」通用加成折进去 ----
#   ★ 2026-10-07 改版 ★ 风行「风声」/ 忘川彼岸套装 / 无效 给的加成, 原来存在
#   zx:data wg_bonus."<uuid>"(按 uuid 的一次性槽位, 由 lib/max_mana_bonus 消费)。
#   用户判定它与面板上的「最大魔力值技能倍率」功能完全重复, 于是把那套槽位
#   (连同 lib/max_mana_bonus / lib/skill_mul/wind) 整体删除, 加成改存玩家计分项
#   zx.mm_add(百分点) + zx.mm_add_t(剩余秒), 由 lib/mm_add 三件套消费:
#     · scan_mul  —— 面板现形(往加算池 mm 通道写), 由 lib/skill_mul/scan 调用;
#     · hook_calc —— 真实结算(挂 #manacore:event/damage_calc, 角色 = 加算);
#     · tick      —— 每秒衰减(由 lib/second 调用)。
#   这里盯: scan 有没有折入 / scan 里不许有 return / 三件套文件齐不齐 /
#   tick 有没有挂在 lib/second 上 / scan_mul 的面板行声明。
#   (hook_calc 在事件里的位置与 `# @calc:` 角色由规则 67 dmgord 单独盯。)
#   真实反馈 2026-10-04: 用户放完风行技能, 面板"最大魔力值技能倍率"仍显示 ×1。
#   真实反馈 2026-10-07: 用户要求"把风声加成并进最大魔力值技能倍率, 去掉重复的那套"。
SMSCAN = (ROOT / 'sweetdream' / 'data' / 'sweetdream' / 'function'
          / 'lib' / 'skill_mul' / 'scan.mcfunction')
if SMSCAN.exists():
    sscan = SMSCAN.read_text(encoding='utf-8', errors='ignore')
    # ★ 必须在**非注释行**上真的调它 ★ —— 只查子串的话, 把调用注释掉
    #   (行首加 #) 仍然含那串文本, 探针会假绿。
    _has_call = any(
        'sweetdream:lib/mm_add/scan_mul' in l and not l.lstrip().startswith('#')
        for l in sscan.splitlines())
    if not _has_call:
        R['smwind'].append((str(SMSCAN),
                            '没有折进「最大魔力值技能倍率」通用加成(风声 / 忘川彼岸 / 无效)'
                            ' -> 放完风行技能后面板里"最大魔力值技能倍率"还是 ×1(像加成没生效)'))
    # ★ scan 里一个 return 都不能有 ★
    #   主干顺序是"默认值 -> 装备乘区 -> 各通道 scan_mul"。装备乘区(lib/skill_mul/gear)
    #   里有两处"拿不到就收工"的 return, 而 mm_add 那份加成是**玩家身上的 buff**
    #   (换不换武器、敲没敲超限都还在)。return 一旦写在 scan 里, 没敲超限 /
    #   主手不是本包装备时折入被一起跳过 -> 面板永远 ×1。要提前收工请写进 gear。
    for n, l in enumerate(sscan.splitlines(), 1):
        s = l.strip()
        if s.startswith('#'):
            continue
        if re.search(r'\breturn\b', s):
            R['smwind'].append((str(SMSCAN),
                                '第 %d 行出现 return —— scan 里 return 会把后面的'
                                '"折入通用加成"一起跳过(没敲超限时面板永远 ×1); '
                                '要提前收工请挪进 lib/skill_mul/gear' % n))

_MMADD = SMSCAN.parent.parent / 'mm_add'
for _need, _why in (('scan_mul', '面板现形那一支(scan 要调它)'),
                    ('hook_calc', '真实结算那一支(挂 event/damage_calc)'),
                    ('take', '消费那一支: 打出一次最大魔力值技能后清零')):
    _p = _MMADD / (_need + '.mcfunction')
    if not _p.exists():
        R['smwind'].append((str(_p), '找不到 lib/mm_add/%s.mcfunction —— %s' % (_need, _why)))
# scan_mul 必须声明自己折进面板哪一行(panelrow 规则只扫 equipment/, 这里补扫 lib/)
_mmsm = _MMADD / 'scan_mul.mcfunction'
if _mmsm.exists():
    _t = _mmsm.read_text(encoding='utf-8', errors='ignore')
    if not re.search(r'^#\s*@panel:\s*smul_mm\s*$', _t, re.M):
        R['smwind'].append((str(_mmsm), '头部缺少 `# @panel: smul_mm` 声明 —— '
                                        '它折进的是面板"最大魔力值技能倍率 ×"那一行'))
# take 必须被 hook_calc 真的调起来 —— 不调用的话加成永远不清零(= 永久 buff)
_mmhc = _MMADD / 'hook_calc.mcfunction'
if _mmhc.exists():
    if 'lib/mm_add/take' not in _mmhc.read_text(encoding='utf-8', errors='ignore'):
        R['smwind'].append((str(_mmhc), 'hook_calc 没调 lib/mm_add/take —— '
                                        '加成永远不会被消费掉(变成永久 buff, 且会越叠越高)'))
# hook_calc 必须在事件里登记 + 计分项必须在 core/load 建出来(没建 = 整段静默失效)
_DCEV = (ROOT / 'sweetdream' / 'data' / 'manacore' / 'tags' / 'function'
         / 'event' / 'damage_calc.json')
if _DCEV.exists() and 'sweetdream:lib/mm_add/hook_calc' not in _DCEV.read_text(
        encoding='utf-8', errors='ignore'):
    R['smwind'].append((str(_DCEV), '没登记 sweetdream:lib/mm_add/hook_calc —— '
                                    '那份加成在结算侧完全不生效(且不报错)'))
_CORELOAD = (ROOT / 'sweetdream' / 'data' / 'sweetdream' / 'function'
             / 'core' / 'load.mcfunction')
if _CORELOAD.exists():
    _cl = [l for l in _CORELOAD.read_text(encoding='utf-8', errors='ignore').splitlines()
           if not l.lstrip().startswith('#')]
    for _obj in ('zx.mm_add', 'zx.mm_add_lt'):
        if not any(('objectives add ' + _obj + ' ') in l for l in _cl):
            R['smwind'].append((str(_CORELOAD), '没建计分项 %s —— 读它的命令会直接失败, '
                                                '加成整段静默不触发' % _obj))


# ---- boltseen) 真召唤的闪电必须带 zx.th_seen(除非明确豁免) ----
#   core/tick 每刻扫 `type=minecraft:lightning_bolt,tag=!zx.th_seen]` 并跑
#   tool/thunder/strike —— 该函数会**先给这道雷打上 zx.th_seen**(去重), 再检查
#   6 格内有没有持「雷鸣」的玩家。所以"不带 seen 的闪电" = 会被雷鸣机制当成
#   "刚出现的新一道雷"接管。后果分两种:
#     · 鸣雷反应链里劈出的雷(见 tool/thunder/pend_go / axe/thunderclap/bolt_one)
#       若忘了 seen -> 那道雷自己被 strike 命中 -> 1 秒后再劈 -> **无限连锁**
#       (每刻都在劈, 直到有人把雷鸣摘了)。这是最危险的一种。
#     · 其它来源(如 anion/charge)落在持雷鸣的玩家旁 -> 会被额外接管一次。
#   现行**故意**不带 seen 的两处(看了头注释确认是有意的, 加进白名单):
#     · axe/anion/cast   —— 原版真闪电, 就是要让雷鸣接管
#     · axe/charge/bolt  —— 同上
#   另外盯: 威霆"每刻劈一道"的驱动 bolt_fx 必须挂在 core/tick、且三维度各一行
#   (core/tick 只在主世界每刻跑 -> 少了维度, 在别的维度打威霆就永远不落雷)。
_BOLT_EXEMPT = {
    'equipment/axe/anion/cast.mcfunction',
    'equipment/axe/charge/bolt.mcfunction',
}
_DPFUN = ROOT / 'sweetdream' / 'data' / 'sweetdream' / 'function'
if _DPFUN.exists():
    for _fp in sorted(_DPFUN.rglob('*.mcfunction')):
        _rel = _fp.relative_to(_DPFUN).as_posix()
        if _rel in _BOLT_EXEMPT:
            continue
        for _n, _l in enumerate(_fp.read_text(encoding='utf-8', errors='ignore').splitlines(), 1):
            _s = _l.strip()
            if _s.startswith('#') or 'summon minecraft:lightning_bolt' not in _s:
                continue
            if 'zx.th_seen' in _s:
                continue
            R['boltseen'].append((str(_fp), _n, _s[:100] +
                                  '  <- 召唤真闪电必须带 {Tags:["zx.th_seen"]}'
                                  '(漏了会被雷鸣的每刻扫描当成新雷接管; 反应链里劈出的雷会无限连锁)'
                                  '。若这道雷**故意**要让雷鸣接管, 把文件路径加进 check.py 的 _BOLT_EXEMPT'))
_TCTICK = (ROOT / 'sweetdream' / 'data' / 'sweetdream' / 'function'
           / 'core' / 'tick.mcfunction')
if _TCTICK.exists():
    _tt = _TCTICK.read_text(encoding='utf-8', errors='ignore')
    for _d in ('minecraft:overworld', 'minecraft:the_nether', 'minecraft:the_end'):
        if not any(('execute in ' + _d) in l
                   and 'sweetdream:equipment/axe/thunderclap/bolt_fx' in l
                   and not l.lstrip().startswith('#')
                   for l in _tt.splitlines()):
            R['boltseen'].append((str(_TCTICK), 0,
                                  'core/tick 缺 "execute in %s ... run function '
                                  'sweetdream:equipment/axe/thunderclap/bolt_fx" —— '
                                  '少了这个维度, 在该维度打威霆就永远不落雷' % _d))


# ---- 33) 面板数字不许被截成整数 ----
#   lib/num/plain 以前有一句
#       execute store result storage zx:work a.num double 1 run data get storage zx:work a.num
#   本意是"不管传进来是 int / float / 字符串, 先归一化成 double"。但 `data get`
#   作为**命令结果只会给整数部分** —— 1.5 变 1、2.44 变 2, 于是面板上所有带小数的
#   倍率被悄悄抹平(2026-10-04 用户反馈"下次技能加成 1", 存档里的真值其实是 1.5)。
#   宏渲染本来就会把 DoubleTag 渲染成 "1.5"/"1.5d", 这句纯属多余 —— 禁掉。
NMPLAIN = (ROOT / 'sweetdream' / 'data' / 'sweetdream' / 'function'
           / 'lib' / 'num' / 'plain.mcfunction')
if NMPLAIN.exists():
    for n, l in enumerate(NMPLAIN.read_text(encoding='utf-8', errors='ignore').splitlines(), 1):
        s = l.strip()
        if s.startswith('#'):
            continue
        if re.search(r'store result storage \S+ \S+ double\b.*\brun data get\b', s):
            R['numloss'].append((str(NMPLAIN),
                                 '第 %d 行拿 data get 当 store result 的源 —— data get 只给'
                                 '整数部分(1.5 -> 1), 面板上的小数会被悄悄抹平; '
                                 '删掉这句, 直接交给 plain_go' % n))

# ---- 34) 染色潜影盒方块 id 必须是合法的 16 种染料色 ----
#   shulker_box **方块**只有 16 种染色版(白/橙/品红/淡蓝/黄/黄绿/粉/灰/淡灰/青/紫/蓝/棕/绿/红/黑)
#   + 1 个默认版 `minecraft:shulker_box`, **没有** gold / light_purple / aqua 这类
#   "只有文字组件才认的颜色"。写错了 setblock 直接失败 -> (give_all 的)中转站建不起来
#   -> 盒子全发不出去, 而且**不报错**。
#   2026-10-04 真实踩过: _gen_give_all.py 的 BOX_COLOR 写的就是 gold/light_purple/aqua。
SHULKER_COLORS = {'white', 'orange', 'magenta', 'light_blue', 'yellow', 'lime', 'pink',
                  'gray', 'light_gray', 'cyan', 'purple', 'blue', 'brown', 'green',
                  'red', 'black'}
shulker_re = re.compile(r'minecraft:([a-z_]+)_shulker_box')
for fnk, fp in functions.items():
    for i, l in enumerate(ftext(fnk).split('\n'), 1):
        s = l.strip()
        if s.startswith('#'):
            continue
        for m in shulker_re.finditer(s):
            if m.group(1) not in SHULKER_COLORS:
                R['shulker'].append((
                    str(fp),
                    '第 %d 行 minecraft:%s_shulker_box 不是合法染色潜影盒(只有 16 种染料色): %s'
                    % (i, m.group(1), s[:80])))

# ---- 35) 不要用 NBT 写"玩家"的 Pos —— 会静默不生效 ----
#   玩家的位置是**客户端权威**的: 服务端 `store result entity @s Pos[1] ...` 或
#   `data modify entity @s Pos ...` 改完之后, 客户端下一个移动包就把它顶回去 ——
#   表现是"放了技能但人没动", 而且**不报错、不写日志**。位移一律用 /tp。
#   2026-10-04 真实踩过: 天穹的第一段跃升写成 `store result entity @s Pos[1]`,
#   玩家反馈"开了技能没飞起来"; 改成 `tp @s ~ ~0.2 ~` 就好了。
#   ⚠️ 只抓 @s / @p(@a/@r/@e 既可能是玩家也可能是生物, 抓了容易误报)。
#   确有正当用途(比如只推非玩家实体)就在那一行的**上方**写 `# pos-ok: 理由` 豁免。
POSNBT_RE = re.compile(
    r'(?:store\s+result\s+entity|data\s+modify\s+entity|data\s+merge\s+entity)'
    r'\s+(@[spr](?:\[[^\]]*\])?)\s+\bPos\b')
for fnk, fp in functions.items():
    lines = ftext(fnk).split('\n')
    for i, l in enumerate(lines, 1):
        s = l.strip()
        if s.startswith('#'):
            continue
        m = POSNBT_RE.search(s)
        if not m:
            continue
        if any('pos-ok:' in (lines[j].strip() if 0 <= j < len(lines) else '')
               for j in (i - 2, i - 3, i - 4)):
            continue
        R['posnbt'].append((str(fp),
            '第 %d 行用 NBT 写 %s 的 Pos —— 玩家位置是客户端权威的, 服务端写完会被'
            '顶回去(静默不生效); 位移请改用 /tp: %s' % (i, m.group(1), s[:70])))

# ---- 专用基准节点 zx:work ob 只许伤害模块碰 ----
#   背景: zx:work a 是全包共用的临时节点(226 处引用)。范围伤害是
#   `execute as <选择器>` 一个个打的, 循环里任何嵌套调用(击杀记账 / 物品备份 /
#   升级结算 / 流光回调…)都可能往 a 里写东西 —— 于是"就地改 a 再还原"的写法
#   迟早失手, 表现就是"升痕加伤有时漏给没升痕的目标"(随机、难复现)。
#   修法是把"这一批的完整入参快照"抄进 zx:work ob, 别的函数一律不许碰它。
OB_OK = {'sweetdream:internal/damage/with_from',
         'sweetdream:internal/damage/one',
         'sweetdream:internal/damage/stg_mul'}
for fnk, fp in functions.items():
    if fnk in OB_OK:
        continue
    for i, l in enumerate(ftext(fnk).split('\n'), 1):
        s = l.strip()
        if s.startswith('#'):
            continue
        if 'zx:work ob' in s:
            R['obnode'].append((str(fp),
                '第 %d 行动了专用基准节点 zx:work ob —— 它只给 internal/damage 的 '
                'with_from/one/stg_mul 用(见那三个文件的长注释): %s' % (i, s[:70])))

# ---- 48) 带 zx.anim 的实体必须先写 data.zx.anim, 再加标签 ----
#   lib/anim_step 是宏函数, 四个宏参数(field/track/key/dir)从**实体自己的**
#   data.zx.anim 里取。缺任何一个 -> 宏绑定失败 -> **被调函数一条命令都不跑**,
#   而且几乎是静默的: 表现是"召唤出来就定在起始帧、永远不动"(不是少一个效果,
#   是整个动画消失)。规矩: 同一个函数里**先写 data.zx.anim, 再 tag ... add zx.anim**。
#   (2026-10-05 建立通用逐帧库时立的约)
ANIM_ADD = re.compile(r'(?<![a-z_.])add\s+zx\.anim\b')
for fnk, fp in functions.items():
    body = ftext(fnk)
    if 'add zx.anim' not in body:
        continue
    has_data = any('data.zx.anim' in l for l in body.split('\n')
                   if not l.strip().startswith('#'))
    for i, l in enumerate(body.split('\n'), 1):
        s = l.strip()
        if s.startswith('#'):
            continue
        if ANIM_ADD.search(s) and not has_data:
            R['animdata'].append((str(fp),
                '第 %d 行给实体打了 zx.anim 标签, 但本函数里没有写 data.zx.anim —— '
                'lib/anim_step 的宏参数绑不上, 整段动画一条命令都不跑(静默): %s'
                % (i, s[:80])))

# ---- 49) 属性修饰符: 有 add 就必须全包存在同 id 的 remove ----
#   attribute modifier 是**实体数据**, 不随标签/计分项消失。标签到期、被武器消耗、
#   或状态被移除时若不摘 -> 那个减益**永久**留在生物身上, 而且不报错、不写日志。
#   (真实隐患: 流火的护甲 -20% / 白昼梦的攻击力 -20% 忘了 remove 就是永久减益)
ADD_MOD = re.compile(r'modifier\s+add\s+(\S+)')
REM_MOD = re.compile(r'modifier\s+remove\s+(\S+)')
_add_mod, _rem_mod = {}, {}
for fnk, fp in functions.items():
    for i, l in enumerate(ftext(fnk).split('\n'), 1):
        s = l.strip()
        if s.startswith('#'):
            continue
        for m in ADD_MOD.finditer(s):
            mid = m.group(1)
            if '$' in mid or ':' not in mid:
                continue
            _add_mod.setdefault(mid, (str(fp), i))
        for m in REM_MOD.finditer(s):
            _rem_mod.setdefault(m.group(1), (str(fp), i))
for mid, (fp, i) in _add_mod.items():
    if mid not in _rem_mod:
        R['attrleave'].append((fp,
            '第 %d 行 modifier add %s, 但全包没有同 id 的 modifier remove —— '
            '摘标签/状态结束时摘不掉, 那个减益会永久留在生物身上(不报错)' % (i, mid)))

# ---- 50) 时长一致性: "施加处给满值" 与 "每秒衰减处兜底" 必须一致 ----
#   两处对不上会出现"刚贴上就剩几秒"或"倒数被重置", 都不报错。
#   覆盖两类(2026-10-06 扩): ①头顶图标那套通用标签(zx.tt.*) ②贴在**生物**上、有寿命的
#   武器专属标签(zx.sh_t=圣痕 / zx.stg_t=升痕, 见 status/decay)。以后加新生物标签,
#   往 _DUR_PAIRS 加一行即可。
def _dur_map(name, objpat):
    out = {}
    fnk = 'sweetdream:' + name
    if fnk not in functions:
        return out
    pat = re.compile(r'scoreboard players set \S+ (' + objpat + r') (\d+)\b')
    for l in ftext(fnk).split('\n'):
        s = l.strip()
        if s.startswith('#'):
            continue
        m = pat.search(s)
        if m:
            out.setdefault(m.group(1), set()).add(int(m.group(2)))
    return out

def _dur_fmt(v):
    return '/'.join(str(x) for x in sorted(v)) if v else '-'

# (标注, 施加处, 衰减/兜底处, 计时计分项正则)
_DUR_PAIRS = [
    ('通用标签',      'tag/mark_one',                  'tag/ttl_tick',          r'zx\.tt\.[a-z]+'),
    ('生物标签·圣痕', 'equipment/axe/angel_core/mark', 'status/decay_shenghen', r'zx\.sh_t'),
    ('生物标签·升痕', 'equipment/axe/skyvault/mark',   'status/decay_stg',      r'zx\.stg_t'),
]
for _lab, _fa, _fb, _op in _DUR_PAIRS:
    _A, _B = _dur_map(_fa, _op), _dur_map(_fb, _op)
    for _o in sorted(set(_A) | set(_B)):
        if _A.get(_o) != _B.get(_o):
            R['ttl'].append((str(ROOT / 'sweetdream' / 'data' / 'sweetdream' / 'function'
                                / (_fa + '.mcfunction')),
                '%s[%s]: 施加处(%s)=%s / 兜底处(%s)=%s —— 两处时长不一致(会出现"刚贴上就剩几秒", '
                '或旧标签倒数被重置)' % (_lab, _o, _fa, _dur_fmt(_A.get(_o)), _fb, _dur_fmt(_B.get(_o)))))

# ---- 51) 控制时长倍率: 必须走"单一真源" lib/ctrl_mul/pct ----
#   2026-10-06 之前, lib/timestop 与 lib/freeze **各自**算一遍 `ticks × #20 ÷ #100`
#   -> 数值改一处漏一处; 而且 debug/stats 面板无从显示(用户要的"控制时间算进倍率、
#   被 stats 读到"就是靠把它收敛成一个文件)。结算与显示必须读同一个数。
def _has_call(text, fname):
    """非注释行里有没有真正调用 fname(注释里提到不算 —— 否则探针一改就漏报)。"""
    for _l in text.split('\n'):
        _s = _l.strip()
        if _s.startswith('#'):
            continue
        if ('function ' + fname) in _s:
            return True
    return False

_CP = ROOT / 'sweetdream' / 'data' / 'sweetdream' / 'function' / 'lib' / 'ctrl_mul' / 'pct.mcfunction'
if not _CP.exists():
    R['ctrlmul'].append((str(ROOT), '缺少 lib/ctrl_mul/pct.mcfunction(控制时长倍率的单一真源)'))
else:
    _cpt = ftext('sweetdream:lib/ctrl_mul/pct') if 'sweetdream:lib/ctrl_mul/pct' in functions else ''
    if 'scoreboard players set #cm_add zx.meta 0' not in _cpt:
        R['ctrlmul'].append((str(_CP), '没有把 #cm_add 置 0 -> 每次调用会残留上一次的加成'))
    if '#cm_pct zx.meta 100' not in _cpt:
        R['ctrlmul'].append((str(_CP), '没有把 #cm_pct 置 100(无加成基准)'))
    # ★ $(target) 可能是范围选择器 -> 每个来源必须 set 临时量再加, 不能直接 add
    for _l in _cpt.split('\n'):
        _s = _l.strip()
        if _s.startswith('#'):
            continue
        if re.search(r'execute as \$\(target\).*scoreboard players add #cm_add', _s):
            R['ctrlmul'].append((str(_CP), '来源直接 add 到 #cm_add —— $(target) 是范围选择器时'
                                           '会按匹配只数叠加(3 只 = +60%); 要用"set 临时量再并入"'))
for _n in ('lib/timestop', 'lib/freeze'):
    _fnk = 'sweetdream:' + _n
    if _fnk not in functions:
        R['ctrlmul'].append((str(ROOT), '缺少 %s.mcfunction' % _n)); continue
    _t = ftext(_fnk)
    # ★ 判据只看"非注释行里有没有真调用" —— 注释里提到文件名不算(否则探针一改就漏报)
    if not _has_call(_t, 'sweetdream:lib/ctrl_mul/pct'):
        R['ctrlmul'].append((str(functions[_fnk]),
            '没有真正调用 lib/ctrl_mul/pct —— 控制时长倍率又变成写死的了(面板与实际会走散)'))
    if re.search(r'operation\s+#\w+ zx\.meta \*= #20 zx\.meta', _t):
        R['ctrlmul'].append((str(functions[_fnk]),
            '还在用 #20 硬编码"控制时长 +20%" —— 应改成读 lib/ctrl_mul/pct'))
if 'sweetdream:debug/stats' in functions and not _has_call(
        ftext('sweetdream:debug/stats'), 'sweetdream:lib/ctrl_mul/pct'):
    R['ctrlmul'].append((str(functions['sweetdream:debug/stats']),
        'debug/stats 没读 lib/ctrl_mul/pct -> 面板上"控制时长"那行不会出现(用户要求能读到)'))

# ---- 52) 标签图标"剩余<=3秒变淡": 位掩码 / 阈值 / 字形三处必须对得上 ----
#   淡出位: 渊海32 流火64 夜火128 噬心256 白昼梦512(位 5..9, 与位 0..4 的"在不在"配套)
DIM_BITS = [('yuanhai', 32), ('liuhuo', 64), ('yehuo', 128), ('shixin', 256), ('dream', 512)]
_irdfnk, _irffnk = 'sweetdream:tag/icon_render', 'sweetdream:tag/icon_refresh'
if _irffnk not in functions:
    R['dimflag'].append((str(ROOT), '缺少 tag/icon_refresh.mcfunction'))
else:
    _t = ftext(_irffnk)
    for _m, _bit in DIM_BITS:
        if not re.search(r'if score @s zx\.tt\.%s matches \.\.\d+ run scoreboard players add #tag_mask zx\.meta %d'
                         % (_m, _bit), _t):
            R['dimflag'].append((str(functions[_irffnk]),
                '缺 %s 的淡出位(应 "add #tag_mask zx.meta %d") -> 该标签跨进 ≤3 秒不会触发重渲染'
                % (_m, _bit)))
#   ★ 只取 "if score ..."(= 变淡那一侧)的阈值: 普通侧写的是 unless, 不参与比较。
TH_RE = re.compile(r'\bif score @s zx\.tt\.(\w+) matches \.\.(\d+)')
def _thrs(name):
    fnk = 'sweetdream:' + name
    if fnk not in functions:
        return {}
    return {m.group(1): int(m.group(2)) for m in TH_RE.finditer(ftext(fnk))}
_ref_th, _ren_th = _thrs('tag/icon_refresh'), _thrs('tag/icon_render')
if _irdfnk not in functions:
    R['dimflag'].append((str(ROOT), '缺少 tag/icon_render.mcfunction'))
else:
    _t = ftext(_irdfnk)
    for _m, _bit in DIM_BITS:
        if 'sweetdream.icon.dim.%s' % _m not in _t:
            R['dimflag'].append((str(functions[_irdfnk]),
                '没有 %s 的淡色字形分支(应引 sweetdream.icon.dim.%s)' % (_m, _m)))
        if 'unless score @s zx.tt.%s matches ..' % _m not in _t:
            R['dimflag'].append((str(functions[_irdfnk]),
                '没有 %s 的"普通字形"分支(unless score ... matches ..N)' % _m))
    if _ref_th != _ren_th:
        R['dimflag'].append((str(ROOT),
            'icon_refresh 与 icon_render 的"剩余秒数阈值"不一致: %s vs %s -> '
            '掩码说该变淡、字形却没换(或反过来)' % (_ref_th, _ren_th)))
# 资源包: 图集必须是"普通 + 淡色"两份, 且 icon_render 用的回退字符都在图集里
_ICON_JSON = RP / 'assets' / 'sweetdream' / 'font' / 'icons.json'
_ICON_PNG = RP / 'assets' / 'sweetdream' / 'textures' / 'font' / 'icons.png'
try:
    _font = json.loads(_ICON_JSON.read_text(encoding='utf-8'))
    _chars = ''.join(p.get('chars', ['']) [0] for p in _font.get('providers', [])
                     if p.get('type') == 'bitmap')
    if len(_chars) < 2 * len(DIM_BITS):
        R['dimflag'].append((str(_ICON_JSON), 'bitmap 字形只有 %d 个, 至少要有 %d 个'
                                              '(5 普通 + 5 淡色)' % (len(_chars), 2 * len(DIM_BITS))))
    if _ICON_PNG.exists():
        _d = _ICON_PNG.read_bytes()
        _w, _h = struct.unpack('>II', _d[16:24])
        _cols = len(_chars) or 1
        if _w != 32 * _cols or _h != 32:
            R['dimflag'].append((str(_ICON_PNG),
                '图集尺寸 %dx%d 与 %d 个字形对不上(应 %dx32)' % (_w, _h, _cols, 32 * _cols)))
    else:
        R['dimflag'].append((str(_ICON_PNG), '缺字体图集'))
    if _irdfnk in functions:
        for _c in re.findall(r'"fallback":"([^"]*)"', ftext(_irdfnk)):
            if _chars and _c and _c not in _chars:
                R['dimflag'].append((str(functions[_irdfnk]),
                    '回退字符 U+%04X 不在字体图集里(会渲染成缺字方块)' % ord(_c[0])))
    for _lang in ('zh_cn', 'en_us'):
        _lp = RP / 'assets' / 'sweetdream' / 'lang' / (_lang + '.json')
        _tab = json.loads(_lp.read_text(encoding='utf-8')) if _lp.exists() else {}
        for _m, _ in DIM_BITS:
            if ('sweetdream.icon.dim.' + _m) not in _tab:
                R['dimflag'].append((str(_lp), 'lang 缺 sweetdream.icon.dim.%s(淡色字形不认)' % _m))
except Exception as _e:
    R['dimflag'].append((str(_ICON_JSON), '读取字体资源失败: %s' % _e))

# ---- 53) 敌方技能伤害: 来源标记 src 的通道必须完整 ----
#   "敌人放的技能"要与"玩家放的技能"区分开, 靠 zx:work a.src("ally" / "enemy")。
#   三处必须对得上: ① api/damage 复位+兜底; ② api/enemy_damage 写 "enemy";
#   ③ internal/damage/one 的夜火按来源分流, 且与"本包技能类型"那条**互斥**。
_dmgk, _edk, _onek = 'sweetdream:api/damage', 'sweetdream:api/enemy_damage', 'sweetdream:internal/damage/one'
if _dmgk not in functions:
    R['enemysrc'].append((str(ROOT), '缺少 api/damage.mcfunction'))
else:
    _t = ftext(_dmgk)
    if 'src:""' not in _t:
        R['enemysrc'].append((str(functions[_dmgk]),
            'api/damage 复位 zx:work a 时没带 src 字段 -> 来源标记会串上一次调用的值'))
    if 'unless data storage zx:work a{src:"enemy"} run data modify storage zx:work a.src set value "ally"' not in _t:
        R['enemysrc'].append((str(functions[_dmgk]),
            'api/damage 缺 a.src 的兜底默认值(应为 "ally"; ★ 不能用 merge 补 —— '
            'merge 会覆盖调用方给的 "enemy")'))
if _edk not in functions:
    R['enemysrc'].append((str(ROOT), '缺少 api/enemy_damage.mcfunction(敌方技能入口)'))
else:
    _t = ftext(_edk)
    if 'set value "enemy"' not in _t or 'sweetdream:api/damage' not in _t:
        R['enemysrc'].append((str(functions[_edk]),
            'api/enemy_damage 必须写 src="enemy" 并转调 api/damage'))
if _onek not in functions:
    R['enemysrc'].append((str(ROOT), '缺少 internal/damage/one.mcfunction'))
else:
    _t = ftext(_onek)
    if 'src:"enemy"' not in _t:
        R['enemysrc'].append((str(functions[_onek]),
            '夜火没有按"敌方技能"(src:"enemy")分流 -> 敌方技能打不进去, 标签静默少生效'))
    elif not any('type:"sweetdream:skill"' in l and 'unless data storage zx:work a{src:"enemy"}' in l
                 for l in _t.split('\n')):
        R['enemysrc'].append((str(functions[_onek]),
            '夜火的"本包技能类型"分支没带 unless src:"enemy" -> 敌方技能同时满足两条判据, '
            'vuln_tag 会跑两次(+32% 而不是 +15%)'))

# ---- 54) /reload 不许偷走标签时长: tag/load 不得调 tag/second / tag/ttl_tick ----
#   真实事故 2026-10-06: tag/load 末尾调了一次 tag/second 想"加载时顺手重建显示",
#   但 tag/second -> tag/second_dimension -> tag/ttl_tick 里是"每秒 -1" —— 而
#   core/load 在 /reload 时**也会跑** -> 玩家每敲一次 /reload, 场上所有标签就白扣 1 秒。
#   调试期频繁 /reload 时表现就是"标签莫名其妙短命、明显不到预设的十几秒", 一个字都不报。
#   图标不需要在这里重建: text_display 随存档持久化, 每秒校验(最多 1 秒后)会校好租约/掩码;
#   所以 load 只负责"建两个缓存计分项 + 把节拍清零"。注释里提到不算 —— 只看非注释行。
for _lk, _lname in ((('sweetdream:tag/load'), 'tag/load'),):
    if _lk not in functions:
        continue
    for _ln, _ls in enumerate(ftext(_lk).split('\n'), 1):
        _s = _ls.strip()
        if not _s or _s.startswith('#'):
            continue
        _bad = 'tag/second' if 'tag/second' in _s else ('tag/ttl_tick' if 'ttl_tick' in _s else None)
        if _bad:
            R['reloadttl'].append((str(functions[_lk]), _ln,
                '%s 第 %d 行调了 %s —— /reload(会跑 core/load)时白扣场上所有标签 1 秒, '
                '标签会莫名其妙短命且不报错' % (_lname, _ln, _bad)))

# ---- 55) 三维度循环: 带 `execute in <维度>` 的选择器必须带**位置参数** ----
#   Java 版规则(MC wiki / Target selectors): 只有**位置类参数**(x/y/z 或 distance 或
#   dx/dy/dz)才会把实体搜索限制到"当前维度"; 一个都不带时(@e[tag=X] / @e[scores={...}])
#   会**跨全部维度搜索**。所以"三维度各写一遍"这种写法, 只要选择器是裸的, 同一只实体
#   就会被三行各处理一遍 = 3 倍速 / 3 倍伤害 / 3 倍粒子 —— 而且一个字都不报。
#   正确写法: @e[distance=0..,tag=X]。distance=0.. 本身不过滤任何东西, 它的唯一作用是
#   "给选择器一个位置基准", 从而把搜索锁进当前维度。
#   ★ 顺带纠正一个流传很久的错误认知: "裸 @e 只覆盖当前维度" —— 反了。
#   真实事故 2026-10-06(同日同一根因, 全包 7 处):
#     tag/second       标签寿命 3 倍快(玩家报"5 秒掉了 15 秒")
#     status/decay     圣痕 15 秒变 5 秒 / 升痕 15 秒掉 3 层(新写的功能当场中招)
#     unfreeze_dim     时停结束事件广播 3 遍 -> 异彩的结束真伤 3 倍
#     remelt/second    融甲文档写 10 秒、实际 3.3 秒
#     core/tick(ball)  法球每刻前进 3 次 = 3 倍速
#     core/tick(anim)  朽木/暗潮逐帧动画 3 倍速
#     core/tick(se_live/ld_mark) 每刻伤害 3 倍
#   豁免(刻意不报): 选择器里带 nbt={UUID:[I;...]}(按唯一 UUID 跨维度找人是有意的);
#     写在字符串字面量里的 "@e[...]"(那是给 storage 用的文本, 不是本行执行的选择器);
#     注释行。
_HASDIM = re.compile(r'execute\s+in\s+minecraft:(?:overworld|the_nether|the_end)\b')
_SELRE = re.compile(r'@e\[([^\]]*)\]')
_POSRE = re.compile(r'(?:^|[,{\[])\s*(?:x|y|z|distance|dx|dy|dz)\s*=')
_QUOT = re.compile(r'"[^"]*"|\'[^\']*\'')
_CALLF = re.compile(r'run\s+function\s+(#?[a-z0-9_:/.]+)')

# 函数标签表: 'ns:路径' -> [被引用的函数 / 子标签]
_ftags = {}
for _ns in nsdirs:
    _td = _ns / 'tags' / 'function'
    if not _td.is_dir():
        continue
    for _jp in _td.rglob('*.json'):
        try:
            _vals = json.loads(_jp.read_text(encoding='utf-8')).get('values', [])
        except Exception:
            continue
        _ftags['%s:%s' % (_ns.name, _jp.relative_to(_td).as_posix()[:-len('.json')])] = \
            [(_e if isinstance(_e, str) else (_e or {}).get('id')) for _e in _vals]

def _bare_sels(text):
    """本行里"没带位置参数"的 @e 选择器(先剔掉字符串字面量)"""
    out = []
    for _m in _SELRE.finditer(_QUOT.sub('', text)):
        _a = _m.group(1)
        if _POSRE.search(_a) or 'UUID:[' in _a:
            continue
        out.append(_a.strip())
    return out

def _expand_callee(fnk, depth=0):
    """(保留给以后可能的单点调用) 把 run function 的目标展开成具体函数(#tag 递归)"""
    if depth > 4:
        return []
    if fnk.startswith('#'):
        out = []
        for _v in _ftags.get(fnk[1:], []):
            if _v:
                out += _expand_callee(_v, depth + 1)
        return out
    return [fnk] if fnk in functions else []

# ① 先把"每个维度各跑一次"的函数集合算出来: 从所有带 `execute in <维度>` 的行出发,
#    沿 `run function`(含 `#tag` 转发)递归展开, 深度上限 2 ——
#    这样 lib/unfreeze_sweep -> lib/unfreeze_dim -> #event/timestop_end -> mirage/ts_end
#    这种两级转发也跑不掉(2026-10-06 的反向探针就是这么发现漏检的)。
_dim_seen, _dim_q = set(), []
for _fk in functions:
    for _ls in ftext(_fk).split('\n'):
        _s = _ls.strip()
        if not _s or _s.startswith('#') or not _HASDIM.search(_s):
            continue
        for _cf in _CALLF.findall(_QUOT.sub('', _s)):
            _dim_q.append((_cf, 0))
while _dim_q:
    _cf, _cd = _dim_q.pop(0)
    if _cf.startswith('#'):
        for _v in _ftags.get(_cf[1:], []):
            if _v:
                _dim_q.append((_v, _cd))
        continue
    if _cf in _dim_seen or _cf not in functions:
        continue
    _dim_seen.add(_cf)
    if _cd >= 2:
        continue
    for _ls in ftext(_cf).split('\n'):
        for _c2 in _CALLF.findall(_QUOT.sub('', _ls)):
            _dim_q.append((_c2, _cd + 1))

# ② 维度行本身的选择器
for _fk in sorted(functions):
    for _ln, _ls in enumerate(ftext(_fk).split('\n'), 1):
        _s = _ls.strip()
        if not _s or _s.startswith('#') or not _HASDIM.search(_s):
            continue
        for _a in _bare_sels(_s):
            R['dimsel'].append((functions[_fk], _ln,
                'execute in <维度> 的选择器 @e[%s] 没带位置参数 —— 裸 @e 会跨维度搜索全部维度, '
                '"三维度各写一遍"会让同一只实体被处理 3 次(3 倍速 / 3 倍伤害, 不报错); '
                '加 distance=0.. 即可' % _a[:50]))

# ③ 这些函数体内也不行(它们是"每维度各跑一次"的)
for _fk in sorted(_dim_seen):
    for _ln, _ls in enumerate(ftext(_fk).split('\n'), 1):
        _s = _ls.strip()
        if not _s or _s.startswith('#') or _s.startswith('$'):
            continue
        for _a in _bare_sels(_s):
            R['dimsel'].append((functions[_fk], _ln,
                '%s 在"每维度各跑一次"的调用链上(沿 execute in <维度> 可达), 体内这行的 '
                '@e[%s] 没带位置参数 —— 裸 @e 会跨维度重复处理(3 倍); 加 distance=0..'
                % (_fk, _a[:40])))

# ---- 60) `data storage <ns:path>.<键>` —— 存储名与路径之间少了空格 ----
#   存储名是资源位置, **允许 `.`** —— 所以 `storage manacore:ctx.uuid` 会被解析成
#   "存储名 = manacore:ctx.uuid", 后面就没有路径了, 命令树在后续参数处报
#   "错误的命令参数" ⇒ **整个函数加载失败**(一条命令都不跑), 而且事件 tag 里
#   引用它的那一条也会跟着断(tag 加载失败)。
#   2026-10-06 真实事故: nullify/on_create 与 thunder/bolt_dmg 双双中招 ——
#   「无效」的整条接线是断的(玩家报"看不见倍率变化"), 而 check.py 当时 0 报告:
#   这两类都是**命令语法级**的错, 静态查不出来, 只能靠这类针对性规则 + latest.log。
_STOR_GAP = re.compile(r'\bstorage\s+([A-Za-z0-9_]+:[A-Za-z0-9_/]+)\.[A-Za-z0-9_]')


def _brace_in_string(line):
    """引号内出现 `{` / `}` —— `set value` 的 NBT 读取器会被这类字符带偏(配平错位),
    接着在该行后面的参数上报错, 整个函数加载失败。"""
    inq = False
    for ch in line:
        if ch == '"':
            inq = not inq
        elif inq and ch in '{}':
            return True
    return False


for _fk in sorted(functions):
    for _ln, _ls in enumerate(ftext(_fk).split('\n'), 1):
        _s = _ls.strip()
        if not _s or _s.startswith('#'):
            continue
        _m = _STOR_GAP.search(_s)
        if _m:
            R['storid'].append((functions[_fk], _ln,
                '存储名和路径粘连: 现在写的是 `storage %s.<路径>` —— 会被当成**一个存储名**'
                '(资源位置允许 .), 于是没有路径可读 → 该行解析失败 → **整个函数不加载**。'
                '改成 `storage %s <路径>`(中间要有空格)' % (_m.group(1), _m.group(1))))
        if 'set value' in _s:
            # ★ 只判"复合 value"(以 `{` 开头)里的字符串 ★
            #   反例: `set value "@a[nbt={UUID:[I;...]}]"` —— value 整体就是一个字符串,
            #   引号里的花括号**没问题**(manacore/internal/damage/mk_from 就是这么写的,
            #   线上一直在跑)。只有"复合里的字符串含花括号"才会把读取器带偏。
            _rest = _s[_s.find('set value') + len('set value'):].lstrip()
            if _rest.startswith('{') and _brace_in_string(_rest):
                R['braceval'].append((functions[_fk], _ln,
                    'set value 的**复合值**里, 字符串中出现花括号 —— NBT 读取器会被 `{`/`}` 带偏, '
                    '在该行后面的参数上报 "应为字面量" → **整个函数不加载**。'
                    '要选带 nbt= 过滤的目标就改成"先打标签再按 tag 选", '
                    '别把 `nbt=!{...}` 塞进 set value 的复合值里'
                    '(注意: `set value "@e[nbt={...}]"` 这种**整体是字符串**的写法是合法的)'))

# ---- 78) `data storage <存储名> <SNBT键值对>` —— 判据忘了写成"路径" ----
#   条件式 `execute if/unless data <target> [<path>]` 里, 存储名后面那个参数必须是
#   **NBT 路径**(`r.ready` / `r{ready:1b}`), 不是 NBT 复合。直接写 SNBT 键值对
#   (`data storage manacore:out ready:1b`)时, `ready:1b` 不是合法路径(`:` 未加引号
#   只能出现在键名里) ⇒ 该行解析失败 ⇒ **整个函数不加载**(一条命令都不跑),
#   只在 latest.log 留下一行 "Whilst parsing command ... "。
#   修法: 用谓词路径 `r{ready:1b}`(存不存在), 或直读值 `r.ready`。
#   真实事故 2026-10-09: charge/end_ol 与 charge/mode_tick 都写成 `... out ready:1b`
#   ⇒ 超限·超•负•荷 的「第二形态」整段加载不出来, 状态结束后永远进不了第二形态(零日志)。
#   ★ 判据刻意只认"NBT 路径首段是裸词且紧跟 `:` " 这一种形态: 合法路径不会有裸 `:`,
#     而引号里的 `:{...}` 谓词(`r{reason:"x"}`)首段是 `r{`, 不会被误伤。
_STORPAIR = re.compile(r'\bdata\s+storage\s+[A-Za-z0-9_]+:[A-Za-z0-9_/]+\s+([A-Za-z0-9_.+-]+):')
for _fk in sorted(functions):
    for _ln, _ls in enumerate(ftext(_fk).split('\n'), 1):
        _s = _ls.strip()
        if not _s or _s.startswith('#'):
            continue
        _mp = _STORPAIR.search(_s)
        if _mp:
            R['storpath'].append((functions[_fk], _ln,
                '`data storage <存储名> <SNBT键值对>` —— 条件式的存储名后面要写 **NBT 路径** '
                '(如 `r{ready:1b}` / `r.ready`), 不是复合。现在 `%s:` 会被当成路径首段, '
                '`:` 非法 ⇒ **整个函数不加载**。改成 `... <存储名> r{%s:...}`' % (_mp.group(1), _mp.group(1))))

# ---- 65) damage_calc 事件: 必须由 lib/dmg_ch 先拍"通道快照", 且别人别直读 manacore:work a ----
#   "按通道区分"的装备加成(炽天使之翼 / 愠怒)要判"本次技能走的是哪条倍率通道",
#   唯一凭据是 damage_calc 抛出时的 manacore:work a。但同一事件里更早/更晚跑的
#   resonance/hook_calc 会调 api/formation/count, 而那个接口第一行就是
#   `data modify storage manacore:work a set value {uuid:""}` —— 三条通道当场清零。
#   ⇒ 必须在事件**第一条**把 a 快照成 zx:work ch, 后面一律读快照。
#   顺序一被改动, 那些加成会**一次都不生效, 而且一个字都不报**(2026-10-06 差点埋雷)。
_dc = (ROOT / 'sweetdream' / 'data' / 'manacore' / 'tags' / 'function' / 'event'
       / 'damage_calc.json')
if _dc.exists():
    try:
        _vals = json.loads(_dc.read_text(encoding='utf-8')).get('values', [])
    except Exception as _e:
        R['dmgch'].append((_dc, '解析失败: %s' % _e))
        _vals = []
    if not _vals:
        R['dmgch'].append((_dc, 'values 为空 —— 通道快照(lib/dmg_ch)没挂上'))
    elif _vals[0] != 'sweetdream:lib/dmg_ch':
        R['dmgch'].append((_dc, '第一条必须是 "sweetdream:lib/dmg_ch"(通道快照), '
                                '现在第一条是 "%s" —— 顺序一变, "按通道区分"的装备加成'
                                '(seraph_wing / wrath)会永远读到 0(静默不生效)' % _vals[0]))
    for _v in _vals:
        if _v == 'sweetdream:lib/dmg_ch' or ':' not in _v:
            continue
        _p = (ROOT / 'sweetdream' / 'data' / 'sweetdream' / 'function'
              / (_v.split(':', 1)[1] + '.mcfunction'))
        if not _p.exists():
            continue
        for _i, _l in enumerate(_p.read_text(encoding='utf-8', errors='ignore').splitlines(), 1):
            if _l.lstrip().startswith('#'):
                continue
            if 'manacore:work a' in _l:
                R['dmgch'].append((_p, '第 %d 行在 damage_calc 事件里直接读 manacore:work a'
                                       ' —— 同事件的 resonance/hook_calc(经 api/formation/count)'
                                       '会把它整份重置, 这里读到的**永远是 0**; '
                                       '改读 lib/dmg_ch 拍的快照 zx:work ch' % _i))
else:
    R['dmgch'].append((str(ROOT), '找不到 sweetdream 侧的 event/damage_calc.json'))

# ---- 67) damage_calc 事件的顺序 + 每个 hook 的"加算/独立乘区"角色 ----
#   事件是一串**有先后语义**的回调, 顺序错了不会报错, 只会算错:
#     ① lib/dmg_ch          快照本次技能走的三条通道(dmgch 单独盯)
#     ② lib/dmg_add_clear   清"加算池" zx:work add
#     ③ 加算 hook (@calc: add)   只往池子里写百分比
#     ④ lib/dmg_add_apply   把池子**先合并、再乘一次**(这才是"加算")
#     ⑤ 独立乘区 hook (@calc: indep)  乘在加算之后
#   三条都是"静默偏大/偏小"的坑:
#     · 少了 ② -> 上一次施法的贡献留在池子里, 伤害一次比一次大;
#     · 加算 hook 排在 ④ 之后 -> 它的那份**完全不算**(还看不出报错);
#     · 独立乘区排在 ④ 之前 -> 乘在没合并的值上, 数值和面板对不上。
#   2026-10-06 用户定稿: 文案没写"独立乘区"的一律加算 -> 必须走 ③/④ 这条路。
#   ★ 约定: 每个 equipment/**/hook_calc.mcfunction 头部写 `# @calc: add|indep`。
_CALC_ADD = 'sweetdream:lib/dmg_add_clear'
_CALC_APPLY = 'sweetdream:lib/dmg_add_apply'
if _dc.exists():
    _vals2 = []
    try:
        _vals2 = json.loads(_dc.read_text(encoding='utf-8')).get('values', [])
    except Exception:
        pass
    if _vals2:
        if _vals2[1:2] != [_CALC_ADD]:
            R['dmgord'].append((_dc, '第二条必须是 "%s"(清加算池), 现在是 "%s" —— '
                                     '没清池的话上一次施法的加算贡献会留着, 伤害越打越大'
                               % (_CALC_ADD, _vals2[1] if len(_vals2) > 1 else '(缺)')))
        _ai = [i for i, v in enumerate(_vals2) if v == _CALC_APPLY]
        if len(_ai) != 1:
            R['dmgord'].append((_dc, '"%s" 必须出现且只出现一次(现在是 %d 次)—— 少了它'
                                     '"加算"就退化成"各自乘一次"(= 独立乘区)'
                                % (_CALC_APPLY, len(_ai))))
        else:
            _ai = _ai[0]
            _eq = (ROOT / 'sweetdream' / 'data' / 'sweetdream' / 'function' / 'equipment')
            _seen = set()
            for _i, _v in enumerate(_vals2):
                if ':' not in _v:
                    continue
                _rel = _v.split(':', 1)[1]
                if not _rel.endswith('/hook_calc'):
                    continue
                _p = (ROOT / 'sweetdream' / 'data' / 'sweetdream' / 'function'
                      / (_rel + '.mcfunction'))
                _seen.add(str(_p))
                if not _p.exists():
                    R['dmgord'].append((_dc, '列了不存在的 %s' % _v))
                    continue
                _role = None
                for _l in _p.read_text(encoding='utf-8', errors='ignore').splitlines()[:40]:
                    _m = re.match(r'#\s*@calc:\s*(add|indep)\b', _l.strip())
                    if _m:
                        _role = _m.group(1)
                        break
                if _role is None:
                    R['dmgord'].append((_p, '头部缺少 `# @calc: add|indep` 声明 —— '
                                            '这个 hook 是"加算"(先合并再乘一次)还是'
                                            '"独立乘区"(乘在加算之后)? check 无法判断它'
                                            '该排在 lib/dmg_add_apply 的哪一边'))
                elif _role == 'add' and _i > _ai:
                    R['dmgord'].append((_p, '声明是"加算"(# @calc: add), 却排在 '
                                           '%s **之后** —— 它写进池子的百分比永远不会被算上'
                                           '(静默失效)' % _CALC_APPLY))
                elif _role == 'indep' and _i < _ai:
                    R['dmgord'].append((_p, '声明是"独立乘区"(# @calc: indep), 却排在 '
                                           '%s **之前** —— 独立乘区必须乘在加算之后'
                                           % _CALC_APPLY))
            # 完整性: equipment 下每个 hook_calc 都要在事件里登记(否则写完忘了挂, 静默不生效)
            for _p in sorted(_eq.rglob('hook_calc.mcfunction')):
                if str(_p) not in _seen:
                    R['dmgord'].append((_p, '这个 hook_calc 没登记进 event/damage_calc.json '
                                            '—— 写了但没挂 = 永远不生效(且一个字都不报)'))

# ---- 66) scan_mul 声明的"折进面板哪一行"必须与代码实际写入的一致 ----
#   「加算(并进通道倍率)」和「独立乘区」在面板上是**两处不同的行**:
#     · 技能倍率三行 = pl.smul_mm / smul_atk / smul_oth  (通道口径)
#     · 独立乘区     = pl.independent_multiplier          (整体再乘一次)
#   装备的 scan_mul 折错行 = 面板把"独立乘区"说成"通道 +20%"(或反过来), 玩家按
#   stats 看到的和实伤对不上 —— 而且不报错、不进日志(2026-10-06 用户反馈:
#   "愠怒是独立乘区", 而当时它被折进了 smul_mm)。
#   约定: 每个 scan_mul 头部写一行 `# @panel: <键>[,<键>...]` 声明自己折哪一行。
_PANEL_ROWS = {'smul_mm', 'smul_atk', 'smul_oth', 'independent_multiplier'}
_scan_root = ROOT / 'sweetdream' / 'data' / 'sweetdream' / 'function' / 'equipment'
for _p in sorted(_scan_root.rglob('scan_mul.mcfunction')):
    _lines = _p.read_text(encoding='utf-8', errors='ignore').splitlines()
    _decl = None
    for _l in _lines[:60]:
        _m = re.match(r'#\s*@panel:\s*(.*?)\s*$', _l)
        if _m:
            _decl = {x.strip() for x in _m.group(1).split(',') if x.strip()}
            break
    if _decl is None:
        R['panelrow'].append((_p, '头部缺少 `# @panel: <键>` 声明 —— 这个 scan_mul 到底折进'
                                 '"通道倍率"(smul_mm/atk/oth)还是"独立乘区"'
                                 '(independent_multiplier)? 折错行面板就会说假话'))
        continue
    _unknown = _decl - _PANEL_ROWS
    if _unknown:
        R['panelrow'].append((_p, '声明了不认识的面板行 %s (只认 %s)'
                              % (sorted(_unknown), sorted(_PANEL_ROWS))))
        continue
    _used = set()
    for _l in _lines:
        if _l.lstrip().startswith('#'):
            continue
        # 写法一: 直接写面板行(独立乘区那种) —— store result storage zx:work pl.<键>
        for _mm in re.finditer(r'store\s+result\s+storage\s+zx:work\s+pl\.([A-Za-z_]+)', _l):
            _used.add(_mm.group(1))
        # 写法二: 只往"加算池"里扔通道名(加算型, 由 lib/skill_mul/padd_apply 统一折入)
        #   data modify storage zx:work put.ch set value "mm|atk|oth"
        for _mm in re.finditer(r'storage\s+zx:work\s+put\.ch\s+set\s+value\s+"(mm|atk|oth)"', _l):
            _used.add({'mm': 'smul_mm', 'atk': 'smul_atk', 'oth': 'smul_oth'}[_mm.group(1)])
    _used &= _PANEL_ROWS
    if _used != _decl:
        R['panelrow'].append((_p, '声明折入 %s, 但代码实际写入的是 %s —— 两者必须一致'
                              '(否则面板显示的行和真实生效的乘区对不上)'
                              % (sorted(_decl) or '无', sorted(_used) or '无')))

# ---- 69) 与视线共线的粒子光束: 第一人称永远看不见(必须沿本地坐标偏出去) ----
#   第一人称的摄像机就在**眼睛**上, 而 `positioned ^ ^ ^N` 铺出来的粒子全部落在
#   `眼睛 + N·视线` 这条射线上 ⇒ 屏幕上全部投影到正中那一个点(准星) = **隐形**。
#   玩家看到的"光柱"只是 dust 残影(寿命约 1 秒), 永远指着 1 秒前瞄的方向 ⇒
#   报"特效没跟着玩家"(真实事故 2026-10-07 终末天启)。
#   正解 = 整体沿视线**本地下方**平移: `positioned ^ ^-0.35 ^N`。
#   判据: 一个文件里 **>=5 条** "particle + positioned ^ ^ ^N" 且**全部** x/y 本地
#   偏移为 0、又没用 rotated 改朝向 ⇒ 就是一条沿视线的光束, 必然隐形。
_beam_axis = re.compile(r'positioned\s+\^([-0-9.]*)\s+\^([-0-9.]*)\s+\^([-0-9.]+)')
_ZERO = {'', '0', '0.0', '-0', '-0.0', '+0', '+0.0'}
_beam_root = ROOT / 'sweetdream' / 'data' / 'sweetdream' / 'function'
for _p in sorted(_beam_root.rglob('*.mcfunction')):
    _bx = []
    for _i, _l in enumerate(_p.read_text(encoding='utf-8', errors='ignore').splitlines(), 1):
        if 'particle' not in _l or _l.lstrip().startswith('#'):
            continue
        if 'rotated' in _l:
            continue
        _m = _beam_axis.search(_l)
        if _m:
            _bx.append((_i, _m.group(1).strip(), _m.group(2).strip(), _l[:100]))
    if len(_bx) >= 5 and all(a in _ZERO and b in _ZERO for _, a, b, _ in _bx):
        R['beamoff'].append((
            _p, '%d 条粒子行全部落在视线轴线上(第 %d 行起) —— 第一人称里与摄像机共线, '
                '屏幕上只是准星上的一点, **整条光束看不见**(玩家只会看到 dust 残影, '
                '于是报"特效不跟着我")。修法: 整体沿本地下方平移, 如 `positioned ^ ^-0.35 ^N`; '
                '不要用 `~-0.35`(世界竖直, 抬头会横着窜出画面), 也别把判定 scan 跟着偏'
            % (len(_bx), _bx[0][0])))

# ---- 69) scoreeq: 计分板比较符写成 `==` ----
#   原版 `if score` / `scoreboard players operation` 的比较符只有
#   `=` `<` `<=` `>` `>=` —— **没有 `==`**。写了 `==` 是命令语法错, 报
#   "Whilst parsing command on line N: 错误的命令参数"(只给行号、不给原因),
#   后果是**整个函数加载失败**(一条命令都不跑)。
#   真实事故 2026-10-07: upgrade/api/fit_uncolor 4 行写成 `==`
#   ⇒ 无色石右键完全没反应(函数根本没加载), 而当时 check.py 0 报告。
_scorectx = re.compile(r'(?:^|\s)(?:if|unless)\s+score\b|\bplayers\s+operation\b')
_eqsign = re.compile(r'(?<![=<>!])==(?!=)')
for _fk in sorted(functions):
    for _ln, _ls in enumerate(ftext(_fk).split('\n'), 1):
        _s = _ls.strip()
        if not _s or _s.startswith('#'):
            continue
        if _scorectx.search(_s) and _eqsign.search(_QUOT.sub('""', _s)):
            R['scoreeq'].append((functions[_fk], _ln,
                '计分板比较符写成了 `==` —— 原版只有 `=` / `<` / `<=` / `>` / `>=`, '
                '`==` 会让**整个函数加载失败**(Whilst parsing ... 错误的命令参数)。: '
                + _s[:90]))

# ---- 74) scorelit: `if score` 拿"字面量"当比较对象 ----
#   `if score` 的比较符两侧**都必须是计分项**(`<t> <o> <op> <t2> <o2>`)。
#   想跟**字面量 / 区间**比, 只有 `matches <范围>` 这一条路 —— 写 `if score @s obj = 7`
#   是命令语法错(不是"当成 0", 是**压根不合法**)。
#   后果分两种, 都很毒:
#     · 普通函数: 加载期就报错 ⇒ 整个函数不加载(latest.log 里 "Whilst parsing ..." 看得见);
#     · ★ `$` 宏行 ★: 加载期**只校验"这一行有没有 $(变量)", 不校验替换之后的语法**
#       (日志里的 "Macro without variables on line N" 就是这么报的)。
#       于是错误被推迟到**运行期**: 一条命令解析失败 ⇒ **该行之后的命令全不执行**
#       (函数就地中断)。全程零日志、静态 check 也看不见。
#   真实事故 2026-10-08: palette/color_body 的
#       `$execute as @e[tag=zx.pal_c] if score @s zx.pal_hit = $(id) run tag @s remove zx.pal_c`
#     ⇒ 替换成 `... = 7` 后整条解析失败 ⇒ 该行**之后**的"挑目标收尾 / 移动 / 命中"全不跑,
#       玩家报"「色彩」生成后不动、也不打人"(而它**前面**的出界/寿命判断照跑 ⇒ 还会到点消失)。
#   正确写法: 宏参数先落到一个计分项, 再"计分项比计分项":
#       `$scoreboard players set #tmp zx.meta $(id)`   ← set 用字面量是合法的
#       `... if score @s obj = #tmp zx.meta`           ← 两侧都是计分项 ✓
_ifscore_lit = re.compile(r'(?:^|\s)(?:if|unless)\s+score\s+\S+\s+\S+\s+(<=|>=|=|<|>)\s+(\S+)')
for _fk in sorted(functions):
    for _ln, _ls in enumerate(ftext(_fk).split('\n'), 1):
        _s = _ls.strip()
        if not _s or _s.startswith('#'):
            continue
        for _m in _ifscore_lit.finditer(_s):
            _src = _m.group(2)
            # 比较符右边第一个 token 是**数字**或**宏变量** ⇒ 它不是"计分项", 这行必炸
            if re.fullmatch(r'-?\d+', _src) or '$(' in _src:
                R['scorelit'].append((functions[_fk], _ln,
                    '`if score` 拿字面量/宏变量当比较对象(`= %s`) —— 比较符两侧都必须是计分项, '
                    '字面量只能用 `matches <范围>`. 宏行还会把错误拖到运行期: 该行之后全不执行(静默). '
                    '改法 = 先 `$scoreboard players set #tmp zx.meta $(x)` 再比计分项.: ' % _src
                    + _s[:90]))

# ---- 75) guardclob: 守卫变量被它自己调用的函数改写 ----
#   `#xxx`(假玩家计分项)是**全局共享变量** —— 谁都能写, 没有作用域。于是一个函数里
#   很容易写出这种结构:
#       execute if score #S ... matches <A> run function F    # F 内部会把 #S 改成别的值
#       execute if score #S ... matches <B> run <动作>        # ← 这里读到的已经不是原来的 #S
#   两条守卫本该"互补/互斥", 却可能**同时成立** ⇒ 同一个动作被跑两遍(数值翻倍),
#   而且完全静默(没有报错、没有日志、静态也看不出来)。
#   真实事故 2026-10-08: manacore internal/cooldown/reduce 的两条互补守卫共用 #amt,
#     `if #amt matches ..0 run reduce_sec`(它把 #amt 改写成 秒x20 = 100/200)
#     之后 `if #amt matches 1.. run reduce_body` 也成立 ⇒ reduce_body 减了**两遍**。
#     波及面: 凡以 {seconds:...} 传参的减冷却全都减 2 倍 ——
#       调色盘 蓝(-5 秒 -> 实减 10 秒, 玩家实测报"打一下就 -10 秒")、
#       风帆 再次使用(3 秒 -> 6 秒)、息影(10 秒 -> 20 秒)、冷却剂Ω / 魔力沸涌(每秒 1 秒 -> 2 秒)。
#     教训: **"判定用的变量"和"被分支改写的变量"不能是同一个名字**; 更稳的写法是
#     把动作收成**唯一一个调用点**(本例: *_sec 只做换算, *_body 只在调用方调一次)。
#   判据(**只抓"互补守卫", 刻意收窄**): 同一文件里同一个 `#S` 有两条守卫,
#     ① 它们的范围是**互补**的(把整数轴切成没有交集的上下两半, 如 `..0` 与 `1..`)——
#        这种对偶本是"if / else if"的写法, 前提是**期间没人动过 #S**;
#     ② 第一条守卫那行调用的函数 F(含传递闭包)会写 `#S`。
#     ⇒ 第二条守卫读到的不是它以为的值, 两条可能同时成立。
#   ★ 为什么不抓"非互补"的重复守卫(两个 `matches 0`、递减阈值 `6..`→`1..`) ——
#     那些恰恰是**故意**让被调函数去改这个分数的(顺序重试 / 固定次数循环), 见反例:
#       debug/tag_rate_go(先试主世界, 采不到再试下界/末地)
#       equipment/sword/myriad/hit_go(6 行递减阈值 + hit_once 自己 -1 = 固定 6 次循环)
#     不加这层收窄会把这两处正例全报出来(实测: 全仓 2 条报告, 全是正例)。
#   ★ 有意为之的例外: 在文件里写 `# guard-clobber-ok: <理由>` 即可豁免。
_CODE = {}


def _code(fnk):
    """去掉空行与注释行之后的正文(注释里常出现函数名/计分项名, 不能当证据)。"""
    if fnk not in _CODE:
        _CODE[fnk] = '\n'.join(
            l for l in ftext(fnk).split('\n')
            if l.strip() and not l.strip().startswith('#'))
    return _CODE[fnk]


_SC_WRITE = re.compile(r'scoreboard\s+players\s+(?!get\b)'
                       r'(?:set|add|remove|reset|enable|operation)\s+(\S+)')
_SC_FCALL = re.compile(r'(?:^|\s|\brun\s+)function\s+([a-z0-9_:/.]+)')
_SC_GUARD = re.compile(r'(?:^|\s)(?:if|unless)\s+score\s+(#\S+)\s+\S+\s+matches\s+(\S+)')


def _rng(tok):
    """把 `matches` 的范围词解析成 (lo, hi); `..` 一侧为 None = 开区间; 解析不了 -> None。"""
    m = re.fullmatch(r'(-?\d*)\.\.(-?\d*)', tok)
    if m:
        lo = int(m.group(1)) if m.group(1) not in ('', '-', '+') else None
        hi = int(m.group(2)) if m.group(2) not in ('', '-', '+') else None
        return (lo, hi)
    if re.fullmatch(r'-?\d+', tok):
        v = int(tok)
        return (v, v)
    return None


def _complement(a, b):
    """a、b 是否互补(把整数轴切成无交集的上下两半, 如 `..0` 与 `1..`)。"""
    if not a or not b:
        return False
    if a[0] is None and a[1] is not None and b[0] is not None and b[1] is None:
        return b[0] == a[1] + 1
    if b[0] is None and b[1] is not None and a[0] is not None and a[1] is None:
        return a[0] == b[1] + 1
    return False
_wrote, _called = {}, {}
for _fk in functions:
    _ct = _QUOT.sub('""', _code(_fk))
    _wrote[_fk] = {m for m in _SC_WRITE.findall(_ct) if m.startswith('#')}
    _called[_fk] = {m for m in _SC_FCALL.findall(_ct) if m != _fk}
_wall = {}


def _writes_all(fnk, seen=None):
    """fnk 及其所有被调函数(传递闭包)写到的 #分数 集合。"""
    if fnk in _wall:
        return _wall[fnk]
    seen = seen or set()
    if fnk in seen:
        return set()
    seen.add(fnk)
    out = set(_wrote.get(fnk, ()))
    for c in _called.get(fnk, ()):
        if c in functions:
            out |= _writes_all(c, seen)
    _wall[fnk] = out
    return out


for _fk in sorted(functions):
    _guards, _calls = [], []
    for _i, _ls in enumerate(ftext(_fk).split('\n'), 1):
        _s = _ls.strip()
        if not _s or _s.startswith('#'):
            continue
        _s2 = _QUOT.sub('""', _s)
        _guards += [(_i, g, _rng(r)) for g, r in _SC_GUARD.findall(_s2)]
        _calls += [(_i, c) for c in _SC_FCALL.findall(_s2)
                   if c in functions and c != _fk]
    _bad = None
    for _g1, _S, _r1 in _guards:
        for _g2, _S2, _r2 in _guards:
            if _S2 != _S or _g2 <= _g1 or not _complement(_r1, _r2):
                continue
            for _cl, _cf in _calls:
                if _g1 <= _cl < _g2 and _S in _writes_all(_cf):
                    _bad = (_S, _g1, _cl, _cf, _g2)
                    break
            if _bad:
                break
        if _bad:
            break
    if _bad and 'guard-clobber-ok' not in ftext(_fk):
        _S, _g1, _cl, _cf, _g2 = _bad
        R['guardclob'].append((functions[_fk], _g1,
            '共享计分项 %s 的**互补守卫**(第 %d 行 / 第 %d 行)本该互斥, 但第 %d 行调用的 %s '
            '会改写 %s —— 后一条守卫读到的已不是原来的值, 两条可能同时成立, 动作跑两遍'
            '(数值翻倍, 静默)。修法 = 判定变量与结果变量分开, 或把动作收成'
            '**唯一一个调用点**(如 `*_sec` 只换算、`*_body` 只在调用方调一次)。'
            % (_S, _g1, _g2, _cl, _cf, _S)))

# ---- 70) retabort: 靠"被调函数里的 return"中断自己 ----
#   `return` 只结束**它自己那次调用**。所以这种写法是无效的:
#       execute if <坏> run function helper     # helper 里写着 return 0
#       ... (本函数继续往下跑)
#       data modify storage zx:out r.ok set value 1b   # ← 照样执行, 校验被吞
#   正确姿势: helper 只写"标记分/标记 NBT", 由调用方判 + `execute ... run return`。
#   真实事故 2026-10-07: upgrade/api/fit 调 fit_slot_free(内含 return 0)
#   ⇒ "2 个自由槽"的上限失效, 玩家可以无限敲(用户报"不限多少都可以敲")。
_refusers = set()
for _fk in sorted(functions):
    _t = ftext(_fk)
    if re.search(r'(?:^|\s)return\b', _t, re.M) and 'zx:out r.reason' in _t:
        _refusers.add(_fk)
_okline = re.compile(r'zx:out\s+r\.ok\s+set\s+value\s+1b')
_callany = re.compile(r'(?:^|\s|\brun\s+)function\s+(#?[a-z0-9_:/.]+)')
for _fk in sorted(functions):
    _lines = ftext(_fk).split('\n')
    for _i, _ls in enumerate(_lines, 1):
        _s = _ls.strip()
        if not _s or _s.startswith('#'):
            continue
        _hit = None
        for _cf in _callany.findall(_QUOT.sub('""', _s)):
            if _cf in _refusers and _cf != _fk:
                _hit = _cf
                break
        if not _hit:
            continue
        for _j in range(_i, len(_lines)):
            if (_okline.search(_lines[_j])
                    and not _lines[_j].lstrip().startswith('#')):
                R['retabort'].append((functions[_fk], _i,
                    '第 %d 行调用了 %s(它内部有 return + 写 zx:out r.reason), 但本函数'
                    '第 %d 行还会把 zx:out r.ok 置成 1b —— `return` 只能中断被调函数'
                    '本身, 这里照样往下跑, 那次校验被静默吞掉。改成"helper 只写标记, '
                    '调用方判 + execute ... run return"。'
                    % (_i, _hit, _j + 1)))
                break

# ---- 71) atkonce: 文案写"每次攻击"的入口没按游戏刻去重 ----
#   `player_hurt_entity` 是**每命中一个生物触发一次** —— 横扫打 3 只, 同一次平A
#   会让入口函数同一刻跑 3 遍 ⇒ 文案里的"每次攻击"实际变成"每次命中"(3 倍, 静默)。
#   口径(玩家 2026-10-07 定, 以后一律照此):
#     文案「每次攻击(后)」   -> 一次平A算一次(命中几只都一样)
#     文案「攻击到生物」     -> 才按命中数算(不需要去重)
#   真实事故 2026-10-07: 脑髓蛭攒「蛊虫」+3 层 / 天使核心扣 3×80 魔力并铺 3 轮圣痕 /
#                       陨星 10% 掷 3 次骰子(≈27%) / 升级·魔力增殖打 3 只回 15 魔力。
#   判据(名单式): 名单里每条入口函数必须含"自己的刻戳"去重指纹 ——
#     `execute if score @s <obj> = #now manacore.meta run return 0`
#     `scoreboard players operation @s <obj> = #now manacore.meta`
#   ★ 每件各用一个计分项, 不共用(同一次平A可能同时命中多个入口, 共用会互相吞)。
#   ★ 名单要在 check 与 core/load 双向一致: 新增"每次攻击"型入口时, 两处都要加。
_PER_ATTACK = {
    'sweetdream:equipment/armor/brain_leech/attack': 'zx.bl_lt',
    'sweetdream:equipment/axe/angel_core/hit': 'zx.ac_lt',
    'sweetdream:equipment/axe/meteor/hit': 'zx.mt_lt',
    'sweetdream:upgrade/api/on_hit': 'zx.up_lt',
    # 热熔: 只有①「熔解」状态那半是"每攻击一次"(②是"攻击到生物"、按命中数, 故意不去重)。
    #   ★ 同一个入口里两种口径 = 两件事的顺序有意义: ①的 return 会中断整个函数,
    #     所以②必须排在①之前(见 hit 头部注释)。
    'sweetdream:equipment/sword/remelt/hit': 'zx.rm_lt',
    # 第三批(2026-10-07 批1·剑): 文案都是"每次攻击(后)" -> 各用一个刻戳去重
    'sweetdream:equipment/sword/verdict/hit': 'zx.vd_lt',
    'sweetdream:equipment/sword/tinder/hit': 'zx.td_lt',
    'sweetdream:equipment/sword/rebound/hit': 'zx.rb_lt',
    # 第三批(2026-10-07 批2·斧): 文案都是"每次攻击" -> 各用一个刻戳去重
    'sweetdream:equipment/axe/pyre/hit': 'zx.py_lt',
    'sweetdream:equipment/axe/ballad/hit': 'zx.bd_lt',
    'sweetdream:equipment/axe/thunderclap/hit': 'zx.tc_lt',
    'sweetdream:equipment/axe/azure_star/hit': 'zx.as_lt',
}
for _fn, _obj in sorted(_PER_ATTACK.items()):
    if _fn not in functions:
        continue
    _t = ftext(_fn)
    if not re.search(r'if\s+score\s+@s\s+%s\s*=\s*#now' % re.escape(_obj), _t) \
            or not re.search(r'operation\s+@s\s+%s\s*=\s*#now' % re.escape(_obj), _t):
        R['atkonce'].append((functions[_fn],
            '这个入口的文案是"每次攻击", 但函数里找不到按游戏刻去重的指纹 —— 需要 '
            '`execute if score @s %s = #now manacore.meta run return 0` + '
            '`scoreboard players operation @s %s = #now manacore.meta`。'
            '`player_hurt_entity` 每命中一只触发一次, 不去重则同一次平A结算 N 遍'
            '(横扫打 3 只 = 3 倍, 静默)。' % (_obj, _obj)))

# ---- 72) upreq: 升级定义表的 req 链必须"指得着、同系、不成环" ----
#   `req` = "敲这条之前必须先有哪条"的前置 id(α -> β -> Ω)。三种写坏法都**完全静默**:
#     · 指向不存在的 id   -> 这条升级永远敲不上(fit_req 判不过);
#     · 成环(A->B->A)     -> 前置校验互相等对方; 且无色石的"整链返还"是沿 req 递归,
#                            会**无限递归**(2026-10-07 加 uncolor_give 递归时自查到风险);
#     · 跨 series / 跳级  -> 链条意义不明(定义里 α/β/Ω 必须同 series 且 tier 差 1)。
#   顺带查同一 series 里 tier 不能重复 —— 覆盖制按 tier 取最高, 重复就说不清算哪条。
_urq_def = {}
_urq_path = ROOT / 'sweetdream' / 'data' / 'sweetdream' / 'function' / 'upgrade' / 'def' / 'load.mcfunction'
if _urq_path.exists():
    for _urq_ln, _urq_ls in enumerate(_urq_path.read_text(encoding='utf-8', errors='ignore').split('\n'), 1):
        if _urq_ls.lstrip().startswith('#') or 'updef.' not in _urq_ls:
            continue
        _urq_m = re.search(r'updef\."([^"]+)"\s*set\s*value\s*\{', _urq_ls)
        if not _urq_m:
            continue
        _urq_body = _urq_ls[_urq_m.end() - 1:]
        _urq_r = re.search(r'req:"([^"]*)"', _urq_body)
        _urq_s = re.search(r'series:"([^"]*)"', _urq_body)
        _urq_t = re.search(r'tier:([0-9]+)', _urq_body)
        _urq_def[_urq_m.group(1)] = {
            'ln': _urq_ln,
            'req': _urq_r.group(1) if _urq_r else '',
            'series': _urq_s.group(1) if _urq_s else '',
            'tier': int(_urq_t.group(1)) if _urq_t else None}
for _urq_id, _urq_d in sorted(_urq_def.items()):
    _urq_r = _urq_d['req']
    if not _urq_r:
        continue
    # ① req 指得着吗
    if _urq_r not in _urq_def:
        R['upreq'].append((_urq_path, _urq_d['ln'],
            'updef."%s" 的 req 指向不存在的 id "%s" ⇒ 这条升级**永远敲不上**'
            '(fit_req 判不过、静默无报错); 无色石的整链返还也会断在这里。'
            % (_urq_id, _urq_r)))
        continue
    _urq_rd = _urq_def[_urq_r]
    # ② 同 series 吗
    if _urq_d['series'] and _urq_rd['series'] and _urq_d['series'] != _urq_rd['series']:
        R['upreq'].append((_urq_path, _urq_d['ln'],
            'updef."%s"(series %s) 的 req 指向 "%s"(series %s) —— 前置必须**同系列**。'
            % (_urq_id, _urq_d['series'], _urq_r, _urq_rd['series'])))
    # ③ tier 正好差 1 吗
    elif (_urq_d['tier'] is not None and _urq_rd['tier'] is not None
          and _urq_d['tier'] != _urq_rd['tier'] + 1):
        R['upreq'].append((_urq_path, _urq_d['ln'],
            'updef."%s"(tier %s) 的 req 指向 "%s"(tier %s) —— 前置必须是**正好低一级**'
            '(差 1); 跳级会让 fit_req 与覆盖制对不上。'
            % (_urq_id, _urq_d['tier'], _urq_r, _urq_rd['tier'])))
# ④ req 链不成环
for _urq_id in sorted(_urq_def):
    _urq_seen, _urq_cur = [], _urq_id
    while _urq_cur and _urq_cur in _urq_def:
        if _urq_cur in _urq_seen:
            R['upreq'].append((_urq_path, _urq_def[_urq_id]['ln'],
                'updef."%s" 的 req 链成环: %s ⇒ 前置校验互相等对方, 且无色石的整链返还'
                '(uncolor_give 沿 req 递归)**会无限递归**。'
                % (_urq_id, ' -> '.join(_urq_seen + [_urq_cur]))))
            break
        _urq_seen.append(_urq_cur)
        _urq_cur = _urq_def[_urq_cur]['req']
# ⑤ 同一 series 里 tier 不能重复
_urq_tier_seen = {}
for _urq_id, _urq_d in sorted(_urq_def.items()):
    if not _urq_d['series'] or _urq_d['tier'] is None:
        continue
    _urq_k = (_urq_d['series'], _urq_d['tier'])
    if _urq_k in _urq_tier_seen:
        R['upreq'].append((_urq_path, _urq_d['ln'],
            'updef."%s" 与 "%s" 同属 series "%s"、tier 都是 %s —— 覆盖制按 tier 取最高,'
            '重复就说不清算哪条。' % (_urq_id, _urq_tier_seen[_urq_k],
                                    _urq_d['series'], _urq_d['tier'])))
    else:
        _urq_tier_seen[_urq_k] = _urq_id

# ---- 73) nbtrange: NBT 复合里写了 `key:1..` 范围写法 ----
#   1.21.5 的 NBT 读取器 **不接受** `1..` / `..1` 这种范围写法(选择器 nbt= 一样):
#   报 "Whilst parsing command on line N: 应为十进制数", 后果是**整个函数加载失败**
#   (一条命令都不跑, 而且只在 latest.log 里报, 游戏里表现为"装备没反应")。
#   要判"某个数值字段 >= X", 只能逐实体 `data get entity @s <字段>` 存进分数再判
#   —— 见 equipment/armor/immolate/check_burn 的成熟写法。
#   真实事故 2026-10-07: equipment/sword/tinder/burn 写了
#   `unless data entity @s {Fire:1..}` ⇒ 整个 burn 不加载(用户报"点火没反应")。
_nbtrange = re.compile(r'[\{,\[]\s*[A-Za-z_][A-Za-z0-9_.]*\s*:\s*(?:-?\d+[bBsSlLfFdD]?\s*\.\.|\.\.\s*-?\d+[bBsSlLfFdD]?)')
for _fk in sorted(functions):
    for _ln, _ls in enumerate(ftext(_fk).split('\n'), 1):
        _s = _ls.strip()
        if not _s or _s.startswith('#'):
            continue
        _body = _s[1:].strip() if _s.startswith('$') else _s
        if _nbtrange.search(_QUOT.sub('""', _body)):
            R['nbtrange'].append((functions[_fk], _ln,
                'NBT 里写了范围写法(`key:1..` / `key:..1`) —— 1.21.5 不接受这种语法, '
                '会报 "Whilst parsing command on line N: 应为十进制数" 并让**整个函数'
                '加载失败**( Whilst parsing ...)。改法: 逐实体 `data get entity @s <字段>` '
                '存分数再判(见 immolate/check_burn)。: ' + _body[:90]))

# ---- 74) selfclr: 先把自己清零, 后面又按原阈值判自己(恒假) ----
#   形状: `execute if score @s zx.X matches <R> run scoreboard players set @s zx.X 0`
#   之后(同一函数内)又出现 `... if score @s zx.X matches <R> ...` —— 那个"改"已经
#   把值压到 0, 后续判据 `<R>`(如 `5..`)当场变假 ⇒ 那几条命令**永远不执行**,
#   而且不报错(不等于函数加载失败, 属于"静默死分支", 只能靠本规则抓)。
#   ★ 口径: **同一条计分项上"判"与"改"交错时, 把"改"放到该分支的所有"判"之后。**
#   真实事故 2026-10-08: equipment/sword/myriad/on_hit 把 `set @s zx.mq_h5 0`
#   排在 tellraw / playsound 之前 ⇒ "特殊技能就绪"提示与音效从来没出现过
#   (玩家反馈"触发特殊技能时没有提示", 而窗口本身照开)。
#   ★ 同类: scoreeq(写成 `==`)、规则 58(每秒清 + 同秒判)、atkonce(入口同刻重复)。
_selfclr = re.compile(r'^execute if score @s (zx\.[a-z0-9_]+) matches (\S+) '
                      r'run scoreboard players set @s \1 (-?\d+)$')
for _fk in sorted(functions):
    _lines = ftext(_fk).split('\n')
    for _ln, _ls in enumerate(_lines, 1):
        _s = _ls.strip()
        if not _s or _s.startswith('#'):
            continue
        _body = _s[1:].strip() if _s.startswith('$') else _s
        _m = _selfclr.match(_body)
        if not _m:
            continue
        _obj, _rng = _m.group(1), _m.group(2)
        _judge = 'if score @s %s matches %s' % (_obj, _rng)
        for _j in range(_ln, min(_ln + 6, len(_lines))):
            _jls = _lines[_j].strip()
            if not _jls or _jls.startswith('#'):
                continue
            if _judge in _jls:
                R['selfclr'].append((functions[_fk], _ln,
                    '先把自己清零(`set @s %s 0`)又在后面按 `matches %s` 判自己 —— '
                    '那条判据恒假, 后面的命令**永远不执行**(静默死分支)。'
                    '改法: 把"清零"移到该分支所有"判"之后。: %s' % (_obj, _rng, _body[:80])))
                break

# ---- 75) mqgate: 超限·万念/千散 —— 剑魂的三条口径必须真的被门控住 ----
#   口径(用户 2026-10-08 定稿): 千散那段描述里的"**本武器**"= **千散**
#     (剑魂整套机制: 召唤 / 每魂重复一次 / 清除 / 居合, 只写在千散那段里)。于是:
#       · 清剑魂 = **主动放千散**   (主动放万念不清、被动的窗口技能也不清)
#       · 重复   = **千散口径**的技能伤害才 1 + 剑魂数 次
#       · 进居合 = **千散口径** + 剑魂 >= 5
#   三道都挂在那两个"本次施法"的假玩家上: #mq_qs(1 = 本次是千散口径)
#   / #mq_pas(1 = 本次是被动兑现)。★ 判据必须写 `matches 1` 正判:
#   假玩家没 set 过时 `matches 0` 不成立(见 RULES「没分数≠0」), 写成 `matches 0`
#   会让"主动放万念"反过来清剑魂 —— 正是本次要修的那个现象。
#   这里只做**存在性/形状**断言(和 smwind 一样只认非注释行, 免得把调用注释掉还假绿)。
#   真实反馈 2026-10-08: 用户"为什么我使用万念后剑魂也会清除" —— 老实现只判
#   zx.mq_ol, 于是主动放万念(它自己又不攒剑魂)把攒的全清光, 一声不响。
_MQSW = ROOT / 'sweetdream' / 'data' / 'sweetdream' / 'function' / 'equipment' / 'sword'
_MQ_GQ = '#mq_qs zx.meta matches 1'
_MQ_GP = '#mq_pas zx.meta matches 1'


def _mqcode(rel):
    """读一个万念/千散函数的**非注释**行; 文件不存在返回 None。"""
    _p = _MQSW / (rel + '.mcfunction')
    if not _p.exists():
        return None
    return [l for l in _p.read_text(encoding='utf-8', errors='ignore').splitlines()
            if l.strip() and not l.strip().startswith('#')]


# ① tail: 清剑魂那一行必须被两道门控卡住, 且末尾必须复位 #mq_qs
_tl, _TP = _mqcode('myriad/tail'), str(_MQSW / 'myriad' / 'tail.mcfunction')
if _tl is None:
    R['mqgate'].append((_TP, '找不到 myriad/tail.mcfunction(万念/千散放完技能的公共收尾)'))
else:
    _clear = [l for l in _tl if 'myriad/soul_clear' in l and ' run ' in l]
    if not _clear:
        R['mqgate'].append((_TP, '没有调用 myriad/soul_clear —— 主动放千散不清剑魂, '
                                 '"剑魂"会永久留在身上(文案要求技能结束后清除)'))
    else:
        if not any(_MQ_GQ in l for l in _clear):
            R['mqgate'].append((_TP, '清剑魂那行缺 `%s` 门控 —— 主动放万念(它自己又不攒'
                                     '剑魂)会把攒的剑魂一次清光(真实反馈: 用户"为什么我'
                                     '使用万念后剑魂也会清除")' % _MQ_GQ))
        if not any(_MQ_GP in l for l in _clear):
            R['mqgate'].append((_TP, '清剑魂那行缺 `%s` 门控 —— 特殊技能窗口(被动兑现)'
                                     '会跟着清剑魂, 与用户口径"被动触发的不消耗"相反' % _MQ_GP))
    if not any(re.match(r'^scoreboard players set #mq_qs zx\.meta 0\s*$', l) for l in _tl):
        R['mqgate'].append((_TP, '末尾没有 `scoreboard players set #mq_qs zx.meta 0` —— '
                                 '本次的"千散口径"会漏给下一次施法(下一次放万念也会清剑魂)'))

# ② hit_go: 两条"按剑魂重复"的赋值行都必须带千散口径
_hg, _HP = _mqcode('myriad/hit_go'), str(_MQSW / 'myriad' / 'hit_go.mcfunction')
if _hg is None:
    R['mqgate'].append((_HP, '找不到 myriad/hit_go.mcfunction(把算好的伤害打出去那一段)'))
else:
    _rep = [l for l in _hg
            if '#mq_rep zx.meta' in l and ('zx.mq_soul' in l or 'add #mq_rep' in l)]
    if len(_rep) < 2:
        R['mqgate'].append((_HP, '找不到"按剑魂重复"那两条(#mq_rep = 剑魂数 / #mq_rep +1)'
                                 ' —— 代码形状改了, 请先看 hit_go 再改本规则'))
    for _l in _rep:
        if _MQ_GQ not in _l:
            R['mqgate'].append((_HP, '"按剑魂重复"那行缺 `%s` 门控 —— 主动放万念也会按'
                                     '剑魂重复 1+N 次(这句只写在千散那段描述里)' % _MQ_GQ))

# ③ 两把 cast 各自声明口径(千散 1 / 万念 0), 缺一个两条规则一起歪
for _rel, _val, _who in (('qiansan/cast', '1', '千散'), ('myriad/cast', '0', '万念')):
    _ls, _fp = _mqcode(_rel), str(_MQSW / (_rel + '.mcfunction'))
    _want = 'scoreboard players set #mq_qs zx.meta ' + _val
    if _ls is None:
        R['mqgate'].append((_fp, '找不到 %s.mcfunction' % _rel))
    elif _want not in [l.strip() for l in _ls]:
        R['mqgate'].append((_fp, '缺 `%s` —— %s这把没声明"本次施法"的口径, '
                                 '声明丢了会让另一把跟着吃千散那套剑魂规则' % (_want, _who)))

# ④ ju_check: "满 5 进居合"也认千散口径
_jc, _JP = _mqcode('myriad/ju_check'), str(_MQSW / 'myriad' / 'ju_check.mcfunction')
if _jc is None:
    R['mqgate'].append((_JP, '找不到 myriad/ju_check.mcfunction'))
else:
    _ju = [l for l in _jc if 'myriad/ju_enter' in l and ' run ' in l]
    if not _ju:
        R['mqgate'].append((_JP, '没有调用 myriad/ju_enter —— 集满 5 个剑魂也进不了「居合」'))
    elif not any(_MQ_GQ in l for l in _ju):
        R['mqgate'].append((_JP, '进居合那行缺 `%s` 门控 —— 主动放万念(与剑魂无关那一把)'
                                 '也会触发「居合」(文案写的是"使用了**该技能**")' % _MQ_GQ))

# ---- 77) attrprefix: attribute 用了 1.21.2 之前带前缀的属性名 ----
#   1.21.2 起原版把属性注册名里的 `generic.` / `horse.` / `player.` / `zombie.` 前缀
#   **整体移除了**:
#     minecraft:generic.attack_speed        -> minecraft:attack_speed
#     minecraft:generic.max_health          -> minecraft:max_health
#     minecraft:player.block_interaction_range -> minecraft:block_interaction_range
#   写旧名不是"运行时找不到那个属性、命令静默失败", 而是**解析期直接失败**(实测 1.21.5):
#     Whilst parsing command on line N: 无法找到类型为"minecraft:attribute"的元素
#       "minecraft:generic.attack_speed"  at position ...
#   ⇒ **整个函数加载失败**(一条命令都不跑, 只在 latest.log 报一行)。
#   权威名: jar 里属性注册表 Attributes 类(bzl.class) 的注册串**全是无前缀**的
#   (attack_speed / attack_damage / max_health / movement_speed / armor / scale …)。
#   本包既有代码(macore meteor / freeze 等)用的都是无前缀写法。
#   真实事故 2026-10-10: lib/atk_charge 第 40 行写成 `minecraft:generic.attack_speed`
#   ⇒ 工具整份不加载, 玩家 `/tag @s add zx.dbg_atk` 后平A 毫无输出(零日志)。
_ATTR_OLDPREFIX = re.compile(r'minecraft:(?:generic|horse|player|zombie)\.[a-z_]')
for _fk in sorted(functions):
    for _ln, _ls in enumerate(ftext(_fk).split('\n'), 1):
        _s = _ls.strip()
        if not _s or _s.startswith('#'):
            continue
        if 'attribute' not in _s:
            continue
        _m = _ATTR_OLDPREFIX.search(_s)
        if _m:
            R['attrprefix'].append((functions[_fk], _ln,
                '属性名带了 1.21.2 之前的前缀 `%s` —— 该行解析失败 ⇒ **整个函数不加载**'
                '(一条命令都不跑, 只在 latest.log 报一行)。改成无前缀写法'
                '(如 minecraft:attack_speed / minecraft:max_health)。: %s'
                % (_m.group(0), _s[:90])))

# ---- 78) cdstop: "冻结冷却"必须"先查后冻", 且冻结要带"未就绪"保护 ----
#   形状: 同一函数里既有 `manacore:api/cooldown/check` 又有 `.../cooldown/increase`
#   (= 正在实现文案里的"停止正常冷却缩减"那种每秒冻结; 见 RULES 同名节
#    与 equipment/axe/charge/mode_tick)。
#   ★ manacore 冷却是"记结束时刻 end"式的(绝对游戏刻, 无全局衰减器) ⇒
#     · 若 increase(把 end 后推 20 刻) 排在同拍的 check **之前**: 冷却恰好到点那一刻
#       会被 +20 又推远 ⇒ "冷却完成 -> 自动使用"永远触发不了(静默死循环)。
#     · 若 increase 没有"未就绪"保护: 同理 —— 冷却已就绪时记录已被 check 惰性清掉,
#       写成无条件会在记录尚存时把"刚好"推远。
#   只对"同时用 check + increase"的函数报(纯"加冷却惩罚"的函数没有 check, 不受影响)。
_CD_CHECK = 'manacore:api/cooldown/check'
_CD_INC = 'manacore:api/cooldown/increase'
for _fk in sorted(functions):
    _ci = _cc = None
    _inc_line = ''
    for _ln, _ls in enumerate(ftext(_fk).split('\n'), 1):
        _s = _ls.strip()
        if not _s or _s.startswith('#'):
            continue
        if _cc is None and _CD_CHECK in _s:
            _cc = _ln
        if _ci is None and _CD_INC in _s:
            _ci, _inc_line = _ln, _s
    if _ci is None or _cc is None:
        continue
    if _ci < _cc:
        R['cdstop'].append((functions[_fk], _ci,
            '"冻结冷却"里 increase 排在 check **之前** —— 同拍先冻会把"刚到点的冷却"'
            '又后推 20 刻 ⇒ "冷却完成→自动使用"永远触发不了(静默死循环)。'
            '改成"先 check、后 increase"。: %s' % _inc_line[:90]))
    elif not ('unless' in _inc_line or ' if ' in _inc_line):
        R['cdstop'].append((functions[_fk], _ci,
            '"冻结冷却"的 increase 没有"未就绪"保护 —— 冷却已就绪(记录已被 check 惰性'
            '清掉)时本应跳过冻结; 无条件会让刚好的冷却被推远。改成 '
            '`execute unless data storage manacore:out r{ready:1b} run function …/increase`。'
            ': %s' % _inc_line[:90]))

# ---- 79) freezegate: 冻结冷却只能挂"第二形态"(chg_mode), 不能挂"超限版快照"(chg_ol) ----
#   形状: 调用 `.../charge/freeze_cd`(文案"该技能停止正常冷却缩减"的冻结)的那一行,
#   判据必须是 `zx.chg_mode`(已进第二形态)。
#   ★ 真实事故 2026-10-10: 修"永久冻结"(⑨)那次把冻结从 chg_mode 挪到"状态期间", 判据
#     却写成 `zx.chg_ol matches 1` —— 而 chg_ol 是 cast 那刻拍的"**这次施法**是不是超限版"
#     的快照, **第一形态同样成立** ⇒ 第一阶段(第一形态)的状态也被冻上了。
#     lore(用户原文)是 "该状态结束后若该技能完成冷却, 则自动使用**且**该技能停止正常
#     冷却缩减" ⇒ 冻结属于"自动使用之后"(= 第二形态)那一句; 第一阶段冷却照常自然走。
#     (用户原话: "在第一阶段是不冻结的" / "超载阶段才会冻结")
#   ★ 这条和 78(`cdstop`)是两码事: 78 管 freeze_cd **内部**"先查后冻"的顺序, 79 管
#     它的**调用点**该由谁触发。
_FREEZE_FN = 'sweetdream:equipment/axe/charge/freeze_cd'
for _fk in sorted(functions):
    for _ln, _ls in enumerate(ftext(_fk).split('\n'), 1):
        _s = _ls.strip()
        if not _s or _s.startswith('#') or _FREEZE_FN not in _s:
            continue
        if 'zx.chg_mode' not in _s:
            R['freezegate'].append((functions[_fk], _ln,
                '冻结冷却(freeze_cd)的调用点没用 `zx.chg_mode`(第二形态) 当判据 —— '
                '冻结**只在第二形态(= 超载阶段)**的状态期间生效, 第一阶段(第一形态)的'
                '状态冷却要照常自然 -1/秒。别用 `zx.chg_ol`(那是"这次施法是不是超限版"的'
                '快照, 第一形态也成立 ⇒ 第一阶段被误冻)。: %s' % _s[:90]))

# ---- 80) olfit: 超限石 apply 里的 `of` 必须是**英文 zx id**(= 文件名), 且 oldef 真有条目 ----
#   `of` 的三处用途(见 overlimit/api/fit + station/api/apply_go)全都要英文 id:
#     ① `oldef."$(of)"` 取超限定义 —— 写中文名 -> 键不存在 -> reason=no_def;
#     ② `zx:["$(of)"]` 认副手装备 —— 物品 custom_data.zx 里存的**一律是英文 id**;
#     ③ 写进物品 `custom_data.ol`, 之后 station/api/lore_refresh 也拿它当 oldef 键。
#   ★ 真实事故 2026-10-10: 批 G/H 生成器格式参数错位, 4 块石头的 apply 写成
#     `of:"偏振光"`(中文名) ⇒ 全部 no_def, 敲上去只回"这把武器没有超限定义(定义表缺
#     条目)", 一件都敲不上(玩家: "为什么我敲偏振光显示没有超限条目")。中文名只该出现在
#     给玩家看的文案里。这条同时守"超限石三件套(item/advancement/apply)齐全"。
_olf_apply_dir = ROOT / 'sweetdream' / 'data' / 'sweetdream' / 'function' / 'overlimit' / 'apply'
_olf_def_path = ROOT / 'sweetdream' / 'data' / 'sweetdream' / 'function' / 'overlimit' / 'def' / 'load.mcfunction'
_olf_defs = set()
if _olf_def_path.exists():
    for _ln in _olf_def_path.read_text(encoding='utf-8', errors='ignore').split('\n'):
        _m = re.search(r'oldef\."([^"]+)"\s*set\s*value', _ln)
        if _m:
            _olf_defs.add(_m.group(1))
if _olf_apply_dir.exists():
    for _p in sorted(_olf_apply_dir.glob('*.mcfunction')):
        _uid = _p.stem
        _hit = None
        for _ln, _ls in enumerate(_p.read_text(encoding='utf-8', errors='ignore').split('\n'), 1):
            if _ls.lstrip().startswith('#') or 'of:' not in _ls:
                continue
            _m = re.search(r'of:"([^"]*)"', _ls)
            if _m:
                _hit = (_ln, _m.group(1), _ls.strip())
                break
        if _hit is None:
            R['olfit'].append((_p, 1, 'overlimit/apply/%s 里找不到 `of:"..."` —— '
                '石头没告诉 fit 自己属于哪件装备, 敲上去必然 no_def。' % _uid))
            continue
        _ln, _of, _s = _hit
        if _of != _uid:
            R['olfit'].append((_p, _ln,
                'apply 的 of="%s" 与文件名 "%s" 不一致 —— of 必须是**英文 zx id**'
                '(= 装备 custom_data.zx 里存的那个), 写中文/显示名既取不到 oldef 也没法和'
                '副手装备匹配 ⇒ 敲上去只报"这把武器没有超限定义(定义表缺条目)"。: %s'
                % (_of, _uid, _s[:80])))
        elif _of not in _olf_defs:
            R['olfit'].append((_p, _ln,
                'apply 的 of="%s" 在 overlimit/def/load 里没有 oldef."%s" 定义 ⇒ '
                'fit 第一行就判 no_def, 这件永远敲不上。' % (_of, _of)))
        if not (ROOT / 'sweetdream' / 'data' / 'sweetdream' / 'function' / 'overlimit'
                / 'item' / (_uid + '.mcfunction')).exists():
            R['olfit'].append((_p, 1, '超限石三件套不齐: 缺 overlimit/item/%s.mcfunction(石头本体给不出来)。' % _uid))
        if not (ROOT / 'sweetdream' / 'data' / 'sweetdream' / 'advancement' / 'overlimit'
                / (_uid + '.json')).exists():
            R['olfit'].append((_p, 1, '超限石三件套不齐: 缺 advancement/overlimit/%s.json(右键石头不会触发 apply)。' % _uid))

# ---- 81) eyedist: 瞄"眼睛"的光束/线, 不能用小 distance 当"到达/命中"判据 ----
#   形状: 某件装备目录里有文件用 `facing entity <目标> eyes` 定朝向(光束/线是沿
#   "眼睛 -> 目标眼睛"的斜线走的), 那么**同目录**里任何"小 distance 判据"
#   (distance=0..X 或 distance=..X, X<=1.6, 且该行不是 marker/item_display)都可疑。
#   为什么必然坏: distance 量的是"执行位置 -> 生物**脚底坐标**"的距离, 和判定箱无关。
#   光线走到目标**头上**那一点时, 离脚底还差整整一个眼高(所有生物 >=1.6) ⇒ 阈值 <=1.6
#   **恒假** ⇒ 递归一路走到步数上限才停, 现象 = 光束**越过生物继续往前飞**。
#   两种正解: ① 判定箱相交 `dx/dy/dz`(见 projectile/ball/tick ② 与 bow/cold_crow/step ②);
#             ② 朝向改成 `facing entity <目标> feet`(见 bow/arc/wire)。
#   ★ 阈值取 1.6: 现有仓库里瞄眼睛的目录只有 polarized_light 和 projectile/ball, 后者
#     合法的"目标搜索"用的是 ..1.8/..2.5/..3.0(>1.6) —— 所以这条规则现在 0 误报。
#   真实事故 2026-10-10: equipment/staff/polarized_light/beam_step ④ 写
#   `@e[tag=zx.pl_cur,distance=0..0.5]` 判"到达" ⇒ 光束越过生物(用户: "很违和")。
#   讽刺的是 projectile/ball/tick ② 的注释里早就把这一课写明白了 —— 那处没被规则守住。
_ed_eyes_dirs = set()
for _ed_fn in sorted(functions):
    for _ed_ls in ftext(_ed_fn).split('\n'):
        _ed_s = _ed_ls.strip()
        if _ed_s.startswith('#'):
            continue
        if re.search(r'facing\s+entity\s+.*\beyes\b', _ed_s):
            _ed_eyes_dirs.add(str(functions[_ed_fn].parent))
            break
for _ed_fn in sorted(functions):
    _ed_p = functions[_ed_fn]
    if str(_ed_p.parent) not in _ed_eyes_dirs:
        continue
    for _ed_ln, _ed_ls in enumerate(ftext(_ed_fn).split('\n'), 1):
        _ed_s = _ed_ls.strip()
        if _ed_s.startswith('#') or 'distance=' not in _ed_s:
            continue
        if 'type=minecraft:marker' in _ed_s or 'type=marker' in _ed_s:
            continue
        if 'type=minecraft:item_display' in _ed_s or 'type=item_display' in _ed_s:
            continue
        for _ed_m in re.finditer(r'distance=(?:0\.\.|\.\.)([0-9]+(?:\.[0-9]+)?)', _ed_s):
            if float(_ed_m.group(1)) > 1.6:
                continue
            R['eyedist'].append((_ed_p, _ed_ln,
                '这一行用 `distance=%s` 当"到达/命中"判据, 但同目录里有一处 `facing entity '
                '... eyes`(光束沿"眼睛 -> 目标眼睛"的斜线走) —— distance 量的是到生物'
                '**脚底**的距离, 走到目标头上时还差一个眼高(>=1.6) ⇒ 阈值 <=1.6 恒假, '
                '线会**越过生物继续飞**。改判定箱相交(dx/dy/dz)或把朝向改成 feet。: %s'
                % (_ed_m.group(0), _ed_s[:70])))

# ---- 82) tgvocab: 装备 give 的 custom_data.tags 词必须在词汇表(tgdef)里 ----
#   标签(批 A, 2026-10-10) = 给未来**肉鸽地图**查询用的语义关键词(如 dash 位移 /
#   max_mana 最大魔力口径 / liuhuo 涉及流火)。词表是**封闭集**(单一真源
#   .workbuddy/_tags_data.py -> 生成 tg/def/load 的 tgdef)。
#   写错一个词 = 该装备**静默地**查不到(谓词恒不命中), 文件本身看不出任何异常 ——
#   这条就是防拼错、防手滑塞进"没登记的私有资源名"(熔浆/燃灰/酒浆…本来就不该进标签)。
_tg_vocab = set()
_tg_load = ROOT / 'sweetdream' / 'data' / 'sweetdream' / 'function' / 'tg' / 'def' / 'load.mcfunction'
if _tg_load.exists():
    for _ln in _tg_load.read_text(encoding='utf-8', errors='ignore').split('\n'):
        _m = re.search(r'tgdef\."([^"]+)"\s*set\s*value', _ln)
        if _m:
            _tg_vocab.add(_m.group(1))
_tg_give_root = ROOT / 'sweetdream' / 'data' / 'sweetdream' / 'function' / 'equipment'
if _tg_give_root.exists():
    for _p in sorted(_tg_give_root.glob('*/*/give.mcfunction')):
        for _ln, _ls in enumerate(_p.read_text(encoding='utf-8', errors='ignore').split('\n'), 1):
            if not _ls.startswith('give ') or 'tags:[' not in _ls:
                continue
            _m = re.search(r'tags:\[([^\]]*)\]', _ls)
            if not _m:
                continue
            for _t in re.findall(r'"([^"]*)"', _m.group(1)):
                if _t not in _tg_vocab:
                    R['tgvocab'].append((_p, _ln,
                        'custom_data.tags 里的 "%s" 不在词汇表(tg/def/load 的 tgdef)里 —— '
                        '拼错/未登记的标签会让该装备**静默**查不到(谓词恒不命中)。'
                        '词表见 .workbuddy/_tags_data.py; 私有资源名(熔浆/燃灰/酒浆…)不该进标签。: %s'
                        % (_t, _ls.strip()[:70])))

# ---- 84) resetset: player_reset 的"逐项清账清单"必须 == 源码声明的 zx.* 集合(双向) ----
#   审查 N06(2026-10-11): 旧写法 `scoreboard players reset @s`(**不带 objective**)
#   = 清该玩家在**所有**计分项上的分 —— 连别的数据包的分一起清。本包目录里就住着
#   第二个数据包 naturewind(nw.anim / nw.cast_t) ⇒ 现场可证被误清(不是假想)。
#   现在清单由 .workbuddy/_gen_reset_scores.py 从**源码**生成(单一真源), 本条守门:
#     · 源码声明了 zx.X 却不在清单 -> "漏清"(账本残留, 装备被动"应加的不加回", 静默)
#     · 清单里有 zx.Y 但源码没声明 -> 拼错 / 已删(白清, 且掩盖真实问题)
#     · 又写回"不带 objective"的全清 -> 直接报(跨包误伤回来)
_reset_fp = (ROOT / 'sweetdream' / 'data' / 'sweetdream' / 'function' / 'event'
             / 'player_reset.mcfunction')
if not _reset_fp.exists():
    R['resetset'].append((str(_reset_fp), 0,
                          'N06: 清账清单文件不见了(player_first_join 也依赖它)'))
else:
    _declared_zx = set()
    for _pack in ('manacore-1.0.0', 'sweetdream'):
        for _p in (ROOT / _pack / 'data').rglob('*.mcfunction'):
            try:
                _t = _p.read_text(encoding='utf-8', errors='ignore')
            except Exception:
                continue
            for _m in obj_add_re.finditer(_t):
                if _m.group(1).startswith('zx.'):
                    _declared_zx.add(_m.group(1))
    _rtxt = _reset_fp.read_text(encoding='utf-8', errors='ignore')
    _listed_zx = set(m.group(1) for m in re.finditer(
        r'scoreboard\s+players\s+reset\s+@s\s+(zx\.[A-Za-z0-9_.]+)', _rtxt))
    for _n in sorted(_declared_zx - _listed_zx):
        R['resetset'].append((str(_reset_fp), 0,
            'N06 漏清: 源码里声明了 %s, 但本清单没有 reset 它 —— 重置后该账本残留, '
            '装备被动"应加的不加回"(静默)。改法: 重跑 '
            '.workbuddy/_gen_reset_scores.py --write' % _n))
    for _n in sorted(_listed_zx - _declared_zx):
        R['resetset'].append((str(_reset_fp), 0,
            'N06 多清: 清单 reset 了 %s, 但全仓没有任何 `scoreboard objectives add` '
            '声明它 —— 名字拼错 / 该计分项已被删, 白清且掩盖真实问题。' % _n))
    if not _listed_zx:
        R['resetset'].append((str(_reset_fp), 0,
            'N06: 清单是空的 —— 命令段应由 _gen_reset_scores.py 生成, 别留下空文件'))
    for _i, _l in enumerate(_rtxt.split('\n'), 1):
        if _l.strip().startswith('#'):
            continue
        if re.fullmatch(r'scoreboard\s+players\s+reset\s+@s', _l.strip()):
            R['resetset'].append((str(_reset_fp), _i,
                'N06 回归: 又写回了"不带 objective"的全清 `scoreboard players reset @s` '
                '—— 会连别的数据包(naturewind 的 nw.*)的分数一起清掉。'))

# ---- 84b) Q02(2026-10-11 四审): player_reset 的尾标记必须存在 ----
#   为什么单开一条: 上面的 _REGRESS 循环把**注释行整个滤掉**了
#   (`if not l.strip().startswith('#')`) ⇒ 任何"锚点是注释"的 must 都永远匹配不到,
#   看着像锁、其实是死锁。这里直接读原文。
#   尾标记的作用: _gen_reset_scores.py 只托管「两个标记之间」的清单, 尾标记之下的
#   手写区(Q02 的镜像重建调用)不会被覆盖。丢了尾标记 ⇒ 下次重跑生成器会把那段
#   整段吃掉 ⇒ Q02 静默失效(而且**当场**看不出任何异常)。
if _reset_fp.exists():
    if '# @@GEN-SCORES-ABOVE@@' not in _reset_fp.read_text(encoding='utf-8', errors='ignore'):
        R['resetset'].append((str(_reset_fp), 0,
            'Q02(四审): 缺尾标记 `# @@GEN-SCORES-ABOVE@@` —— _gen_reset_scores.py 只托管'
            '"两个标记之间"的清单; 尾标记之下是手写区(清账后的镜像重建 resync_go 就在那里)。'
            '丢了尾标记, 下次重跑生成器会把那段整段吃掉 ⇒ Q02 静默失效。'))

# ---- 85) dmgseg: D01 口径 B —— "分量级"伤害的三件套必须成对存在 ----
#   加算池 zx:work add 有**两个消费者**, 走**两套算法**:
#     · 面板侧 lib/skill_mul/padd_apply : smul_<c> ×(1+add.<c>)   ← 逐通道(本来就是 B)
#     · 伤害侧 lib/dmg_add_apply       : (Σseg+x) ×(1+Σadd)      ← 汇总(= 旧口径 A)
#   D01(2026-10-11 用户定 **口径 B**)把伤害侧也改成"逐通道各乘各的分量":
#       dmg = Σ_i seg_i×(1+add_i) + seg_x      (再 × im)
#   这要求**三处同时**成立, 缺一个就是"静默算错"(多通道技能数值偏差, 不报错):
#     ① calc 必须把分量落进 out: r.seg_m/seg_a/seg_o/seg_x 与 r.im;
#     ② dmg_add_apply 必须按分量级重算(调 mul_pct), 且**不得**再读 zx:work ch
#        —— 读回 ch 判通道 = 退回旧口径 A(100mm+10atk+炽天使 = 165 而非 115);
#     ③ dmg_add_put_any(不挑口径: 愿景/共振/桂冠)必须**三条通道各写一份**
#        —— 分段式下 Σseg_i×(1+X)=整段×(1+X) 才是"技能伤害 +X%"的唯一正确写法
#        (旧 F14 的"只写一条"只在**汇总式**下成立; 分段式下只写一条 = 其余段吃不到)。
#   报告验收例: 100mm + 10atk + 炽天使(+50%→atk) = 100 + 15 = **115**。
_segc_fn = functions.get('manacore:internal/damage/calc')
_sega_fn = functions.get('sweetdream:lib/dmg_add_apply')
_segp_fn = functions.get('sweetdream:lib/dmg_add_put_any')
if _segc_fn is None:
    R['dmgseg'].append((str(ROOT), 0, 'D01: 找不到 manacore:internal/damage/calc'))
else:
    _ct = _segc_fn.read_text(encoding='utf-8', errors='ignore')
    for _k in ('r.seg_m', 'r.seg_a', 'r.seg_o', 'r.seg_x', 'r.im'):
        if not re.search(r'storage\s+manacore:out\s+%s\b' % re.escape(_k), _ct):
            R['dmgseg'].append((_segc_fn, 0,
                'D01 口径 B: calc 没有把 %s 落进 manacore:out —— dmg_add_apply 读不到'
                '分量就会按 0/旧值算(静默)。' % _k))
if _sega_fn is None:
    R['dmgseg'].append((str(ROOT), 0, 'D01: 找不到 sweetdream:lib/dmg_add_apply'))
else:
    _at_all = _sega_fn.read_text(encoding='utf-8', errors='ignore')
    _at = '\n'.join(l for l in _at_all.split('\n') if not l.strip().startswith('#'))
    if 'internal/damage/mul_pct' not in _at:
        R['dmgseg'].append((_sega_fn, 0,
            'D01 口径 B: dmg_add_apply 没走 mul_pct —— seg(可达 ~2e9)×(100+add) 会越过 '
            'int32 回绕(同 N10)。'))
    for _k in ('r.seg_m', 'r.seg_a', 'r.seg_o', 'r.seg_x'):
        if not re.search(r'storage\s+manacore:out\s+%s\b' % re.escape(_k), _at):
            R['dmgseg'].append((_sega_fn, 0,
                'D01 口径 B: dmg_add_apply 没读 %s(分量级必须有四条分量)。' % _k))
    if 'zx:work ch' in _at:
        R['dmgseg'].append((_sega_fn, 0,
            'D01 回归: dmg_add_apply 又读快照 zx:work ch 判通道 —— 口径 B 靠分量自动筛选'
            '(seg=0), 读 ch 会把落点退回"整段"(旧口径 A: 100mm+10atk+炽天使 = 165 而非 115)。'))
if _segp_fn is None:
    R['dmgseg'].append((str(ROOT), 0, 'D01: 找不到 sweetdream:lib/dmg_add_put_any'))
else:
    _pt_all = _segp_fn.read_text(encoding='utf-8', errors='ignore')
    _pt = '\n'.join(l for l in _pt_all.split('\n') if not l.strip().startswith('#'))
    _chs = re.findall(r'storage\s+zx:work\s+put\.ch\s+set\s+value\s+"(mm|atk|oth)"', _pt)
    if sorted(set(_chs)) != ['atk', 'mm', 'oth'] or len(_chs) < 3:
        R['dmgseg'].append((_segp_fn, 0,
            'D01 口径 B: dmg_add_put_any 必须给 mm/atk/oth 三条各写一份(分段式下 '
            'Σseg_i×(1+X)=整段×(1+X)); 现在只写了 %s —— 其余通道吃不到这份"技能伤害 +X%%"'
            '(静默)。' % (_chs or '无')))
    if 'zx:work ch' in _pt:
        R['dmgseg'].append((_segp_fn, 0,
            'D01 回归: dmg_add_put_any 又读 zx:work ch 挑通路 —— 口径 B 下应固定写满三条。'))

# ---- 86) creative: 创造模式下"使用武器会凭空多一把"(2026-10-11 用户实测) ----
#   所有带 zx:["itemreplace"] 的武器(剑 20 + 斧 15 + 法杖 12)都靠 consumable 触发技能,
#   同时也会触发 sweetdream:itembackup/consume —— 那是一套"消耗 → 备份 → 下一 tick 回手"。
#   这套系统是为**生存/冒险**写的: 那里 consumable 走完后原版会把那一格设成消耗
#   结果(空), 武器真的没了, 必须补回来。
#   但**创造模式下原版根本不消耗物品**, 手上那把还在 —— 于是 effect_2 的回手
#   (首选槽位 → 放不下就依次找任意空格: offhand/hotbar.N/hotbar.0..8/inventory.0..26
#    共 39 个候选)会把它当成"原格放不下", 往背包某个空格再塞一把同样的武器。
#   ⇒ 修法 = effect_1 里创造模式直接 return(物品没丢就不用还)。两条都要盯:
#     ① 门禁本身还在吗?  ② revoke 必须排在门禁**之前** —— 否则进度停在"已完成",
#        玩家切回生存模式后整个返还链就再也不触发了(静默: 武器用完直接消失)。
_cr_fn = functions.get('sweetdream:internal/itembackup/effect_1')
if _cr_fn is None:
    R['creative'].append((str(ROOT), 0,
        '创造模式幽灵物品: 找不到 sweetdream:internal/itembackup/effect_1 —— '
        '返还链的入口没了(武器用完不回手)。'))
else:
    _cr = '\n'.join(l for l in _cr_fn.read_text(encoding='utf-8', errors='ignore').split('\n')
                    if not l.strip().startswith('#'))
    if 'gamemode=creative' not in _cr:
        R['creative'].append((_cr_fn, 0,
            '创造模式幽灵物品: effect_1 没有 gamemode=creative 门禁 —— 创造模式下原版'
            '不消耗物品, 该格非空 ⇒ effect_2 的 39 个兜底候选会往背包空格再塞一把。'
            '正解: `advancement revoke` 之后加 '
            '`execute if entity @s[gamemode=creative] run return fail`。'))
    else:
        _i_rev = _cr.find('advancement revoke')
        _i_gm = _cr.find('gamemode=creative')
        if _i_rev < 0 or _i_gm < _i_rev:
            R['creative'].append((_cr_fn, 0,
                '创造模式幽灵物品: gamemode=creative 门禁排在了 `advancement revoke` '
                '**之前** —— 创造模式下会直接 return 而**没有撤进度**, 进度永远停在'
                '"已完成", 玩家切回生存模式后整条返还链静默失效(武器用完直接消失)。'))

# ---- 87) pldur: 偏振光"持续 5 秒"的计时单位(2026-10-11 用户实测: 超限版只撑 2.5 秒) ----
#   zx.pl_t 的单位恒为"秒", 但超限版的**结算节奏**是"每 0.5 秒"(half 每 10 刻调一次 tick)。
#   倒计时写在 tick 里 ⇒ 一次 tick 扣 1 = 把"秒"当成"半秒" ⇒ pl_t=5 只撑 **2.5 秒**,
#   与 lore 写的"该效果持续 5 秒"整整差一半。★ 静默: 不报错、不写日志, 只是光早灭一半。
#   正解 = **干活频率与持续时间彻底解耦**: tick 只干活, 倒计时由驱动方按真实时间扣
#   (基础版 second 每 20 刻扣 1; 超限版 half 每 20 刻扣 1, 每 10 刻多结算一次)。
_pl_rm = re.compile(r'scoreboard\s+players\s+remove\s+@s\s+zx\.pl_t')


def _pl_code(_fnk):
    _f = functions.get(_fnk)
    if _f is None:
        return None
    return '\n'.join(l for l in _f.read_text(encoding='utf-8', errors='ignore').split('\n')
                     if not l.strip().startswith('#'))


_pl_files = {'tick': 'sweetdream:equipment/staff/polarized_light/tick',
             'second': 'sweetdream:equipment/staff/polarized_light/second',
             'half': 'sweetdream:equipment/staff/polarized_light/half'}
_pl = {k: _pl_code(v) for k, v in _pl_files.items()}
for _k, _v in _pl.items():
    if _v is None:
        R['pldur'].append((str(ROOT), 0,
            '偏振光持续时间: 找不到 %s —— 光束驱动链断了一环(技能放不出来 / 不结束)。' % _pl_files[_k]))
if _pl.get('tick') and _pl_rm.search(_pl['tick']):
    R['pldur'].append((str(_pl_files['tick'].split('/')[-1]), 0,
        '偏振光持续时间(坑 120): tick 里又在扣 `zx.pl_t` —— tick 的调用节奏在超限版是 '
        '**0.5 秒**一次, 在这里扣 1 等于把"秒"当"半秒", pl_t=5 只撑 2.5 秒(lore 写 5 秒)。'
        '正解: tick 只干活, 倒计时交给驱动方按真实时间扣(second/half 各扣自己的)。'))
for _k in ('second', 'half'):
    _c = _pl.get(_k)
    if _c is None:
        continue
    _m = _pl_rm.search(_c)
    if not _m:
        R['pldur'].append((str(_pl_files[_k]), 0,
            '偏振光持续时间(坑 120): %s 没有扣 `zx.pl_t` —— 光束倒计时没人扣, '
            'zx.pl_t 永远 >0 ⇒ 光线不灭(永久光束 + 每 0.5/1 秒一直结算)。' % _k))
        continue
    if _k == 'half' and not re.search(
            r'if\s+score\s+@s\s+zx\.pl_ct\s+matches\s+20\s+run\s+scoreboard\s+players\s+remove\s+@s\s+zx\.pl_t',
            _c):
        R['pldur'].append((str(_pl_files['half']), 0,
            '偏振光持续时间(坑 120): half 的 `remove zx.pl_t` 没有挂在 **20 刻(1 秒)**闸上 —— '
            '超限版每 10 刻(0.5 秒)就调一次 tick, 必须每 20 刻才扣 1 秒; 挂在 10 刻闸上 '
            '就又把"秒"当"半秒"(pl_t=5 只撑 2.5 秒)。'))

# ---- 88) fdsnap: 堕梦"谁原本在时停里"必须先快照(2026-10-12 用户实测两条 bug) ----
#   skill ⑦ 先给"未时停"的那批上时停(lib/timestop 立刻挂上 zx.stop), 于是:
#     · 下一句再选 `tag=!zx.stop` ⇒ **空集** ⇒ 「白昼梦」一件都没附上;
#     · ⑧ 再选 `tag=zx.stop` ⇒ 把刚被 ⑦ 时停的这批也算成"原本就在时停"
#       ⇒ 3 秒 + 2 秒 = 5 秒(玩家: "说好的 3 秒变成 5 秒")。
#   ★ 通用形态: **"按当前状态选人"的选择器, 不能在改了同一状态之后再求值**
#     —— 必须先把分类抄成快照标签, 后面一律按快照取值(和 selfclr/cdstop 同族:
#     "改"排在"判"前面 ⇒ 后面的判永远不成立)。
_fd_fn = functions.get('sweetdream:equipment/staff/fallen_dream/skill')
if _fd_fn is None:
    R['fdsnap'].append((str(ROOT), 0,
        '堕梦分流快照: 找不到 sweetdream:equipment/staff/fallen_dream/skill。'))
else:
    _fd = _fd_fn.read_text(encoding='utf-8', errors='ignore')
    _fd_code = '\n'.join(l for l in _fd.split('\n') if not l.strip().startswith('#'))
    if 'zx.fd_new' not in _fd_code or 'zx.fd_old' not in _fd_code:
        R['fdsnap'].append((str(_fd_fn), 0,
            '堕梦分流快照(坑 123): skill 里没有 zx.fd_new / zx.fd_old 两组快照标签 —— '
            '时停一挂上 zx.stop 就变了, 后面按 zx.stop 现选 ⇒ 白昼梦落空、新时停的 '
            '被重复 +2 秒(3 秒变 5 秒)。正解 = 改状态**之前**先打两个快照标签。'))
    if re.search(r'target:"@e\[tag=zx\.fd_area,tag=', _fd):
        R['fdsnap'].append((str(_fd_fn), 0,
            '堕梦分流快照(坑 123): 还在用 `target:"@e[tag=zx.fd_area,tag=…]"` 现用现选 —— '
            '⑦ 的时停已经把 zx.stop 改了, 这个选择器求值时要么空集(白昼梦落空)、'
            '要么把新时停的也算进"原本就在时停"(3 秒变 5 秒)。改用 zx.fd_new / zx.fd_old。'))
    if not re.search(r'as\s+@e\[tag=zx\.fd_old\]\s+run\s+scoreboard\s+players\s+add\s+@s\s+zx\.ts_end\s+40',
                     _fd_code):
        R['fdsnap'].append((str(_fd_fn), 0,
            '堕梦分流快照(坑 123): ⑧ 的"+2 秒"没有认 zx.fd_old —— 认 zx.stop 会把 ⑦ '
            '刚时停的这批一起加时(3 秒 -> 5 秒, 与文案不符)。'))
    if not re.search(r'target:"@e\[tag=zx\.fd_area\]",mark:"dream"', _fd_code):
        R['fdsnap'].append((str(_fd_fn), 0,
            '堕梦「白昼梦」(坑 124): mark 没有施给**圈内全体** zx.fd_area —— 只给 '
            'zx.fd_new(原本没时停的那批)的话, 已经在时停里的目标就吃不到白昼梦, '
            '普攻打上去转不了真伤(用户 2026-10-12 拍板: 一律全体)。'))

# ---- 89) ddpair: 黄昏黎明「100×X」必须由 5 条标签进度各自独立触发 ----
#   ★ 2026-10-12 坑 138 重写。旧版这条路是"新增附魔 sweetdream:dusk_dawn
#     (post_attack, affected:victim), 让回调函数就地数死者的标签数" ——
#     但**原版 post_attack 只读攻击者的主手物品**上的附魔, 附在靴子(slots:feet)上
#     永远不触发 ⇒ 回调零调用 ⇒ X 恒用兜底值 1 ⇒ 超限版"额外 100×X"永远只给 100
#     (用户实测: 打一只「流火+夜火」的怪只加 300 = 基础 200 + 100, 本该 400)。
#   新口径 = **不用附魔**: 一个标签一条进度(dusk_dawn_kill_mark_<tag>), 死者身上有几个
#   通用标签就有几条同刻触发 ⇒ kill_mark 被调几次就是 X。五个必须同时成立的点:
#     ① 5 个进度都在, rewards.function **各自**指向同名 wrapper kill_mark_<tag>;
#     ② 每个 wrapper 首行 revoke **自己**那条进度(自撤销型契约, 与 lib/rearm 同源),
#        并转发到共享的 kill_mark;
#     ③ 旧的**合并版**进度 dusk_dawn_kill_mark.json 必须已删(留着会同刻触发两遍, X 虚高);
#     ④ kill_mark 用 `@s zx.dd_n` 数次数, 自己**不得**再 revoke 进度(那是 wrapper 的活,
#        重复一份会掩盖"某个 wrapper 漏 revoke"), 也不得再引用已废弃的 dd_xk / dd_px;
#     ⑤ kill_init 必须把 dd_n 归零(不归零 ⇒ 第二次击杀接着上次涨 ⇒ 基础版少给)。
#   ★ 通用: 依附魔回调的机制, **先确认那个附魔挂在会被遍历到的位置** ——
#     post_attack 只遍历攻击者的主手物品, 挂到护甲/背包槽位是静默失效(不报错、零日志)。
_DD_TAGS = ('yuanhai', 'liuhuo', 'yehuo', 'shixin', 'dream')
_dd_root = ROOT / 'sweetdream' / 'data' / 'sweetdream'
_dd_adv_dir = _dd_root / 'advancement' / 'equipment' / 'armor'
_dd_fn_dir = _dd_root / 'function' / 'equipment' / 'armor' / 'dusk_dawn'
_dd_km = functions.get('sweetdream:equipment/armor/dusk_dawn/kill_mark')
_dd_ki = functions.get('sweetdream:equipment/armor/dusk_dawn/kill_init')


def _dd_code(_f):
    return '\n'.join(l for l in _f.read_text(encoding='utf-8', errors='ignore').split('\n')
                     if not l.strip().startswith('#'))


if _dd_km is None:
    R['ddpair'].append((str(ROOT), 0,
        '黄昏黎明 100×X(坑 138): 找不到 dusk_dawn/kill_mark —— 击杀计数链断了。'))
else:
    _ddc = _dd_code(_dd_km)
    if not re.search(r'scoreboard players add @s zx\.dd_n 1', _ddc):
        R['ddpair'].append((str(_dd_km), 0,
            '黄昏黎明 100×X(坑 138): kill_mark 没有 `scoreboard players add @s zx.dd_n 1` —— '
            'X 永远是 0, 超限版不会加任何"带标签"的额度。'))
    elif not re.search(r'zx\.dd_n(?![\w])', _ddc):
        R['ddpair'].append((str(_dd_km), 0,
            '黄昏黎明 100×X(坑 138): kill_mark 没有用专用计数 `zx.dd_n` —— 5 条标签进度各自'
            '独立触发, "本刻进来几次"就是 X, 必须由它来数。'))
    if re.search(r'zx\.dd_(xk|px)(?![\w])', _ddc):
        R['ddpair'].append((str(_dd_km), 0,
            '黄昏黎明 100×X(坑 138): kill_mark 还在引用已废弃的 zx.dd_xk / zx.dd_px —— 那是'
            '"附魔 post_attack 回调"时代的产物, 而原版 post_attack 只读攻击者主手物品, '
            '附魔挂在靴子上永不触发, 整套已删。'))
    if re.search(r'advancement revoke @s only sweetdream:equipment/armor/dusk_dawn_kill_mark', _ddc):
        R['ddpair'].append((str(_dd_km), 0,
            '黄昏黎明 100×X(坑 138): kill_mark 自己又 revoke 了进度 —— revoke 必须留在各自的 '
            'wrapper 首行(自撤销型契约), 在共享函数里重复一份只会掩盖"某个 wrapper 漏 revoke"。'))

for _t in _DD_TAGS:
    _rev = 'advancement revoke @s only sweetdream:equipment/armor/dusk_dawn_kill_mark_%s' % _t
    _w = _dd_fn_dir / ('kill_mark_%s.mcfunction' % _t)
    if not _w.exists():
        R['ddpair'].append((str(_w), 0,
            '黄昏黎明 100×X(坑 138): 少了 wrapper kill_mark_%s.mcfunction —— 进度 '
            'dusk_dawn_kill_mark_%s 的 rewards.function 就没有着落。' % (_t, _t)))
    else:
        _wc = [l.strip() for l in _dd_code(_w).split('\n') if l.strip()]
        if not _wc or _wc[0] != _rev:
            R['ddpair'].append((str(_w), 0,
                '黄昏黎明 100×X(坑 138): wrapper kill_mark_%s 的首行必须是 `%s` —— '
                '自撤销型进度不 revoke 自己, 第二次触发就永远不再发生(X 少算)。' % (_t, _rev)))
        if 'function sweetdream:equipment/armor/dusk_dawn/kill_mark' not in _dd_code(_w):
            R['ddpair'].append((str(_w), 0,
                '黄昏黎明 100×X(坑 138): wrapper kill_mark_%s 没有转发到共享的 '
                'dusk_dawn/kill_mark —— 这次击杀就白触发了。' % _t))
    _p = _dd_adv_dir / ('dusk_dawn_kill_mark_%s.json' % _t)
    if not _p.exists():
        R['ddpair'].append((str(_p), 0,
            '黄昏黎明 100×X(坑 138): 少了标签进度 dusk_dawn_kill_mark_%s.json —— 死者的 '
            '`zx.status.%s` 就数不进 X。' % (_t, _t)))
    elif ('"sweetdream:equipment/armor/dusk_dawn/kill_mark_%s"' % _t) not in _p.read_text(encoding='utf-8', errors='ignore'):
        R['ddpair'].append((str(_p), 0,
            '黄昏黎明 100×X(坑 138): 进度 %s 的 rewards.function 没指向它**自己**的 wrapper '
            'kill_mark_%s —— 指向共享函数的话就没人 revoke 它了。' % (_p.name, _t)))

if (_dd_adv_dir / 'dusk_dawn_kill_mark.json').exists():
    R['ddpair'].append((str(_dd_adv_dir / 'dusk_dawn_kill_mark.json'), 0,
        '黄昏黎明 100×X(坑 138): 旧的**合并版**进度 dusk_dawn_kill_mark.json 还在 —— '
        '它和 5 条单标签进度会**双双触发**, 一次击杀被记两遍(X 虚高)。必须删掉。'))

if _dd_ki is None:
    R['ddpair'].append((str(ROOT), 0,
        '黄昏黎明 100×X(坑 138): 找不到 dusk_dawn/kill_init —— 同刻账本去重链断了。'))
elif not re.search(r'scoreboard players set @s zx\.dd_n 0', _dd_code(_dd_ki)):
    R['ddpair'].append((str(_dd_ki), 0,
        '黄昏黎明 100×X(坑 138): kill_init 没有把 `zx.dd_n` 归零 —— 第二次击杀会接着上次的'
        '数往上加, 基础版"同一次击杀只加一次"(dd_n matches 1)的判据永远不成立, 静默少给。'))

# ---- 90) embertop: 余烬"夜火怪也要补流火" + 它的 5 秒节流(坑 137, 2026-10-12 用户拍板) ----
#   文案只说"使其附着流火", **没有**排除"已经有夜火"的情况。旧版 burned_out 在这一支
#   `if entity @s[tag=zx.status.yehuo] run return 0`(保持最高阶) 把整支吞掉 ⇒
#   穿余烬永远看不到"流火 + 夜火"(用户实测: "夜火怪再燃烧后没有附加流火")。
#   拍板口径: 已是双状态 -> 不动; 只有夜火 -> 补流火。
#   ★★ 但这条补流火**必须限速** ★★: 双状态被吸收(烈火残躯的 night / 红莲的 step_night
#   把夜火摘走)之后只剩流火, 下次熄灭又会升级成夜火 -> 反复给余烬回 100 魔力; 而这条
#   补流火正是该循环**唯一**能自我重新武装的来源, 不限速就是刷魔力漏洞。
#   ★ 通用形态: 凡是"能凭空重新产生某个可被消耗资源"的被动, 都要先问一句
#     "它能不能自己给自己续杯" —— 能, 就必须挂节流(时刻闸 / 次数闸)。
_em_bo = functions.get('sweetdream:equipment/armor/ember/burned_out')
_em_tu = functions.get('sweetdream:equipment/armor/ember/top_up')
if _em_bo is None:
    R['embertop'].append((str(ROOT), 0,
        '余烬补流火(坑 137): 找不到 ember/burned_out。'))
if _em_tu is None:
    R['embertop'].append((str(ROOT), 0,
        '余烬补流火(坑 137): 找不到 ember/top_up —— 夜火怪熄灭后不会补流火(功能缺失)。'))


def _em_code(_f):
    return '\n'.join(l for l in _f.read_text(encoding='utf-8', errors='ignore').split('\n')
                     if not l.strip().startswith('#'))


if _em_bo is not None:
    _emb = _em_code(_em_bo)
    _m_call = re.search(r'function\s+sweetdream:equipment/armor/ember/top_up', _emb)
    if not _m_call:
        R['embertop'].append((str(_em_bo), 0,
            '余烬补流火(坑 137): burned_out 没有调用 ember/top_up —— 夜火怪熄灭又变成'
            '"保持最高阶直接收工", 拿不到"流火+夜火"双状态(用户实测反馈的正是这条)。'))
    else:
        _m_back = re.search(r'tag=zx\.status\.yehuo\]\s+run\s+return\s+0', _emb)
        if _m_back and _m_back.start() < _m_call.start():
            R['embertop'].append((str(_em_bo), 0,
                '余烬补流火(坑 137): burned_out 里"见夜火就 return 0"跑在 top_up **前面** —— '
                '补流火那一支成了死代码。顺序必须"先补、再收工"。'))
if _em_tu is not None:
    _emt = _em_code(_em_tu)
    if 'zx.em_gate' not in _emt or not re.search(r'#now\s+manacore\.meta', _emt):
        R['embertop'].append((str(_em_tu), 0,
            '余烬补流火(坑 137): top_up 没有 5 秒节流(zx.em_gate + #now manacore.meta) —— '
            '双状态被吸走夜火后只剩流火, 下次熄灭又升级成夜火, 反复给余烬回 100 魔力 = '
            '刷魔力漏洞。必须按"下次可补的 tick 时刻"限速。'))

# ---- 83) regress: 已修缺陷的"形态锁定"(审查报告 2026-10-10 · O10) ----
#   报告里 F06–F21 那批坑的共同点是**静默**: 不报错、不写日志, 游戏里只表现为
#   "没效果 / 数值不对", 而且大多要"多人 / 多目标 / 跨 tick / 重连"才现形 ——
#   静态扫描验证不了运行时行为, 能做的是把**修复后的代码形态**锁死: 谁改回去
#   (或新写一个同款) 立刻报出来, 不必等玩家反馈再回头查。
#   每条 = (相对路径, 必须含的片段 or None, 禁止匹配的正则 or None, 顺序对 or None, 说明)
_SD = 'sweetdream/data/sweetdream/function'
_MC = 'manacore-1.0.0/data/manacore/function'

# ---- R05(2026-10-10): 定点乘法跨 Scale 的 int32 上界保护 ----
#   计分板是 **int32**。"先把 double 读成定点整数(x1000), 再乘一个百分数"这种写法,
#   中间值会在远超玩家体感的时候就回绕成负数 —— 不报错, 结果却是天文数字或负值。
#   报告点名的两处: internal/damage/vuln_tag(x1000 ×#115, 伤害 ≈18,674 触界)、
#   lib/dmg_add_apply(x100 ×#k, #k 是动态叠加的加成)。
#   ★ 正派是"动态上限 = INT32_MAX ÷ 乘数"再钳住, 而不是改成"先除后乘" ——
#     后者会把 45.67 砍成 45, 让常态丢掉小数精度。
for _fnk, _fp in functions.items():
    try:
        _raw = _fp.read_text(encoding='utf-8').split('\n')
        _act = [(n, l.strip()) for n, l in enumerate(_raw, 1)
                if l.strip() and not l.strip().startswith('#')]
    except Exception:
        continue
    for _n, (_li, _s) in enumerate(_act):
        _g = re.search(r'execute\b.*\bstore\s+result\s+score\s+(#\w+)\s+\S+\s+run\s+'
                       r'data\s+get\s+.*?\s+1000\s*$', _s)
        if not _g:
            continue
        _acc = _g.group(1)
        for _nm in range(_n + 1, min(_n + 8, len(_act))):
            _lj, _s2 = _act[_nm]
            _m = re.search(r'scoreboard\s+players\s+operation\s+%s\s+\S+\s+\*=\s+(#\w+)\s'
                           % re.escape(_acc), _s2)
            if not _m:
                continue
            # ★ 豁免: 上方注释里写了 `intovf-ok` 的行放行 —— 同 dup-ok / empty-ok 的惯例。
            #   用于"已经算过量级、明确接受当前阈值"的老设计(如 manacore 的 health_part /
            #   mul_calc: 倍率刻意取 ×100 而不是 ×1000, 把可承受范围提到约 21,474)。
            if any('intovf-ok' in _r for _r in _raw[max(0, _lj - 12):_lj]):
                break
            # 保护代码可能写在"读入行之后"或"乘法行之前" -> 取这两行之间的闭区间
            _ctx = '\n'.join(x[1] for x in _act[max(0, _n - 4):_nm + 1])
            if '2147483647' not in _ctx:
                R['intovf'].append(
                    (str(_fp), _lj, _s2[:100]
                     + '  <- %s 是**×1000 定点**(第 %d 行读入), 再 ×%s 时中间值很容易越过 '
                       'int32 上界(2,147,483,647)并**回绕成负数**(不报错)。'
                       '补一道动态上限: `set <cap> 2147483647` -> '
                       '`if score %s matches 1.. operation <cap> /= %s` -> '
                       '`if score %s > <cap> operation %s = <cap>`。'
                       '★ 除法的 `matches 1..` 守卫不能省: 除数是 0 时这条 operation '
                       '**静默失败**(同坑 85 的除零事故)'
                     % (_acc, _li, _m.group(1), _m.group(1), _m.group(1), _acc, _m.group(1))))
            break

# ---- 84) tagmacro: 被函数标签**直接引用**的函数里不能有宏行 ($(…)) ----
#   函数标签是**无参调用**(`function #ns:tag` 后面接不了 with / 复合标签) ⇒ 被它
#   直接引用的函数必须是**普通函数**。含 `$(变量)` 的行拿不到参数: 整条宏行
#   (以及它之后的一切)在运行期被跳过, 严重时整个宏函数不实例化 —— **零日志**,
#   游戏里只表现为"这个功能不存在"。
#   真实事故 2026-10-11(N09): sweetdream:equipment/staff/begonia/hook_calc 里写着
#   `$execute if entity @e[…u0:$(u0)…]`, 而它是 #manacore:event/damage_calc 的值之一
#   ⇒ 海棠「漩涡增强 mm +20%」整段不执行(玩家只会觉得"这装备没增强")。
#   正解: 标签指**普通 wrapper**, wrapper 再用 `with storage` 调**宏叶子**。
#   ★ 只扫**非注释行** —— 头注释里讲"本文件不能写 $(变量)"不该被算进来。
for _pk in ('manacore-1.0.0', 'sweetdream'):
    _tbase = ROOT / _pk / 'data'
    if not _tbase.exists():
        continue
    for _jp in sorted(_tbase.rglob('*.json')):
        if '/tags/function/' not in str(_jp).replace('\\', '/'):
            continue
        try:
            _jv = json.loads(_jp.read_text(encoding='utf-8')).get('values', [])
        except Exception:
            continue
        for _v in _jv:
            if isinstance(_v, dict):
                _v = _v.get('id', '')
            if not _v or _v.startswith('#'):
                continue
            _ns, _, _pth = _v.partition(':')
            _tf = _tbase / _ns / 'function' / (_pth + '.mcfunction')
            if not _tf.exists():
                continue
            try:
                _tx = _tf.read_text(encoding='utf-8', errors='ignore')
            except Exception:
                continue
            _body = '\n'.join(_l for _l in _tx.split('\n') if not _l.strip().startswith('#'))
            if macro_var.search(_body):
                R['tagmacro'].append((_tf, 0,
                    '被函数标签直接引用(%s)却含宏行 $(…) —— `function #…` 是**无参**调用, '
                    '宏行拿不到参数会整段跳过(零日志)。拆成"普通 wrapper + 宏叶子", '
                    '由 wrapper 用 with storage 调叶子。' % _jp.name))

_REGRESS = [
    (_SD + '/equipment/armor/lightless_sea/passive.mcfunction',
     'nbt={active_effects:[{id:"minecraft:slowness"}]}', r'nbt\s*=\s*\{ActiveEffects', None,
     'S01: 无光之海缓慢源必须读 1.20.2+ 的 active_effects'),
    (_SD + '/equipment/armor/withered_garden/wood_tick.mcfunction',
     'nbt={active_effects:[{id:"minecraft:slowness"}]}', r'nbt\s*=\s*\{ActiveEffects', None,
     'S01: 枯萎花园缓慢伤害圈必须读 1.20.2+ 的 active_effects'),
    (_MC + '/internal/join/new.mcfunction',
     'function #manacore:event/player_prepare_new', None,
     ('record.stats.base_attack double 1 run attribute', 'function #manacore:event/player_prepare_new'),
     'S02: 应用清旧属性必须早于建档读取实际攻击力'),
    (_MC + '/internal/join/new.mcfunction', None, None,
     ('function #manacore:event/player_prepare_new', '#slot_full manacore.meta matches 1 run return 0'),
     'S02: 槽位耗尽时不得清属性, 必须先退出'),
    ('manacore-1.0.0/data/manacore/tags/function/event/player_prepare_new.json',
     'manacore:event/noop', None, None, 'S02: 前置包必须定义建档前事件标签'),
    ('sweetdream/data/manacore/tags/function/event/player_prepare_new.json',
     'sweetdream:event/player_prepare_new', None, None, 'S02: sweetdream 必须挂载建档前清理'),
    (_SD + '/event/player_prepare_new.mcfunction',
     'function sweetdream:internal/attr/cleanup',
     r'function (?:sweetdream:lib/uuid|manacore:api/)|scoreboard players (?:reset|set) @s', None,
     'S02: 未登记时只摘属性, 不调用登记 API/UUID 查找或提前清掉迁移判据'),
    (_SD + '/lib/ledger_resync_go.mcfunction',
     'function sweetdream:equipment/armor/lightless_sea/atk_add with storage zx:work x',
     r'scoreboard players (?:set @s zx\.ls_buf 0|reset @s zx\.ls_buf)|#lr_sum zx\.meta \+= @s zx\.ls_buf',
     ('function sweetdream:equipment/armor/lightless_sea/atk_add',
      'attribute @s minecraft:attack_damage modifier remove sweetdream:eqp_ls_atk'),
     'S03: 无光之海账本兼作三秒宽限缓存, 保留账本/面板且只重挂原版属性'),
    (_SD + '/lib/ledger_resync_go.mcfunction',
     'attribute @s minecraft:attack_damage modifier remove sweetdream:eqp_ls_atk', None, None,
     'S03: 无光之海重挂必须先摘同 id, 兼容修饰符未丢的世界'),
    (_SD + '/lib/ledger_resync_go.mcfunction',
     'function sweetdream:equipment/armor/mirage/set_atk_add with storage zx:work x',
     r'scoreboard players (?:set @s zx\.mr_atk 0|reset @s zx\.mr_atk)|#lr_sum zx\.meta \+= @s zx\.mr_atk',
     ('function sweetdream:equipment/armor/mirage/set_atk_add',
      'attribute @s minecraft:attack_damage modifier remove sweetdream:eqp_mr_set_atk'),
     'S03: 蜃楼保留面板与旧账只重挂属性, 到期/卸装仍可按差值正常减回'),
    (_SD + '/lib/ledger_resync_go.mcfunction',
     'attribute @s minecraft:attack_damage modifier remove sweetdream:eqp_mr_set_atk', None, None,
     'S03: 蜃楼重挂必须先摘同 id, 兼容修饰符未丢的世界'),
    (_MC + '/internal/skill/stage_mana.mcfunction',
     'manacore:work a.value set from storage manacore:work a.mana', None, None,
     'F06 扣费契约: 少了这行显式映射, internal/mana/consume 读的是 a.value(空/旧值), '
     '而 api/skill/cast 传的是 a.mana ⇒ 技能**一点蓝都不扣**'),

    (_MC + '/internal/damage/calc.mcfunction',
     'manacore:work ctx set from storage manacore:work a', None, None,
     'F07 调用上下文: 少了备份/恢复, damage_calc 里的 hook 经 api/* 把 work a 整份重置, '
     '外层 deal/cast 读不到 target ⇒ 穿共振的人"技能只有特效没伤害"'),

    (_MC + '/api/skill/check.mcfunction', '{uuid:""}', None, None,
     'F19 非空校验: 少了它, 缺参数的调用被当成功(默认值里就有 uuid:"" / skill:"", '
     '`if data a.uuid` 恒真 ⇒ 必须用复合匹配取反)'),

    (_MC + '/debug/reset_all.mcfunction',
     'internal/debug/purge_registry', r'data\s+remove\s+storage\s+\S+\s*$',
     None,
     'F16 整体清库: ① 只遍历在线索引的话, **离线玩家的残留记录**永远清不掉 ⇒ 必须按'
     '"终身清单"兜底; ② 不要再写 `data remove storage manacore:players`(不带路径) —— '
     '那会让**整个函数加载失败**(2026-10-10 实测), 存储的根在命令层面删不掉'),

    (_MC + '/internal/player/create.mcfunction', 'players_all', None, None,
     'F16 终身清单: 建记录的地方必须登记 uuid(API 按需建记录), 否则 debug/reset_all '
     '漏掉这条记录的离线残留'),

    (_MC + '/internal/join/new.mcfunction', 'players_all', None, None,
     'F16 终身清单: 新玩家首次建记录时必须登记 uuid'),

    (_MC + '/internal/debug/reset_one.mcfunction', 'players_all', None, None,
     'F16 终身清单: 管理员重置会重建记录, 也要登记 uuid'),

    (_MC + '/internal/uuid/migrate.mcfunction', 'players_all', None, None,
     'F16 终身清单: 旧键迁移会新建一个键, 属于"建记录"⇒ 也要登记 uuid'),

    (_MC + '/internal/uuid/migrate.mcfunction',
     'storage manacore:players "$(h0)"', r'players\."',
     None,
     '旧键迁移必须是"真存储": 少一个空格会让 id 被解析成 `manacore:players.`(尾点多一点), '
     '整段迁移静默作用在另一个存储上 —— 老玩家的 8 位旧键永远迁不过来, 数据看起来被清空'),

    (_MC + '/internal/uuid/join.mcfunction', None, r'players\."', None,
     '同上(该文件当前无调用方, 但保留同样的形态约束, 免得将来被接回去时踩同一个坑)'),

    (_SD + '/debug/snap_save.mcfunction', None, r'players\."', None,
     'zx.dbg_diff 快照: `storage manacore:players."$(uuid)"…` 读的是**另一个存储**, '
     '7 项属性全部读不到(静默) ⇒ 差值面板永远是空的/垃圾值'),

    (_SD + '/debug/diff_go.mcfunction', None, r'players\."', None,
     '同上(差值的另一侧)'),

    (_SD + '/internal/damage/one.mcfunction',
     'storage zx:work a set from storage zx:work ob', None, None,
     'F08 多目标隔离: 改成"挑字段恢复"会漏 a.num ⇒ 带易伤的多目标伤害按选择器遍历顺序'
     '累积放大(100 -> 115 -> 132.25, 静默)'),

    # ---- 2026-10-11 三审 A03(uuid/migrate 双键漏登记 + 离线补登记口) ----
    (_MC + '/internal/uuid/migrate.mcfunction',
     'if data storage manacore:players "$(uuid)" unless data storage manacore:players "$(h0)" '
     'unless data storage manacore:players "$(uuid)".reg run data modify storage '
     'manacore:players_all list append value "$(uuid)"', None, None,
     '★ A03: "完整 UUID 键已存在、旧键已不在、且未登记"的历史记录也要补登记(第③步)。'
     '缺了它, 这一类记录永远进不了终身清单 ⇒ debug/reset_all 清不到(报告 A03 的现场形态)。'
     '★ 与第①步互斥(① 看旧键存在、③ 看旧键不在)⇒ 不会重复 append。'),
    (_MC + '/debug/registry_add.mcfunction',
     'if data storage manacore:players "$(uuid)" run data modify storage '
     'manacore:players_all list append value "$(uuid)"',
     r'unless\s+data\s+storage\s+manacore:players\s+"\$\(uuid\)"\.reg\s+run\s+data\s+modify\s+'
     r'storage\s+manacore:players_all',
     None,
     '★ A03(三审) + Q03(四审): 运维入口的登记行**必须无 `unless reg`**(强制补登记)。'
     'A03 只修好了 migrate 的双键路径, 没能修**已经产生的坏状态**(更早的版本给一条记录'
     '打过 reg=1b 而它从没进过清单); 旧版本入口也带 `unless reg` ⇒ 人工口同样救不回来。'
     '★ 为什么敢不看 reg: 清单元素是**裸字符串**, 没有任何"列表里含不含某串"的语法,'
     '查重做不到; 而重复项**无害** —— purge_registry 逐删时第二条会被 `if data` 挡掉。'
     '★ 必须保留 `if data storage manacore:players "$(uuid)"`(否则会给不存在的记录建空条目)'
     ' 与 `tellraw @s`(纯命令枚举不出未知存储键, 这条只能人工逐个调)。'),
    (_MC + '/debug/registry_add.mcfunction',
     'if data storage manacore:players "$(uuid)" run data modify storage '
     'manacore:players "$(uuid)".reg set value 1b',
     None, None,
     '★ A03/Q03: 打 reg 标志的守卫与登记一致(记录存在)。自动路径(migrate/existing)仍带'
     ' `unless reg` —— 那两条每次上线都跑, 无条件 append 会让清单无限增长; 本入口是人工的。'),
    (_MC + '/debug/registry_add.mcfunction',
     '必须是 32 位纯十六进制', None, None,
     '★ Q03(四审): 用法必须写清"实际存储键 = 32 位纯十六进制"(见 internal/uuid/build)。'
     '旧注释写 `<8-4-4-4-12 或 8 位短键>` 是错的 —— 带连字符的 UUID 与 8 位短键都匹配不到'
     '任何记录(短键只是 migrate 的**输入**), 用户按说明敲会以为命令坏了。'),

    # ---- 2026-10-11 四审 Q01(旧快照 -> 新队列的升级迁移) ----
    (_SD + '/internal/itembackup/migrate_legacy.mcfunction',
     'if score @s zx.ret_pend matches 1.. if score @s zx.ret_slot matches 0..8 unless data '
     'storage zx:ret p."$(uuid)".q[0] if data storage zx:ret p."$(uuid)".mainhand.id run '
     'scoreboard players set #lg_main zx.meta 1',
     None, None,
     '★ Q01(四审): 迁移的**判据**必须是"旧版 zx.ret_pend >= 1(真的欠一把)" + 队列为空 + 旧快照有货。'
     '★ 为什么不能只看"旧快照在不在": 旧版 backup_go **每秒刷新** .mainhand/.offhand ⇒ '
     '"有快照"完全不代表"欠一把", 拿它当判据会把玩家非待还状态下的普通备份当成欠款、'
     '**凭空发一件武器**。'),
    (_SD + '/internal/itembackup/migrate_legacy.mcfunction',
     'run data modify storage zx:ret p."$(uuid)".q[0].item set from storage '
     'zx:ret p."$(uuid)".mainhand',
     None, None,
     '★ Q01: 主手那笔必须把**旧快照内容**搬进队首条目(.item) —— 只 append 一个 {slot:...} '
     '而忘了 set from ⇒ 建成"只有槽位、没有物品"的空条目 ⇒ 反而永久堵死队首。'),
    (_SD + '/internal/itembackup/migrate_legacy.mcfunction',
     'run data remove storage zx:ret p."$(uuid)".mainhand', None, None,
     '★ Q01: 迁移 = **搬移** —— 成功搬进队列后删掉旧键(与 uuid/migrate 同款)。'
     '留着旧键, 下次上线虽然因 `unless q[0]` 不会再迁, 但现场会一直混淆"哪份才是真待还"。'),
    (_SD + '/internal/itembackup/migrate_legacy.mcfunction',
     'run data modify storage zx:ret p."$(uuid)".q set value []',
     None,
     ('#lg_off zx.meta matches 1 run data modify storage zx:ret p."$(uuid)".q append value {slot:-1}',
      'if data storage zx:ret p."$(uuid)".offhand.id run scoreboard players set #lg_off zx.meta 1'),
     '★ Q01: **先算标志、再按标志建队列**, 顺序不能反(本锁 + 下面那条 `q set value []` 一起钉)。'
     '边判边建的话: 建完 q[0] 之后, 后面几行的 `unless q[0]` 立刻变假 ⇒ 搬移那步被跳过 '
     '⇒ 建出空条目。★ `_order` = (应更晚, 应更早)。'
     '★ 另: `append` 要求目标是**已存在的 list** ⇒ 必须先 `q set value []` 建空壳。'),
    (_SD + '/internal/itembackup/migrate_legacy.mcfunction',
     'function sweetdream:internal/itembackup/resync_go', None, None,
     '★ Q01: 迁移完**立刻重建镜像**(pend/slot/wait) —— 否则下一秒 recover 的选择器'
     ' `@a[scores={zx.ret_pend=1..}]` 还是选不到人, 等于白迁。'),
    (_SD + '/event/player_join.mcfunction',
     'function sweetdream:internal/itembackup/migrate_legacy with storage zx:work a', None, None,
     '★ Q01: 迁移挂在 **player_join**(register 末尾, 每次上线/重注册都抛; 且它排在 '
     '`player_first_join` **之前** ⇒ 迁移早于清账, 那时 zx.ret_pend 还在 —— 它是迁移的唯一判据)。'),
    ('sweetdream/data/manacore/tags/function/event/player_join.json',
     'sweetdream:event/player_join', None, None,
     '★ Q01: 新的上线收尾函数必须真的挂进跨包事件标签(少这一行 = 迁移永不执行, 且完全静默)。'),

    # ---- 2026-10-11 四审 Q02(重置后按队列重建镜像) ----
    (_SD + '/internal/itembackup/resync.mcfunction',
     'if data storage zx:ret p."$(uuid)".q[0] store result score @s zx.ret_slot run data get '
     'storage zx:ret p."$(uuid)".q[0].slot',
     None, None,
     '★ Q02(四审): 镜像必须**从队列重算**(q[0].slot), 而不是照抄旧分数 —— 队列是唯一真相。'),
    (_SD + '/internal/itembackup/resync.mcfunction',
     'unless data storage zx:ret p."$(uuid)".q[0] run scoreboard players set @s zx.ret_pend 0',
     None, None,
     '★ Q02: **双向**重建 —— q 空时要把镜像复位成干净态。只管"q 非空就置 1"的话, '
     'q 已被还净而镜像还留着 1 的玩家会被永久挂上 ret_pend=1(每秒空转 + 20 秒后吃到'
     '那句"背包已满"的误导提示)。'),
    (_SD + '/internal/itembackup/resync_go.mcfunction',
     'function sweetdream:internal/itembackup/resync with storage zx:work a', None, None,
     '★ Q02: 普通包装(取 uuid) -> 宏叶子; 宏函数不能裸调(整函数作废、零日志)。'),
    (_SD + '/event/player_reset.mcfunction',
     'function sweetdream:internal/itembackup/resync_go', None,
     ('function sweetdream:internal/itembackup/resync_go',
      'scoreboard players reset @s zx.ret_pend'),
     '★ Q02(四审): 镜像重建必须排在**清账清单之后** —— 放前面的话刚建的镜像会被清单'
     '立刻 reset 掉, 等于没做。★ `_order` = (应更晚, 应更早)。'),
    (_SD + '/event/player_reset.mcfunction',
     'function sweetdream:internal/itembackup/resync_go', None, None,
     '★ Q02(四审): 清账之后必须真的调用镜像重建(存在性)。'
     '★ 该行位于尾标记 `@@GEN-SCORES-ABOVE@@` 之下的**手写区**; 尾标记本身是注释, '
     '本锁看不到 —— 它的存在性由 resetset 规则单独守(见那里)。'),

    # ---- 2026-10-11 四审 Q04(装备型修饰符一并摘净) ----
    (_SD + '/internal/attr/cleanup.mcfunction',
     'minecraft:max_health modifier remove sweetdream:eqp_power_hp', None, None,
     '★ Q04(四审): 装备型修饰符也必须摘 —— 报告例。清账清单会把装备账本(zx.power_hp 等)'
     '一起清零, 而"重置那一刻没穿这件"时 want=0/账本=0 ⇒ 差额 0 ⇒ 跳过 apply_hp '
     '⇒ 这份 +8 永久留在身上, 而且 apply_hp 自己的"先按旧账摘"门(账本 matches 1..)也随'
     '账本归零失效 ⇒ **以后再也摘不掉**。★ 别再写回"装备型不摘"。'),
    (_SD + '/internal/attr/cleanup.mcfunction',
     'minecraft:attack_damage modifier remove sweetdream:eqp_mr_set_atk', None, None,
     '★ Q04: 装备型清单的**末位**一条(蜃楼套装攻击力) —— 钉住"这一批真的整段摘完了", '
     '而不是只加了两条应付差事。'),
    (_SD + '/internal/attr/cleanup.mcfunction',
     'tag @s remove zx.status.liuhuo', None, None,
     '★ Q04: 标签驱动型的修饰符**必须连标签一起清**(见下方 never 说明的配对清单)。'
     'liuhuo 的撤销只在 tag/unmark_one, 而它的触发条件是 zx.tt.liuhuo matches ..0 —— '
     '那个分数被清单清了 ⇒ 永不撤销 ⇒ 护甲 -20% 与标签双双残留。'),
    (_SD + '/internal/attr/cleanup.mcfunction',
     'tag @s remove zx.rm_melt', None, None,
     '★ Q04: 同类配对还有 freeze / rm_melt / tw_tgt / status.dream / lethe; '
     '这里钉住 rm_melt(remelt/second 每秒认这个标签)。'),

    # ---- 2026-10-11 四审 Q05(增量入口也要保护 pack.description) ----
    ('.workbuddy/build_full_pack.py',
     "metadata.append('pack.mcmeta 的 pack.description')", None, None,
     '★ Q05(四审): `--update-crossbows` 收尾会**无条件**把 pack.description 写成 DESC'
     '(main 里的 `meta[\'pack\'][\'description\'] = DESC`) —— 而旧护栏只盯 65 个弩资源 '
     '⇒ 用户手改过的包说明会被静默覆盖。必须把 pack.mcmeta 也纳入同一套"备份 + 中止"。'),

    # ---- 2026-10-11 四审 Q06(③ 步对倍率二次分解) ----
    (_MC + '/internal/damage/mul_pct.mcfunction',
     '#lo $(obj) *= #q1 $(obj)', None, None,
     '★ Q06(四审): ③ 步后半必须走"对倍率再分解一次"的新式 —— 旧式 `#lo *= $(mul)` 的中间量'
     ' 99·|M| **与最终结果无关**, |M| > 约 2.17e7 就回绕(报告例 250000 实得 456800.327, '
     '真值 499750; 而同组输入的前半 19×25,000,000 = 475,000,000 完全正常)。'),
    (_MC + '/internal/damage/mul_pct.mcfunction',
     '#t $(obj) *= #r2 $(obj)', None, None,
     '★ Q06: 后半 r·r2 ≤ 99×99 = 9801 —— 恒安全。这三行(q1/t/r2)是二次分解的全部。'),
    (_MC + '/internal/damage/mul_pct.mcfunction', None,
     r'#lo\s+\$\(obj\)\s+\*=\s+\$\(mul\)\s+\$\(obj\)', None,
     '★ Q06 回归锁: `#lo *= $(mul)` 一律不许写回 —— 那是"99·倍率与结果无关地溢出"的旧式。'),


    # ---- 2026-10-11 三审 A04(重置时清理"状态型"原版属性修饰符) ----
    (_SD + '/event/player_reset.mcfunction',
     'function sweetdream:internal/attr/cleanup', None,
     ('scoreboard players reset @s zx.', 'function sweetdream:internal/attr/cleanup'),
     '★ A04: player_reset **必须先摘"状态型"修饰符, 再清分数**。'
     '修饰符的到期回收全靠"计时分数驱动的每秒心跳"; 分数一清, 心跳选择器不再命中 ⇒ '
     '收尾永不执行 ⇒ 修饰符永久残留(熔星攻速永久变大 / 残念速度永久翻倍 + 每秒白回 20 魔力)。'
     '★ `_order` 约定 = (应更晚出现者, 应更早出现者): 本条断言**第一条 reset 排在 cleanup 之后**。'),
    (_SD + '/internal/attr/cleanup.mcfunction',
     'minecraft:attack_speed modifier remove sweetdream:meteor', None, None,
     '★ A04: 熔星的攻速倍率必须显式摘(`modifier remove` 对不存在的 id 是空操作, 不必先判存在)。'),
    (_SD + '/internal/attr/cleanup.mcfunction',
     'minecraft:movement_speed modifier remove sweetdream:lethe_speed', None, None,
     '★ A04: 残念的速度倍率必须显式摘。'),
    (_SD + '/internal/attr/cleanup.mcfunction',
     'tag @s remove zx.lethe', None, None,
     '★ A04: 残念的**状态标签**必须一起摘 —— 留着它, "残念每秒 +20 魔力 + 速度翻倍"'
     '会靠标签一直续下去(zx.lt_end 已被清, 到期判定永不成立)。'),
    (_SD + '/internal/attr/cleanup.mcfunction', None,
     r'modifier\s+(?:add|value\s+get)\b|\bset\s+base\b', None,
     '★ A04: 清理函数**只许摘**(modifier remove / tag remove), 绝不许挂修饰符或改 base —— '
     '它是在"重置"路径上跑的, 任何加法都会被随后的清账本吞掉或在下次上线时翻倍。'),

    (_SD + '/internal/itembackup/backup.mcfunction',
     'execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["itemreplace"]}] '
     'run function sweetdream:internal/itembackup/snap_main with storage zx:work a',
     r'from entity @s equipment\.|\$execute if items entity @s weapon\.(mainhand|offhand)', None,
     '★ 坑 95(2026-10-11 二次事故): 玩家 NBT 的 equipment 复合只存**穿戴的盔甲**'
     '(playerdata 实测 equipment={feet,legs}, 主手在 Inventory 列表) —— '
     '`set from entity @s equipment.mainhand` 对玩家 = 路径不存在 ⇒ 静默失败 ⇒ '
     'zx:ret 从未被写入 ⇒ 永不回手。玩家物品拷贝必须走 snap_main/snap_off 中转'
     '(item replace 谓词语法拷上临时架 -> 从架子的 equipment.mainhand 拷进存储)。'
     '★ 与坑 93 同族: 生物 NBT 形态不能套玩家, 玩家 NBT 形态不能套生物。'
     '★ 另拦 `$execute`(空宏行, dollar 规则同源): 门控转发是静态行, 不带 $'),
    (_SD + '/internal/itembackup/restore.mcfunction', None, None,
     ('run item replace entity @s $(dst) from entity @e[tag=zx.ret_tmp,limit=1] weapon.mainhand',
      'if items entity @e[tag=zx.ret_tmp,limit=1] weapon.mainhand *'),
     '★ O03 回手的安全闸顺序: 必须先 `if items`(临时架真的拿到了快照)再 item replace。'
     'item replace from 空槽 = 把玩家槽位**清成空气** —— 不设闸, 快照缺失/写架失败时'
     '就会把玩家手里的东西吃掉。临时架流程: kill 防串味 -> 就地召 -> 快照写进主手 -> '
     '有货才还 -> 删快照(防 recover 重试"复活") -> kill。'
     '★ `_order` 约定 = (应更晚出现者, 应更早出现者): 本条断言 item replace 晚于 if items。'
     '★ 注: 旧版把两个子串写在**同一行**(a==b)⇒ 本条其实从未触发过(死锁), N08 拆分后才生效'),
    (_SD + '/internal/itembackup/restore.mcfunction',
     'unless items entity @s $(dst) *', None, None,
     '★ N08(2026-10-11): item replace 是**覆盖式**的 —— 不判"目标槽为空"就会把玩家'
     '放在那一格的另一件物品**直接吃掉**(不落地、找不回)。判空门逐字为 '
     '`unless items entity @s $(dst) *`(判空只能用 `unless … *`, 见 airpred)。'),
    (_SD + '/internal/itembackup/restore.mcfunction', None,
     r'data\s+remove\s+storage\s+zx:ret'
     r'|scoreboard\s+players\s+set\s+@s\s+zx\.ret_pend\s+0', None,
     '★ A02(2026-10-11 三审): restore **只负责"把队首 q[0].item 写进这一格 + 置 #ret_ok"**。'
     '出队(删 q[0])与销账(zx.ret_pend=0)是 effect_2 的活 —— 它还要据"出没出队"重算'
     '队首镜像 zx.ret_slot。在 restore 里删/销账会让 effect_2 读不到队首、或把镜像留在旧值上 '
     '(下一件就写错槽位)。'
     '★ 铁律②(落地才算数)仍在: #ret_ok 由"临时架有货 且 目标槽空"置位, 由 effect_2 消费。'),
    (_SD + '/internal/itembackup/effect_2.mcfunction',
     '$execute if score @s zx.ret_pend matches 1.. if score @s zx.ret_slot matches 0..8 '
     'if score #ret_ok zx.meta matches 0 '
     'unless items entity @s hotbar.$(slot) * '
     'if data storage zx:ret p."$(uuid)".q[0].item.id '
     'run function sweetdream:internal/itembackup/restore '
     '{uuid:"$(uuid)",dst:"hotbar.$(slot)"}',
     r'items\s+entity\s+@s\s+\S+\s+air', None,
     '★ R01 的正写形态 ②-a(A02 后): 目标格**是空的** -> 还回 **hotbar.$(slot)**(消耗时'
     '那一格)而不是 weapon.mainhand(当前选中格)⇒ 切一下快捷栏就会顶掉那一格原有的物品; '
     '判据必须读 zx.ret_slot(队首镜像)而不是 tag zx.ret_off(tag 随实体消失, 重连后 recover 会判错手); '
     '物品存在性门 `if data storage zx:ret …q[0].item.id` 必须在(队首没东西不还原); '
     '`#ret_ok matches 0` 是"本轮还没落地"的传球标志(第一名命中后整段跳过)。'
     '★ 行首必须有"待归还门" `if score @s zx.ret_pend matches 1..`(队列非空)。'
     '★ 判空只能用 `unless items … *` —— `items … air` **恒假**(2026-10-10 实测), 见 airpred'),
    (_SD + '/internal/itembackup/effect_2.mcfunction',
     'unless items entity @s weapon.offhand *', None, None,
     '★ N08(2026-10-11): ① 副手返还也必须先判"副手为空" —— 旧版直接把快照写进副手, 若'
     '副手已被换入另一件物品就把它**吃掉**。没有空副手时保留待归还(不写不删), recover 重试。'),
    (_SD + '/internal/itembackup/effect_2.mcfunction',
     'if score @s zx.ret_pend matches 1.. if score @s zx.ret_slot matches -1', None, None,
     '★ N08 续修(2026-10-11, 玩家实测"回手后还多给一把"): ① 副手分支同样必须带"待归还门" '
     '`if score @s zx.ret_pend matches 1..`。没有它: 只要 zx:ret 里有副手快照'
     '(每秒被 backup_go 刷新, 副手又常拿 itemreplace 武器), recover 每秒都会再还一次 '
     '⇒ 重复发武器。'),
    (_SD + '/internal/itembackup/effect_2.mcfunction',
     '$execute if score @s zx.ret_pend matches 1.. if score #ret_ok zx.meta matches 0 '
     'unless items entity @s hotbar.8 * '
     'if data storage zx:ret p."$(uuid)".q[0].item.id '
     'run function sweetdream:internal/itembackup/restore '
     '{uuid:"$(uuid)",dst:"hotbar.8"}',
     None, None,
     '★ A02(2026-10-11 三审) ④ 兜底扫描(快捷栏 0..8): 首选槽(原格/副手)被占或镜像非法时, '
     '依次扫 hotbar.0..8 落进**第一个空格**(行 `…restore {…,dst:"hotbar.N"}`)。'
     '★ 每行都必须带**三件套**: `if score @s zx.ret_pend matches 1..`(队列非空) + '
     '`if score #ret_ok zx.meta matches 0`(本轮还没落地) + `unless items … N *`(那一格是空的)。'
     '少了判空 => 覆盖玩家物品(N08); 少了 #ret_ok 门 => 未命中也会一路调 restore。'),
    (_SD + '/internal/itembackup/effect_2.mcfunction',
     '$execute if score @s zx.ret_pend matches 1.. if score #ret_ok zx.meta matches 0 '
     'unless items entity @s inventory.26 * '
     'if data storage zx:ret p."$(uuid)".q[0].item.id '
     'run function sweetdream:internal/itembackup/restore '
     '{uuid:"$(uuid)",dst:"inventory.26"}',
     None, None,
     '★ A02(2026-10-11 三审) ⑤ 兜底扫描(主背包 inventory.0..26 = 索引 9-35, 27 格): '
     '旧版只找快捷栏 ⇒ 主背包有空格也不还(报告 A02 ①)。'
     '`inventory.N` 是 1.21.5 `item` / `if items` 对**玩家**合法的槽位名(映射到索引 N+9)。'
     '★ 同 ④ 的三件套门控; 27 行缺一不可(一行都不能"顺手删掉看着重复的")。'),
    (_SD + '/internal/itembackup/effect_2.mcfunction',
     '$execute if score @s zx.ret_pend matches 1.. if data storage zx:ret '
     'p."$(uuid)".q[0] store result score @s zx.ret_slot run data get storage zx:ret '
     'p."$(uuid)".q[0].slot', None, None,
     '★ A02(2026-10-11 三审) ⑦ 出队后重算队首镜像(队列**非空**那一支): 出队后必须把 '
     'zx.ret_slot 重算成**新队首**的首选槽; 缺了它, ret_slot 会停在"刚归还那件"的槽位 '
     '⇒ 下一件还错格子(姊妹行 = "队列空 => 复位 -2", 见下一条)。'
     '★ 2026-10-11 反向探针**抓出来的漏锁**: 本条原先没有锁 —— 探针把这一行删掉, '
     'check 居然一条不报(「31 条探针 30 命中」里唯一未命中的那个)。'),
    (_SD + '/internal/itembackup/effect_2.mcfunction',
     '$execute if score @s zx.ret_pend matches 1.. unless data storage zx:ret '
     'p."$(uuid)".q[0] run scoreboard players set @s zx.ret_slot -2',
     r'p\."\$\(uuid\)"\.(?:mainhand|offhand)\.id'
     r'|custom_data~\{zx:\["itemreplace"\]\}\].? run scoreboard players set @s zx\.ret_pend 0', None,
     '★ A02(2026-10-11 三审) ⑦ 出队后重算队首镜像: 队列空了 => zx.ret_slot 复位成 -2 '
     '(干净)。**永不放弃**: 队列非空而这一秒没还成 => 什么都不做, 留给 recover 每秒重试'
     '(旧版的 20 秒"放弃"已删)。'
     '★ 禁止回归: 把"目标格本来就有另一件 itemreplace 物品"误判成"已还成功" ⇒ 提前出队/'
     '销账 ⇒ 武器丢在外面; 或改回去读固定快照键 p."<uuid>".mainhand/.offhand(A02 已改成队首 q[0])。'),
    (_SD + '/internal/itembackup/effect_2.mcfunction',
     '$execute if score @s zx.ret_pend matches 1.. if score #ret_ok zx.meta matches 1 '
     'run data remove storage zx:ret p."$(uuid)".q[0]',
     None, None,
     '★ A02(2026-10-11 三审) ⑥ 出队: **落地成功(#ret_ok=1)才删队首**。'
     '只删快照/不删队首 => 下一秒又还一遍(重复发武器); 没落地就删 => 武器永久丢失。'),
    (_SD + '/internal/itembackup/effect_2.mcfunction',
     '$execute if score @s zx.ret_pend matches 1.. unless data storage zx:ret '
     'p."$(uuid)".q[0] run scoreboard players set @s zx.ret_pend 0',
     None,
     ('run scoreboard players set @s zx.ret_pend 0',
      'run scoreboard players set @s zx.ret_slot -2'),
     '★ A02(2026-10-11 三审) ⑦ 出队后销账: 队列空 => zx.ret_pend=0(不变式: ret_pend=1 ⟺ 队列非空)。'
     '★ `_order` 约定 = (应更晚出现者, 应更早出现者): 本条断言 **ret_slot 复位排在 ret_pend 清零之前** '
     '—— 反过来的话最后那行 `… run set ret_pend 0` 的门 `if score @s zx.ret_pend matches 1..` '
     '会被自己刚清掉的 0 挡掉 ⇒ ret_slot 永远停在旧值 ⇒ 下一件写错槽位。'),
    (_SD + '/internal/itembackup/backup_go.mcfunction', None,
     r'unless\s+score\s+@s\s+zx\.ret_pend\s+matches\s+1\.\.\s+run\s+function\s+'
     r'sweetdream:internal/itembackup/backup', None,
     '★ A02(2026-10-11 三审): 暂存区(stage.*)不再需要"待归还期间冻结"。'
     '待还武器已经搬进**队列** q, 与暂存区彻底解耦 —— 冻结逻辑(N08 续修那版)已删除。'
     '写回来只会让暂存区发霉(消耗当刻 effect_1 还会再拍一次最新), 没有任何好处。'),
    (_SD + '/internal/itembackup/backup_go.mcfunction',
     'function sweetdream:internal/itembackup/backup with storage zx:work a', None, None,
     '★ 每秒安全网仍要转调宏本体(宏函数不能裸调: 整函数作废、零日志)。'),

    (_SD + '/equipment/sword/rebound/cast.mcfunction', None, None,
     ('scoreboard players reset @s zx.rb_t', 'function manacore:api/cooldown/start'),
     'F11 失败施法必须无副作用: 清队列排在扣费/记冷却之前 ⇒ 冷却中再右键那种注定失败的'
     '尝试也会清掉上一轮没打完的连击'),

    (_SD + '/equipment/axe/red_lotus/cast.mcfunction', None, None,
     ('scoreboard players reset @s zx.rl_t', 'function manacore:api/cooldown/start'),
     'F11 同上(红莲)'),

    (_SD + '/equipment/bow/cold_crow/model/offhand.mcfunction', None,
     r'Inventory\[\{Slot:-106b\}\]', None,
     'F12 副手路径: 1.21.5 已迁到 equipment.offhand.components —— 旧路径读不到(静默), '
     '变化比较恒失效 ⇒ 每轮都白刷组件(客户端手上抖)'),

    (_SD + '/equipment/sword/sickle_dreams/sweep/tick.mcfunction', None,
     r'Inventory\[\{Slot:-106b\}\]', None,
     'F12 同上(梦镰副手重置条件永不成立)'),

    (_SD + '/equipment/staff/palette/color_hit.mcfunction',
     'internal/damage/calc_as_owner', None, None,
     'F13 召唤物算伤: 直接调 api/damage/calc ⇒ 执行者是召唤物, 加算 hook 开头的'
     '"玩家限定"把主人的装备加成整段跳过(静默少伤)'),

    (_SD + '/equipment/staff/begonia/vortex_end.mcfunction',
     'internal/damage/calc_as_owner', None, None,
     'F13 同上(海棠漩涡收尾)'),

    (_SD + '/upgrade/api/dmg_held.mcfunction', 'dmg_add_put_any', None, None,
     'F14/D01: "不挑口径"的加成必须经 dmg_add_put_any 统一写(现在它写满三条 —— '
     '分段式下三条各乘各的段 = 整段 +X%, 不会重复计入; 详见 dmgseg 桶)'),

    (_SD + '/lib/in_bak.mcfunction', 'prepend', None, None,
     'F15 参数备份必须是栈: 退回单层 ⇒ 内层覆盖外层、外层恢复不到 ⇒ 聊天栏手填的参数永久丢失'),

    (_SD + '/equipment/axe/thunderclap/field_end.mcfunction', 'thunderclap/domain_kill', None, None,
     'F17 术阵归属: 按 distance 通杀 ⇒ 两座术阵 <=2 格时, 先结束的那座会删掉邻居的域显示'),

    ('sweetdream/data/sweetdream/tags/entity_type/no_damage.json', 'minecraft:oak_boat', None, None,
     'F18 目标黑名单: 漏掉船/矿车等非生物 ⇒ "锁最近一只"被船抢走, 技能打空'),

    # ---- 2026-10-10 整包静默失效(槽位耗尽死锁) ----
    (_MC + '/core/boot.mcfunction', 'internal/slot/rebuild', r'free_slots\s*\{list:\[\]\}',
     None,
     '槽位回收池: ① 必须调用 internal/slot/rebuild 按 index 反推重建(否则历史上漏掉的槽位'
     '找不回来, #slot_full 卡在 1 就永久死锁); ② 不要再写 `data merge storage '
     'manacore:free_slots {list:[]}` —— merge 对列表是整体替换, 每 reload 清空一次 ⇒ 槽位'
     '只出不进 ⇒ 撑满后整包静默失效'),
    (_MC + '/core/boot.mcfunction', 'data merge storage manacore:free_slots {}', None, None,
     '回收池"保证存在"的正确写法是空复合 merge(不清内容); 内容初始化交给 '
     '`execute unless data … run data modify … set value []`'),

    (_MC + '/internal/slot/rebuild_one.mcfunction',
     'unless data storage manacore:index "$(i)"', None, None,
     '重建判据: 空闲 = 1..#max_slots 里**没有** index 条目的槽位(占用 ⇔ 有条目, 由 '
     'leave/body 与 register 成对维护)。改成看 #next_slot 或看 free_slots 旧值都对不了账'),

    (_MC + '/internal/uuid/migrate.mcfunction',
     'if data storage manacore:players "$(h0)" unless data storage manacore:players '
     '"$(uuid)".reg run data modify storage manacore:players_all list append value "$(uuid)"',
     None,
     ('run data modify storage manacore:players "$(uuid)".reg set value 1b',
      'manacore:players_all list append value "$(uuid)"'),
     '终身清单登记必须**逐字照抄**迁移那句的 if/unless: 第一版漏抄 ⇒ 每次 join 无条件 '
     'append 一条(现场同一个 uuid 重复 92 次, 每秒长一条)。裸字符串列表判不了重, '
     '只能靠调用点守卫。'
     '★ A03(2026-10-11 三审): 登记条件补 `.reg` 未登记门 —— 否则"双键历史记录"(新键在、'
     '旧键也在/不在)永远不登记, 且 existing 见 reg 又跳过补登记 ⇒ reset_all 清不到它。'
     '★ 顺序锁 = (应更晚者, 应更早者): 打 reg 标记**必须排在登记之后** —— 反过来会'
     '"标记已登记、实际不在清单", 就是报告 A03 那个场景。'),
    (_MC + '/internal/uuid/join.mcfunction',
     'if data storage manacore:players "$(h0)" unless data storage manacore:players '
     '"$(h0)-$(h1)-$(h2)-$(h3)-$(h4)" run data modify storage manacore:players_all list append',
     None, None,
     '同 migrate: 本文件目前无调用方, 但登记必须带同样的守卫, 免得将来接回去时重演 92 条重复'),

    # ---- 2026-10-10 整包静默失效(两个真 bug 各留一条形态锁) ----
    (_MC + '/internal/join/register.mcfunction',
     '$execute store result storage manacore:players "$(uuid)".slot int 1', None, None,
     '★ 这一行**必须带 execute**。漏掉 execute 时 `store` 不是命令, 宏函数在运行时中断 '
     '(加载期不解析 ⇒ 无 Failed to load function、日志零报错)⇒ 索引与 manacore.gen '
     '都写不进去 ⇒ 每秒重注册 + 每秒弹走一格槽位 ⇒ self_uuid 恒空 ⇒ 整包静默失效'),
    (_MC + '/internal/uuid/nibbles.mcfunction',
     'scoreboard players operation #t manacore.math /= #16 manacore.meta',
     r'#16\s+manacore\.math', None,
     '★ `/=` 的除数必须用 manacore.meta(boot 只设了 `set #16 manacore.meta 16`)。'
     '用 manacore.math 时 #16 读到 0 ⇒ 除零 ⇒ 该条静默失败、#t 不更新 ⇒ 32 位 hex '
     '退化成"四个整数各自的低 4 位" ⇒ 玩家键大面积冲突(实测 0000000f000000050000000000000007)'),

    # ---- 2026-10-10 审查报告 R01 / R06(消耗型武器回手) ----
    (_SD + '/lib/second.mcfunction',
     'function sweetdream:internal/itembackup/recover', None, None,
     '★ R06 的兜底必须挂在每秒链上。原来只有 effect_1 schedule 出来的 1 tick 一次机会, '
     '且只找 @a[tag=test_pending_return] ⇒ 消耗后立刻掉线/当刻死亡/目标格被占时武器永久消失'),
    (_SD + '/internal/itembackup/return_go.mcfunction',
     'store result storage zx:work a.slot int 1', None, None,
     '★ effect_2 的第二个宏参数 $(slot) 由这一行填: 漏掉 ⇒ 含 $(slot) 的行取不到变量 '
     '⇒ 整个宏函数运行时作废 ⇒ 回手全废(武器凭空消失, 且零日志)'),
    (_SD + '/internal/itembackup/recover_go.mcfunction',
     'store result storage zx:work a.slot int 1', None, None,
     '★ 同上: recover 这条兜底路径也必须给 effect_2 传 $(slot)'),
    (_SD + '/internal/itembackup/return_go.mcfunction', None,
     r'zx:work\s+a\.src\b', None,
     '★ A02(2026-10-11 三审): effect_2 已**不再有 $(src)**(物品改从队首 q[0].item 取), '
     'return_go 别再写 a.src —— 多写一条不会报错, 但会让"宏参数面"白白多出作废风险'
     '(旧 N08 那版就是靠 $(src) 撑着第三个参数); 现在只留 $(slot)。'),
    (_SD + '/internal/itembackup/recover_go.mcfunction', None,
     r'zx:work\s+a\.src\b', None,
     '★ A02: 同上(recover 这条兜底路径也不再备 $(src))。'),
    (_SD + '/internal/itembackup/effect_1.mcfunction',
     'store result storage zx:work a.slot int 1 run data get entity @s SelectedItemSlot',
     None, None,
     '★ R01 的记账端(A02 形态): 必须在"消耗还没走完"这一刻把 SelectedItemSlot 读进 '
     'zx:work a.slot(副手给 -1), 交给 enqueue 入队 —— 入队后队首镜像 zx.ret_slot / '
     '开关 zx.ret_pend 由 enqueue 统一写。'
     '★ 字段名是 Selected**Item**Slot(先例: sickle_dreams/sweep/start 第 14 行); '
     '写成 SelectedSlot ⇒ data get 抛错 ⇒ 本函数从这一行起中断 ⇒ 快照没做、入队没做、'
     'schedule 没排 ⇒ 武器消耗后再也没人还(2026-10-10 实测)。'),
    (_SD + '/internal/itembackup/effect_1.mcfunction',
     'function sweetdream:internal/itembackup/enqueue with storage zx:work a', None, None,
     '★ A02(2026-10-11 三审): 消耗当刻必须**入队** —— 少了它, 连消耗两件会互相顶掉、'
     '且 20 秒后放弃(报告 A02 ①②)。zx.ret_slot / zx.ret_pend 的写入都随它一起走'
     '(别在 effect_1 里另写一遍: 那会把"队首镜像"写成本次那一格, 队列非空时就写错了)。'),
    (_SD + '/internal/itembackup/enqueue.mcfunction',
     'store result score @s zx.ret_slot run data get storage zx:ret '
     'p."$(uuid)".q[0].slot', None, None,
     '★ A02: 入队后**按队首重算**镜像 zx.ret_slot(队列空时 = 本次这一格; 非空时队首没变, '
     '重算结果与原来一致 ⇒ 天然幂等)。写成"直接写 $(slot)"会在队列非空时把队首镜像改错。'),
    (_SD + '/internal/itembackup/enqueue.mcfunction',
     'data modify storage zx:ret p."$(uuid)".q append value {slot:$(slot)}', None, None,
     '★ A02: 队列条目 = {slot:<int>, item:<快照>}(item 由下一行从暂存区搬入)。'
     '`append` 要求 q 已是 list ⇒ 必须保留"不存在就先 `set value []`"那一行。'),
    (_SD + '/core/load.mcfunction',
     'execute unless data storage zx:config obj_ret_slot run scoreboard objectives '
     'add zx.ret_slot dummy',
     r'^\s*scoreboard\s+objectives\s+add\s+zx\.ret_', None,
     '★ zx.ret_slot / zx.ret_pend / zx.ret_wait 必须在 load 里声明, 且**必须带 obj_ 创建标记守卫**: '
     '1.21.5 的 objectives add 在目标已存在时会报错并中断整个函数 ⇒ 第二次 /reload 之后 '
     '后面的初始化全都不跑(见 load 头部注释)。裸 add 即报这一条'),
    (_SD + '/core/load.mcfunction',
     'execute unless data storage zx:config obj_ret_wait run scoreboard objectives '
     'add zx.ret_wait dummy', None, None,
     '★ A02(2026-10-11 三审): 新增 zx.ret_wait(待归还已等待秒数)必须在 load 里声明, '
     '否则 recover 里那两条 `scoreboard players add/reset @s zx.ret_wait` 运行时直接失败'
     '(objmiss 也会报), "首次超时提示"静默失效。'),

    # ---- 2026-10-11 P1(槽位统一 N01/N02): #next_slot 语义 = "最高占用槽" ----
    # bg: #next_slot 曾作"累计发号上限"用 ⇒ boot 满槽归零(N02 覆盖 slot 1)、回收池收进
    #     从未发过的高位槽而 foreach 只遍历 1..#next_slot(N01 漏遍历)。统一为
    #     "#next_slot = 当前最高已登记(占用)槽", 由 boot 的 rebuild→scan_go 重算。
    (_MC + '/core/boot.mcfunction', None,
     r'#next_slot\s+manacore\.meta\s+0', None,
     '★ boot 禁止把 #next_slot 归零(`… set #next_slot manacore.meta 0`): 那是 N02 的根 '
     '—— 满槽 reload 归零后, slot/new 不判 index 是否存在 ⇒ 第 65 人覆盖已占用的 slot 1 '
     '的索引。正解 = 由 internal/slot/rebuild 里的 scan_go 按 index 重算"最高占用槽"'),
    (_MC + '/internal/slot/rebuild.mcfunction',
     'function manacore:internal/slot/scan_go', None, None,
     '★ rebuild 必在"重建回收池之前"调用 scan_go 重算 #next_slot(= 最高占用槽)。缺它则 '
     '#next_slot 用旧值 ⇒ 建池上限错 + 遍历上界错(N01/N02 回归)。'
     '★ scan_go 是纯驱动器(不含宏行), 调用**不带** with; 带宏源的是叶子 scan_one。'),
    (_MC + '/internal/slot/rebuild.mcfunction',
     'storage manacore:work s.i', None,
     ('function manacore:internal/slot/scan_go', 'storage manacore:work s.i'),
     '★ 调 scan_go 前必须先把宏源 s.i 写成起始槽号 1(与 index/foreach 同构): '
     '`execute store result storage manacore:work s.i ... run scoreboard players get #i`。'
     '★ 不这么写则第一轮叶子渲染到的 $(i) 是 0 ⇒ off-by-one, 漏掉第 #max_slots 槽 '
     '(2026-10-11 事故: #next_slot 恒 0, 见 scan_go 头部)'),
    (_MC + '/internal/slot/rebuild_one.mcfunction',
     '<= #next_slot', None, None,
     '★ 回收池只许收 1..#next_slot 范围内的空槽, 守卫逐字为 `<= #next_slot`。少了它就会把 '
     '"从未发过的高位空槽"也塞进池 ⇒ from_free 取到 > #next_slot 的槽, 而 foreach 只遍历 '
     '1..#next_slot ⇒ 高位槽漏遍历(N01)'),
    (_MC + '/internal/slot/scan_go.mcfunction',
     'function manacore:internal/slot/scan_one with storage manacore:work s', None,
     ('function manacore:internal/slot/scan_one', 'store result storage manacore:work s.i'),
     '★ scan_go 是**驱动器**: 必须"先写宏源 s.i、再带 with 调用叶子 scan_one"。'
     '★ 宏时序陷阱(2026-10-11 事故): 若在**同一层**里先写 s.i 再用 $(i), 本轮 $(i) 永远是'
     '上一轮的值 ⇒ off-by-one, 只扫 0..#max_slots-1, 漏掉第 #max_slots 槽 ⇒ #next_slot 恒 0'),
    (_MC + '/internal/slot/scan_one.mcfunction',
     'operation #next_slot manacore.meta = #i manacore.meta', None, None,
     '★ scan_one(叶子)的核心: index."$(i)" 存在就把 #next_slot 抬到 i。'
     '★ 本文件只读 $(i)、**绝不写宏源**(写了就 off-by-one, 见 scan_go 头部)'),
    (_MC + '/internal/debug/slot_recount_loop.mcfunction',
     '> #max_slots', r'>=\s*#max_slots', None,
     '★ 重算循环边界必须是 `> #max_slots`(扫到并含第 #max_slots 槽, 默认 64)。原 `>=` 会'
     '漏掉第 64 槽 ⇒ 最高占槽 = 64 时报成 0/63(N01 同类遗漏)'),

    # ---- 2026-10-11 复审 N03 / N04(清档链: 漏删最后一项 + 登记死代码) ----
    (_MC + '/internal/debug/purge_registry_go.mcfunction',
     'function manacore:internal/debug/purge_registry_del with storage manacore:work a',
     r'run data remove storage manacore:players "\$\(uuid\)"',
     ('function manacore:internal/debug/purge_registry_del with storage manacore:work a',
      'a.uuid set from storage manacore:players_all list[$(i)]'),
     '★ N03 修(2026-10-11): 带 `with` 的宏函数里 `$(var)` 在本函数入口就冻结 ⇒ '
     '"同层写 a.uuid + 用 $(uuid)" 恒 off-by-one(删的是上一轮的 uuid: 清单 [A,B] 漏 B、'
     '[A] 全留)。正解 = 本层只用 $(i) 读 uuid 进 a.uuid, 再用**另一层** '
     'purge_registry_del(进入时读到新值)去删。_order 断言"读 uuid 行"早于"调 del 行"; '
     '_never 封同层删除 `run data remove … "$(uuid)"`。同坑 96'),

    (_MC + '/internal/debug/purge_registry_del.mcfunction',
     'data remove storage manacore:players "$(uuid)"', None, None,
     '★ N03 修(2026-10-11): 删除叶子 —— 它进入时 a.uuid 已被驱动器写好, 所以 $(uuid) 是'
     '**本轮**的值。这一层是"跨调用才用宏变量"的正解形态, 别再并回 go(见其头部说明)'),

    (_MC + '/internal/uuid/migrate.mcfunction',
     'players_all list append value "$(uuid)"', None,
     ('data modify storage manacore:players "$(uuid)" set from storage manacore:players "$(h0)"',
      'players_all list append value "$(uuid)"'),
     '★ N04 修(2026-10-11): 复制与登记用的是**同一个条件**(旧键存在 且 新键不存在)⇒ 只要'
     '复制先跑, 新键就存在, 后面那句登记**恒假 = 死代码** ⇒ 迁移过的记录永不进终身清单。'
     '_order 断言"登记"必须**早于**"复制": (应更晚者=复制, 应更早者=登记)'),

    (_MC + '/internal/join/existing.mcfunction',
     'unless data storage manacore:players "$(uuid)".reg run data modify '
     'storage manacore:players_all list append value "$(uuid)"', None, None,
     '★ N04 修(2026-10-11) 补登记: 补丁前就存在的记录(尤其已离线、无 index 的)不在 '
     'players_all 里 ⇒ debug/reset_all 清不到。老玩家重上线走 existing ⇒ 这里按"幂等标志 '
     'reg"补登记一次。少了它, 历史记录永远清不干净(报告 N04 的核心)'),

    (_MC + '/internal/player/create.mcfunction',
     'players "$(uuid)".reg set value 1b', None, None,
     '★ N04 修(2026-10-11): 建记录口必须打"已登记"标志(供 existing 判补登记)。'
     '5 个建记录口统一写 reg, 否则 existing 会把已登记的新记录再登记一遍'),
    (_MC + '/internal/join/new.mcfunction',
     'players "$(uuid)".reg set value 1b', None, None,
     '★ N04 修: 同上(新玩家首次建记录)'),
    (_MC + '/internal/debug/reset_one.mcfunction',
     'players "$(uuid)".reg set value 1b', None, None,
     '★ N04 修: 同上(管理员重置重建记录)'),
    (_MC + '/internal/uuid/migrate.mcfunction',
     'players "$(uuid)".reg set value 1b', None, None,
     '★ N04 修: 同上(迁移新建键)'),
    (_MC + '/internal/uuid/join.mcfunction',
     'reg set value 1b', None, None,
     '★ N04 修: 同上(该文件当前无调用方, 保持一致免得将来接回去时漏)'),

    # ---- N05/N06(2026-10-11): 重置链(逐项清账清单 + 首次加入事件) ----
    (_SD + '/event/player_reset.mcfunction',
     'scoreboard players reset @s zx.', None, None,
     '★ N06(2026-10-11): 清账清单必须**逐项** reset zx.*(由 _gen_reset_scores.py 生成), '
     '不能再回到"不带 objective 的全清"(那会连 naturewind 的 nw.* 一起清)。'
     '本锁只保证"清单非空且指向 zx.*"; 集合的完整对账由 resetset 规则负责。'),
    (_SD + '/event/player_first_join.mcfunction',
     'function sweetdream:event/player_reset', None, None,
     '★ N05(2026-10-11): 首次加入事件必须复用同一份清账清单(player_reset)—— '
     'reset_all 清不到的离线玩家靠它上线时补清; 少这行 = N05 没修。'),
    (_MC + '/internal/join/new.mcfunction',
     'function #manacore:event/player_first_join', None,
     ('function #manacore:event/player_first_join',
      'manacore:internal/join/register'),
     '★ N05(2026-10-11): join/new(新玩家 / reset_all 后首次上线)必须在 register '
     '**之后**抛 #manacore:event/player_first_join。抛早了(记录/索引还没落库)应用层'
     '可能读到未就绪的上下文; 抛在 existing 里则会让老玩家每次重连都清账本。'),
    ('manacore-1.0.0/data/manacore/tags/function/event/player_first_join.json',
     'manacore:event/noop', None, None,
     '★ N05(2026-10-11): 新事件标签的默认占位 —— 空标签不是合法目标, 会让 '
     '`function #manacore:event/player_first_join` 在解析期报错(整个 join/new 加载失败)。'),
    ('sweetdream/data/manacore/tags/function/event/player_first_join.json',
     'sweetdream:event/player_first_join', None, None,
     '★ N05(2026-10-11): sweetdream 侧必须往 #manacore:event/player_first_join 追加'
     '自己的 handler(否则事件抛了没人听 = N05 没生效)。'),
    (_MC + '/debug/reset_all.mcfunction',
     'scoreboard players reset @a manacore.gen', None, None,
     '★ N05(2026-10-11): reset_all 顺带清注册代/心跳(让在线玩家下一拍必然重走 join/new '
     '-> 触发 player_first_join)。不清也不致命(索引已空, verify 会判需要重注册), '
     '但显式清掉更"彻底重生"。'),
    # ---- N07(2026-10-11): 观测镜缓存按 UUID 分片 ----
    (_SD + '/equipment/tool/look/render_go.mcfunction',
     'cache."$(uuid)".eq',
     r'storage zx:look cache\.eq\b|storage zx:look cache\.skill\b', None,
     '★ N07: render(每刻·每个开面板的人)必须读**自己那份**缓存 cache."<uuid>". '
     '写回/读回全局单格 cache.eq / cache.skill 时, `execute as @a[tag=test_look_on]` '
     '的每一次覆盖都会串人: 装备专属段穿上别人的装备、冷却拿别人的技能 id 去查。'),
    (_SD + '/equipment/tool/look/render_go.mcfunction',
     'cache."$(uuid)".skill',
     r'storage zx:look cache\.eq\b|storage zx:look cache\.skill\b', None,
     '★ N07: 冷却读的"手持技能"也必须是自己 uuid 那份。'),
    (_SD + '/equipment/tool/look/cache.mcfunction',
     'sweetdream:equipment/tool/look/cache_go',
     r'storage zx:look cache\.', None,
     '★ N07: cache 只做"取 uuid / 判空 / 转交"(普通命令), 宏落库全在 cache_go —— '
     '它自己不许再写全局缓存格(否则 N07 原样回归)。'),
    (_SD + '/equipment/tool/look/cache_go.mcfunction',
     'cache."$(uuid)".eq',
     r'storage zx:look cache\.[a-z]', None,
     '★ N07: 缓存落库必须按 uuid 分片(见 cache 头注释); 写回全局单格 = 多人串人。'),
    (_SD + '/equipment/tool/look/cache_go.mcfunction',
     'cache."$(uuid)".skill',
     r'storage zx:look cache\.[a-z]', None,
     '★ N07: 手持技能的缓存同样按 uuid 分片。'),
    (_SD + '/equipment/tool/look/toggle.mcfunction',
     'execute if entity @s[tag=test_look_on] run function sweetdream:equipment/tool/look/cache',
     None, None,
     '★ N07: 开启面板那一刻必须**立即**刷一次缓存 —— 否则头一秒 render 读到的还是'
     '上一次留下的旧缓存(旧版是别人的, 新版是自己上一轮的)。'),
    # ---- N09(2026-10-11): 海棠 hook 必须"普通 wrapper + 宏叶子" ----
    (_SD + '/equipment/staff/begonia/hook_calc.mcfunction',
     'sweetdream:equipment/staff/begonia/emp_find',
     r'\$\(u[0-3]\)', None,
     '★ N09: 本文件被 #manacore:event/damage_calc **无参派发**, 绝不能含 $(u0..u3) '
     '(宏行拿不到参数 ⇒ 整段不执行、零日志)。宏行必须住在 emp_find, 由本文件 with storage 调。'),
    (_SD + '/equipment/staff/begonia/hook_calc.mcfunction',
     'execute at @s run function sweetdream:equipment/staff/begonia/emp_find', None, None,
     '★ N09: 查漩涡前必须先 `at @s` 把**位置**定到施法者本人 —— calc_as_owner 只换了'
     '执行者、没换位置, 否则 `distance=..6` 会按召唤物残留坐标量, 判成"不在漩涡旁"。'),
    (_SD + '/equipment/staff/begonia/emp_find.mcfunction',
     '$(u0)', None, None,
     '★ N09: 那条宏行必须住在 emp_find(只由 hook_calc `with storage zx:work bgc` 调)。'),
    # ---- N10(2026-10-11): 核心伤害的定点乘法必须走 mul_pct 除余分解 ----
    (_MC + '/internal/damage/calc.mcfunction',
     'manacore:internal/damage/mul_pct',
     r'operation\s+#\w+\s+\S+\s+\*=\s+#(?:mul_[mao]|im)\b', None,
     '★ N10: 基数(x1000) × 倍率(x100) ÷ 100 的**裸乘**会在 基数×倍率 > 约 21,474 时把'
     '中间值顶过 int32 ⇒ 回绕成负 ⇒ 末尾 `matches ..0` 夹成 0(报告例: max_mana 3 万、'
     '期望 30000, 实打 0)。四处都必须走 mul_pct 的"除余分解"(既不溢出也不掉精度)。'),
    (_MC + '/internal/damage/mul_pct.mcfunction',
     'scoreboard players operation #lo $(obj) -= #r $(obj)', None, None,
     '★ N10: 除余分解的关键一步 —— 余数用**减法**取(r = B − (B÷100)×100), **不用 %=**:'
     '原版 %= 对负数的取余符号没有先例背书, 减法版对正负严格成立(20 万组离线比对通过)。'
     '★ A01(2026-10-11 三审): 四个临时量(#q/#r/#lo/#mul_out)一律落在调用方传入的 $(obj), 不再硬编码。'),
    (_MC + '/internal/damage/mul_pct.mcfunction',
     'scoreboard players operation #mul_out $(obj) += #lo $(obj)', None, None,
     '★ N10: 出参必须是"前半(q·M) + 后半(r·M÷100)"两项之和, 少一项 = 丢掉小数部分。'
     '★ A01: 出参 objective = $(obj)(= 调用方的 objective)。'),
    (_MC + '/internal/damage/mul_pct.mcfunction', None,
     r'scoreboard\s+players\s+operation\s+#(?:q|r|lo|mul_out)\s+manacore\.math\b'
     r'|store\s+result\s+score\s+#mul_out\s+manacore\.math\b', None,
     '★ A01(2026-10-11 三审)禁止回归: mul_pct 里出现**硬编码** manacore.math 的输入/出参。'
     '调用方 sweetdream:lib/dmg_add_apply 的分数写在 zx.meta —— "持有者名对、objective 错" '
     '会让输入一律读不到(0) ⇒ 只要本轮有增伤, 重算结果就是 0(报告例: 该给 115 实得 0), '
     '而且**零日志、仿真也看不见**(数值仿真按值建模, 没建 (持有者,objective) 键)。'
     'objective 只能由 $(obj) 显式传入。'),
    # ---- N11(2026-10-11): tick_self 一轮只 join 一次 ----
    (_MC + '/internal/session/tick_self.mcfunction',
     'execute if score #need manacore.meta matches 1 run function manacore:core/player/join',
     r'unless data storage manacore:work id\{ok:1b\} run function manacore:core/player/join',
     None,
     '★ N11: 两个注册判据(代落后 OR 索引无效)必须在**任何 join 之前**合成单一 #need。'
     '顺排两条时首次注册会双跑: 第一句 join 已把 @s gen 顶到 #gen, 而 ② 留下的 '
     'id.ok=0b 还是旧值(join 之后没人回写) ⇒ 第二句又 join ⇒ 同一秒两次 player_join。'),

    # ---- D01(2026-10-11): 口径 B —— 加算只作用于"本通道分量" ----
    (_MC + '/internal/damage/calc.mcfunction',
     'storage manacore:out r.seg_m', None, None,
     'D01 口径 B: calc 必须把三通道分量落进 out(r.seg_m/a/o), 否则 dmg_add_apply 读不到'
     '分量 ⇒ 只能按 0 算(静默)'),
    (_MC + '/internal/damage/calc.mcfunction',
     'storage manacore:out r.seg_x', None, None,
     'D01 口径 B: calc 必须落 r.seg_x(custom_damage + 生命项 = 第四条分量, 不吃通道加算)'),
    (_MC + '/internal/damage/calc.mcfunction',
     'storage manacore:out r.im', None, None,
     'D01 口径 B: calc 必须落 r.im(独立乘区) —— 事件里 work a 会被 hook 重置, '
     'apply 只能从 out 读'),
    (_MC + '/internal/damage/health_part.mcfunction',
     '#seg_x manacore.math += #hp', None, None,
     'D01 口径 B: 生命项必须**同时**累加进 #seg_x(第四条分量), 否则会漏进"不吃加算"的 0'),
    (_SD + '/lib/dmg_add_apply.mcfunction',
     'internal/damage/mul_pct', None, None,
     'D01 口径 B: 分量级乘法必须走 mul_pct(seg 可达 ~2e9, 裸乘会越过 int32 回绕, 同 N10)'),
    (_SD + '/lib/dmg_add_apply.mcfunction',
     'storage manacore:out r.seg_m', None, None,
     'D01 口径 B: dmg_add_apply 必须按分量级重算(读 r.seg_*), 而不是乘整段'),
    (_SD + '/lib/dmg_add_apply.mcfunction',
     None, r'zx:work ch', None,
     'D01 回归: dmg_add_apply 又读快照 zx:work ch 判通道 —— 口径 B 靠分量自动筛选(seg=0), '
     '读 ch 会把落点退回"整段"(旧口径 A: 100mm+10atk+炽天使 = 165 而非 115)'),
    (_SD + '/lib/dmg_add_put_any.mcfunction',
     'put.ch set value "oth"', None, None,
     'D01 口径 B: 不挑口径的加成必须给 mm/atk/oth 三条各写一份(分段式下 '
     'Σseg_i×(1+X)=整段×(1+X)); 只写一条 = 其余通道吃不到(静默)'),
    (_SD + '/lib/dmg_add_put_any.mcfunction',
     None, r'zx:work ch', None,
     'D01 回归: dmg_add_put_any 又读 zx:work ch 挑通路 —— 口径 B 下应固定写满三条'),
]
for _rel, _must, _never, _order, _why in _REGRESS:
    _p = ROOT / _rel
    if not _p.exists():
        R['regress'].append((_rel, 0, '探针的目标文件不见了(被删/改名?): ' + _why))
        continue
    try:
        _ls = [(i, l) for i, l in enumerate(
            _p.read_text(encoding='utf-8', errors='ignore').split('\n'), 1)
            if not l.strip().startswith('#')]
    except Exception:
        continue
    if _must and not any(_must in l for _, l in _ls):
        R['regress'].append((_rel, 0, '缺少"修复标志"(应含 `%s`) —— %s' % (_must, _why)))
    if _never:
        for _i, _l in _ls:
            if re.search(_never, _l):
                R['regress'].append((_rel, _i, '又写回了已修掉的老写法 —— ' + _why))
    if _order:
        _a = next((i for i, l in _ls if _order[0] in l), None)
        _b = next((i for i, l in _ls if _order[1] in l), None)
        if _a is not None and _b is not None and _a < _b:
            R['regress'].append((_rel, _a,
                '「%s」(第 %d 行) 排在「%s」(第 %d 行) 之前 —— %s'
                % (_order[0], _a, _order[1], _b, _why)))

# F10 无息的跨 tick 标记: 必须带施法者 uuid 后缀(全局同名会让"多人同时施放"互相清标记 /
#     漏命中), 且清理只能按自己的 uuid(见 hush/tag_clear)。
_hush_dir = ROOT / 'sweetdream' / 'data' / 'sweetdream' / 'function' / 'equipment' / 'sword' / 'hush'
if _hush_dir.exists():
    for _p in sorted(_hush_dir.glob('*.mcfunction')):
        for _i, _l in enumerate(_p.read_text(encoding='utf-8', errors='ignore').split('\n'), 1):
            _s = _l.strip()
            if _s.startswith('#'):
                continue
            if re.search(r'zx\.hs_(?:hit|path|new)(?![_0-9A-Za-z])', _s):
                R['regress'].append((_p, _i,
                    'F10 无息标记归属: 出现**无归属**的突击标记 —— 必须写成 zx.hs_hit_$(uuid) / '
                    'zx.hs_path_$(uuid) / zx.hs_new_$(uuid)。全局同名时 B 施法会清掉 A 的标记, '
                    '两人打同一群怪时又互相让对方漏命中(静默)'))

# F21 原版音效 ID: 拼错的不会报错, 只是那一声不响(已对照本机 1.21.5 assets/indexes)。
_SFX_BAD = re.compile(r'minecraft:entity\.(?:allay\.item_throw|evoker\.cast)(?![_a-z])')
for _fnk, _fp in functions.items():
    try:
        _txt = _fp.read_text(encoding='utf-8', errors='ignore')
    except Exception:
        continue
    for _i, _l in enumerate(_txt.split('\n'), 1):
        if _l.strip().startswith('#'):
            continue
        if _SFX_BAD.search(_l):
            R['regress'].append((_fp, _i,
                'F21 音效 ID 拼写错(1.21.5 里应为 entity.allay.item_thrown / '
                'entity.evoker.cast_spell), 这一声不会播 —— 且不报错'))

TITLE = {'fn': 'function 引用不存在的目标', 'tag': '#tag 引用无对应 json',
         'upfield': '升级数值字段缺"减旧/加回"一半, 或累加器没归零(静默算错)',
         'macro': '含 $(变量) 但行首不是 $', 'sel': 'data entity 选择器缺 limit=1',
         'adv': '进度奖励问题', 'json': 'JSON 解析失败', 'rp': '模型引用缺失',
         'sched': 'schedule 同名(默认 replace, 会互相顶掉)',
         'dust': '老式 dust 粒子写法(会让整个函数加载失败)',
         'comp': 'tellraw/title 的 JSON 组件解析失败(会让整个函数加载失败)',
         'dup': '同一文件内命令完全重复(多半是复制粘贴事故)',
         'ply': '只认玩家的命令配了非玩家选择器(会让整个函数加载失败)',
         'ply2': '被 as 非玩家调用却用 tellraw @s (运行时静默失效, 需人工确认)',
         'mcomma': 'matches 用了逗号列表(会让整个函数加载失败)',
         'swap': '逐帧切换 / 被数据包驱动的物品模型没关 hand_animation_on_swap'
                 '(第一人称手上一直抽搐; 含覆盖层资源包, 不限于 sweetdream_rp)',
         'dollar': '行首有 $ 但不含 $(变量)(会让整个函数作废)',
         'regcap': '通用数值注册表: 表行数超 cap / cap 与生成器不一致',
         'regobj': '通用数值注册表: 引用了没建过的计分项(静默显示不出来)',
         'regname': '装备 id 没登记中文名(debug/worn 只会显示英文 id)',
         'rege': '注册表行缺 e 字段 / e 不是已登记装备(那行在 stats 里永远不显示, 静默)',
         'selfmacro': '宏参数直接传 zx:data self(会让宏函数一条命令都不跑, 静默)',
         'dspace': '参数间出现连续两个空格(会让整个函数加载失败)',
         'nbtsp': 'data 的路径与 NBT 过滤器之间多了空格(过滤器必须紧贴路径, 如 Items[{Slot:0b}] / updef."x"{req:""}; 带空格 = 整条命令解析失败, 整个函数加载失败且不报行号)',
         'storescale': 'store result score 多写了 scale(会让整个函数加载失败)',
         'opnum': 'scoreboard operation 用数字当运算数 —— 字面量会整个函数加载失败, '
                  '宏展开成数字则**运行时静默失效**(加载期看不出来, 现象是"函数在跑却没效果")。'
                  '常数放假玩家(如 #k1000), 宏值改用 players add',
         'floatz': 'custom_model_data 的 floats 列表缺 f 后缀(整型列表 -> 物品丢失模型)',
         'base': '强化材料底座会被合成吃掉(玩家会把它用掉, 已踩两次)',
         'oldname': '超限定义表缺 name / label / lore(漏了静默: 敲完不改名 或 描述被清空); '
                    '或 name.color 不等于该装备本名颜色(超限后要沿用原装备颜色, 不统一成紫色)',
         'rearm': '一次性进度的防卡死契约: 自撤销型进度必须进 lib/rearm, '
                  'revoke 不得排在 return 之后(漏了会永久静默失效)',
         'const': 'operation 用了没 set 过的数字常数假玩家(值为 0, /= 会除以 0 中断整个函数)',
         'itempath': '物品谓词槽位名(weapon.mainhand / armor.head / hotbar.N / container.N) '
                     '混进 data 命令的 NBT 路径 —— **静默失败、零日志**。这些名字只有 '
                     'item replace / if items 认; data 的 NBT 路径用 equipment.mainhand 等',
         'intovf': '★ R05: ×1000 定点数再乘法没有 int32 上界保护 —— 中间值越过 '
                   '2,147,483,647 会**回绕成负数**(不报错), 常态却看不出来。'
                   '应加动态上限 = INT32_MAX ÷ 乘数。注意别改成"先除后乘": 那会让常态丢精度。',
         'equip': '装备逻辑被 @a 广播调用却没在函数体内判穿着(没穿也生效, 静默)',
         'melee': '"只平A"契约: 伤害触发型进度没限定 minecraft:is_player_attack'
                  '(技能伤害也会算进去, 静默)',
         'glint': '弩的 give 带了附魔却没写 enchantment_glint_override=false'
                  '(物品会一直闪紫色附魔光效, 静默)',
         'lorestyle': '物品描述的版式不是 lore_fmt 的输出(数字没留白 / 用了 * 当乘号…)',
         'chanhack': '技能倍率: 又把面板读数塞进 base_attack(旧口径 hack, 面板没法归类)',
         'chandef': '技能倍率三通道: 口径表(lib/skill_mul/def)和技能文件对不上'
                    '(面板会漏显示或归错列, 静默)',
         'olchan': '超限伤害没按三条通道派发(漏掉的那条通道会静默少吃超限)',
         'olvcache': '读了 zx:work olv.mana 却没自己先写基准值(没超限时 mod 会提前 return, '
                     '读到 0 / 陈旧值: 提示显示「需要 0」或扣错蓝, 都不报错)',
         'smwind': '面板技能倍率没折进「最大魔力值技能倍率」通用加成(风声/忘川彼岸/无效) / '
                   'scan 里出现 return 把它折入跳过(放完风行后面板仍显示 ×1, 像没生效) / '
                   'lib/mm_add 三件套缺件 / tick 没挂 lib/second / 计分项没在 core/load 建出来',
         'regsent': '注册表"全局行"哨兵不齐: e:"all" 的行会打 "(没登记中文名!)" 假警报',
         'numloss': '面板数字被 data get 截成整数(1.5 -> 1, 小数全被抹平)',
         'shulker': '染色潜影盒方块 id 非法(只有 16 种染料色; 写 gold/aqua 这类 setblock 会失败, 静默)',
         'posnbt': '用 NBT 写玩家 Pos(客户端权威, 服务端写完被顶回去 -> 静默不生效; 位移请用 /tp)',
         'obnode': '动了专用基准节点 zx:work ob(它只给 internal/damage 的 '
                   'with_from/one/stg_mul 用; 别的函数一碰, 基准就被污染 -> 范围伤害'
                   '的"只对某类目标生效"会随机串到下一条命上)',
         'dstore': 'data ... storage 的 id 后要用空格分隔路径(写成 zx:look.line2 会让整个函数加载失败;'
                   '★ 写成 players."$(uuid)".stats 同样中招: id 会被解析成 players.(尾点多一点) '
                   '⇒ 静默读写**另一个存储**, 不报错也取不到值)',
         'datarm': 'data remove storage <id> 不带路径 —— <path> 必填, 少了它整个函数加载失败;'
                   '存储的"根"在命令层面删不掉(2026-10-10 reset_all 实测)',
         'datapath': 'data modify storage <id> 少写 <targetPath> —— 操作符被当成路径名,'
                     '不报错但静默写错键(如建出一个叫 set 的键)',
         'mergelist': 'data merge 的 NBT 里带列表字面量 —— merge 对**列表是整体替换**,'
                      '`{list:[]}` 会把已有列表清空(2026-10-10: boot 每 reload 清一次槽位'
                      '回收池 ⇒ 槽位耗尽 ⇒ 整包静默失效)',
         'noexecute': '行首直接写 execute 的子命令(store / if / unless / as / at / positioned / '
                      'aligned / anchored / rotated / facing / on / run)却没写 execute。'
                      '★ 在宏函数($ 行)里**加载期不解析** ⇒ 不会变 "Failed to load function", '
                      '只在运行时中断整段(2026-10-10 register 第 14 行漏 execute ⇒ 整包静默失效)',
         'norun': '`if/unless score … matches <范围>` 后面漏了 run —— 范围不是命令, 后面必须接 '
                  'execute 子命令(`… matches 1.. run <命令>`); 漏写 ⇒ 整函数 Failed to load function'
                  '(2026-10-10 R05 批量加固脚本一次写坏 8 个函数)',
         'placeholder': '命令里残留模板占位符 `{xxx}` —— 批量生成脚本的占位符没替换就写进了文件, '
                        '它不是合法假玩家名/路径 ⇒ 该处命令直接失败(同上事故, 与 norun 叠加)',
         'selfield': '把玩家快捷栏下标写成 SelectedSlot —— 正确字段名是 Selected**Item**Slot; '
                    '写错则 data get/modify 抛错 ⇒ 函数从这一行起中断(运行时错误, 不进日志)',
         'airpred': '用 `items … air` 判空 —— **恒假**(2026-10-10 实测: 空手与持有都不触发); '
                    '空槽不是一个物品栈, 任何物品谓词都匹配不到它。判空请用 `unless items … *`',
         'itempath': '物品谓词槽位名(weapon.mainhand / armor.head / hotbar.N / container.N) '
                     '混进 data 命令的 NBT 路径 —— **静默失败、零日志**。这些名字只有 '
                     'item replace / if items 认; data 的 NBT 路径用 equipment.mainhand 等',
         'pname': '粒子名不存在 / 该带选项的粒子没写 {...}(整个函数加载失败, 日志只报一行)。'
                  '★ 命令里不能用"紧跟资源位置"的简写 (item minecraft:bone), 必须 {item:"..."}',
         'nbtint': '{"nbt":"<组件列表>"} 少了 "interpret":true —— 组件列表会被当 SNBT 原样打出来'
                   '(屏幕上吐一串 JSON, 而不是渲染成两行)',
         'scorelive': '把 {"score":"#假玩家"} 存进组件列表 —— 假玩家是全局共享, 渲染时读到最后一次的值'
                      '(逐行循环里会被后面的行覆盖; 常数请写 {"text":...})',
         'nowith': '调宏函数却忘了 with storage/entity/block —— 宏参数没绑定, 被调函数一条命令都不跑'
                   '(静默; 真实事故: 悲鸣永远清不掉)',
         'crossgate': '弩的 post_attack 附魔缺 damaging_entity 门控 —— 拿弩近战敲人也会触发技能'
                      '(不耗魔力 + 用上一发快照的层数; 真实事故 2026-10-05: 寒鸦等 5 把弩)',
         'crossshot': '弩没有配套的"射击进度 + shot 扣蓝" —— lore 写着「魔力 N」却从来不扣'
                      '(真实事故 2026-10-12: 电弧发射不消耗魔力)',
         'hbslot': 'items 命令用了裸 hotbar 槽位(未知槽位, 整个函数加载失败; 要 hotbar.0..8)',
         'strent': 'execute store result/success entity 目标是多实体(只收单实体, 整个函数加载失败; 多目标要 as 循环)',
         'nbtempty': '{"nbt":...,"interpret":true} 引用的 storage 节点被初始化成空表 [] —— 空列表'
                     '不是合法文本组件, 每次渲染都刷一条 "Failed to parse component: []"'
                     '(开面板时每刻一条, 几分钟就能把 latest.log 刷爆; 初值给 [{"text":""}])',
         'objmiss': '计分项被写/读但从没 scoreboard objectives add 过 —— 那条命令运行时直接失败, '
                    '对应机制永远不触发(真实事故: 幽匿残响的箭永不过期 / 天穹俯冲的步数保护不生效)',
         'asnoat': 'execute as @e/@a[...] run function 但链上没有 at @s / positioned '
                   '—— as 不换坐标, 被调函数里的 ~ 和 dx=/distance= 会取在原点'
                   '(真实事故: 清醒梦的漫彩范围真伤一次都打不到人)',
         'animdata': '打了 zx.anim 标签却没写 data.zx.anim —— lib/anim_step 的宏参数绑不上, '
                     '被调函数一条命令都不跑: 召唤物会定在起始帧、永远不动(静默)',
         'attrleave': 'attribute modifier 有 add 却全包没有同 id 的 remove —— 修饰符是'
                      '**实体数据**, 摘标签时摘不掉 -> 护甲/攻击力/移速的减益永久留在生物身上'
                      '(不报错; 真实隐患: 流火 armor-20% / 白昼梦 attack_damage-20%)',
         'ttl': '时长"施加处给满值"与"每秒衰减处兜底"两处不一致(通用标签 zx.tt.* / '
                '生物标签 圣痕 zx.sh_t·升痕 zx.stg_t)—— 会出现"刚贴上就剩几秒"或倒数被重置, 都不报错',
         'ctrlmul': '控制时长倍率没走单一真源 lib/ctrl_mul/pct(timestop/freeze 各写一份'
                    '或面板没读 -> 结算与实际走散; 来源用 add 会在范围选择器上按只数叠加)',
         'dimflag': '图标"剩余≤3秒变淡": 位掩码/阈值/字形/图集几处对不上 —— 该变淡的没变淡, '
                    '或掩码说变淡而字形没换(都不报错, 只是看起来没做)',
         'enemysrc': '敌方技能来源标记(src)通道不完整: api/damage 没复位/兜底, '
                     'api/enemy_damage 没标 "enemy", 或夜火的两条分支不互斥'
                     '(敌方技能会被算两次 = +32%)',
         'reloadttl': 'tag/load 里调了 tag/second 或 tag/ttl_tick —— core/load 在 /reload 时'
                      '也会跑, 于是每敲一次 /reload 就白扣场上所有标签 1 秒: 标签莫名其妙短命, '
                      '且不报错(真实事故 2026-10-06)',
         'dimsel': '带 execute in <维度> 的选择器没带位置参数 —— 裸 @e/@a 会**跨维度**搜索'
                   '全部维度(有 x/y/z 或 distance 或 dx/dy/dz 才锁当前维度), 于是"三维度各写'
                   '一遍"会让同一只被处理 3 次 = 3 倍速/3 倍伤害/3 倍粒子, 且不报错。'
                   '加 distance=0.. 即可(真实事故 2026-10-06: 标签寿命 3 倍快、融甲 10 秒变 '
                   '3.3 秒、法球 3 倍速、时停真伤 3 倍…)',
         'equipgate': '消耗标签统一入口(lib/mark_take)调用的装备被动没自带 "items entity @s" '
                      '门控 —— 它被 as $(by) 换身份调用, 调用方不会替它判穿着: 没穿的人也生效, '
                      '还会白扣魔力(真实事故 2026-10-06: eternity/reclaim 与 lib/mark_ember '
                      '初版都漏了, 代价是"永恒没生效" + 任何玩家消耗标签都被扣 50 蓝并刷回标签)',
         'storid': 'data storage 的**存储名与路径之间少空格**(`storage manacore:ctx.uuid`)'
                   '—— 会被当成一个存储名, 该行解析失败 -> **整个函数不加载**, 事件 tag 里'
                   '引用它的那一条也一起断(真实事故 2026-10-06:「无效」完全不生效, 而当时'
                   'check.py 0 报告 —— 命令语法级错误只能靠本规则 + latest.log)',
         'braceval': '`set value` 的字符串里写了花括号(常见: 选择器里的 `nbt=!{Health:0.0f}`)'
                     '—— NBT 读取器配平错位, 在该行后面的参数上报 "应为字面量" -> **整个函数'
                     '不加载**(真实事故 2026-10-06: thunder/bolt_dmg 因此整段失效)',
         'dmgch': 'damage_calc 事件里没先拍"通道快照"(lib/dmg_ch 必须是第一条), '
                  '或有 hook 直接读 manacore:work a —— 同事件的 api/formation/count 会把它'
                  '整份重置,"按通道区分"的装备加成(seraph_wing/wrath)会永远读到 0'
                  '(一次都不生效, 且一个字都不报)',
         'dmgord': 'damage_calc 事件的顺序 / hook 角色不对 —— 正确顺序是 '
                   'lib/dmg_ch(快照) -> lib/dmg_add_clear(清加算池) -> 加算 hook '
                   '(@calc: add) -> lib/dmg_add_apply(先合并再乘一次) -> 独立乘区 hook '
                   '(@calc: indep)。顺序错了不报错只算错: 没清池 = 伤害越打越大; '
                   '加算排在 apply 之后 = 那份完全不算; 独立乘区排在 apply 之前 = 乘错层',
         'panelrow': 'scan_mul 头部 `# @panel: <键>` 声明与代码实际写入的面板行不一致 —— '
                     '"加算(通道倍率 smul_*)"和"独立乘区(independent_multiplier)"在面板上是'
                     '两处不同的行, 折错行 = 玩家按 stats 看到的倍率和实伤对不上'
                     '(2026-10-06: 愠怒被折进 smul_mm, 用户反馈"愠怒是独立乘区")',
         'beamoff': '沿视线铺的粒子光束**整段落在视线轴线上** —— 第一人称摄像机就在眼睛上, '
                    '这些粒子全在 `眼睛 + N·视线` 这条射线上, 屏幕上只投影成准星上的一点: '
                    '**光束本身完全看不见**, 玩家看到的只是 dust 残影(寿命约 1 秒), 于是报'
                    '"特效没跟着玩家, 反而从玩家射到放技能的位置"。修法 = 整体沿本地坐标'
                    '下方偏出去(`positioned ^ ^-0.35 ^N`); 必须用本地坐标, 用世界竖直的'
                    '`~-0.35` 抬头时会横着窜出画面(真实事故 2026-10-07: 终末天启光柱)',
         'scoreeq': '计分板比较符写成了 `==` —— 原版只有 `=` / `<` / `<=` / `>` / `>=`, '
                    '`==` 是命令语法错: 报 "Whilst parsing command on line N: 错误的命令参数", '
                    '**整个函数加载失败**(一条命令都不跑)。真实事故 2026-10-07: '
                    'upgrade/api/fit_uncolor 4 行写成 `==` ⇒ 无色石右键完全没反应, '
                    '而 check.py 当时 0 报告(语法级错误静态抓不到, 只能靠本规则 + latest.log)',
         'scorelit': '`if score` 拿"字面量 / 宏变量"当比较对象 —— 比较符两侧**都必须是计分项**, '
                    '想跟字面量比只能用 `matches <范围>`。普通函数会因此**整个不加载**; '
                    '而 `$` 宏行更阴: 加载期只校验"有没有 $(变量)"、不校验替换结果 ⇒ 错误推迟到'
                    '运行期, 表现为"**该行之后的命令全不执行**"(函数就地中断), 零日志。'
                    '真实事故 2026-10-08: palette/color_body 写 `if score @s zx.pal_hit = $(id)` '
                    '⇒ 替换成 `= 7` 后整条解析失败 ⇒ 其后的"挑目标收尾/移动/命中"全不跑, '
                    '玩家报「色彩」生成后不动也不打人(而它前面的判断照跑, 所以还会到点消失)。',
         'guardclob': '同一个共享计分项(`#xxx` 是全局的, 没有作用域)上有一对**互补守卫**'
                    '(`..0` 与 `1..` 这种本该互斥的 if/else), 而第一条那行调用的函数会改写它 '
                    '—— 后一条守卫读到的是**被改写后的值** ⇒ 两条同时成立, 动作跑两遍'
                    '(数值翻倍), 全程静默。'
                    '真实事故 2026-10-08: manacore internal/cooldown/reduce 的 `#amt` 既当守卫'
                    '又被 reduce_sec 改写成"秒x20" ⇒ reduce_body 减两遍 ⇒ **所有以 {seconds:} '
                    '传参的减冷却都减 2 倍**(调色盘蓝 -5→-10 秒 / 风帆 3→6 秒 / 息影 10→20 秒 / '
                    '冷却剂Ω 每秒 1→2 秒)。修法: 判定变量与结果变量分开, 或把动作收成唯一调用点。'
                    '改法 = `$scoreboard players set #tmp zx.meta $(x)` + 计分项比计分项',
         'retabort': '把"被调函数里的 return"当成自己的 return 用 —— `return` 只结束'
                     '**它自己那次调用**, 控制权回到调用方继续往下跑; 如果调用方末尾还会 '
                     '`data modify storage zx:out r.ok set value 1b`, 那次校验就被静默吞掉。'
                     '正确姿势 = helper 只写标记分/NBT, 由调用方判 + `execute ... run return`。'
                     '真实事故 2026-10-07: upgrade/api/fit 调 fit_slot_free(内含 return 0) ⇒ '
                     '"2 个自由槽"上限失效, 玩家可以无限敲',
         'atkonce': '文案写「每次攻击(后)」的入口没有按游戏刻去重 —— `player_hurt_entity` '
                    '是**每命中一个生物触发一次**, 横扫打 3 只则入口同一刻跑 3 遍, '
                    '"每次攻击"实际变成"每次命中"(3 倍, 静默)。口径(玩家 2026-10-07): '
                    '「每次攻击(后)」= 一次平A一次; 「攻击到生物」= 才按命中数。'
                    '真实事故: 脑髓蛭蛊虫 +3 层 / 天使核心扣 3×80 魔力 / 陨星 10% 变 ≈27% / '
                    '魔力增殖打 3 只回 15 魔力。修法 = 每件一个计分项, 存 #now, 同刻再来直接 return',
         'upreq': '升级定义表(upgrade/def/load)的 req 链写坏了(全静默): 指向不存在的 id '
                  '⇒ 那条升级永远敲不上; 成环 ⇒ 前置互等 + 无色石的整链返还会无限递归; '
                  '跨 series / 跳级(不是正好低一级) ⇒ 链条意义不明; 同 series 里 tier 重复 '
                  '⇒ 覆盖制说不清算哪条',
         'nbtrange': 'NBT 复合里写了 `key:1..` / `key:..1` 这类**范围写法** —— 1.21.5 的 '
                     'NBT 读取器不接受(选择器 nbt= 也一样), 报 "Whilst parsing command on '
                     'line N: 应为十进制数", 后果是**整个函数加载失败**(一条命令都不跑, '
                     '游戏里只表现为"装备按了没反应")。要判"数值字段 >= X" 只能逐实体 '
                     '`data get entity @s <字段>` 存分数再判(见 immolate/check_burn)。'
                     '真实事故 2026-10-07: tinder/burn 的 `unless data entity @s {Fire:1..}` '
                     '⇒ 点火整段失效。★ 同类: 计分板 `matches` 用逗号列表、`if score` 写 `==`',
         'boltseen': '手工召唤的真闪电忘了带 zx.th_seen —— 会被雷鸣的每刻扫描(见 '
                     'core/tick 的 `tag=!zx.th_seen` 那三行)当成"刚出现的雷"接管; 若这道雷'
                     '是从雷鸣反应链里劈出的(如 thunder/pend_go、thunderclap/bolt_one), '
                     '它会自己再触发一次 strike -> 1 秒后再劈 -> 无限连锁。故意要让雷鸣'
                     '接管的雷请把文件加进 check.py 的 _BOLT_EXEMPT。另外盯威霆"每刻劈一道"的'
                     'bolt_fx 有没有三维度都挂在 core/tick 上(少一个维度 = 该维度永不落雷)。',
         'selfclr': '同一条计分项上"改"排在了"判"前面, 而且是**自己把自己清零** —— '
                    '`if score @s zx.X matches 5.. run set @s zx.X 0` 之后又出现 '
                    '`if score @s zx.X matches 5..` ⇒ 后面那些命令**永远不执行**, '
                    '不报错、函数也照常加载(静默死分支)。真实事故 2026-10-08: '
                    'equipment/sword/myriad/on_hit 把清零排在 tellraw / playsound 之前 '
                    '⇒ "特殊技能就绪"提示与音效从来没出现过(玩家反馈"触发特殊技能时没提示"), '
                    '而窗口、计数全都正常 —— 所以只看效果永远查不出来。'
                     '改法: 把"清零"移到该分支所有"判"之后。★ 同类: scoreeq / 规则 58。',
         'mqgate': '超限·万念/千散的"剑魂"口径被人拆掉了门控 —— 千散那段描述里的'
                   '"本武器"= 千散(用户 2026-10-08 定稿), 于是三条都只认千散口径: '
                   '① 清剑魂 = 主动放千散(`tail` 那行要同时有 #mq_qs / #mq_pas 两个正判); '
                   '② 按剑魂重复 1+N 次 = 只有千散口径(`hit_go` 两条赋值行); '
                   '③ 满 5 进居合 = 掐在千散口径(`ju_check`)。'
                   '★ 判据一律写 `matches 1` 正判 —— 假玩家没 set 过时 `matches 0` 不成立, '
                   '写成 `matches 0` 会变成"主动放万念反过来清剑魂"。'
                   '真实反馈 2026-10-08: 用户"为什么我使用万念后剑魂也会清除" —— '
                   '老实现只判 zx.mq_ol, 主动放万念(它自己又不攒剑魂)把攒的全清光, 且不报错。',
         'modelrot': '资源包模型元素不合法 —— 整份模型加载失败, 游戏里只能看到"紫黑方块"'
                     '(missing model, 和"贴图丢了"长得几乎一样)。★ MC 1.21.5 的 '
                     '`rotation.angle` **只接受 -45/-22.5/0/22.5/45 五个离散值**, 不是'
                     '"±45 以内任意值"; 连带查 from 严格小于 to(退化元素被静默丢弃)、'
                     '取值域 [-16,32]、uv 必须是 4 个数。'
                     '真实事故 2026-10-08: domain.json 写 60/120/180/240/300(想"每 60° 摆一片'
                     '符文碎片朝切向") + meteor_rock.json 写 22/14/38 —— 两个 item_display 在'
                     '游戏里都是一坨紫黑方块, 而 check.py 当时 0 报告(模型路径与贴图都在, '
                     '只有 latest.log 里那句 `Invalid rotation X found` 能作证)。'
                     '★ 想摆"任意角度"只能绕开 rotation: 改成对 90° 旋转不变的形状(如正交薄片)'
                     '自己用 from/to 摆位, 或换成 ±45/±22.5 的近似角。',
         'storpath': '`execute if/unless data storage <存储名> <SNBT键值对>` —— 条件式的'
                     '存储名后面要写 **NBT 路径**(`r.ready` / `r{ready:1b}`), 不是复合。'
                     '直接写 `... manacore:out ready:1b` 时 `ready:1b` 不是合法路径(`:` 未加'
                     '引号只能出现在键名里) ⇒ 该行解析失败 ⇒ **整个函数不加载**(一条命令都不跑), '
                     '只在 latest.log 报一行。真实事故 2026-10-09: charge/{end_ol,mode_tick} '
                     '都写成 `... out ready:1b` ⇒ 超限·超•负•荷「第二形态」整段加载不出来, '
                     '状态结束后永远进不了第二形态(零日志; 与 storid/braceval 同族)',
         'attrprefix': 'attribute 用了 1.21.2 之前带前缀的属性名(`generic.` / `horse.` / '
                       '`player.` / `zombie.`) —— 1.21.2 起前缀已移除(如 '
                       'generic.attack_speed -> attack_speed), 写旧名会让该行解析失败 ⇒ '
                       '**整个函数加载失败**(一条命令都不跑, 只在 latest.log 报一行'
                       '"无法找到类型为 minecraft:attribute 的元素 ...")。'
                       '真实事故 2026-10-10: lib/atk_charge 写 minecraft:generic.attack_speed '
                       '⇒ 平A蓄力工具整份不加载, 自测毫无输出。',
         'cdstop': '"停止正常冷却缩减"(冻结冷却) 写坏了 —— manacore 冷却是"记结束时刻 end"'
                   '式、无全局衰减器, 冻结 = 每秒 increase(+20 刻)。★ 必须"先 check、后 increase":'
                   '同拍先冻会把"刚到点的冷却"又推远 ⇒ 自动使用永远触发不了(静默死循环)。'
                   '★ 且 increase 要带 `unless ... r{ready:1b}` 保护。'
                   '真实事故 2026-10-10: 超限·超•负•荷 该冻的没冻、又把"攻击 -3 秒"被动关掉 ⇒ '
                   '变成"冷却自然衰减、每 100 秒白送一轮超载", 与文案相反。',
         'freezegate': '冻结冷却(freeze_cd)挂错了形态 —— 调用点必须只用 `zx.chg_mode`(第二形态)'
                       '当判据。写成 `zx.chg_ol`("这次施法是不是超限版"的快照, 第一形态同样成立)'
                       '⇒ 第一阶段被误冻, 与文案"该状态结束后…**则**自动使用**且**该技能停止正常'
                       '冷却缩减"(冻结属于"自动使用之后"= 第二形态)相反。'
                       '用户原话: "在第一阶段是不冻结的 / 超载阶段才会冻结"。',
         'olfit': '超限石 apply 的 `of` 必须是**英文 zx id**(= 文件名), 且 oldef 里真有条目 —— '
                  '写中文/显示名会让 fit 第一行取不到 oldef ⇒ reason=no_def, 敲上去只报'
                  '"这把武器没有超限定义(定义表缺条目)"、一件都敲不上(中文名只该出现在给玩家'
                  '看的文案里)。顺带守 item/advancement/apply 三件套齐全。'
                  '真实事故 2026-10-10: 批 G/H 生成器格式参数错位, 4 块石头(海棠/偏振光/'
                  '桂冠/炉心)的 of 全写成中文名, 静默全废。',
         'eyedist': '瞄"眼睛"的光束/线用了小 distance(<=1.6)当"到达/命中"判据 —— distance 量的是'
                    '到生物**脚底**的距离, 走到目标头上时还差一个眼高(>=1.6) ⇒ 判据恒假, '
                    '光束**越过生物继续飞**到步数上限。改成判定箱相交(dx/dy/dz)或朝向改 feet。'
                    '真实事故 2026-10-10: polarized_light/beam_step ④(distance=0..0.5) ⇒ '
                    '用户反馈"特效会越过生物, 很违和"。',
         'tgvocab': '标签词汇表(批 A): 装备 give 的 custom_data.tags 用了**词表外**的词 —— '
                    '词表是封闭集(单一真源 .workbuddy/_tags_data.py -> tg/def/load 的 tgdef), '
                    '写错/塞进私有资源名会让该装备**静默**查不到(谓词恒不命中)、文件看不出异常。',
         'regress': '已修缺陷的"形态锁定"(审查报告 2026-10-10 · O10): 把 F06–F21 那批'
                    '**静默型**坑修复后的代码形态固定住(必需的映射/校验/归属标志在不在、'
                    '已修掉的老写法有没有写回来、清理动作是否排在扣费之后)。'
                    '这些坑不报错、只"没效果", 且多要多人/多目标/跨 tick 才现形 —— '
                    '静态只能守形态; 真正的运行时回归仍需按报告的 R01–R06 实机验收。',
         'datarm': '`data remove storage <id>` 不带路径 —— <path> 是**必填**参数, 少写会让'
                   '**整个函数加载失败**("Whilst parsing command on line N: 未知或不完整的命令")。'
                   '★ 顺带纠正一个常见误解: 命令存储的"根"在纯命令层面**删不掉**, 没有特殊路径'
                   '可用来删根; 想清空只能逐个键删, 或改成"可遍历清单 + 逐个删"'
                   '(实测 2026-10-10: manacore:debug/reset_all 栽在这条上)。',
         'datapath': '`data modify storage <id>` 少写 <targetPath> —— 操作符名(set/merge/append/'
                     'prepend/insert)本身是合法路径名, 所以**不会报错**, 而是静默在存储里建出'
                     '一个叫 `set` 的键(`data modify storage zx:work set value {}`);'
                     '本意多半是"清空某个节点/整个存储"。想清空请给真实路径, '
                     '根节点清空要改结构(见 purge_registry 头部的说明)。',
         'mergelist': '`data merge storage <id> {…: […]}`, 即 merge 的 NBT 里带**列表字面量**。'
                      '★ NBT merge 对列表是**整体替换**(不是保留/追加) —— 只对复合标签'
                      '递归合并。所以 `data merge storage manacore:free_slots {list:[]}` 看着'
                      '像"保证池子存在", 实际是**每次执行都清空一次**。'
                      '2026-10-10 事故: core/boot 每 /reload 清一次槽位回收池, 而 #next_slot '
                      '只增不减 ⇒ 槽位只出不进 ⇒ 撑满 #max_slots 后 slot/new 永远拒分配 ⇒ '
                      '没人能注册 ⇒ manacore:index 恒空 ⇒ **整包静默失效**(不报错, 但技能/'
                      '观测镜/提示全死; 现场 #next_slot=64=#max_slots、#slot_overflow=52)。'
                      '只想"保证存在"就写 `data merge storage <id> {}`, 内容另用 '
                      '`execute unless data … run data modify … set value []` 初始化。',
         'noexecute': '行首(去掉缩进和 `$`)直接是 `store` / `if` / `unless` / `as` / `at` / '
                      '`positioned` / `aligned` / `anchored` / `rotated` / `facing` / `on` / `run` '
                      '之一, 且整行没有 `execute`。它们只是 execute 的**子命令**, 不能单独成行。'
                      '★ 在宏函数里($ 开头的行)**加载期根本不解析**, 所以不会变成 '
                      '"Failed to load function" —— 只在运行时把整个函数中断掉, '
                      '而且函数内命令报错默认不进 latest.log ⇒ **现场表现为"整包静默失效、'
                      '日志零报错"**。2026-10-10 实测: internal/join/register 第 14 行漏写 '
                      'execute ⇒ 索引与 manacore.gen 都写不进去 ⇒ tick_self 每秒重注册 '
                      '⇒ 每秒弹走一格槽位(64→55)⇒ self_uuid 恒空 ⇒ sweetdream 全死。',
         'norun': '`execute if score A obj matches <范围>` 的**范围后面漏了 `run`**。'
                  '范围(如 `1..`)本身不是命令, 后面必须接 execute 的子命令 —— '
                  '写成 `… matches 1.. scoreboard players operation …` 会在加载期就炸, '
                  '报 "错误的命令参数 at position N: ...matches 1.. <--[HERE]"。'
                  '★ 与 noexecute 相反: 这条**会**变成 Failed to load function(看得见), '
                  '但一次批量脚本能同时写坏十几个函数(2026-10-10 R05: 8 个)。'
                  '正解 `… matches 1.. run scoreboard …`。',
         'placeholder': '命令里残留批量脚本的**模板占位符** `{cap}` / `{mul}` / `{acc}` 之类 '
                        '(花括号里只有一个裸标识符)。说明生成脚本的 format/替换没生效就把内容 '
                        '写进了文件, 于是那几行的假玩家名/路径根本不存在 ⇒ 该处命令直接失败。'
                        '★ 教训: 批量改完必须**读回文件核对**, 不能只信脚本的打印输出 '
                        '(2026-10-10 R05 脚本同时漏了占位符替换和 run, 8 个函数全废)。',
         'selfield': '把玩家"当前选中的快捷栏格"的字段名写成 `SelectedSlot` —— 正确的是 '
                     '`Selected**Item**Slot`。写错后 `data get entity @s SelectedSlot` 抛错, '
                     '而它在**非宏行**里是运行时错误 ⇒ **函数从这一行起整段中断**, '
                     '后面的备份 / schedule / 回写一条都不跑, 且 latest.log **看不到**。'
                     '2026-10-10 实测: internal/itembackup/effect_1 的记账行写错 ⇒ '
                     'backup 没做、`schedule … return 1t` 没排 ⇒ 消耗型武器被吃掉后再也没人还。'
                     '★ 一般形式: **任何 NBT 字段名都要先在库里找先例**, 不要凭印象编 —— '
                     '先例: equipment/sword/sickle_dreams/sweep/start 第 14 行。',
         'airpred': '用 `items … air` 当"槽位是空的"判据 —— **恒假**。'
                    '2026-10-10 玩家实测: `execute if items entity @s weapon.mainhand air` '
                    '在**空手时和拿着东西时都不触发**。原因: 空槽根本不是一个物品栈'
                    '(它压根不在 Inventory 数组里), 所以物品谓词匹配不到它 —— '
                    '`air` 这个 id 既不等于"空", 也不是玩家手里的东西。'
                    '★ 后果是**静默恒假**: 不报错、不进日志, 只是那个条件永远不成立。'
                    '若它被用来做"XX 才执行"的门, 整条线就废了。'
                    '★ 正解: 判空用 **unless items entity @s <槽> \\***(通配物品谓词 `*`), '
                    '非空用 if items … \\*。2026-10-10 已用在 internal/itembackup/effect_2 '
                    '的回手占位保护上(②-a 空 -> 写回原格 / ②-b 非空 -> 退回当前选中格, '
                    '两条互补 ⇒ 就算 `*` 对空槽语义相反也只退化成老行为, 不会丢武器)。',
         'itempath': '把物品谓词槽位名写进 data 命令的 NBT 路径 —— **静默失败、零日志**。'
                     '`weapon.mainhand` / `armor.head` / `hotbar.N` / `container.N` 这些是'
                     '**物品谓词槽位语法**, 只有 `item replace` / `if items` 认; NBT 路径是'
                     '另一套: 1.21.5 实体装备 = `equipment.mainhand` / `equipment.offhand` / '
                     '`equipment.head`…, 玩家背包 = `Inventory`, 容器方块 = `Items`。'
                     '2026-10-11 事故: O03 的 backup 写 `set from entity @s weapon.mainhand` '
                     '⇒ data modify 静默失败 ⇒ 快照从未写入 zx:ret ⇒ 消耗型武器永不回手'
                     '(离线取证: 存档 zx 命名空间 12 个 storage 里连 ret 都没有)。'
                     '先例: debug/raw 第 57-61 行、station/api/lore_refresh 第 41-62 行。'
                     '★ 坑 95 补充: equipment.* 只对**非玩家实体**和玩家的盔甲成立 —— '
                     '玩家的主手/副手在 Inventory 列表(主手=选中的快捷栏格, 无静态路径), '
                     '拷玩家手上的物品必须走 snap_main/snap_off 中转盔甲架',
         'criterion': 'scoreboard objectives add 的准则名带命名空间 —— 2026-10-11 双连事故: '
                      'zx.hp_c 先写 `minecraft.health` 后改 `minecraft:health`, 两次都是"未知的准则" '
                      '⇒ core/load 整函数加载失败 ⇒ **全包静默死**。1.21.5 jar 反查铁证: 只读属性准则 '
                      '只有**裸名** health/food/air/armor/level/xp/deathCount(1.13 起从来没有命名空间); '
                      '点号/冒号只属于统计类准则(minecraft.custom:minecraft.deaths)。★ 与 itempath/'
                      'selfield 同族: 命令参数没有"编译期"检查, 靠本规则 + latest.log 兜底',
         'resetset': '重置清账清单(N06): sweetdream:event/player_reset 的逐项 `reset @s zx.*` '
                     '必须 == 全仓 `scoreboard objectives add zx.*` 的集合(双向)。清单由 '
                     '.workbuddy/_gen_reset_scores.py 生成 —— 新增账本要重跑它。'
                     '★ 少了 -> "漏清"(账本残留, 装备被动应加的不加回); 多了 -> 拼错/已删。'
                     '★ 还禁"不带 objective 的全清": 会连别的数据包(naturewind 的 nw.*)一起清。',
         'tagmacro': '被函数标签(tags/function/*.json)直接引用的函数里含宏行 $(…) —— '
                     '`function #…` 是**无参**调用, 宏行拿不到参数会整段跳过(零日志)。'
                     '真实事故 N09: begonia/hook_calc 里写着 $(u0)..$(u3) 而被 '
                     '#manacore:event/damage_calc 无参派发 ⇒ 海棠漩涡增强整段不执行。'
                     '正解 = 标签指普通 wrapper, wrapper 再用 with storage 调宏叶子。',
         'dmgseg': 'D01 口径 B(2026-10-11) —— 加算只作用于"本通道分量"的三件套必须成对: '
                   '① calc 出 r.seg_m/a/o/x + r.im; ② dmg_add_apply 按分量级重算(走 mul_pct, '
                   '不读快照 zx:work ch); ③ dmg_add_put_any 给三条通道各写一份。'
                   '缺一个 = 静默算错(多通道技能数值偏差, 不报错): 比如 apply 读回 ch ⇒ '
                   '退回旧口径(100mm+10atk+炽天使 = 165 而非 115); put_any 只写一条 ⇒ '
                   '其余通道吃不到"技能伤害 +X%"。',
         'creative': '创造模式幽灵物品(2026-10-11 用户实测) —— itembackup 的"消耗→备份→回手"'
                     '必须在创造模式下跳过: 生存/冒险下 consumable 走完, 原版把该格清空, '
                     '所以要靠 effect_2 补回; 创造模式下原版**根本不消耗**, 该格非空 ⇒ '
                     'effect_2 的 39 个兜底候选会把它当成"原格放不下", 往背包空格再塞一把。'
                     '要求: ① effect_1 含 gamemode=creative 门禁; ② 门禁必须排在 '
                     '`advancement revoke` **之后**(否则进度永远停在已完成, 切回生存也不触发)。',
         'pldur': '偏振光"持续 5 秒"的计时单位(坑 120, 2026-10-11 用户实测: 超限版只撑 2.5 秒) '
                  '—— zx.pl_t 单位恒为"秒", 但超限版结算节奏是"每 0.5 秒"(half 每 10 刻调 tick)。'
                  '倒计时写在 tick 里 ⇒ 一次 tick 扣 1 = 把秒当半秒 ⇒ pl_t=5 只撑 2.5 秒。'
                  '要求: ① tick 里**不得**扣 zx.pl_t; ② second 与 half 各自按真实时间扣; '
                  '③ half 的扣减必须挂在 20 刻(1 秒)闸上, 不能在 10 刻闸上。',
         'fdsnap': '堕梦"谁原本在时停里"必须先快照(坑 123, 2026-10-12 用户实测两条 bug) —— '
                   '⑦ 的时停一挂上就把 zx.stop 改了, 之后按 zx.stop 现选 ⇒ ① 白昼梦的选择器'
                   '变空集(一件都没附上); ② ⑧ 把刚时停的也算成"原本就在时停"(3+2=5 秒)。'
                   '要求: ① 改状态前先打 zx.fd_new / zx.fd_old 两个快照标签; ② ⑦⑧ 一律按'
                   '快照取值, 不许出现 `target:"@e[tag=zx.fd_area,tag=…]"`; ③ +2 秒只认 zx.fd_old; '
                   '④ 「白昼梦」必须施给**圈内全体**(坑 124, 用户拍板: 已在时停里的也要有, '
                   '否则普攻转不了真伤)。★ 通用: 按当前状态选人的选择器, 不能在改了同一状态之后再求值。',
         'ddpair': '黄昏黎明「100×X」必须由 5 条标签进度各自独立触发(坑 138, 2026-10-12 用户实测'
                   '"打一只带流火+夜火的怪只加 300") —— 旧方案用附魔 post_attack 的受害者回调去'
                   '数死者的标签数, 但**原版 post_attack 只读攻击者的主手物品**上的附魔, 附在'
                   '靴子(slots:feet)上永远不触发 ⇒ 回调零调用 ⇒ X 恒用兜底值 1 ⇒ 超限版'
                   '"额外 100×X"永远只给 100。要求: ① 5 个进度 dusk_dawn_kill_mark_<tag>'
                   '(yuanhai/liuhuo/yehuo/shixin/dream) 都要在、rewards.function 各自指向同名 '
                   'wrapper kill_mark_<tag>; ② 每个 wrapper 首行 revoke 自己那条(自撤销型契约)'
                   '并转发到共享的 kill_mark; ③ 旧的合并版 dusk_dawn_kill_mark.json 必须已删'
                   '(留着会同刻触发两遍, X 虚高); ④ kill_mark 用 `@s zx.dd_n` 数"本刻进来几次"'
                   '(= X)、自己不得再 revoke 进度, 也不得引用已废弃的 zx.dd_xk / zx.dd_px; '
                   '⑤ kill_init 必须把 zx.dd_n 归零(否则第二次击杀接着上次涨, 基础版少给)。'
                   '★ 通用: 依附魔回调的机制, 先确认附魔挂在**会被遍历到的位置**'
                   '(post_attack ⇒ 攻击者主手物品) —— 挂错槽位是静默失效(不报错/零日志)。',
         'embertop': '余烬"夜火怪也要补流火"及它的节流(坑 137, 2026-10-12 用户拍板) —— '
                     '文案只说"使其附着流火", 没排除"已经有夜火"; 旧版 burned_out 用 '
                     '`if entity @s[tag=zx.status.yehuo] run return 0` 把这一支吞掉 ⇒ 穿余烬'
                     '永远看不到"流火+夜火"(用户实测"夜火怪再燃烧后没有附加流火")。'
                     '要求: ① burned_out 必须调用 ember/top_up, 且该调用必须排在"见夜火即 '
                     'return 0"**之前**(否则是死代码); ② top_up 必须带 5 秒节流'
                     '(zx.em_gate 记"下次可补的 tick 时刻" + #now manacore.meta 比对) —— '
                     '双状态被吸收后只剩流火, 下次熄灭又升级成夜火, 反复回 100 魔力 = 刷魔力漏洞。'
                     '★ 通用: 能凭空重新产生某可消耗资源的被动, 先问"它能不能给自己续杯"。',
         }
print('=' * 72)
print('数据包静态自检  函数 %d 个 / 命名空间 %s' % (len(functions), sorted({s.name for s in nsdirs})))
print('=' * 72)
total = 0
for k in TITLE:
    print('\n[%s] %d 条' % (TITLE[k], len(R[k])))
    total += len(R[k])
    # ★ regress 这一桶**不截断**: 它的消息天生就长 —— 形态是
    #   `缺少"修复标志"(应含 `<整行>` ) —— <说明>`, 长 must(150~330 字) 会把 `—— 说明`
    #   挤到 180 之外, 而"说明"才是人/探针真正要读的东西。其余桶维持 180。
    _lim = None if k == 'regress' else 180
    for e in R[k][:40]:
        _ln = ' | '.join(str(x).replace(str(ROOT) + '\\', '') for x in e)
        print('   ', _ln if _lim is None else _ln[:_lim])
print('\n' + '=' * 72)
print('合计问题: %d' % total)
