# -*- coding: utf-8 -*-
"""从 build_vanilla_armor.P 生成 配色对照表.md"""
import os
import sys
sys.path.insert(0, r'D:\数据包\.workbuddy')
from build_vanilla_armor import P, SLOT_CN, spec_of   # noqa: E402

OUT = r'D:\数据包\模型设计\原版风_盔甲_20261010\配色对照表.md'
MAT_CN = {'iron': '铁', 'diamond': '钻石', 'netherite': '下界合金'}


def hxstr(c):
    return '#%02X%02X%02X' % c[:3]


lines = []
lines.append('# 原版风 · 盔甲 25 件 · 配色对照表')
lines.append('')
lines.append('> 生成器：`.workbuddy/build_vanilla_armor.py` ｜ 预览：同目录 `预览_<槽位>.png` · `总览_25件.png`')
lines.append('>')
lines.append('> **形状**：alpha 掩码逐像素照抄该件所用的**原版底物**（图标＝原版盔甲物品贴图；穿戴层＝原版 `entity/equipment/humanoid[_leggings]`，64×32）。')
lines.append('> **明暗**：读原版每像素亮度 → 线性映射到下表色阶；原版描边/受光面/暗面结构原样保留，只换色相与材质。')
lines.append('> **配色依据**：逐件读 `give.mcfunction` 的技能原文（意象 + 名字颜色），不凭空配。')
lines.append('')
lines.append('| # | 件名 | 槽位 | 原版底物 | 色阶（暗 → 亮） | 依据（技能意象） |')
lines.append('|---|---|---|---|---|---|')
for i, p in enumerate(P, 1):
    ramp = ' '.join('`%s`' % hxstr(c) for c in p['ramp'])
    lines.append('| %d | **%s** | %s | %s·%s | %s | %s |'
                 % (i, p['cn'], SLOT_CN[p['slot']], MAT_CN[p['mat']],
                    {'helmet': '头盔', 'chestplate': '胸甲', 'leggings': '护腿', 'boots': '靴子'}[p['slot']],
                    ramp, p['motif']))
lines.append('')
lines.append('## 入包后的对应关系（已实装）')
lines.append('')
lines.append('| 件名 | 装备 id | `item_model` | `equippable.asset_id` | 穿戴层目录 |')
lines.append('|---|---|---|---|---|')
for p in P:
    lines.append('| %s | `%s` | `sweetdream:armor_%s` | `sweetdream:armor_%s` | `%s` |'
                 % (p['cn'], p['id'], p['id'], p['id'],
                    'humanoid_leggings' if p['slot'] == 'leggings' else 'humanoid'))
lines.append('')
lines.append('## 同色系说明')
lines.append('')
lines.append('- **聚魔头盔 / 聚魔胸甲** 共用一条色阶（同一套装的二件套），刻意做成一套。')
lines.append('- **脑髓蛭 / 脊骨共生**、**焚舟(cam)/余烬**、**异彩 / 幻昼**、**黄昏黎明之交界 / 群星坠落之挽歌**')
lines.append('  这四组是**套装**，但各件意象不同，故各留独立色阶（同族但可区分）。')
lines.append('')
lines.append('## 元素叠加（tint —— 原版轮廓上再手绘一层具体元素）')
lines.append('')
lines.append('> `build_vanilla_armor.py` 的 `apply_tint()`：在整件换色阶之后逐像素覆盖，'
             '用来画"这件独有"的元素；透明像素不动。')
lines.append('')
lines.append('| 件名 | 叠加元素 | 图标坐标 | 穿戴层坐标 |')
lines.append('|---|---|---|---|')
lines.append('| **脊骨共生** | 骨白脊椎 + 三对肋骨 | 脊椎 x7-8·y5-13；肋 y6/9/12 | 正面 (20,20)-(27,31)：脊椎 x23-24；肋 y24/27/30 |')
lines.append('| **狄俄尼索斯之桂冠** | 前额 V 形月桂叶冠（绿）+ 酒神葡萄串（紫）+ 冠顶金叶 | 叶带 (3,5)(4,5)(5,6)(6,6)(7,7)(8,7)(9,6)(10,6)(11,5)(12,5) | 头部正面 (8,8)-(15,15) 叶带 (8,8)(9,8)(14,8)(15,8)(10,9)(13,9)(11,10)(12,10) + 顶面环 |')
lines.append('| **异彩** | 全光谱虹彩（色相随位置扫满一圈，明度沿用原版明暗） | 以穹顶为中心 k=0.030 | 斜向 k=0.013（各面呈不同色相） |')
lines.append('')
lines.append('## 第二轮调整（用户反馈后 · 2026-10-10 已定稿）')
lines.append('')
lines.append('| 件名 | 调整前 → 调整后（**定稿**） |')
lines.append('|---|---|')
lines.append('| **焚舟** | 青铜褐 → **焦木甲板上烧起的红金烈焰**（色相更红更热 + 白热高光） |')
lines.append('| **体外供能装置** | 中紫 → **能量青绿整支**（暗青绿钢壳 + 青辉；高光一点紫色＝能量指示灯） |')
lines.append('| **幻昼** | 军绿卡其（违和）→ **柔珍珠白 + 冷星辉** |')
lines.append('| **脊骨共生** | 底色紫加深、骨白提亮；**新增脊椎 + 肋骨元素** |')
lines.append('| **狄俄尼索斯之桂冠** | **新增月桂叶冠 + 葡萄串**（希腊·酒神元素） |')
lines.append('| **异彩** | 单色渐变 → **全光谱虹彩**（重点突出「异彩」） |')
lines.append('')
with open(OUT, 'w', encoding='utf-8') as f:
    f.write('\n'.join(lines))
print('->', OUT)
