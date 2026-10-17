# -*- coding: utf-8 -*-
"""_gen_new42.py —— 生成批 14「NEW.md 42 件」的 give.mcfunction。

【范围】用户 2026-10-15 定："现在全做一下 give 并接入 giveall"。
  ⇒ 本批**只做 give**（物品本体：名字 / 描述 / 底材 / custom_data / 标签），
    技能机制 / 进度记账 / updef / 超限石 / 资源包外观 全部留后续批次 ——
    与批 7 / 11 的口径一致（"先做好 give，效果等一会再做"）。
  ⇒ 因此**不挂 item_model**（外观没做，挂了会引用不存在的 items/<id>.json
    ⇒ 游戏里显示缺失模型紫黑方块）。物品先显示为其底材的原版外观。
    好消息：`visual/*_icon_held` 的自动补绑名单是**按 id 逐条枚举**的（不是通配），
    新 id 不在名单里，所以不会被自动写上不存在的模型。

【描述真源】`.workbuddy/_new42_lore.py` 的 ITEMS[].segs（已按包内口径写好正文：
  × 乘号 / 汉字半角留白 / 罗马数字 / 状态「」/ 召唤物“”/ 领域不加括号…）。
  本文件只把 segs 编成 lore 组件，再交给 `lore_fmt.py --write` 统一折行（宽 37）。
  ★ 改描述请改 _new42_lore.py，别改这里。

【标签真源】`.workbuddy/_tags_data.py` 的 TAGS（批 A 的单一真源）。
  本文件从那里取 tags，写进 custom_data.tags。

【稀有度 -> 底材】(用户 2026-10-07 定；2026-10-11 补"稀有 = 铁"；10-15 沿用)
  罕见 = 铁 / 稀有 = 铁 / 史诗 = 钻石 / 传说 = 下界合金 / 禁忌 = 下界合金
  弩底座固定 crossbow；法杖与副手底座固定 recovery_compass（能堆 -> 加 max_stack_size=1）。

【zx 约定（照 batch5/6/7）】
  custom_data.zx = [<id>, <分类标记>, <"itemreplace"(剑/斧/法杖 —— 本包武器标记)>]
  弩 = [<id>,"bow"]（无 itemreplace）；盔甲 = [<id>,<部位>, "armor"]；副手 = [<id>,"tool"]
  带 冷却 的才有 skill:"sweetdream:<id>"（观测镜/清冷却靠它显示）。

【★ 2026-10-15 批 15-1 的改动：4 把弩开始挂 enchantments ★】
  批 15-1（弩 4 件：feather_sleep / ember_string / reverse_string / dark_sun）接上了命中
  结算 —— 弩没有右键/consumable，全靠附魔 post_attack 三回调（hook_arrow / hook_attacker /
  hook_victim；坑 138：回调只读**攻击者主手物品**上的附魔）。所以 `cat == 'bow'` 的 give
  现在会写 `enchantments={"sweetdream:<id>":1}` + `enchantment_glint_override=false`，
  并在 tooltip_display 里同时藏掉 "enchantments"。
  ★ 附魔是**注册表**内容：首次加载须**退世界重进**（坑 153）；旧件须**重新 give**（坑 144）。
"""
import io
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import _new42_lore as SRC          # noqa: E402  描述真源
from _tags_data import TAGS        # noqa: E402  标签单一真源

BASE = r'D:\数据包\sweetdream\data\sweetdream\function\equipment'

# 类别（目录）与部位
KIND_CAT = {'剑': 'sword', '斧': 'axe', '弩': 'bow', '法杖': 'staff', '副手': 'tool',
            '头盔': 'armor', '胸甲': 'armor', '护腿': 'armor', '靴子': 'armor'}
KIND_SLOT = {'头盔': 'helmet', '胸甲': 'chestplate', '护腿': 'leggings', '靴子': 'boots'}

# 稀有度 -> 材料档（铁 / 钻石 / 下界合金）
TIER = {'罕见': 'iron', '稀有': 'iron', '史诗': 'diamond', '传说': 'netherite', '禁忌': 'netherite'}


def base_of(rarity, cat, slot):
    t = TIER[rarity]
    if cat == 'bow':
        return 'crossbow'
    if cat in ('staff', 'tool'):
        return 'recovery_compass'
    if cat == 'armor':
        return '%s_%s' % (t, slot)
    return '%s_%s' % (t, cat)          # sword / axe


RIGHT_CLICK = ('sword', 'axe', 'staff')
CONSUMABLE = ('consumable={animation:"none",consume_seconds:0,'
              'has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}')


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
        zx += [cat]
        zx.append('itemreplace')       # 剑/斧/法杖 = 本包武器标记（照 batch6/7）
    zx_txt = json.dumps(zx, ensure_ascii=False, separators=(',', ':'))
    if cat in RIGHT_CLICK and has_cooldown(it['segs']):
        zx_txt += ',skill:"sweetdream:%s"' % cid

    parts = []
    # ★ 刻意不挂 item_model（外观批次再补；见文件头）。
    parts.append('item_name={text:"%s",bold:true,color:%s}' % (it['name'], it['color']))
    lore = SRC.build_lore(it['segs'])
    parts.append('lore=' + json.dumps(lore, ensure_ascii=False, separators=(',', ':')))
    parts.append('unbreakable={}')
    hide = ['unbreakable']
    # ★ 弩**必须**挂自己的附魔（2026-10-15 批 15-1 接上的）——
    #   弩的命中结算全靠 enchantment 的 post_attack 三回调（hook_arrow / hook_attacker /
    #   hook_victim），没有右键/consumable（坑 138：回调只读**攻击者主手物品**上的附魔）。
    #   漏了它 = 整把弩"射得出去、什么都不发生"，而且零日志。
    #   ⇒ 4 把弩（feather_sleep / ember_string / reverse_string / dark_sun）的
    #     enchantment/*.json 与 advancement/equipment/bow/*.json 已在 15-1 一并创建。
    #   ★ 附魔属于**注册表**内容：第一次加载（或改动它）之后要**退出世界再进**，
    #     光 /reload 不够（坑 153）。
    #   ★ enchantment_glint_override=false + tooltip 里藏掉 "enchantments"：
    #     让附魔生效但不显示附魔名/紫色光效（与既有 10 把弩同一套写法）。
    if cat == 'bow':
        parts.append('enchantments={"sweetdream:%s":1}' % cid)
        parts.append('enchantment_glint_override=false')
        hide.append('enchantments')
    cd_txt = 'zx:%s' % zx_txt
    _tags = TAGS.get(cid) or []
    if _tags:
        cd_txt += ',tags:%s' % json.dumps(_tags, ensure_ascii=False, separators=(',', ':'))
    parts.append('custom_data={%s}' % cd_txt)
    if cat in RIGHT_CLICK:
        parts.append(CONSUMABLE)
    parts.append('tooltip_display={hidden_components:[%s]}'
                 % ','.join('"%s"' % h for h in hide))

    pre = ''
    if cat in ('staff', 'tool'):
        pre += 'max_stack_size=1,'
    return 'give @s %s[%s%s]' % (base, pre, ','.join(parts))


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
    A.append('# 【底材】%s（%s = %s）' % (base, it['rarity'], TIER[it['rarity']]))
    A.append('#')
    A.append('# 【这个文件是生成的】改描述请改 .workbuddy/_new42_lore.py、改标签请改')
    A.append('#   .workbuddy/_tags_data.py，然后重跑本生成器 + `python .workbuddy/lore_fmt.py --write`。')
    A.append('# ★ 批 14（2026-10-15 用户定）**只做 give**：技能 / 进度 / updef / 超限石 /')
    A.append('#   外观 等留后续批次；因此**不挂 item_model**（外观未做，挂了会引用不存在的')
    A.append('#   模型 -> 游戏里显示紫黑方块）。物品先显示为底材的原版外观。')
    if cat == 'bow':
        A.append('# ★ 弩的命中结算要靠 sweetdream:%s 附魔的 post_attack 回调（坑 138：回调' % it['id'])
        A.append('#   只读**攻击者主手物品**上的附魔）=> **必须挂 enchantments**；漏了它整把弩')
        A.append('#   会"射得出去、什么都不发生"且零日志。')
        A.append('#   ★ 附魔属于**注册表**内容：第一次加载（或改动它）之后要**退出世界再进**，')
        A.append('#     光 /reload 不够（坑 153）；改动前发出的旧件也要**重新 give**（坑 144）。')
        A.append('#   ★ enchantment_glint_override=false + tooltip 里藏掉 enchantments：')
        A.append('#     让附魔生效但不显示附魔名与紫色光效（与既有 10 把弩同一套写法）。')
    if cat == 'armor':
        A.append('# ★ 盔甲同样不挂 item_model / equippable（外观未做）；底材自带原版')
        A.append('#   equippable，穿戴与护甲值照常。visual/armor_icon_held 的补绑名单是**按')
        A.append('#   id 枚举**的，本件不在名单里 => 不会被自动写上不存在的模型。')
    A.append('# ============================================================')
    A.append('')
    return '\n'.join(A)


def main():
    n = 0
    for it in SRC.ITEMS:
        cat = KIND_CAT[it['kind']]
        slot = KIND_SLOT.get(it['kind'])
        base = base_of(it['rarity'], cat, slot)
        d = os.path.join(BASE, cat, it['id'])
        os.makedirs(d, exist_ok=True)
        p = os.path.join(d, 'give.mcfunction')
        txt = header(it, cat, slot, base) + build(it, cat, slot, base) + '\n'
        io.open(p, 'w', encoding='utf-8', newline='\n').write(txt)
        n += 1
        print('%-42s %-8s %-6s %s' % ('equipment/%s/%s' % (cat, it['id']),
                                     it['name'], it['rarity'], base))
    print('---- 共 %d 件' % n)


if __name__ == '__main__':
    main()
