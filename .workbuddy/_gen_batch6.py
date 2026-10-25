# -*- coding: utf-8 -*-
"""
生成「第六批」28 件新装备的 give.mcfunction (21 武器 + 7 盔甲)。

【本批范围】用户 2026-10-07 给的一整份设计稿里的**装备部分**:
  剑 6 / 斧 8 / 法杖 6 / 弩 1 / 盔甲 7。
  升级石(火炬/沸腾/夜视仪/生命提升·αβΩ)与超限石(万念/挽歌/交界)不在这里 ——
  它们要和 updef / oldef / 图标编号一起接, 属于"效果"批次。

【稀有度 -> 底材】(用户 2026-10-07 定)
  罕见 = 铁   /   史诗 = 钻石   /   传说 = 下界合金   /   禁忌 = 下界合金
  盔甲没有"罕见=铁"以外的一档, 按同规则: 常见/罕见 = 铁, 史诗 = 钻石, 传说 = 下界合金。

【为什么用生成器】和 _gen_batch5 同一个理由: 28 件只有"底材/名字/描述/custom_data"
  四处不同, 外壳完全一样; 手抄 28 遍必错。改描述改这里一处, 重跑即可。

【描述怎么保证合规】正文每行写成一个长串, 之后交给 `lore_fmt.py --write` 统一按
  37 半角宽重新折行 —— check.py 规则 31 是拿 lore_fmt 的输出逐字比对的。

【三处约定(照既有)]】
  · custom_data.zx = [<id>, <分类标记>, <"itemreplace"(右键触发的才有)>]
  · 带 冷却 的才有 skill:"sweetdream:<id>"(观测镜靠它显示冷却)
  · 剑/斧/弩/甲 有 max_damage -> 不能加 max_stack_size; 法杖底座 recovery_compass 能堆 -> 要加
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
    """正文里的半角标点 -> 全角, 并吃掉标点后面多余的空格(同 _gen_batch5)。"""
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


# ---------------------------------------------------------------- 本批 28 件
ITEMS = [
    # ============================================================ 剑 ============
    dict(cat='sword', id='hush', name='无息', base='diamond_sword', color='gray',
         item_model='sweetdream:hush',
         note='【数值要和 cast 对上】魔力 200 / 冷却 30 秒 / 突击最多 8 格(16 步 × 0.5) /\n'
              '#   撞生物不停、只被终点/障碍物拦下; 途中碰到生物 -> 对身边 3 格内全部生物 ×0.1\n'
              '#   (同一只每次施法至多一次); 归位约 0.2 秒(每刻 2 格, 见 back_move), 落地再对路径生物 ×0.2。',
         lore=[H('✦ 主动技能'),
               I(('魔力 ', '200', 'aqua'), ('冷却 ', '30 秒', 'yellow')),
               S(),
               P('使用后向前突击最多 8 格，途中无视生物、径直穿身而过，只有抵达终点或撞上障碍物才会停下。'
                 '突击途中每碰到一个生物，都会立刻对身边 3 格内的全部生物造成一次相当于自身最大魔力值 ×0.1 '
                 '的伤害（每个生物只会被触发一次）；停下后会在约 0.2 秒内极速闪回原点，并再次对路径上的全部'
                 '生物造成一次相当于自身最大魔力值 ×0.2 的伤害。')]),

    dict(cat='sword', id='rogue_star', name='游星', base='diamond_sword', color='white',
         item_model='sweetdream:rogue_star',
         note='【数值要和 cast 对上】魔力 200 / 冷却 30 秒 / 锁定 3 个 / 半径 10 / 延迟 3 秒 /\n'
              '#   爆炸半径 2 / 倍率 基础攻击力 ×4 / 保底 12。',
         lore=[H('✦ 主动技能'),
               I(('魔力 ', '200', 'aqua'), ('冷却 ', '30 秒', 'yellow')),
               S(),
               P('锁定自身 10 格范围内的 3 个生物，3 秒后对其 2 格内的全部生物造成相当于自身基础攻击力 ×4 的'
                 '伤害。（保底 12 点伤害）')]),

    dict(cat='sword', id='everfrost', name='永霜', base='diamond_sword', color='aqua',
         item_model='sweetdream:everfrost',
         note='【数值要和 cast 对上】魔力 200 / 冷却 30 秒 / 冰冻半径 5 / 最多 8 个 / 3 秒 /\n'
              '#   结束伤害 ×0.1（吃**当前剩余魔力值**, 不是上限）。',
         lore=[H('✦ 主动技能'),
               I(('魔力 ', '200', 'aqua'), ('冷却 ', '30 秒', 'yellow')),
               S(),
               P('冰冻自身 5 格范围内的 8 个生物 3 秒，并在结束后对被冰冻的生物造成相当于自身当前剩余魔力值 '
                 '×0.1 的伤害。')]),

    dict(cat='sword', id='verdict', name='神裁', base='netherite_sword', color='gold',
         item_model='sweetdream:verdict',
         note='【被动 + 主动两段】被动: 魔力≥50 时 25% 消耗 50 -> 被击者 2 格内 ×2 + 虚弱Ⅱ/缓慢Ⅱ/发光 8 秒。\n'
              '#   主动: 380 / 10 秒 -> 自身 6 格内至多 2 个 ×0.1, 落点生成半径 2 的领域 3 秒, 每秒 ×3。\n'
              '# 【★ 该被动是"每次攻击后"口径】平A一下算一次(命中几只都一样), 实装要按刻去重(check `atkonce`)。',
         lore=[H('✦ 被动技能'),
               P('每次攻击后若自身有 50 及以上的魔力值，则有 25% 的概率消耗 50 魔力值并对被攻击的生物的 2 格内'
                 '的全部生物造成相当于自身基础攻击力 ×2 的伤害，并使受到伤害的生物获得虚弱Ⅱ、缓慢Ⅱ及发光效果，'
                 '持续 8 秒。'),
               S(),
               H('✦ 主动技能'),
               I(('魔力 ', '380', 'aqua'), ('冷却 ', '10 秒', 'yellow')),
               S(),
               P('使自身 6 格内的至多 2 个生物受到相当于自身最大魔力值 ×0.1 的伤害，之后在受到伤害的生物处生成'
                 '一个持续 3 秒的半径 2 格的领域，在领域中的生物每秒受到一次相当于施放者基础攻击力 ×3 的伤害。')]),

    dict(cat='sword', id='tinder', name='火种', base='netherite_sword', color='red',
         note='【没有主动技能】整把武器就一个「火种」状态机, 不开右键 -> 不加 consumable/skill。\n'
              '# 【★ 「火种」是这把武器独有的状态】燃烧/熄灭两态; 燃烧态攻击后熄灭, 熄灭态攻击反噬自己。\n'
              '#   魔力>400 且熄灭态时手持自动点燃(消耗 350 魔力) —— 这就是它的"充能"方式。',
         lore=[H('✦ 火种'),
               P('手持时，若自身魔力值大于 400 且「火种」处于熄灭状态则消耗 350 点魔力值并使「火种」变为燃烧状态。'),
               S(),
               P('「火种」处于燃烧状态时，攻击生物时将会对其 2 格内的全部生物造成相当于自身当前魔力值 ×0.1 的'
                 '伤害，之后使未处于燃烧状态的生物燃烧 5 秒并熄灭该武器。处于熄灭状态时，攻击生物后会对自身造成'
                 '相当于自身最大生命值 ×0.3 的伤害并使「火种」变为燃烧状态。')]),

    dict(cat='sword', id='rebound', name='回锋', base='iron_sword', color='white',
         item_model='sweetdream:rebound',
         note='【专属层数「断刃」】被动攒层(攻击时魔力≥50 -> 扣 30 -> +1 层, 上限 3),\n'
              '#   主动(80 / 12 秒)前方 3×5; 有「断刃」则消耗全部, 之后**每 0.35 秒(7 刻)重复一次**、\n'
              '#   每层重复一次(2026-10-07 用户口径: 不再同刻一次性打完) -> 见 cast 的 ⑦/⑦\' + tick_step。\n'
              '#   ★ "每 0.35 秒"是**实现细节, 不写进 lore**(用户 2026-10-07 定): 描述只说"每层重复一次"。',
         lore=[H('✦ 断刃'),
               P('每次攻击时若有 50 及以上魔力则消耗 30 魔力值并为自身附加一层「断刃」（最多 3 层）。'),
               S(),
               H('✦ 主动技能'),
               I(('魔力 ', '80', 'aqua'), ('冷却 ', '12 秒', 'yellow')),
               S(),
               P('对自身前方 3×5 格内的生物造成相当于自身基础攻击力 ×2 的伤害。若有「断刃」则消耗全部「断刃」'
                 '且每有一层则重复一次以上效果。')]),

    # ============================================================ 斧 ============
    # ★★ item_model 是 fissure_axe 不是 fissure：sweetdream:fissure 在资源包里
    #    已经是崩裂技能的「地面裂缝」平面模型（field.mcfunction 用 item_display 召唤）。
    dict(cat='axe', id='fissure', item_model='sweetdream:fissure_axe', name='崩裂', base='iron_axe', color='gray',
         note='【数值要和 cast 对上】魔力 150 / 冷却 40 秒 / 前方 5 格 ×5 倍, 落点裂缝 5 秒,\n'
              '#   裂缝内每秒一次 1 倍基础攻击力。',
         lore=[H('✦ 主动技能'),
               I(('魔力 ', '150', 'aqua'), ('冷却 ', '40 秒', 'yellow')),
               S(),
               P('立即对自身前方 5 格的生物造成一次相当于自身基础攻击力 ×5 的伤害并形成一个持续 5 秒的裂缝。'
                 '之后在裂缝处的生物将每秒受到一次相当于释放者基础攻击力的伤害。')]),

    dict(cat='axe', id='dream_reader', item_model='sweetdream:dream_reader', name='释梦', base='diamond_axe', color='light_purple',
         note='【被动 + 主动】被动: 打时停目标额外 5×剩余时停秒数的真伤, 之后解除其停。\n'
              '#   主动: 200 / 40 秒 -> 召唤 3 个“入梦体”。\n'
              '#   “入梦体”10 格或造成伤害后自毁, 自动追最近生物 -> 当前魔力 ×0.1 + 时停 2 秒 + 白昼梦。\n'
              '# 【不同入梦体不追同一个】实装要判重目标。',
         lore=[H('✦ 被动技能'),
               P('攻击处于时停状态的生物时对其额外造成 5×剩余时停时间的真实伤害，之后解除他的时停状态。'),
               S(),
               H('✦ 主动技能'),
               I(('魔力 ', '200', 'aqua'), ('冷却 ', '40 秒', 'yellow')),
               S(),
               P('使用后召唤 3 个“入梦体”。'),
               S(),
               H('✦ 入梦体'),
               P('“入梦体”会在离自身 10 格远或对生物造成伤害后自毁。“入梦体”会自动追踪离其最近的生物并对其'
                 '造成相当于释放者当前魔力值 ×0.1 的伤害，之后使其时停 2 秒并附加「白昼梦」效果。（不同入梦体'
                 '不会追踪同一个目标）')]),

    dict(cat='axe', id='draught', item_model='sweetdream:draught', name='饮鸩', base='iron_axe', color='dark_red',
         note='【数值要和 cast 对上】魔力 160 / 冷却 80 秒 / 自伤 = 最大生命 ×0.8 /\n'
              '#   换来的基础攻击力加成 = 实际受到的自伤值, 持续 10 秒。',
         lore=[H('✦ 主动技能'),
               I(('魔力 ', '160', 'aqua'), ('冷却 ', '80 秒', 'yellow')),
               S(),
               P('使用后对自身造成相当于自身最大生命值 ×0.8 的伤害，之后获得相当于自身受到的伤害的基础攻击力'
                 '加成，持续 10 秒。')]),

    dict(cat='axe', id='pyre', item_model='sweetdream:pyre', name='葬火', base='netherite_axe', color='dark_red',
         note='【魔力量纲特殊】消耗的是"100%"(放空前魔力), X = 本次消耗的魔力总量。\n'
              '#   落下: 2 格内 X 点 + 燃烧 X×0.05 秒; 2 秒后 5 格内 X×0.5 点。\n'
              '# 【X 是变量】实装时把"放掉的魔力"记下来当代入值, 别烘死。',
         lore=[H('✦ 主动技能'),
               I(('魔力 ', '100%', 'aqua'), ('冷却 ', '240 秒', 'yellow')),
               S(),
               P('使用后下一次攻击额外对自身 2 格内的全部生物造成 X 点伤害并使其燃烧 X×0.05 秒。2 秒后再对'
                 '自身 5 格范围内的全部生物造成 X×0.5 点伤害。X 为使用技能所消耗的魔力。')]),

    dict(cat='axe', id='ballad', item_model='sweetdream:ballad', name='歌谣', base='diamond_axe', color='yellow',
         note='【专属层数「曲调」】每击杀一个生物 +1（最高 8 层）。\n'
              '#   主动 240 / 30 秒: 下次攻击对 X 格内 X 个生物造成基础攻击力 ×（9-X）真伤 + 时停 X 秒, 之后清「曲调」。\n'
              '# 【X = 曲调层数】代入值直接读层数; 用户稿里"X 格内的 X 生物"按"X 个生物"理解。',
         lore=[H('✦ 曲调'),
               P('自身使用「歌谣」时每击杀一个生物则积攒一点「曲调」。（最高 8 层）'),
               S(),
               H('✦ 主动技能'),
               I(('魔力 ', '240', 'aqua'), ('冷却 ', '30 秒', 'yellow')),
               S(),
               P('使用后自身下一次攻击额外对自身 X 格内的 X 个生物造成一次相当于自身基础攻击力 ×（9-X）的'
                 '真实伤害并时停 X 秒。之后清除全部「曲调」。（X 为「曲调」层数）')]),

    dict(cat='axe', id='thunderclap', item_model='sweetdream:thunderclap', name='威霆', base='netherite_axe', color='aqua',
         note='【没有主动技能】全被动, 不开右键 -> 不加 consumable/skill。\n'
              '# 【专属点数「天煌」】手持未攻击时每刻 +1（上限 2000）。攻击后全清并等量扣魔, 落点开半径 6 术阵\n'
              '#   + 半径 6 格领域（真闪电实体, 带 zx.th_seen 防雷鸣连锁）。\n'
              '#   领域内每被攻击一次 -> X 道闪电(每道 最大魔力值 ×0.1); 每 10 次雷击扣 10% 最大生命; 持续 X×2 秒\n'
              '#   （X =「天煌」×0.005）。魔力不足则本次攻击"视消耗的魔力总数为「天煌」点数" ——\n'
              '#   也就是 X 按**实际消耗的魔力**算（2026-10-08 用户定稿口径 a）。\n'
              '# 【同时只能有一个术阵】下一个术阵结束前不能再开。',
         lore=[H('✦ 天煌'),
               P('自身手持该武器且未攻击生物时，每刻积攒一点「天煌」（上限 2000 点）。自身攻击生物后立即消耗'
                 '全部「天煌」并消耗等量的魔力，在目标位置召唤 1 个术阵并生成半径 6 格的领域；该术阵结束前不能'
                 '再次召唤术阵。领域内的生物每受到一次攻击则立即有 X 道闪电对其造成伤害，每道闪电'
                 '的伤害为自身最大魔力值 ×0.1。生物每受到 10 次雷击则损失自身 10% 最大生命值，共持续 X×2 秒'
                 '（X 为「天煌」×0.005）。若魔力值不足则本次攻击视消耗的魔力总数为「天煌」点数。')]),

    dict(cat='axe', id='red_lotus', item_model='sweetdream:red_lotus', name='红莲', base='iron_axe', color='red',
         note='【数值要和 cast 对上】魔力 80 / 冷却 30 秒。消耗自身 5 格内生物的「流火」/「夜火」。\n'
              '#   每层「流火」-> 5 格内 1 倍基础攻击力一次; 每层「夜火」-> 6 格内 ×3 一次。',
         lore=[H('✦ 主动技能'),
               I(('魔力 ', '80', 'aqua'), ('冷却 ', '30 秒', 'yellow')),
               S(),
               P('使用后消耗自身 5 格内全部生物的「流火」或「夜火」效果。之后每消耗一层「流火」则对自身 5 格内'
                 '的生物造成一次相当于自身基础攻击力的伤害，每消耗一层「夜火」则对自身 6 格内的生物造成一次'
                 '相当于自身基础攻击力 ×3 的伤害。')]),

    dict(cat='axe', id='azure_star', item_model='sweetdream:azure_star', name='苍蓝星', base='netherite_axe', color='blue',
         note='【被动 + 主动】被动: 当前魔力 >800 时每次攻击 20% 让本武器伤害倍率翻倍（不可叠加）。\n'
              '#   主动: 500 / 80 秒 -> 最近生物 ×0.5, 之后其 2 格内 ×0.1。',
         lore=[H('✦ 被动技能'),
               P('每次攻击若自身当前魔力值高于 800，则都有 20% 概率使该武器伤害倍率 +100%（不可叠加）。'),
               S(),
               H('✦ 主动技能'),
               I(('魔力 ', '500', 'aqua'), ('冷却 ', '80 秒', 'yellow')),
               S(),
               P('使用后对离自身最近的一个生物造成相当于自身最大魔力值 ×0.5 的伤害，之后对其 2 格内的生物造成'
                 '相当于自身最大魔力值 ×0.1 的伤害。')]),

    # ============================================================ 法杖 ==========
    dict(cat='staff', id='chime', name='共鸣', base='recovery_compass', color='aqua',
         item_model='sweetdream:chime',
         note='【普攻 + 主动】普攻 12 / 伤害 7。主动 140 / 40 秒 -> 术阵 + 原地“共鸣水晶”。\n'
              '#   “共鸣水晶”每 2 秒打 6 格内一个生物 ×0.03; 法术穿过时 3 格内全体 ×0.05; 8 秒自毁。\n'
              '# 【模型】2026-10-10 用户批准独立16×16法杖贴图，绑定完整版资源包。',
         lore=[H('✦ 普攻'),
               I(('魔力 ', '12', 'aqua'), ('伤害 ', '7', 'yellow')),
               S(),
               H('✦ 主动技能'),
               I(('魔力 ', '140', 'aqua'), ('冷却 ', '40 秒', 'yellow')),
               S(),
               P('使用后召唤一个术阵。之后在原地生成一个“共鸣水晶”。'),
               S(),
               H('✦ 共鸣水晶'),
               P('每 2 秒都会对其 6 格内的一个生物造成一次相当于自身最大魔力值 ×0.03 的伤害。自身释放的法术'
                 '穿过“共鸣水晶”时会立即对其 3 格内的全部生物造成一次相当于自身最大魔力值 ×0.05 的伤害。'
                 '“共鸣水晶”8 秒后自毁。')]),

    dict(cat='staff', id='palette', name='调色盘', base='recovery_compass', color='light_purple',
         note='【普攻 + 主动】普攻 50 / 伤害 1; 命中后随机攒颜色(可叠, 最多同时两种)。\n'
              '#   主动 400 / 60 秒 -> 生成“色彩”。\n'
              '#   “色彩”12 格或打满 5 个后自毁, 自动追最近生物 ×0.1, 不会追已打过的生物。\n'
              '#   红=伤害翻倍 / 黄=追踪范围 +8、阈值 +3 / 蓝=打中后回 150 魔力并 -5 秒冷却。\n'
              '# 【X 种颜色 = 最多 2 种】实装时按实际持有色数乘算。',
         lore=[H('✦ 普攻'),
               I(('魔力 ', '50', 'aqua'), ('伤害 ', '1', 'yellow')),
               S(),
               P('每次普攻命中后都会随机积攒一种颜色。颜色可以叠加，最多同时持有两种颜色。'),
               S(),
               H('✦ 主动技能'),
               I(('魔力 ', '400', 'aqua'), ('冷却 ', '60 秒', 'yellow')),
               S(),
               P('使用后将生成一个“色彩”。'),
               S(),
               H('✦ 色彩'),
               P('“色彩”会离自身 12 格远或对 5 个生物造成伤害后自毁。“色彩”会自动追踪离自身最近的生物并对'
                 '其造成相当于自身最大魔力值 ×0.1 的伤害。若调色盘上有颜色，则按颜色获得对应强化。“色彩”不会追踪已经'
                 '攻击过的生物。'),
               S(),
               B('红：每有一个红色都会使伤害翻倍。'),
               B('黄：每有一个黄色都会将“色彩”的追踪范围扩大 8 格，并将可追踪生物的阈值提高 3 个。'),
               B('蓝：每有一个蓝色则在“色彩”对生物造成伤害后回复自身 150 点魔力值并使技能冷却时间 -5 秒。')]),

    dict(cat='staff', id='begonia', name='海棠', base='recovery_compass', color='dark_blue',
         item_model='sweetdream:begonia',
         note='【普攻 + 主动】普攻 30 / 伤害 当前魔力 ×0.02; 命中后轻微吸引其 1 格内至多 3 个生物。\n'
              '#   主动 450 / 120 秒 -> 术阵; 把 16 格内最多 5 个附「渊海」的生物做成漩涡。\n'
              '#   漩涡 8 秒每秒拉 4 格内生物回中心; 结束时中心生物吃 ×0.15; 之后清「渊海」。',
         lore=[H('✦ 普攻'),
               I(('魔力 ', '30', 'aqua'), ('伤害 ', '自身当前魔力 ×0.02', 'yellow')),
               S(),
               P('每次普攻命中后都会使其轻微吸引一次其 1 格内的至多 3 个生物。'),
               S(),
               H('✦ 主动技能'),
               I(('魔力 ', '450', 'aqua'), ('冷却 ', '120 秒', 'yellow')),
               S(),
               P('使用后召唤一个术阵。之后使自身 16 格内的最多 5 个附有「渊海」的生物以自身为中心生成一个漩涡。'
                 '漩涡每秒都会将 4 格内的全部生物拉回中心一段距离，持续 8 秒。漩涡消失后会对处于中心的生物'
                 '造成相当于释放者最大魔力值 ×0.15 的伤害。之后清除「渊海」。')]),

    dict(cat='staff', id='gu_poison', name='蛊毒', base='recovery_compass', color='green',
         item_model='sweetdream:gu_poison',
         note='【普攻 + 主动】普攻 80 / 伤害 当前魔力 ×0.04; 命中后给目标「噬心」+ 3 秒缓慢Ⅱ。\n'
              '#   主动 500 / 120 秒 -> 术阵; 8 格内最多 2 个带「噬心」的每秒吃 最大生命 ×0.1, 之后移除「噬心」, 持续 6 秒。\n'
              '#   ★ 若目标的「噬心」提前掉了, 该目标本轮也提前失效。',
         lore=[H('✦ 普攻'),
               I(('魔力 ', '80', 'aqua'), ('伤害 ', '自身当前魔力 ×0.04', 'yellow')),
               S(),
               P('每次普攻命中后都会使其获得「噬心」效果和 3 秒的缓慢Ⅱ。'),
               S(),
               H('✦ 主动技能'),
               I(('魔力 ', '500', 'aqua'), ('冷却 ', '120 秒', 'yellow')),
               S(),
               P('使用后召唤一个术阵。之后使自身 8 格内的最多 2 个带有「噬心」效果的生物每秒受到相当于自身'
                 '最大生命值 ×0.1 的伤害，之后移除「噬心」。持续 6 秒。（若「噬心」效果提前结束则技能效果'
                 '也提前失效）')]),

    dict(cat='staff', id='twilight', name='暮光', base='recovery_compass', color='dark_purple',
         item_model='sweetdream:twilight',
         note='【普攻 + 主动】普攻 50 / 伤害 最大魔力值 ×0.03; 命中后 20% 附加「噬心」, 成功则再补一次伤害。\n'
              '#   主动 350 / 100 秒 -> 术阵; 12 格内最多 3 个带「噬心」的目标护甲/韧性减半 + 抗性提升失效, 8 秒。',
         lore=[H('✦ 普攻'),
               I(('魔力 ', '50', 'aqua'), ('伤害 ', '自身最大魔力值 ×0.03', 'yellow')),
               S(),
               P('每次普攻命中后有 20% 的概率使其附加「噬心」效果。若成功附加则额外对其造成一次伤害。'),
               S(),
               H('✦ 主动技能'),
               I(('魔力 ', '350', 'aqua'), ('冷却 ', '100 秒', 'yellow')),
               S(),
               P('使用后召唤一个术阵。之后使自身 12 格内最多 3 个带有「噬心」效果的生物的护甲值及护甲韧性'
                 '减半，且其抗性提升效果失效。持续 8 秒。')]),

    dict(cat='staff', id='sail', name='风帆', base='recovery_compass', color='white',
         note='【普攻 + 主动】普攻 80 / 伤害 1; 每次普攻后记录"最近一个生物"身上的渊海/流火/白昼梦/噬心。\n'
              '#   主动 500 / 100 秒 -> 在被记录生物处生成旋风, 持续 15 秒。\n'
              '#   旋风每 3 秒吸引 5 格内生物 + 附加"记录到的随机一种属性"。\n'
              '#   期间可再按一次技能把该旋风召唤到身边(成功则本技能冷却 -3 秒)。',
         lore=[H('✦ 普攻'),
               I(('魔力 ', '80', 'aqua'), ('伤害 ', '1', 'yellow')),
               S(),
               P('每次普攻后都会记录离自身最近的一个生物上所拥有的「渊海」、「流火」、「白昼梦」、「噬心」。'),
               S(),
               H('✦ 主动技能'),
               I(('魔力 ', '500', 'aqua'), ('冷却 ', '100 秒', 'yellow')),
               S(),
               P('使用后在被自身记录的生物处生成一个“旋风”。“旋风”每 3 秒都会吸引一次其 5 格内的生物并使其附加'
                 '被自身记录的生物的随机一种属性。期间自身可以再次使用技能来将该“旋风”召唤至自身处，持续 15 秒。'
                 '若自身召唤了该“旋风”则技能缩短 3 秒。')]),

    # ============================================================ 弩 ============
    dict(cat='bow', id='arc', item_model='sweetdream:crossbow_arc', name='电弧', base='crossbow', color='aqua',
         note='【弩 = 射击触发】不加 consumable/itemreplace, 也没有冷却 -> 不加 skill。\n'
              '# 【附魔】sweetdream:arc(见 enchantment/arc.json), 命中生物时回调 hook_victim。\n'
              '#   ⚠️ 附魔是注册表内容: 装好后要**退出世界重进**(光 /reload 不补)。\n'
              '# 【机制】每次射击给目标「电刺」; 两个带电刺的生物 6 格内 -> 拉一道 1 格宽电线, 沿途 + 双方\n'
              '#   吃 基础攻击力 ×2 + 当前魔力 ×0.03, 之后移除「电刺」。',
         lore=[H('✦ 主动技能'),
               I(('魔力 ', '30', 'aqua')),
               S(),
               P('每次射击都会对被攻击的生物附加「电刺」。'),
               S(),
               H('✦ 电刺'),
               P('若附有「电刺」的生物 6 格内有另一个附有「电刺」的生物，则立即在他们之间产生一道 1 格宽的电线并对沿途的生物及他们自身造成一次'
                 '相当于自身基础攻击力 ×2+当前魔力值 ×0.03 的伤害，之后移除「电刺」。')]),

    # ============================================================ 盔甲 ==========
    dict(cat='armor', id='mana_helm', name='聚魔头盔', base='iron_helmet', color='aqua',
         note='【纯被动 + 二件套】魔力值上限 +10; 与「聚魔胸甲」同穿再 +20。\n'
              '#   ★ 套装成员只有【聚魔头盔 + 聚魔胸甲】两件 —— 2026-10-08 事故: 我曾凭\n'
              '#   "腰带/靴也是盔甲" 把魔化腰带、血肉磨坊也划进来, 还编了个四件套\n'
              '#   (+80 上限 / 每秒 +1)。用户从未这么说过, 已撤。名字里带"聚魔"才是一套。',
         lore=[H('✦ 被动技能'),
               P('自身魔力值上限 +10。'),
               S(),
               H('✦ 套装效果'),
               B('聚魔头盔'),
               B('聚魔胸甲'),
               S(),
               P('自身魔力值上限 +20。')]),

    dict(cat='armor', id='mana_plate', name='聚魔胸甲', base='iron_chestplate', color='aqua',
         note='【纯被动 + 二件套】魔力值上限 +20; 与「聚魔头盔」同穿再 +20。\n'
              '#   ★ 套装成员只有这两件(见 mana_helm 的注)。',
         lore=[H('✦ 被动技能'),
               P('自身魔力值上限 +20。'),
               S(),
               H('✦ 套装效果'),
               B('聚魔头盔'),
               B('聚魔胸甲'),
               S(),
               P('自身魔力值上限 +20。')]),

    dict(cat='armor', id='hex_belt', name='魔化腰带', base='iron_leggings', color='dark_purple',
         note='【纯被动 + 二件套】魔力值上限 +60; 与「血肉磨坊」同穿再 +80 且每秒额外 +1 魔力。\n'
              '#   ★ 本套 =【魔化腰带 + 血肉磨坊】两件, 与「聚魔」(头盔+胸甲)是【两套独立】的。\n'
              '#   2026-10-08 事故: 我曾把这两套揉成一个"聚魔四件套", 已拆回两套。',
         lore=[H('✦ 被动技能'),
               P('自身魔力值上限 +60。'),
               S(),
               H('✦ 套装效果'),
               B('魔化腰带'),
               B('血肉磨坊'),
               S(),
               P('自身魔力值上限 +80。每秒额外获得 1 魔力值。')]),

    dict(cat='armor', id='flesh_mill', name='血肉磨坊', base='iron_boots', color='red',
         note='【被动 + 二件套】受伤后每秒 +2 魔力 + 再生Ⅱ, 持续 5 秒。\n'
              '#   二件套 =【魔化腰带 + 血肉磨坊】: 上限 +80, 每秒额外 +1 魔力。\n'
              '#   ★ 与「聚魔」(头盔+胸甲)是两套独立的, 别再凑成四件套(见 hex_belt 的注)。',
         lore=[H('✦ 被动技能'),
               P('穿戴时，自身受到伤害后则每秒获得 2 魔力值及再生Ⅱ效果，持续 5 秒。'),
               S(),
               H('✦ 套装效果'),
               B('魔化腰带'),
               B('血肉磨坊'),
               S(),
               P('自身魔力值上限 +80。每秒额外获得 1 魔力值。')]),

    dict(cat='armor', id='blaze_armor', name='焱', base='diamond_chestplate', color='red',
         note='【纯被动】常态抗火 + 视为金甲 + 魔力上限 +100。\n'
              '#   打你的生物未燃烧 -> 给它 5 秒燃烧 +「流火」; 已燃烧 -> 自己得再生Ⅱ + 力量Ⅲ 3 秒。\n'
              '# 【id 用 blaze_armor】避开工具「炽翎」blaze_plume。',
         lore=[H('✦ 被动技能'),
               P('获得常态的抗火效果，且视为金甲。自身魔力值上限 +100。攻击自身的生物若未处于燃烧状态，则使'
                 '其获得 5 秒的燃烧状态并使其获得「流火」效果。若其已处于燃烧状态则自身获得再生Ⅱ效果及力量Ⅲ'
                 '效果，持续 3 秒。')]),

    dict(cat='armor', id='spirit_sight', name='灵视', base='iron_helmet', color='yellow',
         note='【纯被动 + 触发】魔力上限 +70。8 格内若有带渊海/流火/夜火/白昼梦/噬心的生物 -> 令其发光,\n'
              '#   且自身每秒回 1 魔力。',
         lore=[H('✦ 被动技能'),
               P('自身魔力值上限 +70。自身 8 格内若有带有「渊海」、「流火」、「夜火」、「白昼梦」、「噬心」'
                 '任一标签的生物则使其发光，且自身每秒恢复一点魔力值。')]),

    dict(cat='armor', id='fade', name='息影', base='iron_leggings', color='dark_gray',
         note='【纯被动 + 触发】魔力上限 +90。放技能后 10 秒没再放 -> 当前手持装备冷却 -10 秒 + 回 50 魔力。',
         lore=[H('✦ 被动技能'),
               P('自身魔力值上限 +90。自身释放技能后若在 10 秒内没有再次释放技能则使当前手持装备冷却时间'
                 '-10 秒且自身恢复 50 魔力值。')]),
]

# ---------------------------------------------------------------- 组装
CONSUMABLE = ('consumable={animation:"none",consume_seconds:0,'
              'has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}')

SLOT = {'mana_helm': 'helmet', 'mana_plate': 'chestplate', 'hex_belt': 'leggings',
        'flesh_mill': 'boots', 'blaze_armor': 'chestplate', 'spirit_sight': 'helmet',
        'fade': 'leggings'}

# 盔甲外观两件套（2026-10-10）：equippable.slot（部位）+ 底材对应的原版穿戴音效。
#   原版盔甲 item **自带** equippable 组件 —— give 里一覆盖就是整体替换，
#   所以 slot / asset_id / equip_sound 必须一次给全（其余字段走默认值 = 原版行为）。
EQ_SLOT = {'helmet': 'head', 'chestplate': 'chest', 'leggings': 'legs', 'boots': 'feet'}
ARMOR_SOUND = {'iron': 'minecraft:item.armor.equip_iron',
               'diamond': 'minecraft:item.armor.equip_diamond',
               'netherite': 'minecraft:item.armor.equip_netherite'}

RIGHT_CLICK = ('sword', 'axe', 'staff')
# 没有主动技能(不开右键)的件: 不加 consumable / skill, 但保留 itemreplace 当"本包武器"标记。
NO_ACTIVE = {'tinder', 'thunderclap'}
BOW_ENCH = {'arc'}


def build(it):
    cid = it['id']
    cat = it['cat']
    zx = [cid]
    if cat == 'armor':
        zx += [SLOT[cid], 'armor']
    elif cat == 'bow':
        zx += ['bow']
    else:
        zx += [cat]
    if cat in RIGHT_CLICK:
        zx.append('itemreplace')

    need_skill = cat in RIGHT_CLICK and cid not in NO_ACTIVE
    zx_txt = json.dumps(zx, ensure_ascii=False, separators=(',', ':'))
    if need_skill:
        zx_txt = zx_txt + ',skill:"sweetdream:%s"' % cid

    # 【组件顺序】palette / sail 的 item_model + custom_model_data 要排在 item_name
    #   **前面** —— 和磁盘上那两份 give 一致(2026-10-09 对齐; 组件顺序不影响功能,
    #   但 _chk_gen_drift 是逐字比对的, 顺序不一致就会被判成"漂移")。
    parts = []
    if it.get('item_model'):
        parts.append('item_model="%s"' % it['item_model'])
    if cid == 'palette':
        parts.extend(['item_model="palette:palette"', 'custom_model_data={floats:[0.0f,0.0f,0.0f,0.0f,1.0f]}'])
    if cid == 'sail':
        parts.extend(['item_model="sail:staff"', 'custom_model_data={floats:[0.0f,0.0f]}'])
    parts.append('item_name={text:"%s",bold:true,color:%s}' % (it['name'], it['color']))
    parts.append('lore=' + json.dumps(it['lore'], ensure_ascii=False, separators=(',', ':')))
    parts.append('unbreakable={}')
    # 弩: 附魔 + ★ 关掉附魔光效(2026-10-10 用户要求: "我希望弩的附魔不显示光效")。
    #   1.21.5 的 enchantment_glint_override 是 **boolean**: false = 有附魔也不发光。
    if cid in BOW_ENCH:
        parts.append('enchantments={"sweetdream:%s":1}' % cid)
        parts.append('enchantment_glint_override=false')
    # ★ 标签(批 A, 2026-10-10): custom_data.tags = 语义关键词(见 _tags_data.py)。
    #   和 zx 并列 —— 类别走 zx[1], 语义走 tags; 一条谓词可同时查两处。
    cd_txt = 'zx:%s' % zx_txt
    _tags = TAGS.get(cid) or []
    if _tags:
        cd_txt += ',tags:%s' % json.dumps(_tags, ensure_ascii=False, separators=(',', ':'))
    parts.append('custom_data={%s}' % cd_txt)
    if cat in RIGHT_CLICK and cid not in NO_ACTIVE:
        parts.append(CONSUMABLE)
    if cid in BOW_ENCH:
        parts.append('tooltip_display={hidden_components:["unbreakable","enchantments"]}')
    else:
        parts.append('tooltip_display={hidden_components:["unbreakable"]}')
    # ★ 盔甲外观两件套（2026-10-10）：图标(item_model) + 穿戴层(equippable)。
    #   配对资源在 sweetdream_rp_原版风 / _完整版：
    #     items/armor_<id>.json → models/item/vanilla/armor_<id>.json → 16×16 图标
    #     equipment/armor_<id>.json → textures/entity/equipment/humanoid[_leggings]/armor_<id>.png
    #   存量装备由 sweetdream:visual/armor_icon_sync（每秒）补课。
    if cat == 'armor':
        parts.append('item_model="sweetdream:armor_%s"' % cid)
        parts.append('equippable={slot:"%s",asset_id:"sweetdream:armor_%s",equip_sound:"%s"}'
                     % (EQ_SLOT[SLOT[cid]], cid, ARMOR_SOUND[it['base'].split('_')[0]]))

    pre = ''
    if cat == 'staff':
        pre += 'max_stack_size=1,'
    return 'give @s %s[%s%s]' % (it['base'], pre, ','.join(parts))


def header(it):
    cat_cn = {'sword': '剑', 'axe': '斧', 'staff': '法杖', 'bow': '弩', 'armor': '盔甲'}[it['cat']]
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
    A('# 【这个文件是生成的】改描述/数值请改 .workbuddy/_gen_batch6.py 再重跑,')
    A('#   然后跑 `python .workbuddy/lore_fmt.py --write` 让规范器重新折行。')
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
