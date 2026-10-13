# -*- coding: utf-8 -*-
"""
生成「第五批」15 件新装备的 give.mcfunction。

【为什么用生成器】15 件的 give 只有"底材 / 名字 / 描述 / custom_data"四处不同,
  外壳(consumable / unbreakable / tooltip_display / skill)完全一样 —— 手抄 15 遍
  必然抄错某一处。改描述改这里一处, 重跑即可。

【描述怎么保证合规】正文**每行写成一个长串**, 之后交给 `lore_fmt.py --write`
  统一按 37 半角宽重新折行 —— check.py 规则 31 是拿 lore_fmt 的输出**逐字比对**的,
  所以手敲的折行一定会被判不合规。本脚本只负责"内容", 折行交给规范器。

【三处约定(照既有 28 件)]】
  · custom_data.zx = [<装备 id>, <分类标记>, <"itemreplace"(右键触发的才有)>]
  · 带 冷却 的才有 skill:"sweetdream:<id>"(观测镜靠它显示冷却)
  · 剑/斧/弩/甲 都有 max_damage -> **不能加 max_stack_size**(1.21.5 两者互斥);
    法杖底座是 recovery_compass(能堆) -> 要加
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
    """正文里的半角标点 -> 全角, 并吃掉标点后面多余的空格。

    ★ 为什么必须全角: lore_fmt 的折行器遇到"半角逗号 + 空格"时, 断点可能正好落在
      那个空格上 —— 合并回段落时空格就丢了, 于是第二遍折出不一样的行,
      **规范器不收敛**(check 31 会一直报"不是 lore_fmt 的输出")。
      全角标点不参与"汉字<->半角留白", 也不会被当断点, 和包里既有 28 件一致。

    ★ 为什么还要再吃一次空格: 源文本里写成 "生物, 则..." 时, 只替换标点会得到
      "生物， 则..." —— 全角标点后面挂个半角空格, 包里既有 28 件**一处都没有**。
      (2026-10-05 实测: 15 个新文件里有 34 处这种空格, 老文件全是 0。)
    """
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


# ---------------------------------------------------------------- 15 件装备
ITEMS = [
    # ---------------- 剑 ----------------
    dict(cat='sword', id='myriad', name='万念', base='iron_sword', color='white',
         item_model='sweetdream:myriad',
         note='【切换】使用后把自己换成「千散」(qiansan); 千散用完再换回万念。\n'
              '#   两把是同一把武器的一体两面, 所以冷却/魔力都要一致。\n'
              '# 【数值要和 cast 对上】魔力 80 / 冷却 20 秒。',
         lore=[H('✦ 主动技能'),
               I(('魔力 ', '80', 'aqua'), ('冷却 ', '20 秒', 'yellow')),
               S(),
               P('使用后切换为「千散」并对自身 3 格内的全部生物造成一次相当于自身当前魔力值 ×0.1 的伤害。')]),

    dict(cat='sword', id='qiansan', name='千散', base='iron_sword', color='dark_red',
         item_model='sweetdream:qiansan',
         note='【衍生物】由「万念」使用后切换而来, 也可以直接 give 出来测。\n'
              '#   通道和万念相反: 万念吃当前魔力, 千散吃基础攻击力。\n'
              '# 【数值要和 cast 对上】魔力 80 / 冷却 20 秒。',
         lore=[H('✦ 主动技能'),
               I(('魔力 ', '80', 'aqua'), ('冷却 ', '20 秒', 'yellow')),
               S(),
               P('使用后切换为「万念」并对自身 3 格内的全部生物造成一次相当于自身基础攻击力 ×2 的伤害。')]),

    # ---------------- 斧 ----------------
    dict(cat='axe', id='agony', item_model='sweetdream:agony', name='苦痛', base='netherite_axe', color='dark_purple',
         note='【数值要和 cast 对上】魔力 600 / 冷却 100 秒 / 持续 15 秒。\n'
              '# 【要处理"传递"】目标中途死亡要把效果转给离它最近的那一只,\n'
              '#   所以每秒都要重新找一次目标, 不能只在施法时记一次 uuid。',
         lore=[H('✦ 主动技能'),
               I(('魔力 ', '600', 'aqua'), ('冷却 ', '100 秒', 'yellow')),
               S(),
               P('使用后召唤一个术阵。之后使离自身最近的一个生物每秒受到相当于释放者基础攻击力 ×2 的伤害。'
                 '若持续期间该生物死亡则对其 2 格内的全部生物造成一次相当于其最大生命值的伤害, '
                 '之后使该效果延续到离它最近的一个生物上。该效果持续 15 秒。')]),

    # ---------------- 法杖 ----------------
    dict(cat='staff', id='polarized_light', name='偏振光', base='recovery_compass', color='white',
         item_model='sweetdream:polarized_light',
         note='【数值要和 cast 对上】普攻 魔力 10 / 伤害 6; 技能 魔力 80 / 冷却 20 秒 / 持续 5 秒。\n'
              '# 【"持续发射一道光线"】是表现层(粒子/端点连线), 伤害走每秒一次的检测。\n'
              '# 【模型】2026-10-10 用户批准独立16×16法杖贴图，绑定完整版资源包。',
         lore=[H('✦ 普攻'),
               I(('魔力 ', '10', 'aqua'), ('伤害 ', '6', 'yellow')),
               S(),
               H('✦ 主动技能'),
               I(('魔力 ', '80', 'aqua'), ('冷却 ', '20 秒', 'yellow')),
               S(),
               P('使用后召唤一个术阵。之后自身持续发射一道光线且每秒对自身 10 格内离自己最近的一个生物'
                 '造成一次相当于自身当前魔力值 ×0.05 的伤害, 且被锁定的生物获得缓慢Ⅱ效果。该效果持续 5 秒。')]),

    dict(cat='staff', id='delusion', name='惑梦', base='recovery_compass', color='light_purple',
         item_model='sweetdream:delusion',
         note='【数值要和 cast 对上】普攻 魔力 20; 技能 魔力 300 / 冷却 60 秒。\n'
              '# 【两段分支】先看锁定的那只"在不在时停里"再决定走哪一段,\n'
              '#   注意别写成"先时停 2 秒再看"(那样第二段的判定永远成立)。\n'
              '# 【模型】2026-10-10 用户批准独立16×16法杖贴图，绑定完整版资源包。',
         lore=[H('✦ 普攻'),
               I(('魔力 ', '20', 'aqua'), ('伤害 ', '最大魔力值 ×0.02', 'yellow')),
               S(),
               H('✦ 主动技能'),
               I(('魔力 ', '300', 'aqua'), ('冷却 ', '60 秒', 'yellow')),
               S(),
               P('使用后召唤一个术阵。之后锁定 8 格内离自身最近的一个生物, 之后使其 3 格内的全部生物时停 2 秒。'
                 '若锁定的生物处于时停状态则改为使其 5 格内的全部生物受到一次相当于自身最大魔力值 ×0.1 的伤害'
                 '并时停 3 秒。')]),

    dict(cat='staff', id='fallen_dream', name='堕梦', base='recovery_compass', color='dark_gray',
         item_model='sweetdream:fallen_dream',
         note='【数值要和 cast 对上】普攻 魔力 50; 技能 魔力 500 / 冷却 100 秒。\n'
              '# 【真伤】普攻命中带「白昼梦」的目标时本次改真实伤害 —— 和「幻昼」\n'
              '#   那套「白昼梦」联动, 别自己另起一个效果名。\n'
              '# 【模型】2026-10-10 用户批准独立16×16法杖贴图，绑定完整版资源包。',
         lore=[H('✦ 普攻'),
               I(('魔力 ', '50', 'aqua'), ('伤害 ', '最大魔力值 ×0.03', 'yellow')),
               S(),
               P('每次普攻命中后若其处于「白昼梦」效果则本次伤害变为真实伤害。'),
               S(),
               H('✦ 主动技能'),
               I(('魔力 ', '500', 'aqua'), ('冷却 ', '100 秒', 'yellow')),
               S(),
               P('使用后召唤一个术阵。之后使自身 8 格内的全部生物附加「白昼梦」效果，若其未处于时停状态'
                 '则使其时停 3 秒，若其处于时停状态则使其时停时间 +2 秒。之后使其在接下来的时停时间内'
                 '每秒受到一次相当于使用者当前魔力值 ×0.04 的伤害。')]),

    dict(cat='staff', id='apocalypse', name='启示录', base='recovery_compass', color='gold',
         item_model='sweetdream:apocalypse',
         note='【数值要和 cast 对上】普攻 魔力 60; 技能 魔力 450 / 冷却 90 秒。\n'
              '# 【"启示"是页, 不是层数】最多 3 页, 每页各记一次魔力值 —— 所以存的是\n'
              '#   一个最多 3 项的列表, 不是"层数 +1"。\n'
              '# 【两个计时器】"每 4 秒依次消耗一层"和"每 3 秒一次灾示"是两条,\n'
              '#   别合成一个(描述里是两个独立的节奏)。\n'
              '# 【模型】2026-10-07: 用户已画好模型, 所以本条目带 `item_model` 字段\n'
              '#   (其余三根法杖仍不写)。模型见 sweetdream_rp_完整版/assets/sweetdream/\n'
              '#   items/apocalypse.json —— 按 custom_model_data 分发的完整树。\n'
              '#   ★ 生成器会给它自动配 custom_model_data={floats:[0.0f]}(成对写)。\n'
              '#   ★ 历史坑: 2026-10-05 那版 note 写着"故意不写 item_model", 后来模型\n'
              '#     做好了却只改了磁盘上的 give ⇒ 每次重跑生成器都把 item_model 打掉。',
         lore=[H('✦ 普攻'),
               I(('魔力 ', '60', 'aqua'), ('伤害 ', '最大魔力值 ×0.03', 'yellow')),
               S(),
               H('✦ 启示'),
               P('该武器位于快捷栏时, 自身每次释放主动技能时若该技能消耗了至少 100 魔力, 则「启示录」记录'
                 '该技能消耗的魔力值并获得一页「启示」, 最多记录 3 页。每个技能单次最多产生一页。'),
               S(),
               H('✦ 主动技能'),
               I(('魔力 ', '450', 'aqua'), ('冷却 ', '90 秒', 'yellow')),
               S(),
               P('使用后召唤一个术阵, 并每隔 4 秒就依次消耗一层「启示」。'),
               S(),
               H('✦ 灾示'),
               P('每消耗一页, 每隔 3 秒发生一次「灾示」: 对自身 8 格内全部生物造成相当于该页记录魔力值 '
                 '×0.5 的伤害。若该页记录的技能消耗魔力超过 500, 则本次「灾示」额外使目标获得 5 秒发光'
                 '与虚弱Ⅱ。若三页启示全部被消耗, 则最后一次「灾示」伤害提高 50%。')]),

    # ---------------- 弩 ----------------
    dict(cat='bow', id='sculk_echo', item_model='sweetdream:crossbow_sculk_echo', name='幽匿残响', base='crossbow', color='dark_aqua',
         note='【为什么底材是弩】弩有 minecraft:shot_crossbow 进度触发器, 天然对应"每次射击";\n'
              '#   弓的右键是拉弓蓄力, 做不了这个事件(和「寒鸦」同一个道理)。\n'
              '# 【所以没有 consumable / itemreplace】触发靠 shot_crossbow 进度。\n'
              '# 【弩上的附魔】sweetdream:sculk_echo(见 enchantment/sculk_echo.json),\n'
              '#   只在"这把弩射出的箭打中生物"时回调 hook_victim 结算 —— 命中判定交给原版。\n'
              '#   ⚠️ 附魔是注册表内容: 装好后要**退出世界重进**(光 /reload 不补)。\n'
              '# 【"每刻"的伤害】发射路径周围 2 格那条是 along-ray 的每刻检测, 别用\n'
              '#   schedule(同名 schedule 会互相顶掉, 见 RULES 坑 8)。\n'
              '# 【主动技能 = 射击本身】不是右键释放 —— 触发走 minecraft:shot_crossbow,\n'
              '#   所以**不加 consumable / itemreplace**; 也没有冷却 => **不加 skill 字段**。\n'
              '#   (描述标题写「✦ 主动技能」但正文仍写「每次射击」, 因为就是每次射击生效。)',
         lore=[H('✦ 主动技能'),
               I(('魔力 ', '100', 'aqua')),
               S(),
               P('每次射击会额外积攒 10 点「悲鸣」（上限 50 点）'),
               S(),
               H('✦ 悲鸣'),
               P('每次射击后都会对被射击的生物的 2 格内额外造成相当于自身基础攻击力 ×「悲鸣」值 ×0.1 的伤害, '
                 '同时对发射路径周围 2 格的敌人每刻造成相当于「悲鸣」值 ×0.1 的伤害。每 1 点「悲鸣」会使该'
                 '伤害有 1% 概率造成三倍伤害, 触发后清除全部「悲鸣」。')]),

    dict(cat='bow', id='bone_erode', item_model='sweetdream:crossbow_bone_erode', name='蚀骨', base='crossbow', color='gray',
         note='【衍生物】幽匿残响那条线的副产物, 也能直接 give 出来测。\n'
              '# 【百分比消耗】消耗的是"本次射击所消耗的魔力值"的 20% —— 注意这是\n'
              '#   **按比例**扣, 不是固定 20 点, 别写成常数。\n'
              '# 【弩上的附魔】sweetdream:bone_erode(见 enchantment/bone_erode.json),\n'
              '#   命中生物时回调 hook_victim 结算。⚠️ 装好后要**退出世界重进**。\n'
              '# 【主动技能 = 射击本身】不是右键释放 —— 触发走 minecraft:shot_crossbow,\n'
              '#   所以**不加 consumable / itemreplace**; 也没有冷却 => **不加 skill 字段**。\n'
              '#   (描述标题写「✦ 主动技能」但正文仍写「每次射击」, 因为就是每次射击生效。)',
         lore=[H('✦ 主动技能'),
               I(('魔力 ', '20%', 'aqua')),
               S(),
               P('每次射击都会对被射击的生物的 2 格内的全部生物造成相当于本次射击所消耗的魔力值 ×0.4 的伤害。')]),

    dict(cat='bow', id='lucid_dream', item_model='sweetdream:crossbow_lucid_dream', name='清醒梦', base='crossbow', color='aqua',
         note='【X = 「梦回」层数】描述里那几个 X 不是笔误, 就是层数本身 —— 实现时\n'
              '#   把层数读出来直接当代入值用, 别在描述里烘死成某个数字。\n'
              '# 【和「幻昼」的「白昼梦」联动】判的是同一个效果名(zx.status.dream)。\n'
              '# 【★ 漫彩期内的白昼梦处理 ★】文案是"消耗「白昼梦」且持续时间延长 X 秒"\n'
              '#   —— 所以漫彩期间一旦发现该生物带白昼梦, 就**摘掉它**(tag/unmark dream)\n'
              '#   并把 ld_end 往后推 X 秒(不是每格续命到白昼梦自然结束)。见 hit_extra。\n'
              '# 【弩上的附魔】sweetdream:lucid_dream(见 enchantment/lucid_dream.json),\n'
              '#   命中生物时回调 hook_victim 结算。⚠️ 装好后要**退出世界重进**。\n'
              '# 【主动技能 = 射击本身】不是右键释放 —— 触发走 minecraft:shot_crossbow,\n'
              '#   所以**不加 consumable / itemreplace**; 也没有冷却 => **不加 skill 字段**。\n'
              '#   (描述标题写「✦ 主动技能」但正文仍写「每次射击」, 因为就是每次射击生效。)',
         lore=[H('✦ 主动技能'),
               I(('魔力 ', '180', 'aqua')),
               S(),
               P('每次射击若射击附加了「白昼梦」效果或处于时停状态的生物, 则累计一层「梦回」（最多为 5 层）。'),
               S(),
               H('✦ 梦回'),
               P('当「梦回」达到 3 层及以上后, 再次射击附有「白昼梦」的生物时对其造成相当于自身当前魔力值 '
                 '×0.X 的伤害, 之后清除该生物的「白昼梦」并清除自身「梦回」, 之后召唤一个术阵。召唤术阵后'
                 '该生物每次受到攻击都会使自身 2 格内的全部生物额外受到一次相当于自身最大魔力值 ×0.0X 的'
                 '真实伤害, 持续 X 秒。若持续时间内该生物被附加了「白昼梦」效果, 则消耗「白昼梦」效果且'
                 '技能持续时间延长 X 秒（X 为「梦回」层数）。')]),

    dict(cat='bow', id='rainbow', item_model='sweetdream:crossbow_rainbow', name='虹彩', base='crossbow',
         color='light_purple', color2='aqua', split=1,
         note='【名字是两色】"虹"(light_purple) + "彩"(aqua) —— 用户 2026-10-06 要"两种不同颜色搭配"。\n'
              '#   生成器里由 color2 / split 两个字段控制(见 build 的 item_name 段):\n'
              '#   color2 = 第二段颜色, split = 从第几个字开始换色(这里是 1)。\n'
              '# 【底材为什么是弩】和「寒鸦 / 幽匿残响」同理: 靠 minecraft:shot_crossbow\n'
              '#   拿到"每次射击"这个事件; 弓做不到。\n'
              '# 【注意别和「异彩」(iridescent, 头盔)搞混】两件是不同的东西, id 也不同。\n'
              '# 【弩上的附魔】sweetdream:rainbow(见 enchantment/rainbow.json),\n'
              '#   命中生物时回调 hook_victim 结算。⚠️ 装好后要**退出世界重进**。\n'
              '# 【主动技能 = 射击本身】不是右键释放 —— 触发走 minecraft:shot_crossbow,\n'
              '#   所以**不加 consumable / itemreplace**; 也没有冷却 => **不加 skill 字段**。\n'
              '#   (描述标题写「✦ 主动技能」但正文仍写「每次射击」, 因为就是每次射击生效。)',
         lore=[H('✦ 主动技能'),
               I(('魔力 ', '580', 'aqua')),
               S(),
               P('每次射击若射击到了生物, 则使附着 10 秒「漫彩」。期间若其有「流火」、「夜火」、「渊海」、'
                 '「白昼梦」、「噬心」中任意一个效果则消耗该效果并使其受到相当于自身最大生命值 ×0.1 的伤害, '
                 '之后使「漫彩」效果 -1 秒。若「漫彩」效果在 5 秒内结束则对其 2 格内的生物造成一次相当于'
                 '其最大生命值 ×0.2 的伤害。')]),

    # ---------------- 盔甲 ----------------
    dict(cat='armor', id='withered_garden', name='枯枝园', base='netherite_leggings', color='dark_green',
         note='【套装】和「无光海」(lightless_sea)成套, 套装效果两件都写了。\n'
              '# 【"朽木"是个物件, 不是效果名】头顶图标那套只认 5 种效果名, 别往里塞。\n'              '# 【上限】名下最多 3 棵朽木, 逻辑在 withered_garden/cap(宏), 改上限要同步描述。\n'
              '# 【抗性提升的账本】层数会随朽木数量变化, 要按差值加减, 别直接 set 覆盖。',
         lore=[H('✦ 被动技能'),
               P('自身魔力值上限 +300。'),
               S(),
               H('✦ 朽木'),
               P('自身每使用一次技能都会在自身 8 格内的随机一个附有「渊海」效果的生物处召唤一个持续 8 秒的'
                 '“朽木”, 之后使自身 6 格内随机一个生物附加「渊海」效果。“朽木”每 2 秒对其 5 格内的有缓慢'
                 '效果的生物造成相当于释放者最大魔力值 ×0.08 的伤害, 若该目标同时附有「渊海」效果则额外造成'
                 '一次伤害。场上最多同时存在 3 个“朽木”, 超出时最早召唤的一个会立刻消失。自身 12 格内每有'
                 '一个“朽木”则自身获得一层抗性提升（最大为 3）。'),
               S(),
               H('✦ 套装效果'),
               B('无光海'),
               B('枯枝园'),
               S(),
               P('若“暗潮”内有“朽木”存在, 则每秒都会使“暗潮”内的全部生物受到相当于释放者自身最大魔力值 '
                 '×0.1 的伤害, 且会被附加「渊海」效果。')]),

    dict(cat='armor', id='lightless_sea', name='无光海', base='netherite_boots', color='dark_blue',
         note='【套装】和「枯枝园」(withered_garden)成套, 套装效果两件都写了。\n'
              '# 【基础攻击力 +1 的账本】"每影响一个生物 +1"会随目标数变化, 而且 3 秒\n'
              '#   断供要**清空** —— 一定要按差值加减, 别直接 set(不然脱战也留着加成)。\n'
              '# 【"暗潮"是个区域, 不是效果】范围内的缓慢Ⅱ要每刻/每秒重新施加, 否则会掉。\n'
              '# 【上限】名下最多 3 片暗潮, 逻辑在 lightless_sea/cap(宏), 改上限要同步描述。',
         lore=[H('✦ 被动技能'),
               P('自身魔力值上限 +200。'),
               S(),
               H('✦ 暗潮'),
               P('自身 8 格内若有缓慢效果或附加了「渊海」效果的生物, 则每秒都会使其 3 格内的全部生物获得 '
                 '2 秒虚弱Ⅲ, 且每影响一个生物都会为自身回复 5 魔力值且自身基础攻击力 +1, 若自身 3 秒内'
                 '没有持续该效果则清空该加成。自身每使用一次技能都会在自身位置生成一个半径 4 格的“暗潮”, '
                 '在“暗潮”范围内的生物将获得常态的缓慢Ⅱ。8 秒后“暗潮”自毁。场上最多同时存在 3 个“暗潮”, '
                 '超出时最早召唤的一个会立刻消失。'),
               S(),
               H('✦ 套装效果'),
               B('无光海'),
               B('枯枝园'),
               S(),
               P('若“暗潮”内有“朽木”存在, 则每秒都会使“暗潮”内的全部生物受到相当于释放者自身最大魔力值 '
                 '×0.1 的伤害, 且会被附加「渊海」效果。')]),

    dict(cat='armor', id='furnace_core', name='炉心', base='netherite_chestplate', color='red',
         note='【注意别和「天使核心」(angel_core)搞混】两件是不同的东西。\n'
              '# 【属性加成要双写】原版 attribute modifier + 面板 base_attack/max_health,\n'
              '#   同 id modifier 必须"无条件 remove 再 add"(见 RULES 通用约定)。\n'
              '# 【X/Y 会随层数变】按差值加减, 别直接 set; "最低为 3 / 5"是保底。',
         # ★【二级小标题「✦ 燃灰」】2026-10-07: 原先这里没写小标题(三段正文),
         #   磁盘上早已手工补过 —— 生成器必须跟上, 否则每次重跑都把标题打掉。
         lore=[H('✦ 被动技能'),
               P('自身魔力值上限 +100, 最大生命值 +10, 基础攻击力 +5。'),
               S(),
               H('✦ 燃灰'),
               P('自身每攻击一次处于燃烧状态的生物则积攒一层「燃灰」（最大为 10 层）。'
                 '每有一层「燃灰」则自身魔力值上限 +30, 基础攻击力 +X(X 为自身当前基础攻击力 ×0.1, '
                 '最低为 3), 最大生命值 +Y(Y 为自身当前最大生命值 ×0.1, 最低为 5), 且每秒恢复 1 点魔力值。'
                 '「燃灰」每 3 秒 -1 层。')]),

    dict(cat='armor', id='resonance', name='共振', base='iron_chestplate', color='white',
         note='【"当前有几个术阵"]用前置包的 formation/count 接口读, 别自己数。\n'
              '# 【+10% 是乘区】走技能倍率的"整体乘区", 不是给三条通道各加 10。',
         lore=[H('✦ 被动技能'),
               P('自身魔力值上限 +120。'),
               S(),
               P('自身当前每有一个术阵则自身释放技能的伤害 +10%。')]),
]

# ---------------------------------------------------------------- 组装
CONSUMABLE = ('consumable={animation:"none",consume_seconds:0,'
              'has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}')

# 分类标记: 剑/斧/法杖 走右键(带 itemreplace); 弩 靠 shot_crossbow; 盔甲 是部位
SLOT = {'withered_garden': 'leggings', 'lightless_sea': 'boots',
        'furnace_core': 'chestplate', 'resonance': 'chestplate'}

# 盔甲外观两件套（2026-10-10）：equippable.slot（部位）+ 底材对应的原版穿戴音效。
#   原版盔甲 item **自带** equippable 组件 —— give 里一覆盖就是整体替换，
#   所以 slot / asset_id / equip_sound 必须一次给全（其余字段走默认值 = 原版行为）。
EQ_SLOT = {'helmet': 'head', 'chestplate': 'chest', 'leggings': 'legs', 'boots': 'feet'}
ARMOR_SOUND = {'iron': 'minecraft:item.armor.equip_iron',
               'diamond': 'minecraft:item.armor.equip_diamond',
               'netherite': 'minecraft:item.armor.equip_netherite'}
RIGHT_CLICK = ('sword', 'axe', 'staff')

# 弩类各带一个 post_attack 附魔(命中生物时回调自己的 hook_victim)。
#   ★ 这就是"第二批(4 把弩)"的核心: 每把弩一个附魔, 见 sweetdream/enchantment/<id>.json。
#   附魔是**注册表**内容: 装好/改动后要退出世界重进(光 /reload 不补)。
BOW_ENCH = {'sculk_echo', 'bone_erode', 'lucid_dream', 'rainbow'}


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

    # skill: 只有"有冷却的主动技能"才需要(观测镜靠它显示冷却)。
    #   ★ 必须和 zx 写在**同一个** custom_data 里 —— 分成两个 custom_data 的话
    #     后一个会整个覆盖前一个(物品直接少一半数据)。
    need_skill = cat in RIGHT_CLICK
    # ★ zx_txt 是 custom_data={zx:<这里>} 的**中间那段**, 所以 skill 要接在
    #   数组的 `]` **之后**(写成 {zx:[...],skill:"..."})。早期版本把 `]` 当成
    #   最后一个字符切掉再拼, 结果是 `["a","b",skill:"x"}` —— 方括号没收尾,
    #   整条 give 在加载期就作废(日志 Failed to load function), 而文件看不出异常。
    zx_txt = json.dumps(zx, ensure_ascii=False, separators=(',', ':'))
    if need_skill:
        zx_txt = zx_txt + ',skill:"sweetdream:%s"' % cid

    # item_name: 默认单色; 给了 color2 就拆成"两段不同颜色"的名字
    #   (用户 2026-10-06: 「虹彩」要两种不同颜色搭配)
    #   ★ 子段放 extra 里, 格式从父段继承(bold:true 不用再写一遍)。
    #   ★ SNBT 里 extra 是**数组**, 只有一段也要写出来 —— 少一层方括号会整条 give 作废。
    if it.get('color2'):
        k = it.get('split', 1)
        nm = it['name']
        parts = ['item_name={text:"%s",bold:true,color:%s,extra:[{text:"%s",color:%s}]}'
                 % (nm[:k], it['color'], nm[k:], it['color2'])]
    else:
        parts = ['item_name={text:"%s",bold:true,color:%s}' % (it['name'], it['color'])]
    parts.append('lore=' + json.dumps(it['lore'], ensure_ascii=False, separators=(',', ':')))
    parts.append('unbreakable={}')
    # 弩: 带上自己的 post_attack 附魔(命中生物回调), 并把附魔说明藏掉。
    #   ★ `enchantment_glint_override=false`(2026-10-10 用户要求) —— 附魔会让物品
    #     自带紫色附魔光效(enchantment glint), 用户的弩不想要这层光。
    #     1.21.5 里这个组件是 **boolean**: false = 有附魔也不发光。
    #     (user: "我希望弩的附魔不显示光效")
    if cid in BOW_ENCH:
        parts.append('enchantments={"sweetdream:%s":1}' % cid)
        parts.append('enchantment_glint_override=false')
    # ★ 标签(批 A, 2026-10-10): custom_data.tags = 语义关键词(见 _tags_data.py)。
    #   和 zx 并列 —— 类别走 zx[1], 语义走 tags; 一条谓词可同时查两处:
    #   custom_data~{zx:["staff"],tags:["dash"]}。
    cd_txt = 'zx:%s' % zx_txt
    _tags = TAGS.get(cid) or []
    if _tags:
        cd_txt += ',tags:%s' % json.dumps(_tags, ensure_ascii=False, separators=(',', ':'))
    parts.append('custom_data={%s}' % cd_txt)
    if cat in RIGHT_CLICK:
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

    # 底座前缀: 法杖是 recovery_compass(能堆 -> 要 max_stack_size)
    # 独立贴图显式绑定自己的模型；启示录保留原来的动画初始帧。
    pre = ''
    if it.get('item_model'):
        pre += 'item_model="%s",' % it['item_model']
        if cid == 'apocalypse':
            pre += 'custom_model_data={floats:[0.0f]},'
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
    A('# 【这个文件是生成的】改描述/数值请改 .workbuddy/_gen_batch5.py 再重跑,')
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
        print('%-34s %s' % ('equipment/%s/%s' % (it['cat'], it['id']), it['name']))
    print('---- 共 %d 件' % n)


if __name__ == '__main__':
    main()
