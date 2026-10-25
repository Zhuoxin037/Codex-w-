# -*- coding: utf-8 -*-
"""_gen_batch18.py —— 批二「标签补缺 14 件」的 give.mcfunction 生成器。

【范围】与批一（`_gen_batch17.py`）同口径：**只做 give**
  （名字 / 描述 / 底材 / custom_data / 标签），
  技能函数 / 进度记账 / 图标 / item_model 全部留后续批次。

【这批是什么】总稿 §5 的 14 件（原 16 件，10-20 删去钩沉与冰棺）：
  铁 3（缚烬·沉砣·反照[副手]）· 钻 4（决堤·息土·囚昼·归途·停针·虚位 中的钻档）·
  下界 3（剖心·断碑·夜缚[弩]）· 未分档 7。
  ★ 它们补的是**标签缺口**，不是阶段线（阶段线由批一负责）。

【★ 为什么这批**不挂 item_model**】
  新 14 件还没有画图标，挂上就指向不存在的 `assets/sweetdream/items/<key>.json`
  ⇒ 游戏里是**紫黑方块**，且零日志（坑 195）。
  ⇒ 现在不挂：游戏里显示底材原版贴图。
  ★ 补外观的顺序固定：`_gen_late_icons.py` 出贴图 -> `_gen_late_rp.py` 接线
    （items/models/equipment）-> 再回到本文件打开 MODEL=True 重跑。

【★ 弩在本批**不挂 enchantments**】
  弩没有右键/consumable，命中结算全靠 `sweetdream:<id>` 附魔的 post_attack
  三回调（坑 138）。本批不建 enchantment/*.json，所以**不能挂** ——
  挂一个不存在的附魔 id 会让整条 give 解析失败。

【★ 与本批三件"普攻"有关的写法偏差】
  总稿里 剖心 / 沉砣 / 虚位 的卡片写的是「✦ 普攻」，但包内 `✦ 普攻` 段
  **只存在于法杖 22 件**（有独立耗蓝/伤害）；剑与斧没有独立普攻耗蓝
  ⇒ 这里统一写成「✦ 被动技能」（"每次普通攻击命中时…"），
  并把「砣」这种专属层数按 lore 规范**单独成段**（§二：专属资源必须独占一段）。

【描述真源】本文件 LORE（正文已按包内口径写好：× 乘号 / 汉字半角留白 /
  罗马数字 / 状态「」/ 召唤物·场地“”/ 领域不加括号）。
  编成 lore 组件后交给 `lore_fmt.rebuild(width=37)`，与包内其它装备逐字同规。

【标签真源】`.workbuddy/_tags_data.py` 的 TAGS（单一真源），本文件只取用。

【底材 = 阶段】(用户 10-07 定，10-11 补"稀有 = 铁")
  铁 / 钻 / 下界三档就是阶段，包内没有 rarity 字段、也没有 recipe —— 阶段只看底材。
    铁 -> iron_*    钻 -> diamond_*    下界 -> netherite_*
  弩 / 法杖 / 副手固定 crossbow / recovery_compass（不分档）。

【zx 约定（照 batch5/6/7/new42 与批一）】
  剑/斧/法杖 = [<id>,<cat>,"itemreplace"]；弩 = [<id>,"bow"]；
  副手 = [<id>,"tool"]（★ 包内 10/12 件是两元素，只有殓丝/潮汐扣带 itemreplace）；
  盔甲 = [<id>,<slot>,"armor"]（无 skill、无 consumable）。
  带冷却的剑/斧/法杖才写 skill:"sweetdream:<id>"（观测镜靠它显示 CD）。
  法杖与副手必须 `max_stack_size=1`（包内 22/22 法杖、12/12 副手都带）。

【用法】
  python .workbuddy/_gen_batch18.py
  python .workbuddy/lore_fmt.py --write          # 规范化折行（连跑两遍，第二遍 0 变化）
  python .workbuddy/_gen_give_all.py             # 重排最末几盒
  python .workbuddy/_chk_gen_drift.py            # 应 0 漂移
"""
import io
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import lore_fmt                              # noqa: E402
from _new42_lore import HEAD, INFO, S, build_lore   # noqa: E402
from _tags_data import TAGS                  # noqa: E402

BASE = r'D:\数据包\sweetdream\data\sweetdream\function\equipment'

# ★ 外观未做 -> 先不挂 item_model（挂了 = 紫黑方块，见文件头）
MODEL = False

CONSUMABLE = ('consumable={animation:"none",consume_seconds:0,'
              'has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}')

KIND_CAT = {'剑': 'sword', '斧': 'axe', '弩': 'bow', '法杖': 'staff', '副手': 'tool',
            '头盔': 'armor', '胸甲': 'armor', '护腿': 'armor', '靴子': 'armor'}
KIND_SLOT = {'头盔': 'helmet', '胸甲': 'chestplate', '护腿': 'leggings', '靴子': 'boots'}
TIER = {'罕见': 'iron', '稀有': 'iron', '史诗': 'diamond', '传说': 'netherite'}

RIGHT_CLICK = ('sword', 'axe', 'staff')


# ============================================================
# 批二 14 件（顺序照总稿 §5.1 编号 1–14）
# ============================================================
LORE = [
    # ---------------- 下界（终端）----------------
    dict(id='profane', name='剖心', rarity='传说', kind='剑', color='dark_red', segs=[
        HEAD('✦ 被动技能'),
        S('每次普通攻击命中附有「噬心」的生物时，使其「噬心」的剩余时长延长 2 秒'
          '（最多 18 秒），并额外造成一次相当于自身基础攻击力的伤害。'
          '该效果 5 秒内最多触发一次。'),
        HEAD('✦ 主动技能'), INFO(('魔力', '320'), ('冷却', '30 秒')),
        S('使用后向准星方向斩出一道 2×5 的剖线，对命中的全部生物造成相当于自身基础攻击力 ×5 的伤害。'
          '若命中的生物附有「噬心」，则清除其「噬心」，该次伤害改为相当于自身基础攻击力 ×8，'
          '且伤害额外提高 20%（独立乘区），并使命中的生物 2 格内的其他生物受到该次伤害一半的伤害。'
          '每清除一个「噬心」，自身所有技能的冷却时间减少 2 秒。'),
    ]),
    dict(id='grave_tablet', name='断碑', rarity='传说', kind='斧', color='dark_gray', segs=[
        HEAD('✦ 主动技能'), INFO(('魔力', '300'), ('冷却', '45 秒')),
        S('使用后向准星方向砸出一道长 6 格的裂口，对裂口上及两侧 1.5 格内的全部生物'
          '造成相当于自身基础攻击力 ×4 的真实伤害。若目标护甲值不低于 15，该次伤害提高 80%。'
          '每命中一个生物，本技能的冷却时间减少 6 秒，单次最多减少 30 秒。'),
    ]),
    # ---------------- 钻石（过渡）----------------
    dict(id='burst_bank', name='决堤', rarity='史诗', kind='法杖', color='aqua', segs=[
        HEAD('✦ 普攻'), INFO(('魔力', '80'), ('伤害', '自身当前魔力值 ×0.03')),
        HEAD('✦ 主动技能'), INFO(('魔力', '当前魔力值的 50%'), ('冷却', '25 秒')),
        S('当前魔力值不足 100 时无法施放。使用后向准星方向突进，'
          '每消耗 25 点魔力突进 1 格（最少突进 2 格、最多 15 格）。'
          '被突进路径穿过的生物受到相当于消耗魔力值 ×0.12 的伤害，并被带向落点；'
          '落点 3 格内的生物受到相当于消耗魔力值 ×0.06 的伤害并被向外击退 2 格。'
          '落地后 2 秒内自身获得迅捷Ⅱ。'
          '若落点脚下没有可站立的方块，则改为原地施放并返还一半魔力值。'),
    ]),
    dict(id='breathing_soil', name='息土', rarity='史诗', kind='胸甲', color='green', segs=[
        HEAD('✦ 被动技能'),
        S('自身生命值降至最大生命值 30% 以下时，召唤一个术阵，之后召唤一个半径 8 格的领域，'
          '持续 12 秒。该效果 60 秒内最多触发一次。\n\n'
          '在领域中自身每秒恢复 3 点生命值；每次受到伤害时恢复 1 点生命值，'
          '该效果 2 秒内最多触发一次。'),
    ]),
    dict(id='cage_day', name='囚昼', rarity='史诗', kind='法杖', color='dark_purple', segs=[
        HEAD('✦ 普攻'), INFO(('魔力', '60'), ('伤害', '自身最大魔力值 ×0.025')),
        HEAD('✦ 主动技能'), INFO(('魔力', '240'), ('冷却', '45 秒')),
        S('潜行时使用后，选中自身 8 格内最近的一个敌对生物，使其附加「白昼梦」，持续 8 秒，'
          '并对其 5 格内的全部生物造成相当于自身最大魔力值 ×0.12 的伤害。'
          '若选中的生物已附有「白昼梦」，则该次伤害提高 30%，'
          '并将其「白昼梦」扩散给 5 格内最近的另外三个生物。'),
    ]),
    dict(id='way_back', name='归途', rarity='史诗', kind='剑', color='gold', segs=[
        HEAD('✦ 主动技能'), INFO(('魔力', '240'), ('冷却', '40 秒')),
        S('使用后在脚下放下一盏“归途灯”，持续 20 秒（冷却时间从放下灯时开始计算）。'
          '期间再次使用该技能，立即瞬移回“归途灯”处，'
          '并恢复这 20 秒内自身所受到伤害的 50%（最多恢复最大生命值的 40%）。'
          '若灯存在期间自身生命值从未低于 50%，则瞬移后额外获得 3 秒迅捷Ⅱ。'),
    ]),
    dict(id='stop_needle', name='停针', rarity='史诗', kind='法杖', color='light_purple', segs=[
        HEAD('✦ 普攻'), INFO(('魔力', '60'), ('伤害', '自身最大魔力值 ×0.02')),
        HEAD('✦ 主动技能'), INFO(('魔力', '260'), ('冷却', '45 秒')),
        S('使用后选中自身 5 格内最近的最多 5 个生物。'
          '若选中至少 3 个，则使其时停 2 秒，每个目标使自身全部技能的冷却时间减少 2 秒（最多 10 秒）。'
          '若不足 3 个，则仅使自身获得 3 秒迅捷Ⅱ，不施加时停，也不减少冷却。'),
    ]),
    dict(id='empty_seat', name='虚位', rarity='史诗', kind='剑', color='white', segs=[
        HEAD('✦ 被动技能'),
        S('每个空置的术阵位，使自身每次普通攻击额外造成 4 点固定伤害。'),
        HEAD('✦ 主动技能'), INFO(('魔力', '220'), ('冷却', '35 秒')),
        S('使用后清空自身全部术阵位，对前方 3 格内的全部生物'
          '造成（6 × 清空的术阵位数）点固定伤害，并使其获得 5 秒虚弱Ⅱ。'),
    ]),
    # ---------------- 铁（开局）----------------
    dict(id='bind_ember', name='缚烬', rarity='稀有', kind='斧', color='red', segs=[
        HEAD('✦ 被动技能'),
        S('自身对同时附有「流火」且处于缓慢状态的生物造成的伤害提高 50%。'),
        HEAD('✦ 主动技能'), INFO(('魔力', '260'), ('冷却', '50 秒')),
        S('使用后向前方劈出一道 4 格长、120 度的扇形斧痕，'
          '对范围内全部生物造成相当于自身基础攻击力 ×6 的伤害，'
          '并使其附加「流火」、获得缓慢Ⅱ，持续 3 秒。'
          '每当有生物新获得「流火」时，自身所有技能的冷却时间减少 1 秒。'),
    ]),
    dict(id='sunken_weight', name='沉砣', rarity='稀有', kind='斧', color='dark_gray', segs=[
        HEAD('✦ 被动技能'),
        S('每次命中额外造成 4 点固定伤害（不参与任何加成）。'),
        HEAD('✦ 砣'),
        S('每次命中获得 1 层「砣」，最多 5 层。每层「砣」使该固定伤害 +2 点，'
          '并使自身移动速度降低 4%。自身受到任何伤害时，「砣」立即清零。'),
        HEAD('✦ 主动技能'), INFO(('魔力', '180'), ('冷却', '30 秒')),
        S('消耗全部「砣」，对前方 4 格内的全部生物造成（10 × 层数）点固定伤害，'
          '并使其获得缓慢Ⅱ，持续（层数）秒。'),
    ]),
    # ---------------- 未分档（弩 / 副手）----------------
    dict(id='night_bind', name='夜缚', rarity='稀有', kind='弩', color='dark_purple', segs=[
        HEAD('✦ 主动技能'), INFO(('魔力', '80')),
        S('每次射击命中了附有「夜火」的生物后，额外对其造成一次'
          '相当于自身基础攻击力 ×5 的伤害，并使其获得缓慢Ⅱ，持续 4 秒；'
          '箭矢随后从其身上弹向 6 格内最近的另一个敌对生物，造成该次额外技能伤害数值 60% 的伤害。'
          '该效果不消耗「夜火」。'),
    ]),
    dict(id='sip_frost', name='饮霜', rarity='稀有', kind='副手', color='aqua', segs=[
        HEAD('✦ 被动技能'),
        S('持于副手时，自身每恢复 10 点生命值，便使自身 5 格内最近的 2 个生物'
          '获得 3 秒缓慢Ⅱ。该效果 4 秒内最多触发一次。'),
    ]),
    dict(id='retro_shine', name='反照', rarity='稀有', kind='副手', color='light_purple', segs=[
        HEAD('✦ 被动技能'),
        S('持于副手时，自身受到生物造成的伤害后，对伤害来源造成该次伤害 30% 的真实伤害，'
          '每次最多 12 点，每 2 秒最多触发一次。若伤害来源不是生物，则不触发。'),
    ]),
    # ---------------- 铁 · 法杖（未分档底材）----------------
    dict(id='pour_sack', name='倾囊', rarity='稀有', kind='法杖', color='yellow', segs=[
        HEAD('✦ 普攻'), INFO(('魔力', '60'), ('伤害', '12')),
        HEAD('✦ 主动技能'), INFO(('魔力', '当前魔力值的 40%'), ('冷却', '20 秒')),
        S('当前魔力值不足 60 时无法施放。使用后把消耗的魔力压成一枚钉子射出，'
          '命中 10 格内最近的一个生物，每 5 点消耗魔力转化为 1 点固定伤害。'
          '若本次消耗的魔力不低于 120，则再对其 2 格内的全部生物造成一半的固定伤害。'),
    ]),
]


def base_of(rarity, cat, slot):
    if cat == 'bow':
        return 'crossbow'
    if cat in ('staff', 'tool'):
        return 'recovery_compass'
    t = TIER[rarity]
    if cat == 'armor':
        return '%s_%s' % (t, slot)
    return '%s_%s' % (t, cat)


def model_key(cat, cid):
    if cat == 'armor':
        return 'armor_' + cid
    if cat == 'bow':
        return 'crossbow_' + cid
    if cat == 'tool':
        return 'tool_' + cid
    return cid


def has_cooldown(segs):
    for kind, p in segs:
        if kind == 'info' and any(lab == '冷却' for lab, _v in p):
            return True
    return False


def build(it, cat, slot, base):
    cid = it['id']
    zx = [cid]
    if cat == 'armor':
        zx += [slot, 'armor']
    elif cat == 'bow':
        zx += ['bow']
    elif cat == 'tool':
        zx += ['tool']                       # ★ 包内 10/12 件是两元素
    else:
        zx += [cat, 'itemreplace']
    zx_txt = json.dumps(zx, ensure_ascii=False, separators=(',', ':'))
    if cat in RIGHT_CLICK and has_cooldown(it['segs']):
        zx_txt += ',skill:"sweetdream:%s"' % cid

    _tags = TAGS.get(cid) or []
    if not _tags:
        raise SystemExit('[错误] %s 没在 _tags_data.py 的 TAGS 里登记' % cid)
    zx_txt += ',tags:%s' % json.dumps(_tags, ensure_ascii=False, separators=(',', ':'))

    parts = ['item_name={text:"%s",bold:true,color:%s}' % (it['name'], it['color'])]
    lore = lore_fmt.rebuild(build_lore(it['segs']), width=37)
    parts.append('lore=' + json.dumps(lore, ensure_ascii=False, separators=(',', ':')))
    parts.append('unbreakable={}')
    parts.append('custom_data={zx:%s}' % zx_txt)
    if cat in RIGHT_CLICK:
        parts.append(CONSUMABLE)
    mechanisms = {'lianshi', 'tiejili', 'night_bind', 'retro_shine', 'bind_ember'}
    if cid in mechanisms:
        parts.append('enchantments={"sweetdream:%s":1}' % cid)
        parts.append('enchantment_glint_override=false')
        parts.append('tooltip_display={hidden_components:["unbreakable","enchantments"]}')
    else:
        parts.append('tooltip_display={hidden_components:["unbreakable"]}')
    if cat in ('staff', 'tool'):
        parts.append('max_stack_size=1')     # ★ 包内 22/22 法杖、12/12 副手都带
    if MODEL:
        parts.append('item_model="sweetdream:%s"' % model_key(cat, cid))
        if cat == 'armor':
            parts.append('equippable={slot:"%s",asset_id:"sweetdream:armor_%s"}' % (slot, cid))
    return 'give @s %s[%s]' % (base, ','.join(parts))


def header(it, cat, slot, base):
    cat_cn = {'sword': '剑', 'axe': '斧', 'bow': '弩', 'staff': '法杖',
              'armor': '盔甲', 'tool': '副手'}[cat]
    heads = [p for k, p in it['segs'] if k == 'head']
    A = []
    A.append('# ============================================================')
    A.append('# sweetdream:equipment/%s/%s/give —— 给一件「%s」（%s · %s）'
             % (cat, it['id'], it['name'], it['rarity'], cat_cn))
    A.append('# ------------------------------------------------------------')
    A.append('# 【custom_data】')
    A.append('#   "%s" -> 装备 id, 进度 / 被动判定靠它认人' % it['id'])
    A.append('#   ★ 判定一律写成 custom_data~{zx:["%s"]}(部分匹配 + 独有标记)' % it['id'])
    A.append('#   ★ 语义标签 = custom_data.tags(词表/逐件表见 .workbuddy/_tags_data.py)')
    A.append('# 【描述构成】%s' % ' ｜ '.join(heads))
    if cat in ('bow', 'staff', 'tool'):
        A.append('# 【底材】%s（未分档：这类装备的底物没有材质档）' % base)
    else:
        A.append('# 【底材】%s（%s = %s）—— 本包的"阶段"只由底材判定'
                 % (base, it['rarity'], TIER[it['rarity']]))
    A.append('#')
    A.append('# 【这个文件是生成的】改描述请改 .workbuddy/_gen_batch18.py 的 LORE、改标签请改')
    A.append('#   .workbuddy/_tags_data.py，然后重跑本生成器 + `python .workbuddy/lore_fmt.py --write`。')
    if not MODEL:
        A.append('# 【外观】★ 尚未做 —— 所以**故意不挂 item_model**。挂上会指向不存在的')
        A.append('#   assets/sweetdream/items/%s.json ⇒ 紫黑方块且零日志（坑 195）。' % model_key(cat, it['id']))
        A.append('#   补外观的顺序：_gen_late_icons.py 出贴图 -> _gen_late_rp.py 接线 -> 本文件 MODEL=True。')
    if cat == 'bow' and it['id'] not in {'lianshi', 'tiejili', 'night_bind'}:
        A.append('# ★ 弩的命中结算要靠 sweetdream:%s 附魔的 post_attack 回调（坑 138）。' % it['id'])
        A.append('#   本批**只做 give、没建 enchantment/*.json** ⇒ 现在**不能挂 enchantments**')
        A.append('#   （挂不存在的附魔 id 会让整条 give 解析失败）。等技能批次建好附魔再补，')
        A.append('#   那时还要 `enchantment_glint_override=false` 并在 tooltip 里藏掉 enchantments。')
    if cat == 'armor':
        A.append('# ★ 盔甲本批不挂 equippable（外观层 armor_<id>.json 还没做，asset_id 会悬空）。')
        A.append('#   穿戴效果与触发逻辑仍可正常工作，只是外观是原版底材。')
    A.append('# ============================================================')
    A.append('')
    return '\n'.join(A)


def main():
    n = 0
    for it in LORE:
        cat = KIND_CAT[it['kind']]
        slot = KIND_SLOT.get(it['kind'])
        base = base_of(it['rarity'], cat, slot)
        d = os.path.join(BASE, cat, it['id'])
        os.makedirs(d, exist_ok=True)
        p = os.path.join(d, 'give.mcfunction')
        txt = header(it, cat, slot, base) + build(it, cat, slot, base) + '\n'
        io.open(p, 'w', encoding='utf-8', newline='\n').write(txt)
        n += 1
        print('%-44s %-6s %-6s %s' % ('equipment/%s/%s' % (cat, it['id']),
                                      it['name'], it['rarity'], base))
    print('---- 共 %d 件（MODEL=%s）' % (n, MODEL))


if __name__ == '__main__':
    main()
