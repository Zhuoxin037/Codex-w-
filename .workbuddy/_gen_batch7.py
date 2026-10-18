# -*- coding: utf-8 -*-
"""生成「新批次」11 件新装备的 give.mcfunction（用户 2026-10-11《新的装备-超限等.md》）

【本批范围】该设计稿里的**新武器**部分:
  斧 3（圣骸 sacred_relic / 沉锚 anchor / 焦骨 scorch_bone）
  剑 3（潮痕 tidemark / 灰度 grayscale / 缺月 crescent）
  弩 3（龙舌 dragon_tongue / 云迹 cloudtrail / 爆裂黎明 burst_dawn）
  法杖 2（很冰的斧… triad / 五世恶咒 five_curses）
  ★ 本批**只做 give**（用户 2026-10-11 定："先做好give，效果等一会再做"）——
    技能机制 / 进度 / updef / 超限石 / 资源包外观全部留到后续批次。
  ★ 外观（批 12，2026-10-18）：**7 件平面图标已接上**（潮痕/灰度/缺月/焦骨/龙舌/云迹/三形态），
    见 build() 的 FLAT_ICON；圣骸/沉锚/五世恶咒/爆裂黎明 走的是 3D 手持模型，另有分支。
    另 **anchor（沉锚）仍不挂** —— 资源包里那份 `items/anchor.json` 的 credit 明写
    "四向静态审阅模型；尚未部署，握姿为初始候选"，是没验收的候选件，不能拿去给玩家。
  ★ 挂 item_model 的前提永远是"资源包里那份 items/<id>.json 已经存在" ——
    否则游戏里显示**缺失模型紫黑方块**，是真缺陷不是检查噪音。
    以后新增外观必须先补 items/*.json + models/ + 贴图，再来这里放行。

【稀有度 -> 底材】(用户 2026-10-07 定; 2026-10-11 用户补: "稀有 = 铁")
  罕见 = 铁 / 稀有 = 铁 / 史诗 = 钻石 / 传说 = 下界合金 / 禁忌 = 下界合金
  弩底座固定 crossbow; 法杖底座固定 recovery_compass（能堆 -> 加 max_stack_size）。

【为什么用生成器】和 batch5/6 同理: 11 件只有"底材/名字/描述/custom_data"几处不同，
  外壳完全一样; 手抄必错。改描述改这里一处, 重跑即可。

【描述怎么保证合规】正文每行写成一个长串, 之后交给 lore_fmt.py --write 统一按 37 半角宽
  重新折行 + 乘号 × / 汉字半角留白 / 增益等级罗马数字 —— check.py 规则 31 逐字比对。

【三处约定(照 batch5/6)】
  · custom_data.zx = [<id>, <分类标记>, <"itemreplace"(右键触发的才有)>]
  · 带 冷却 的才有 skill:"sweetdream:<id>"(观测镜靠它显示冷却)
  · 剑/斧/弩 有 max_damage -> 不能加 max_stack_size; 法杖底座 recovery_compass 能堆 -> 要加
"""
import io, os, json, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from _tags_data import TAGS        # noqa: E402  标签单一真源(批 A)

BASE = r'D:\数据包\sweetdream\data\sweetdream\function\equipment'


# ---------------------------------------------------------------- lore 构件
def H(t):
    """✦ 小标题"""
    return {'text': t, 'color': 'gold', 'bold': True, 'italic': False}


def I(*pairs):
    """拼色数值行: ('魔力 ', '80', 'aqua') ...  中间自动插 '   ·   '"""
    segs = []
    for k, (lab, val, col) in enumerate(pairs):
        if k:
            segs.append({'text': '   ·   ', 'color': 'dark_gray'})
        segs.append({'text': lab, 'color': 'gray'})
        segs.append({'text': val, 'color': col})
    return {'text': '', 'italic': False, 'extra': segs}


def S():
    """空行"""
    return {'text': ' ', 'italic': False}


def _cn(t):
    """正文里的半角标点 -> 全角, 并吃掉标点后面多余的空格(同 batch5/6)。"""
    t = t.replace(',', '，').replace(':', '：').replace(';', '；')
    for p in ('，', '：', '；'):
        while p + ' ' in t:
            t = t.replace(p + ' ', p)
    return t


def P(t):
    """灰色正文(一个段落, 交给 lore_fmt 折行)"""
    return {'text': _cn(t), 'color': 'gray', 'italic': False}


def B(t):
    """● 项目符号行"""
    return {'text': '● ' + _cn(t), 'color': 'gray', 'italic': False}


# ---------------------------------------------------------------- 本批 11 件
ITEMS = [
    # ============================================================ 斧 ============
    dict(cat='axe', id='sacred_relic', item_model='sweetdream:sacred_relic', name='圣骸',
         base='netherite_axe', color='white',
         headnote=['# ★ 圣骸外观已接入 sweetdream:sacred_relic；旧物品持有时自动补绑。',
                   '#   实际模型及统一 display 在 assets/sacredrelic/models/item/axe.json。'],
         note='【被动 + 主动】被动: 玩家击杀的生物在死亡位置留 12 秒“遗骸”, 记住死者的最大生命与身上的标签。\n'
              '#   主动: 400 / 40 秒 -> 术阵; 每秒让 12 格内全部“遗骸”打它 3 格内随机一只 最大魔力 ×0.1;\n'
              '#   “遗骸”带「流火」伤害 +30% 且锁定范围 +1 格 / 「夜火」+80% / 「噬心」追加死者最大生命 5% 真伤 /\n'
              '#   「白昼梦」追加 0.3 秒时停 / 「渊海」锁定目标 +2; 共 12 秒。',
         lore=[H('✦ 遗骸'),
               P('持有圣骸时，由玩家击杀的生物会在其死亡位置留下持续 12 秒的“遗骸”。其会保留死者死亡瞬间的'
                 '两个信息：最大生命和身上的标签。'),
               S(),
               H('✦ 主动技能'),
               I(('魔力 ', '400', 'aqua'), ('冷却 ', '40 秒', 'yellow')),
               S(),
               P('使用后召唤一个术阵。每秒使自身 12 格内的全部“遗骸”对其 3 格内的随机一个生物造成一次'
                 '相当于释放者最大魔力值 ×0.1 的伤害。若“遗骸”上有「流火」则伤害 +30% 且锁定范围 +1 格；'
                 '若有「夜火」则伤害 +80%；若有「噬心」则额外附加相当于死亡者最大生命值 5% 的真实伤害；'
                 '若有「白昼梦」则额外附加 0.3 秒的时停；若有「渊海」则锁定目标 +2。共持续 12 秒。')]),

    dict(cat='axe', id='anchor', item_model='sweetdream:anchor', name='沉锚',
         base='diamond_axe', color='blue',
         note='【被动 + 主动】被动: 攻击 10% -> 前方 1 格内生物击飞 1 格 + 最大魔力 ×0.06。\n'
              '#   主动: 200 / 12 秒 -> 向 10 格内准星目标掷锚并位移过去, 落点 2 格内 基础攻击力 ×5 且击飞 2 格。',
         lore=[H('✦ 被动技能'),
               P('每次攻击时都有 10% 的概率将自身前方 1 格内的生物击飞 1 格并对其造成相当于自身最大魔力值 '
                 '×0.06 的伤害。'),
               S(),
               H('✦ 主动技能'),
               I(('魔力 ', '200', 'aqua'), ('冷却 ', '12 秒', 'yellow')),
               S(),
               P('向自身 10 格内的准星上的目标掷出沉锚并位移到目标位置，之后对其 2 格内的生物造成相当于释放者'
                 '基础攻击力 ×5 的伤害并击飞 2 格。')]),

    dict(cat='axe', id='scorch_bone', item_model='sweetdream:scorch_bone', name='焦骨',
         base='diamond_axe', color='dark_gray',
         note='【主动】160 / 28 秒 -> 打 6 格内最近目标 基础攻击力 ×5, 并对其周围 2 格 最大魔力 ×0.05;\n'
              '#   主目标有「流火」-> 转「夜火」+ 返 40 魔力; 主目标原本已是「夜火」-> 范围伤提到 最大魔力 ×0.1。',
         lore=[H('✦ 主动技能'),
               I(('魔力 ', '160', 'aqua'), ('冷却 ', '28 秒', 'yellow')),
               S(),
               P('攻击 6 格内最近一个目标，造成相当于自身基础攻击力 ×5 的伤害，并对其周围 2 格造成最大魔力 '
                 '×0.05 伤害。若主目标拥有「流火」，则将其「流火」转化为「夜火」，并返还 40 魔力；若主目标'
                 '原本已经拥有「夜火」，则改为将范围伤害提高至相当于自身最大魔力 ×0.1。')]),

    # ============================================================ 剑 ============
    dict(cat='sword', id='tidemark', item_model='sweetdream:tidemark', name='潮痕',
         base='iron_sword', color='aqua',
         note='【主动】30 / 20 秒 -> 前方 4×2 范围 最大魔力 ×0.08, 之后随机一个受击者附加「渊海」。',
         lore=[H('✦ 主动技能'),
               I(('魔力 ', '30', 'aqua'), ('冷却 ', '20 秒', 'yellow')),
               S(),
               P('使用后对自身前方 4×2 范围内的生物造成一次相当于自身最大魔力值 ×0.08 的伤害，之后使受到'
                 '伤害的随机一个生物附加「渊海」。')]),

    dict(cat='sword', id='grayscale', item_model='sweetdream:grayscale', name='灰度',
         base='iron_sword', color='gray',
         note='【主动】30 / 18 秒 -> 自身 2 格内 当前魔力 ×0.08 + 燃烧 3 秒; 已在燃烧 -> 改附加「流火」。',
         lore=[H('✦ 主动技能'),
               I(('魔力 ', '30', 'aqua'), ('冷却 ', '18 秒', 'yellow')),
               S(),
               P('使用后使自身 2 格内的生物受到一次相当于自身当前魔力值 ×0.08 的伤害，之后使其燃烧 3 秒。'
                 '若已经处于燃烧状态则改为使其附加「流火」。')]),

    dict(cat='sword', id='crescent', item_model='sweetdream:crescent', name='缺月',
         base='netherite_sword', color='white',
         note='【被动 + 主动】被动: 主手持有缺月时按快捷栏里"正在冷却的其它主动技能"数量分三档(1 / 2 / ≥3)。\n'
              '#   主动: 240 / 30 秒 -> 冻结快捷栏全部技能剩余冷却 6 秒, 每冻结 1 秒总剩余冷却 +1% 最终伤害\n'
              '#   (最高 +150%); 6 秒结束时对 6 格内全部目标 最大魔力 ×0.12 + 基础攻击力 ×4, 之后解冻照常。',
         lore=[H('✦ 被动技能'),
               P('主手持有缺月时，快捷栏中若有正在冷却的主动技能（不包括该武器）则触发以下效果'),
               B('只有 1 个技能正在冷却：普通攻击额外造成相当于自身基础攻击力 ×2 的伤害。'),
               B('有 2 个技能正在冷却：普通攻击在以上基础上再额外造成相当于基础攻击力 ×2 的伤害，并使自身'
                 '所有技能冷却时间 -0.5 秒。'),
               B('有 3 个及以上技能正在冷却：缺月不再获得上述效果。普通攻击改为造成最大魔力 ×0.08，但每次'
                 '攻击随机使一个正在冷却的技能剩余冷却 +1 秒。'),
               S(),
               H('✦ 主动技能'),
               I(('魔力 ', '240', 'aqua'), ('冷却 ', '30 秒', 'yellow')),
               S(),
               P('使用时，将当前快捷栏内所有技能的剩余冷却时间暂时冻结 6 秒。玩家每冻结 1 秒总剩余冷却时间，'
                 '本技能最终伤害就提高 1%（最高 +150%）。6 秒结束时，对 6 格内全部目标造成相当于最大魔力 '
                 '×0.12 + 基础攻击力 ×4 的伤害，之后被冻结的技能继续正常冷却。')]),

    # ============================================================ 弩 ============
    dict(cat='bow', id='dragon_tongue', item_model='sweetdream:crossbow_dragon_tongue', name='龙舌',
         base='crossbow', color='red',
         note='【弩 = 射击触发】不加 consumable/itemreplace, 也没有冷却 -> 不加 skill。\n'
              '#   射中带「夜火」的目标 -> 消其「夜火」+ 其 2 格内随机落箭雨; 箭随机落点, 命中落点处的生物\n'
              '#   (落在空地则落空); 每箭 当前魔力 ×X×0.01, 箭数 X×3,\n'
              '#   X = 被命中生物 6 格内「流火」/「夜火」生物数, 其中「夜火」每个记为 2。',
         lore=[H('✦ 主动技能'),
               I(('魔力 ', '60', 'aqua')),
               S(),
               P('每次射击若射击附加了「夜火」效果的生物，则使其消除「夜火」并在其 2 格内释放一次箭雨，'
                 '箭矢随机落下并命中落点处的生物。每根箭的伤害相当于自身当前魔力值 ×X×0.01，箭的数量'
                 '为 X×3。X 为被命中的生物 6 格内附有「流火」或「夜火」的生物数量，其中附有「夜火」的'
                 '每个记为 2。')]),

    dict(cat='bow', id='cloudtrail', item_model='sweetdream:crossbow_cloudtrail', name='云迹',
         base='crossbow', color='white',
         note='【弩 = 射击触发】不加 consumable/itemreplace, 也没有冷却 -> 不加 skill。\n'
              '#   没射中 -> 箭停留处生成半径 3 的领域 5 秒; 射领域内生物时同步对领域内全体 基础攻击力 ×2。',
         lore=[H('✦ 主动技能'),
               I(('魔力 ', '30', 'aqua')),
               S(),
               P('射击后若未射中生物，则在箭停留位置生成一个持续 5 秒的半径 3 格的领域。当自身射击在领域内'
                 '的生物时会同步对领域内的全部生物造成一次相当于自身基础攻击力 ×2 的伤害。')]),

    dict(cat='bow', id='burst_dawn', item_model='sweetdream:crossbow_burst_dawn', name='爆裂黎明',
         base='crossbow', color='gold',
         note='【弩 = 射击触发】不加 consumable/itemreplace, 也没有冷却 -> 不加 skill。\n'
              '#   799 -> 术阵 + 两个“魂灵之影”(生命 100 / 20 秒); 主力 基础攻击力 ×8 + 最大魔力 ×0.15 + 缓慢5 2 秒,\n'
              '#   再补一次 50%; 之后用“魂灵之影”续轰(基础攻击力 ×4 + 最大魔力 ×0.08), 场上没有则技能结束。',
         lore=[H('✦ 主动技能'),
               I(('魔力 ', '799', 'aqua')),
               S(),
               P('射击后召唤一个术阵。在自身位置周围召唤两个生命值为 100 可持续 20 秒的“魂灵之影”，其每 3 秒'
                 '都会对其 3 格内的一个生物造成相当于其当前生命值 ×0.5 的伤害并使其获得 1 秒缓慢2。若生物'
                 '索敌为自身，则会转移索敌至“魂灵之影”。自身对射中的生物及其 3 格内的全部生物造成一次相当于'
                 '自身基础攻击力 ×8 + 自身最大魔力值 ×0.15 的伤害并使生物获得 2 秒缓慢5，之后再造成一次'
                 '相当于上次总伤害 50% 的伤害。之后自身可以使用自身召唤的“魂灵之影”当作弹药继续进行轰击，'
                 '但是伤害变为自身基础攻击力 ×4 + 自身最大魔力值 ×0.08。场上不存在自身召唤的“魂灵之影”后'
                 '则该技能结束。')]),

    # ============================================================ 法杖 ==========
    dict(cat='staff', id='triad', item_model='sweetdream:triad', name='很冰的斧',
         base='recovery_compass', color='aqua',
         note='【法杖三形态】★ 名字先按初始形态「很冰的斧」；切形态改名属"效果", 本批不做。\n'
              '#   普攻 50: 冰斧 = 最大魔力 ×0.02 / 热刀 = 基础攻击力 ×3 / 重枪 = 基础攻击力 ×6。\n'
              '#   形态被动: 冰斧 20% 冰冻 1 秒 / 热刀 40% 下次攻击额外 2 次 / 重枪 下次攻击为空。\n'
              '#   主动 500 / 80 秒: 再按一次提前切下一把; 术阵 + 15 秒强化(冰斧 60% 且伤害取 最大魔力 ×0.05 /\n'
              '#   热刀 100% 且每次 -1 护甲、3 次 -1 护甲韧性 / 重枪 不再为空 + 抗性提升失效 2 秒), 结束切回冰斧。',
         lore=[H('✦ 普攻'),
               I(('魔力 ', '50', 'aqua'), ('伤害 ', '最大魔力值 ×0.02', 'yellow')),
               S(),
               P('武器初始默认为「很冰的斧」。「很冰的斧」的伤害为自身最大魔力值 ×0.02，「很热的刀」为自身'
                 '基础攻击力 ×3，「很重的枪」为自身基础攻击力 ×6。'),
               S(),
               P('「很冰的斧」每次攻击生物后都有 20% 的概率使其冰冻 1 秒；「很热的刀」每次攻击后都有 40% 的'
                 '概率使下一次攻击额外发射 2 次；「很重的枪」每次攻击后下一次攻击为空。'),
               S(),
               H('✦ 主动技能'),
               I(('魔力 ', '500', 'aqua'), ('冷却 ', '80 秒', 'yellow')),
               S(),
               P('使用后若再次使用该技能则切换武器至下一把。使用后召唤一个术阵。武器被动强化：「很冰的斧」概率'
                 '提升至 60% 且伤害提升至自身最大魔力值 ×0.05；「很热的刀」概率提升为 100% 且每次攻击都会使'
                 '目标 -1 护甲值，命中 3 次后使其 -1 护甲韧性，技能结束后恢复；「很重的枪」下一次攻击不再会为'
                 '空且每次攻击都会使其抗性提升失效 2 秒。本效果持续 15 秒，结束后切回「很冰的斧」。')]),

    dict(cat='staff', id='five_curses', item_model='sweetdream:five_curses', name='五世恶咒',
         base='recovery_compass', color='dark_purple',
         note='【法杖: 普攻 + 主动】普攻 100, 伤害 自身当前魔力值 ×0.03; 每次命中推进一世「世咒」(第一~五世);\n'
              '#   已在第五世再被命中 -> 立即结算终世(30%)并清除(2026-10-15 用户拍板);\n'
              '#   主动 600 / 120 秒 -> 12 格内所有带「世咒」者推进一世; 已在第五世 -> 立即结算终世(比例 30%->80%);\n'
              '#   因此击杀一个生物返 50 魔力, 每次技能最多返 300。',
         lore=[H('✦ 普攻'),
               I(('魔力 ', '100', 'aqua'), ('伤害 ', '自身当前魔力值 ×0.03', 'yellow')),
               S(),
               H('✦ 世咒'),
               P('每次普攻命中都会推进一世「世咒」；在第五世再命中即结算终世。'),
               B('第一世：虚弱3，持续 3 秒。'),
               B('第二世：缓慢4，持续 3 秒。'),
               B('第三世：受到的技能伤害提高 20%，持续 5 秒。'),
               B('第四世：护甲及护甲韧性降低 50%，持续 5 秒。'),
               B('第五世：记录目标在接下来最多 10 秒内受到的全部伤害。'),
               B('终世：对其造成记录伤害的 30% 真实伤害，之后清除「世咒」。'),
               S(),
               H('✦ 主动技能'),
               I(('魔力 ', '600', 'aqua'), ('冷却 ', '120 秒', 'yellow')),
               S(),
               P('对自身 12 格内所有至少拥有一层「世咒」的生物立即推进至下一世。已处于第五世的目标不会推进，'
                 '而是立即结算终世，并使此次结算比例由 30% 提高至 80%。若因此击杀一个生物，则返还 50 魔力，'
                 '每次技能最多返还 300 魔力。')]),
]

# ---------------------------------------------------------------- 组装
CONSUMABLE = ('consumable={animation:"none",consume_seconds:0,'
              'has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}')

# 右键触发的三类(剑/斧/法杖); 弩靠射击触发, 不加 consumable/itemreplace/skill。
RIGHT_CLICK = ('sword', 'axe', 'staff')


def build(it):
    cid = it['id']
    cat = it['cat']
    zx = [cid, cat]
    need_skill = cat in RIGHT_CLICK
    if need_skill:
        zx.append('itemreplace')
    zx_txt = json.dumps(zx, ensure_ascii=False, separators=(',', ':'))
    if need_skill:
        zx_txt = zx_txt + ',skill:"sweetdream:%s"' % cid

    parts = []
    # ★ 批 12（2026-10-18）：这 7 件的 16×16 平面图标已就位
    #   （贴图 `textures/item/vanilla/<x>.png` + models + items 三层齐全，
    #    由 `.workbuddy/_gen_batch12_icons.py` / `_gen_batch12_rp.py` 生成）。
    #   ★ 不追加 custom_model_data：它们用的是纯 `minecraft:model`，
    #     不像圣骸/五世恶咒/爆裂黎明那样按 custom_model_data 做 range_dispatch 分支。
    FLAT_ICON = {
        'tidemark', 'grayscale', 'crescent',      # 剑
        'scorch_bone',                            # 斧
        'dragon_tongue', 'cloudtrail',            # 弩（6 态一整套）
        'triad',                                  # 法杖
    }
    if cid in FLAT_ICON:
        parts.append('item_model="%s"' % it['item_model'])
    if cid == 'sacred_relic':
        # 已批准并接入的圣骸3D外观，其他本批装备仍保留原版。
        parts.append('item_model="sweetdream:sacred_relic"')
        parts.append('custom_model_data={floats:[0.0f]}')
    if cid == 'five_curses':
        # 2026-10-16 用户授权猴头模型、待机、拍颅普攻和重施法接入。
        parts.append('item_model="sweetdream:five_curses"')
        parts.append('custom_model_data={floats:[0.0f]}')
    if cid == 'burst_dawn':
        # 2026-10-16 用户授权维什戴尔炮身、肩饰及真实弹道/背效接入。
        parts.append('item_model="sweetdream:crossbow_burst_dawn"')
        parts.append('custom_model_data={floats:[0.0f,0.0f]}')
    parts.append('item_name={text:"%s",bold:true,color:%s}' % (it['name'], it['color']))
    parts.append('lore=' + json.dumps(it['lore'], ensure_ascii=False, separators=(',', ':')))
    parts.append('unbreakable={}')
    hide = ['unbreakable']
    if cid == 'sacred_relic' or cat == 'bow':
        # ★ 附魔(生效但不显示: glint 关掉紫色附魔光效; tooltip_display 里把
        #   "enchantments" 也藏掉, 否则物品说明会多出一行附魔名) —— 与既有 6 把弩
        #   (bow/*/give)同一套写法。用户 2026-10-12: "希望像寒鸦那样去掉附魔文字"。
        #   ① 圣骸: 附魔「遗骸」= post_attack 的受害者回调(击杀留遗骸)。
        #   ② 弩(cat='bow'): **必须**带自己的附魔 —— 弩没有 consumable/右键,
        #      命中结算全靠 enchantment 的 post_attack 三条回调
        #      (hook_arrow / hook_attacker / hook_victim)。漏了它就整把弩静默失效
        #      (同族事故: 坑 138 —— 回调只读**攻击者主手物品**上的附魔)。
        parts.append('enchantments={"sweetdream:%s":1}' % cid)
        parts.append('enchantment_glint_override=false')
        hide.append('enchantments')
    # ★ 标签(批 A): custom_data.tags = 语义关键词(见 _tags_data.py), 与 zx 并列。
    cd_txt = 'zx:%s' % zx_txt
    _tags = TAGS.get(cid) or []
    if _tags:
        cd_txt += ',tags:%s' % json.dumps(_tags, ensure_ascii=False, separators=(',', ':'))
    parts.append('custom_data={%s}' % cd_txt)
    if need_skill:
        parts.append(CONSUMABLE)
    parts.append('tooltip_display={hidden_components:%s}'
                 % json.dumps(hide, separators=(',', ':')))

    pre = ''
    if cat == 'staff':
        pre += 'max_stack_size=1,'
    return 'give @s %s[%s%s]' % (it['base'], pre, ','.join(parts))


def header(it):
    cat_cn = {'sword': '剑', 'axe': '斧', 'staff': '法杖', 'bow': '弩'}[it['cat']]
    L = []
    A = L.append
    A('# ============================================================')
    A('# sweetdream:equipment/%s/%s/give —— 给一件「%s」（%s）'
      % (it['cat'], it['id'], it['name'], cat_cn))
    A('# ------------------------------------------------------------')
    A('# 【custom_data】')
    A('#   "%s" -> 装备 id, 进度 / 被动判定靠它认人' % it['id'])
    A('#   ★ 判定一律写成 custom_data~{zx:["%s"]}(部分匹配 + 独有标记)' % it['id'])
    A('#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)')
    for line in it['note'].split('\n'):
        A(line if line.startswith('#') else '# ' + line)
    A('#')
    A('# 【这个文件是生成的】改描述/数值请改 .workbuddy/_gen_batch7.py 再重跑,')
    A('#   然后跑 `python .workbuddy/lore_fmt.py --write` 让规范器重新折行。')
    if it['cat'] == 'bow':
        A('# ★ 批 11(2026-10-12)已接上技能: 本件带附魔 sweetdream:%s —— 弩的命中结算' % it['id'])
        if it['id'] == 'burst_dawn':
            # 爆裂黎明 2026-10-16 已接外观 → 不再是"外观仍待做"; 与下一行的 2026-10-16 说明保持一致。
            A('#   全靠附魔的 post_attack 回调(没有右键/消耗)，保留现有机制附魔。')
        else:
            A('#   全靠附魔的 post_attack 回调(没有右键/消耗), 所以这行不能删。外观仍待做。')
    else:
        A('# ★ 本批只做 give（2026-10-11 用户定）: 技能 / 进度 / 外观 等后续批次再接。')
    if it['id'] == 'burst_dawn':
        A('# ★ 2026-10-16 已接入炮身、肩部装置、重后坐与独立真实事件特效。')
        A('#   旧件手持时只补外观组件，保留升级、附魔和技能数值。')
    elif it.get('headnote'):
        # 本件外观已接入 / 有额外说明 -> 用它替掉默认那两句(2026-10-13: 由磁盘回收进生成器)
        for ln in it['headnote']:
            A(ln)
    elif it['id'] in ('tidemark', 'grayscale', 'crescent', 'scorch_bone',
                      'dragon_tongue', 'cloudtrail', 'triad'):
        A('# ★ 2026-10-18（批 12）已接 16×16 平面图标 item_model="%s"' % it['item_model'])
        A('#   （贴图 textures/item/vanilla + models/item/vanilla + items 三层齐全）。')
    else:
        A('# ★ 本件**不挂 item_model**（外观未做或只是未验收的候选模型）。')
        A('#   要接的话先补 items/%s.json + models/ + 贴图，再来这里放行。' % it['item_model'])
    A('# ============================================================')
    A('')
    return '\n'.join(L)


def main():
    n = 0
    for it in ITEMS:
        d = os.path.join(BASE, it['cat'], it['id'])
        os.makedirs(d, exist_ok=True)
        p = os.path.join(d, 'give.mcfunction')
        txt = header(it) + build(it) + '\n'
        io.open(p, 'w', encoding='utf-8', newline='\n').write(txt)
        n += 1
        print('%-36s %s' % ('equipment/%s/%s' % (it['cat'], it['id']), it['name']))
    print('---- 共 %d 件' % n)


if __name__ == '__main__':
    main()
