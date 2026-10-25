# -*- coding: utf-8 -*-
"""_gen_batch17.py —— 批一「阶段补全 10 件」的 give.mcfunction 生成器。

【范围】用户 2026-10-20 定："现在先做 give"。
  ⇒ 本批**只做 give**（名字 / 描述 / 底材 / custom_data / 标签），
    技能函数 / 进度记账 / 图标 / item_model 全部留后续批次 ——
    与批 14 的口径一致（当时也是"先 give，外观与效果等一会再做"）。

【★ 为什么这批**不挂 item_model**】
  批 16（10-18）之前，包内 140 件已经全都有 item_model（指向
  `assets/sweetdream/items/<key>.json`）。新 10 件还没有画图标，
  一旦挂上就指向不存在的 items 定义 ⇒ 游戏里是**紫黑方块**，且零日志（坑 195）。
  ⇒ 现在不挂：游戏里显示底材原版贴图（铁剑/钻靴/下界合金胸甲…）。
  ★ 补外观的顺序固定：`_gen_late_icons.py` 出贴图 -> `_gen_late_rp.py` 接线
    （items/models/equipment）-> 再回到本文件打开 MODEL=True 重跑。

【★ 弩在本批**不挂 enchantments**】
  弩没有右键/consumable，命中结算全靠 `sweetdream:<id>` 附魔的 post_attack
  三回调（坑 138）。本批不建 enchantment/*.json 与 advancement，所以**不能挂** ——
  挂一个不存在的附魔 id 会让整条 give 解析失败。
  等技能批次建好附魔文件再回来补 `enchantments` + `enchantment_glint_override=false`。

【描述真源】本文件 LORE（已按包内口径写好正文：× 乘号 / 汉字半角留白 /
  罗马数字 / 状态「」/ 召唤物“”/ 领域不加括号）。
  编成 lore 组件后交给 `lore_fmt.rebuild(width=37)`，与包内其它装备逐字同规。

【标签真源】`.workbuddy/_tags_data.py` 的 TAGS（单一真源），本文件只取用。
  ★ 新增件必须先登记 TAGS，否则 custom_data 里没有 tags 字段（标签体系里查不到）。

【底材 = 阶段】(用户 10-07 定，10-11 补"稀有 = 铁")
  铁 / 钻 / 下界三档就是阶段，包内没有 rarity 字段、也没有 recipe —— 阶段只看底材。
    铁 -> iron_*    钻 -> diamond_*    下界 -> netherite_*
  弩固定 crossbow（不分档）。

【zx 约定（照 batch5/6/7/new42）】
  剑/斧 = [<id>,<cat>,"itemreplace"]；弩 = [<id>,"bow"]；
  盔甲 = [<id>,<slot>,"armor"]（无 skill、无 consumable）。
  带冷却的剑/斧才写 skill:"sweetdream:<id>"（观测镜靠它显示 CD）。

【用法】
  python .workbuddy/_gen_batch17.py
  python .workbuddy/lore_fmt.py --write          # 规范化折行（连跑两遍，第二遍 0 变化）
  python .workbuddy/_gen_give_all.py             # 重排最末两盒
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
# 批一 10 件（顺序照总稿 §4：开局 3 -> 过渡 5 -> 终端 2）
# ============================================================
LORE = [
    # ---------------- 开局档（铁）----------------
    dict(id='yebu', name='曳步', rarity='稀有', kind='剑', color='gray', segs=[
        HEAD('✦ 被动技能'),
        S('每次普通攻击命中后，使其获得 4 秒缓慢Ⅰ。若其此时已处于缓慢状态，'
          '则改为使其获得 3 秒缓慢Ⅱ。对同一个生物 4 秒内只能升级一次。'),
    ]),
    dict(id='xiugou', name='锈犬', rarity='稀有', kind='斧', color='gold', segs=[
        HEAD('✦ 主动技能'), INFO(('魔力', '90'), ('冷却', '32 秒')),
        S('使用后在自身身前 2 格召唤“锈犬”，持续 10 秒。'
          '锈犬每秒撕咬自身 3 格内最近的一个生物，造成一次等同于自身基础攻击力的伤害，'
          '最多撕咬 10 次。同一时间只能存在一只“锈犬”，再次使用时先收回原有的。'),
    ]),
    dict(id='zhuzu', name='驻足', rarity='稀有', kind='靴子', color='aqua', segs=[
        HEAD('✦ 被动技能'),
        S('受到伤害后开始计时。若 1.5 秒内没有移动，则在脚下展开半径 3 格的领域，持续 10 秒。'
          '领域内的生物每秒受到 5 点固定伤害，并获得 1 秒缓慢Ⅰ。自身移动即收起领域。'
          '该效果 30 秒内最多触发一次。'),
    ]),
    # ---------------- 过渡档（钻石 / 弩）----------------
    dict(id='gousi', name='钩丝', rarity='史诗', kind='剑', color='dark_aqua', segs=[
        HEAD('✦ 主动技能'), INFO(('魔力', '180'), ('冷却', '28 秒')),
        S('使用后选中自身 8 格内最近的一个生物，以每 0.25 秒 0.5 格的速度将其拉向自身，'
          '最多拉动 6 格，在抵达身前 2 格或撞上不可替换的方块时停下。'
          '拉到位置后，使其获得 3 秒缓慢Ⅱ，并对其造成一次相当于自身最大魔力值 ×0.12 的伤害，'
          '同时使自身下一次以最大魔力值为基准的技能伤害 +10%。'
          '若中途未能拉到，则改为造成一次相当于自身最大魔力值 ×0.04 的伤害，且不获得加成。'),
    ]),
    dict(id='lianshi', name='连矢', rarity='稀有', kind='弩', color='yellow', segs=[
        HEAD('✦ 主动技能'), INFO(('魔力', '120')),
        S('每次射击命中后，若命中位置 4 格内存在另一个生物，则箭矢弹向其中一个，'
          '对其造成一次相当于自身当前魔力值 ×0.15 的伤害（已扣除本次射击消耗）。'
          '每支箭最多弹射一次。'),
    ]),
    dict(id='tiejili', name='铁蒺藜', rarity='稀有', kind='弩', color='gray', segs=[
        HEAD('✦ 主动技能'), INFO(('魔力', '150')),
        S('每次射击命中后，在箭矢落点撒下半径 2.5 格的蒺藜，持续 5 秒。'
          '蒺藜内的生物每秒受到一次等同于自身基础攻击力的伤害，并获得 2 秒缓慢Ⅱ。'
          '离开蒺藜后减速立刻消失。'),
    ]),
    dict(id='lvshuang', name='履霜', rarity='史诗', kind='靴子', color='aqua', segs=[
        HEAD('✦ 被动技能'),
        S('每移动 1 格，在脚下留下一片霜，最多同时存在 6 片，每片持续 5 秒。'
          '生物踩到霜时获得 2 秒缓慢Ⅱ；自身踩到霜时获得 2 秒迅捷Ⅰ，且不消耗该片霜。'),
    ]),
    dict(id='dongtu', name='冻土', rarity='史诗', kind='靴子', color='blue', segs=[
        HEAD('✦ 被动技能'),
        S('站立不动 1.5 秒后获得「冻土」：获得抗性提升Ⅰ，并每秒恢复自身 3% 最大生命值，'
          '最多持续 6 秒。移动后「冻土」立刻中断，并从此刻起 20 秒内不能再次获得。'),
    ]),
    # ---------------- 终端档（下界）----------------
    dict(id='huilan', name='回澜', rarity='传说', kind='胸甲', color='dark_aqua', segs=[
        HEAD('✦ 被动技能'),
        S('每次受到伤害时记录该次伤害。若 3 秒内没有再次受到伤害，'
          '则恢复该次伤害 50% 的生命值（保底 4 点）。'
          '若 3 秒内再次受到伤害，则覆盖上一次的记录，永远只结算最后一次。'),
    ]),
    dict(id='chengxing', name='秤星', rarity='传说', kind='剑', color='gold', segs=[
        HEAD('✦ 被动技能'),
        S('每次普通攻击额外附带一次固定伤害，数值为（自身护甲韧性 + 自身护甲值）×2，'
          '该伤害不受任何加成影响。'),
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
    A.append('#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)')
    A.append('# 【描述构成】%s' % ' ｜ '.join(heads))
    A.append('# 【底材】%s（%s = %s）—— 本包的"阶段"只由底材判定' % (base, it['rarity'], TIER[it['rarity']]))
    A.append('#')
    A.append('# 【这个文件是生成的】改描述请改 .workbuddy/_gen_batch17.py 的 LORE、改标签请改')
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
