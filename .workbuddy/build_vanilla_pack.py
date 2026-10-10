# -*- coding: utf-8 -*-
"""
build_vanilla_pack.py —— 组装「原版风」覆盖资源包

产出：D:\\数据包\\sweetdream_rp_原版风\\            （源）
部署：versions/1.21.5-Fabric 0.16.10/resourcepacks/sweetdream_rp_原版风\\  （--deploy）

本包含**五组**内容：
  ① 覆盖组 `ITEMS` —— 替换 sweetdream_rp 里**已有的独立 3D 模型**（4 件）。
  ② 新增组 `ADD`   —— 底物是原版剑、老包里**没有**独立定义的武器
     （13 件剑 = 12 件平面图标 + 火种两态）。
  ③ 新增组 `AXES`  —— 同上，但是斧（14 件）。
  ④ 新增组 `ARMOR` —— 25 件盔甲（图标 16×16 + 穿戴层 64×32 + 装备定义）。
  ⑤ 新增组 `TOOLS` —— 7 件「副手 · 被动」道具（底物 = 原版回响罗盘，图标 16×16）。

★★ 新增组的每一件都必须同时有**数据包侧的驱动**，否则定义放在这儿永远不会被用上：
    · 12 件剑 → give 里直接写 item_model；老物品靠
      `sweetdream:visual/sword_icon_sync`（每秒）兜底修一次。
    · 14 件斧 → 同构，靠 `sweetdream:visual/axe_icon_sync`（每秒）。
    · 25 件盔甲 → give 里写 item_model + equippable；
      `sweetdream:visual/armor_icon_sync`（每秒）兜底。
    · 7 件副手 → give 里写 item_model；`sweetdream:visual/tool_icon_sync`（每秒）兜底。
    · 火种     → give 里**不写** item_model，全靠
      `equipment/sword/tinder/visual/sync` 按 zx.td_on 在两态之间切。
   改完记得 `_deploy.py --apply` 把数据包推过去。

设计：**覆盖层**。老包 `sweetdream_rp` 一个字节都不改；把它排在老包**之上**即可切换。
合并版 `sweetdream_rp_完整版` 由 `build_full_pack.py` 从本目录整份取（见该脚本）。

★★ 每条 items 定义必须带 "hand_animation_on_swap": false
    数据包每刻/每秒用 `item modify`（item_modifier/*.json）改写物品的 item_model 组件。
    若关掉「换手动画」的开关缺失，客户端会把组件刷新当成「换了一件物品」
    → 每刻播一次举手动画 → 手上一直抽搐。（sweetdream_rp 里 11 件的定义本来就都写着它。）
"""
import os, json, shutil, sys
from PIL import Image, ImageDraw, ImageFont

SRC_ICONS = r'D:\数据包\模型设计\原版风_资源包_20261010\icons'
SRC_SWORD = r'D:\数据包\模型设计\原版风_资源包_20261010\剑_预览'
SRC_AXE   = r'D:\数据包\模型设计\原版风_资源包_20261010\斧_预览'
OUT_DIR   = r'D:\数据包\模型设计\原版风_资源包_20261010'
REF       = r'D:\数据包\.workbuddy\_vanilla_ref'
PACK      = r'D:\数据包\sweetdream_rp_原版风'
DEPLOY    = r'D:\PCL 正式版 2.10.0\.minecraft\versions\1.21.5-Fabric 0.16.10\resourcepacks\sweetdream_rp_原版风'
FONT      = r'C:\Windows\Fonts\msyh.ttc'

# ---------------------------------------------------------------- ① 覆盖组
# 老包里本来就有独立 3D 模型，这里整份换掉 —— 必须排在 sweetdream_rp 之上。
# (命名空间, items 定义名, 模型键, 父模型, 图标源文件, 中文名, 原版对照模板)
ITEMS = [
    ('angelcore',  'axe',          'axe',          'minecraft:item/handheld',  'angelcore_axe',     '天使核心',   'netherite_axe'),
    ('sail',       'staff',        'staff',        'minecraft:item/handheld',  'sail_staff',        '风帆',       'blaze_rod'),
    ('sweetdream', 'aurora_dream', 'aurora_dream', 'minecraft:item/handheld',  'sweetdream_aurora', '极光与幻梦', 'iron_sword'),
    ('sweetdream', 'look',         'look',         'minecraft:item/generated', 'sweetdream_look',   '观测镜',     'spyglass'),
]

# ---------------------------------------------------------------- ② 新增组
# 数据包里这些武器用的是**原版底物**（铁剑/钻石剑/下界合金剑…），老包里没有独立定义，
# 所以这里是"补上"而不是"覆盖"。图标源 = 剑类生成器（build_vanilla_swords.py）的输出
# （模型设计\原版风_资源包_20261010\剑_预览\）。
#
# ★ `vtpl` 必须等于生成器里那一条的 `tpl` —— 图标的 alpha 掩码是逐像素照抄该模板的，
#   底物对不上就会出现"图标形状 ≠ 物品形状"（例：铁剑的图标挂在下界合金剑上）。
#   已用脚本逐件核过：缺失 0；多出的 0~5 像素全是生成器里**刻意加的**
#   （extra 火星 / carve 崩口，见 build_vanilla_swords.py 各组注释）。
ADD = [
    ('sweetdream', 'everfrost',    'everfrost',    'minecraft:item/handheld', 'everfrost',    '永霜',       'diamond_sword'),
    ('sweetdream', 'hengdao',      'hengdao',      'minecraft:item/handheld', 'hengdao',      '横刀',       'iron_sword'),
    ('sweetdream', 'hush',         'hush',         'minecraft:item/handheld', 'hush',         '无息',       'diamond_sword'),
    ('sweetdream', 'liaoyuan',     'liaoyuan',     'minecraft:item/handheld', 'liaoyuan',     '燎原',       'netherite_sword'),
    ('sweetdream', 'liuguang',     'liuguang',     'minecraft:item/handheld', 'liuguang',     '流光',       'iron_sword'),
    ('sweetdream', 'myriad',       'myriad',       'minecraft:item/handheld', 'myriad',       '万念',       'iron_sword'),
    ('sweetdream', 'qiansan',      'qiansan',      'minecraft:item/handheld', 'qiansan',      '千散',       'iron_sword'),
    ('sweetdream', 'rebound',      'rebound',      'minecraft:item/handheld', 'rebound',      '回锋',       'iron_sword'),
    ('sweetdream', 'remelt',       'remelt',       'minecraft:item/handheld', 'remelt',       '热熔',       'netherite_sword'),
    ('sweetdream', 'rogue_star',   'rogue_star',   'minecraft:item/handheld', 'rogue_star',   '游星',       'diamond_sword'),
    ('sweetdream', 'shadow_blade', 'shadow_blade', 'minecraft:item/handheld', 'shadow_blade', '影刃',       'diamond_sword'),
    ('sweetdream', 'verdict',      'verdict',      'minecraft:item/handheld', 'verdict',      '神裁',       'netherite_sword'),
    # 火种：两态（唯一一个**不写进 give** 的 —— 由数据包按 zx.td_on 切）
    ('sweetdream', 'tinder_off',   'tinder_off',   'minecraft:item/handheld', 'tinder_off',   '火种 · 熄灭', 'netherite_sword'),
    ('sweetdream', 'tinder_on',    'tinder_on',    'minecraft:item/handheld', 'tinder_on',    '火种 · 燃烧', 'netherite_sword'),
]

# ---------------------------------------------------------------- ③ 新增组 · 斧
# 同上，底物是原版斧（铁/钻石/下界合金斧）。生成器 = build_vanilla_axes.py，
# 图标源 = 模型设计\原版风_资源包_20261010\斧_预览\。
#
# ★★ 一件例外：`fissure`（崩裂）的模型键写成 **fissure_axe** —— 不能用 fissure。
#    老包 sweetdream_rp 里 `sweetdream:fissure` **已经被占用**了：那是崩裂技能的
#    「地面裂缝」平面模型（equipment/axe/fissure/field.mcfunction 用 item_display +
#    item_model="sweetdream:fissure" 召唤，横平面贴地、scale 6）。
#    斧要是也叫 fissure，物品就会显示成一块贴地的裂缝 —— 必须换名。
AXES = [
    ('sweetdream', 'agony',        'agony',        'minecraft:item/handheld', 'agony',        '苦痛',      'netherite_axe'),
    ('sweetdream', 'anion',        'anion',        'minecraft:item/handheld', 'anion',        '负离子',    'iron_axe'),
    ('sweetdream', 'azure_star',   'azure_star',   'minecraft:item/handheld', 'azure_star',   '苍蓝星',    'netherite_axe'),
    ('sweetdream', 'ballad',       'ballad',       'minecraft:item/handheld', 'ballad',       '歌谣',      'diamond_axe'),
    ('sweetdream', 'charge',       'charge',       'minecraft:item/handheld', 'charge',       '超•负•荷',  'diamond_axe'),
    ('sweetdream', 'chenyuan',     'chenyuan',     'minecraft:item/handheld', 'chenyuan',     '沉渊',      'diamond_axe'),
    ('sweetdream', 'draught',      'draught',      'minecraft:item/handheld', 'draught',      '饮鸩',      'iron_axe'),
    ('sweetdream', 'dream_reader', 'dream_reader', 'minecraft:item/handheld', 'dream_reader', '释梦',      'diamond_axe'),
    ('sweetdream', 'fissure_axe',  'fissure_axe',  'minecraft:item/handheld', 'fissure',      '崩裂',      'iron_axe'),
    ('sweetdream', 'meteor',       'meteor',       'minecraft:item/handheld', 'meteor',       '陨星',      'diamond_axe'),
    ('sweetdream', 'pyre',         'pyre',         'minecraft:item/handheld', 'pyre',         '葬火',      'netherite_axe'),
    ('sweetdream', 'red_lotus',    'red_lotus',    'minecraft:item/handheld', 'red_lotus',    '红莲',      'iron_axe'),
    ('sweetdream', 'skyvault',     'skyvault',     'minecraft:item/handheld', 'skyvault',     '天穹',      'netherite_axe'),
    ('sweetdream', 'thunderclap',  'thunderclap',  'minecraft:item/handheld', 'thunderclap',  '威霆',      'netherite_axe'),
]

# ---------------------------------------------------------------- ④ 盔甲组
# 25 件盔甲（2026-10-10）：底物 = 原版 铁 / 钻石 / 下界合金 的 头盔/胸甲/护腿/靴子。
# 与武器不同，一件盔甲要**两份**资源、两个组件（都只能由**数据包 give** 写）：
#   · 图标  —— `item_model` → assets/sweetdream/items/armor_<id>.json
#                            → models/item/vanilla/armor_<id>.json
#                            → textures/item/vanilla/armor_<id>.png （16×16，item/generated）
#   · 穿戴  —— `equippable.asset_id` → assets/sweetdream/equipment/armor_<id>.json
#                            → textures/entity/equipment/humanoid[_leggings]/armor_<id>.png（64×32）
# 存量装备由 `sweetdream:visual/armor_icon_sync`（每秒）补课。
# ★ 单件真相来源 = build_vanilla_armor.P（id / 中文名 / 槽位 / 原版底材），别在这儿另抄一份。
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import build_vanilla_armor as ARMOR_SRC                        # noqa: E402

ARMOR_ICON_SRC  = os.path.join(ARMOR_SRC.OUT, '图标')
ARMOR_LAYER_SRC = os.path.join(ARMOR_SRC.OUT, '盔甲层')
# 槽位 → (equippable.slot, 装备层目录)
ARMOR_SLOT = {
    'helmet':     ('head',  'humanoid'),
    'chestplate': ('chest', 'humanoid'),
    'leggings':   ('legs',  'humanoid_leggings'),
    'boots':      ('feet',  'humanoid'),
}
# 装备音效（= 原版同名盔甲用的那一个；覆盖 equippable 时必须自己补回来，
# 否则会退回默认的 item.armor.equip_generic，穿戴手感变。ID 已在原版 sounds.json 核过。）
ARMOR_SOUND = {'iron':      'minecraft:item.armor.equip_iron',
               'diamond':   'minecraft:item.armor.equip_diamond',
               'netherite': 'minecraft:item.armor.equip_netherite'}


def armor_key(pid):
    return 'armor_' + pid


def armor_layer_dir(slot):
    return 'humanoid_leggings' if slot == 'leggings' else 'humanoid'


# ---------------------------------------------------------------- ⑤ 副手组
# 7 件「副手 · 被动」道具（2026-10-10）。底物全都是原版 **回响罗盘 recovery_compass**
# （`equipment/tool/<id>/give.mcfunction` 里的 `give @s recovery_compass[...]`）——
# 它们此前在游戏里就一直显示成"追溯指针"的原版样子，本包给它们补上平面图标：
#   `item_model` → assets/sweetdream/items/tool_<id>.json
#                → models/item/vanilla/tool_<id>.json （minecraft:item/generated）
#                → textures/item/vanilla/tool_<id>.png （16×16）
# 与武器同构，只有图标、没有穿戴层。存量道具由
# `sweetdream:visual/tool_icon_sync`（每秒）补课。
#
# ★ **观测镜(look) 不在这一组** —— 它 2026-10-05 就有独立平面图标了（见 ① 覆盖组）。
# ★ 单件真相来源 = `build_offhand_icons.ICONS`（id / 中文名），别在这儿另抄一份。
#   图标源目录 = 那个生成器的 `模型设计/原版风_副手物品_20261010/贴图`。
#   `vtpl` 字段（原版对照贴图）= 本件的原版底物 `recovery_compass_16`。
import build_offhand_icons as TOOL_SRC                          # noqa: E402

SRC_TOOL = os.path.join(TOOL_SRC.OUT, '贴图')


def tool_key(pid):
    return 'tool_' + pid


TOOLS = [('sweetdream', tool_key(pid), tool_key(pid), 'minecraft:item/generated',
          pid, cn, 'recovery_compass_16')
         for pid, cn, _motif, _fn in TOOL_SRC.ICONS]


# ---------------------------------------------------------------- ⑥ 保留
# 继续用 sweetdream_rp 里的独立 3D 模型，本包**不覆盖**
KEEP = [
    ('引梦镰',        'dreamscythe:sickle'),
    ('风行于大地之上', 'naturewind:staff'),
    ('烈火，残躯',     'flameremnant:sword'),
    ('深海的回响',     'deepseaecho:sword'),
    ('寒鸦',          'coldcrow:crossbow'),
    ('启示录',        'sweetdream:apocalypse'),
    ('调色盘',        'palette:palette'),
]

# (名字, 表, 图标源目录, 语义)
GROUPS = [
    ('覆盖',   ITEMS, SRC_ICONS, '替换 sweetdream_rp 里已有的独立 3D 模型'),
    ('新增·剑', ADD,  SRC_SWORD, '老包里没有独立定义的剑（底物 = 原版铁/钻石/下界合金剑）'),
    ('新增·斧', AXES, SRC_AXE,   '老包里没有独立定义的斧（底物 = 原版铁/钻石/下界合金斧）'),
    ('新增·副手', TOOLS, SRC_TOOL, '副手 · 被动道具（底物 = 原版回响罗盘）'),
]

MCMETA = {
    "pack": {
        "pack_format": 55,
        "supported_formats": {"min_inclusive": 55, "max_inclusive": 55},
        "description": "sweetdream 原版风平面图标（覆盖 4 件 + 剑 13 件／含火种两态 + 斧 14 件 + 盔甲 25 件 + 副手 7 件 · 请置于 sweetdream_rp 之上）",
    }
}

README = """# sweetdream_rp_原版风

把 sweetdream 的武器、盔甲与副手道具换成"原版风"的像素图标（武器/副手 16×16 平面；盔甲 = 16×16 图标 + 64×32 穿戴层）。**五层内容**：

## ① 覆盖（替换 sweetdream_rp 里已有的独立 3D 模型）—— 4 件

| 武器 | 原版轮廓 | 模型/贴图键 |
|---|---|---|
| 天使核心 | 斧 | `angelcore:item/vanilla/axe` |
| 风帆 | 杖（烈焰棒） | `sail:item/vanilla/staff` |
| 极光与幻梦 | 剑 | `sweetdream:item/vanilla/aurora_dream` |
| 观测镜 | 望远镜 | `sweetdream:item/vanilla/look` |

## ② 新增（老包里没有独立定义的剑）—— 13 件

这 13 件在数据包里就是**原版剑**（铁剑 / 钻石剑 / 下界合金剑），老包里没有独立模型。
本包给它们补上平面图标，`item_model` 由数据包侧写进物品：

| 武器 | 底物 | 模型键 |
|---|---|---|
| 永霜 | 钻石剑 | `sweetdream:item/vanilla/everfrost` |
| 横刀 | 铁剑 | `sweetdream:item/vanilla/hengdao` |
| 无息 | 钻石剑 | `sweetdream:item/vanilla/hush` |
| 燎原 | 下界合金剑 | `sweetdream:item/vanilla/liaoyuan` |
| 流光 | 铁剑 | `sweetdream:item/vanilla/liuguang` |
| 万念 | 铁剑 | `sweetdream:item/vanilla/myriad` |
| 千散 | 铁剑 | `sweetdream:item/vanilla/qiansan` |
| 回锋 | 铁剑 | `sweetdream:item/vanilla/rebound` |
| 热熔 | 下界合金剑 | `sweetdream:item/vanilla/remelt` |
| 游星 | 钻石剑 | `sweetdream:item/vanilla/rogue_star` |
| 影刃 | 钻石剑 | `sweetdream:item/vanilla/shadow_blade` |
| 神裁 | 下界合金剑 | `sweetdream:item/vanilla/verdict` |

### 火种 —— 两态（例外：**不写进 give**）

| 状态 | 模型键 | 由谁切换 |
|---|---|---|
| 熄灭 | `sweetdream:item/vanilla/tinder_off` | 数据包 `equipment/sword/tinder/visual/sync` |
| 燃烧 | `sweetdream:item/vanilla/tinder_on` | 同上（按玩家计分项 `zx.td_on` 切） |

> 火种是这 13 件里唯一有**离散状态**的（燃烧 / 熄灭），两态共用同一 alpha 剪影，
> 只靠亮度 + 火焰区分。它的 `item_model` 不写在 give 里，全部交给数据包按状态切。

## ③ 新增（老包里没有独立定义的斧）—— 14 件

与剑同构：`item_model` 由数据包写进物品，存量由 `sweetdream:visual/axe_icon_sync`（每秒）补课。

| 武器 | 底物 | 模型键 |
|---|---|---|
| 苦痛 | 下界合金斧 | `sweetdream:item/vanilla/agony` |
| 负离子 | 铁斧 | `sweetdream:item/vanilla/anion` |
| 苍蓝星 | 下界合金斧 | `sweetdream:item/vanilla/azure_star` |
| 歌谣 | 钻石斧 | `sweetdream:item/vanilla/ballad` |
| 超•负•荷 | 钻石斧 | `sweetdream:item/vanilla/charge` |
| 沉渊 | 钻石斧 | `sweetdream:item/vanilla/chenyuan` |
| 饮鸩 | 铁斧 | `sweetdream:item/vanilla/draught` |
| 释梦 | 钻石斧 | `sweetdream:item/vanilla/dream_reader` |
| 崩裂 | 铁斧 | `sweetdream:item/vanilla/fissure_axe` ★ |
| 陨星 | 钻石斧 | `sweetdream:item/vanilla/meteor` |
| 葬火 | 下界合金斧 | `sweetdream:item/vanilla/pyre` |
| 红莲 | 铁斧 | `sweetdream:item/vanilla/red_lotus` |
| 天穹 | 下界合金斧 | `sweetdream:item/vanilla/skyvault` |
| 威霆 | 下界合金斧 | `sweetdream:item/vanilla/thunderclap` |

> ★ **崩裂不能用 `sweetdream:fissure`** —— 老包里这个名字已经被崩裂技能的
> 「地面裂缝」平面模型占了（`equipment/axe/fissure/field.mcfunction` 用
> `item_display` + `item_model="sweetdream:fissure"` 召唤，横平面贴地、scale 6）。
> 斧要是也叫 fissure，物品就会显示成一块贴地的裂缝。所以斧的键是 `fissure_axe`。

## ④ 新增（盔甲）—— 25 件

底物是**原版**铁 / 钻石 / 下界合金的头盔·胸甲·护腿·靴子。老包里没有它们的独立资源，
本包补上**两份**：

| 用途 | 由什么驱动 | 资源 |
|---|---|---|
| 背包 / 手上的图标 | 数据包写 `item_model` = `sweetdream:armor_<id>` | `assets/sweetdream/items/armor_<id>.json` → `models/item/vanilla/armor_<id>.json` → `textures/item/vanilla/armor_<id>.png`（16×16） |
| 穿在身上的外观 | 数据包写 `equippable.asset_id` = `sweetdream:armor_<id>` | `assets/sweetdream/equipment/armor_<id>.json` → `textures/entity/equipment/<humanoid\|humanoid_leggings>/armor_<id>.png`（64×32） |

- **护腿**走 `humanoid_leggings`（＝原版 layer2），**头盔 / 胸甲 / 靴子**走 `humanoid`（＝原版 layer1）。
- 两件资源都由 `build_vanilla_armor.py` 生成（逐件读 `give.mcfunction` 的技能原文配色）；
  本节只是把它们组装进包，单件真相来源仍是那个 P 表。
- 存量装备由 `sweetdream:visual/armor_icon_sync`（每秒）补课。
- 逐件配色见 `模型设计/原版风_盔甲_20261010/配色对照表.md`。

## ⑤ 新增（副手 · 被动道具）—— 7 件

底物全都是原版 **回响罗盘 `recovery_compass`**（它们此前在游戏里一直显示成"追溯指针"的
原版样子）。本包给它们补上平面图标，`item_model` 由数据包侧写进物品：

| 道具 | 主题 | 模型键 |
|---|---|---|
| 苦寒 | 矢量六向冰晶（中心六角核 + 每臂一对分叉） | `sweetdream:item/vanilla/tool_bitter_cold` |
| 炽翎 | 原版 `feather` 掩码 + 按高度分段火焰色 | `sweetdream:item/vanilla/tool_blaze_plume` |
| 体外魔力泵 | 金属壳 + 正面魔力液竖窗 + 顶部接线柱 | `sweetdream:item/vanilla/tool_mana_pump` |
| 无效 | 禁制环 + 45° 斜杠 | `sweetdream:item/vanilla/tool_nullify` |
| 炽天使之翼 | **现实翼形**（前缘外弧 + 后缘 4 根飞羽带羽尖）+ 白金 · 白羽金尖 | `sweetdream:item/vanilla/tool_seraph_wing` |
| 雷鸣 | 标准 bolt 折线闪电 | `sweetdream:item/vanilla/tool_thunder` |
| 愠怒 | 暗红怒面（怒眉 / 怒目 / 锯齿嘴） | `sweetdream:item/vanilla/tool_wrath` |

- 存量道具由 `sweetdream:visual/tool_icon_sync`（每秒）补课；图标由
  `build_offhand_icons.py` 生成，逐件配色见 `模型设计/原版风_副手物品_20261010/配色对照表.md`。
- ★ **观测镜（`look`）不在这一组** —— 它 2026-10-05 就有独立平面图标了（见 ① 覆盖组）。

## 本次**保留**（继续用 sweetdream_rp 里的独立 3D 模型，本包不覆盖）

引梦镰 · 风行于大地之上 · 烈火，残躯 · 深海的回响 · 寒鸦 · 启示录 · 调色盘

## 用法（重要）

这是一个**覆盖层**，本身只有上面这些图标，不含其它资源。

1. 把本文件夹（或压缩包）放进资源包目录。
2. 在资源包列表中把它排到 **`sweetdream_rp` 之上**。
3. 应用资源包（或 `F3+T` 重载）。

> ⚠ **新增的 59 件（剑 13 + 斧 14 + 盔甲 25 + 副手 7）必须搭配本包**：数据包会把它们的
> `item_model`（盔甲还有 `equippable.asset_id`）改成 `sweetdream:armor_<id>` / `tool_<id>` 这类，
> 这些定义在本包里 —— 只开老包 `sweetdream_rp` 会显示成缺模型 / 穿成原版外观。
> 日常直接用合并版 `sweetdream_rp_完整版` 最省心（已内含本包）。
>
> 关掉/移到下面：立刻回到原来的样子，老包一个字节都没改。

## 做法

- **轮廓**：逐像素照抄原版客户端贴图的 alpha 掩码 —— 形状与原版同类武器完全一致。
- **明暗**：读原版每个像素的亮度，按部位映射到该武器自己的色阶 —— 原版的描边、
  受光面、暗面结构全部原样保留，只换色相/材质。
- **配色**：色阶从每件武器**自己的 3D 贴图**（或技能原文的意象）里取，不凭空配。

## 为什么定义里要写 `hand_animation_on_swap: false`

`item_model` 组件是数据包在运行时**改写**的（`item_modifier/*.json`）。物品组件变化 ⇒
客户端会把它当成"换了一件物品" ⇒ 播一次举手动画 ⇒ **在手上一直抽搐**。
`sweetdream_rp` 里 11 件的定义本来就都写着它；本包是整份替换 `items/<id>.json`，
所以必须照带，否则就会抽搐。

## 已知取舍

- 图标是**静态平面图**，不再跟随 `custom_model_data` 变化 —— 原包里天使核心的待机帧、
  风帆的「记录」状态等动态外观都会消失。这是"偏原版"的直接代价（原版武器图标本身也不动）。
- 火种的**两态**不是动效，是**离散状态**（燃烧/熄灭），所以照做。
"""


def write(path, text):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w', encoding='utf-8') as f:
        f.write(text)
    print('  write', os.path.relpath(path, PACK))


def build_armor():
    """25 件盔甲：图标（16×16）+ 装备定义 + 穿戴层贴图（64×32）。"""
    n = 0
    for p in ARMOR_SRC.P:
        pid, slot, mat = p['id'], p['slot'], p['mat']
        key = armor_key(pid)
        mid = 'sweetdream:item/vanilla/' + key
        assert mat in ARMOR_SOUND, '未知底材 ' + mat
        assert slot in ARMOR_SLOT, '未知槽位 ' + slot
        # 1) 物品定义：静态指向平面模型 + ★ 关掉换手动画（防抽搐）
        write(os.path.join(PACK, 'assets', 'sweetdream', 'items', key + '.json'),
              json.dumps({"hand_animation_on_swap": False,
                          "model": {"type": "minecraft:model", "model": mid}},
                         ensure_ascii=False, indent=2) + '\n')
        # 2) 平面模型（原版 item/generated，和原版盔甲图标同构）
        write(os.path.join(PACK, 'assets', 'sweetdream', 'models', 'item', 'vanilla', key + '.json'),
              json.dumps({"parent": "minecraft:item/generated",
                          "textures": {"layer0": mid}},
                         ensure_ascii=False, indent=2) + '\n')
        # 3) 16×16 图标
        dst = os.path.join(PACK, 'assets', 'sweetdream', 'textures', 'item', 'vanilla', key + '.png')
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        shutil.copyfile(os.path.join(ARMOR_ICON_SRC, pid + '.png'), dst)
        # 4) 装备定义：asset_id → 穿戴层（护腿用 humanoid_leggings，其余用 humanoid）
        ldir = armor_layer_dir(slot)
        write(os.path.join(PACK, 'assets', 'sweetdream', 'equipment', key + '.json'),
              json.dumps({"layers": {ldir: [{"texture": "sweetdream:" + key}]}},
                         ensure_ascii=False, indent=2) + '\n')
        # 5) 64×32 穿戴层贴图
        dst2 = os.path.join(PACK, 'assets', 'sweetdream', 'textures', 'entity', 'equipment', ldir,
                            key + '.png')
        os.makedirs(os.path.dirname(dst2), exist_ok=True)
        shutil.copyfile(os.path.join(ARMOR_LAYER_SRC, pid + '.png'), dst2)
        print('  armor %-16s [%s] -> %s (%s, %s)' % (p['cn'], slot, key, mat, ldir))
        n += 1
    print('盔甲 %d 件：图标 + 装备定义 + 穿戴层贴图' % n)


def make_preview():
    """两组内容各自的对照预览（原版底物 / 我们的图标 / 背包格），放到 模型设计/ 下。"""
    S, PAD = 10, 14
    cell = 16 * S
    ft = ImageFont.truetype(FONT, 21)
    f  = ImageFont.truetype(FONT, 17)
    fs = ImageFont.truetype(FONT, 15)

    ncol = max(len(g[1]) for g in GROUPS)
    W = PAD + ncol * (cell + PAD)
    ROW = cell + 50
    BLOCK = 26 + ROW * 3 + 34            # 组标题 + 三行 + 组说明
    H = PAD + 56 + len(GROUPS) * BLOCK + 76 + PAD
    sheet = Image.new('RGBA', (W, H), (22, 24, 29, 255))
    d = ImageDraw.Draw(sheet)
    d.text((PAD, 12), '原版风 · 覆盖 4 件 + 新增剑 13 件（含火种两态）+ 新增斧 14 件'
                      ' + 新增副手 7 件（其余保留独立 3D 模型）',
           font=ft, fill=(246, 246, 250))

    slot = Image.new('RGBA', (cell + 16, cell + 16), (139, 139, 139, 255))
    y = PAD + 56
    for gname, table, src, note in GROUPS:
        d.text((PAD, y), '【%s】%s —— %d 件' % (gname, note, len(table)), font=f, fill=(250, 224, 140))
        y += 30
        y0, y1, y2 = y, y + ROW, y + ROW * 2
        for i, (ns, item_id, key, parent, icon, cn, vtpl) in enumerate(table):
            x = PAD + i * (cell + PAD)
            org  = Image.open(os.path.join(REF, vtpl + '.png')).convert('RGBA').resize((cell, cell), Image.NEAREST)
            ours = Image.open(os.path.join(src, icon + '.png')).convert('RGBA').resize((cell, cell), Image.NEAREST)
            sheet.paste(org, (x, y0), org)
            d.text((x, y0 + cell + 5), '原版·' + vtpl, font=fs, fill=(158, 162, 174))
            sheet.paste(ours, (x, y1), ours)
            d.text((x, y1 + cell + 5), cn, font=f, fill=(250, 224, 140))
            c = slot.copy(); c.paste(ours, (8, 8), ours)
            sheet.paste(c, (x, y2))
        d.text((PAD, y0 - 22), '① 原版同类武器（对照）', font=fs, fill=(150, 154, 166))
        d.text((PAD, y1 - 22), '② 我们的图标（轮廓＝原版底物，配色＝该武器自己的贴图 / 技能意象）', font=fs, fill=(150, 154, 166))
        d.text((PAD, y2 - 22), '③ 背包格内实际观感', font=fs, fill=(150, 154, 166))
        y += BLOCK

    d.text((PAD, y + 10),
           '保留 7 件 3D 模型：引梦镰 / 风行于大地之上 / 烈火，残躯 / 深海的回响 / 寒鸦 / 启示录 / 调色盘',
           font=f, fill=(190, 196, 208))
    p = os.path.join(OUT_DIR, '原版风_预览.png')
    sheet.save(p)
    print('preview ->', p, sheet.size)


def verify():
    """构建后自检 —— 只要有一条不成立, 游戏里就会出问题, 直接报错退出。

    ① 两组覆盖范围恰好是 ITEMS / ADD 那几件（不许多也不许漏）
    ② ★ 每条定义都带 "hand_animation_on_swap": false（丢了 = 手上一直抽搐）
    ③ 定义指向的模型文件存在, 且模型引用的贴图存在、为 16×16，且与源图标逐字节一致
    ④ --deploy 时, 源目录与游戏目录逐字节一致
    """
    errs = []
    for gname, table, src, _ in GROUPS:
        got = set()
        for ns, item_id, key, parent, icon, cn, vtpl in table:
            rel = os.path.join('assets', ns, 'items', item_id + '.json')
            p = os.path.join(PACK, rel)
            got.add('%s:%s' % (ns, item_id))
            if not os.path.isfile(p):
                errs.append('缺定义 ' + rel); continue
            j = json.load(open(p, encoding='utf-8'))
            if j.get('hand_animation_on_swap') is not False:
                errs.append('%s: 缺 "hand_animation_on_swap": false —— 游戏里会在手上一直抽搐' % rel)
            if j.get('model', {}).get('type') != 'minecraft:model':
                errs.append('%s: model.type 应为 minecraft:model' % rel)

            mp = os.path.join(PACK, 'assets', ns, 'models', 'item', 'vanilla', key + '.json')
            if not os.path.isfile(mp):
                errs.append('缺模型 ' + os.path.relpath(mp, PACK)); continue
            mj = json.load(open(mp, encoding='utf-8'))
            if mj.get('parent') != parent:
                errs.append('%s: parent 应为 %s' % (os.path.relpath(mp, PACK), parent))
            tp = os.path.join(PACK, 'assets', ns, 'textures', 'item', 'vanilla', key + '.png')
            if not os.path.isfile(tp):
                errs.append('缺贴图 ' + os.path.relpath(tp, PACK)); continue
            with Image.open(tp) as im:
                if im.size != (16, 16):
                    errs.append('%s: 贴图尺寸 %s, 应为 (16, 16)' % (os.path.relpath(tp, PACK), im.size))
            sp = os.path.join(src, icon + '.png')
            if open(tp, 'rb').read() != open(sp, 'rb').read():
                errs.append('%s: 与源图标不一致 %s' % (os.path.relpath(tp, PACK), sp))

        want = {'%s:%s' % (i[0], i[1]) for i in table}
        if got != want:
            errs.append('[%s组] 覆盖范围不只 %d 件: 多出/缺少 %s' % (gname, len(table), got ^ want))

    # ⑤ 盔甲 25 件：定义字段 + 模型/图标可达 + 装备定义/穿戴层可达 + 与源逐字节一致
    for p in ARMOR_SRC.P:
        pid, slot = p['id'], p['slot']
        key = armor_key(pid)
        ldir = armor_layer_dir(slot)
        # 物品定义
        ip = os.path.join(PACK, 'assets', 'sweetdream', 'items', key + '.json')
        if not os.path.isfile(ip):
            errs.append('缺盔甲定义 items/%s.json' % key); continue
        j = json.load(open(ip, encoding='utf-8'))
        if j.get('hand_animation_on_swap') is not False:
            errs.append('%s: 缺 "hand_animation_on_swap": false —— 穿脱时会抽搐' % key)
        if j.get('model') != {"type": "minecraft:model", "model": "sweetdream:item/vanilla/" + key}:
            errs.append('%s: model 应指向 sweetdream:item/vanilla/%s' % (key, key))
        # 模型 → 图标贴图
        mp = os.path.join(PACK, 'assets', 'sweetdream', 'models', 'item', 'vanilla', key + '.json')
        if not os.path.isfile(mp):
            errs.append('缺盔甲模型 %s' % key); continue
        mj = json.load(open(mp, encoding='utf-8'))
        if mj.get('parent') != 'minecraft:item/generated':
            errs.append('%s: parent 应为 minecraft:item/generated' % key)
        if mj.get('textures', {}).get('layer0') != 'sweetdream:item/vanilla/' + key:
            errs.append('%s: layer0 应为 sweetdream:item/vanilla/%s' % (key, key))
        tp = os.path.join(PACK, 'assets', 'sweetdream', 'textures', 'item', 'vanilla', key + '.png')
        if not os.path.isfile(tp):
            errs.append('缺盔甲图标 ' + key); continue
        # 装备定义 → 穿戴层贴图
        ep = os.path.join(PACK, 'assets', 'sweetdream', 'equipment', key + '.json')
        if not os.path.isfile(ep):
            errs.append('缺装备定义 equipment/%s.json' % key); continue
        ej = json.load(open(ep, encoding='utf-8'))
        layers = ej.get('layers', {})
        if set(layers) != {ldir}:
            errs.append('%s: layers 应只有 %s，实为 %s' % (key, ldir, sorted(layers)))
        elif layers[ldir] != [{"texture": "sweetdream:" + key}]:
            errs.append('%s: layers.%s 应指向 sweetdream:%s' % (key, ldir, key))
        lp = os.path.join(PACK, 'assets', 'sweetdream', 'textures', 'entity', 'equipment',
                          ldir, key + '.png')
        if not os.path.isfile(lp):
            errs.append('缺穿戴层贴图 ' + key); continue
        with Image.open(tp) as im:
            if im.size != (16, 16):
                errs.append('%s: 图标尺寸 %s, 应为 (16, 16)' % (key, im.size))
        with Image.open(lp) as im:
            if im.size != (64, 32):
                errs.append('%s: 穿戴层尺寸 %s, 应为 (64, 32)' % (key, im.size))
        if open(tp, 'rb').read() != open(os.path.join(ARMOR_ICON_SRC, pid + '.png'), 'rb').read():
            errs.append('%s: 图标与源不一致' % key)
        if open(lp, 'rb').read() != open(os.path.join(ARMOR_LAYER_SRC, pid + '.png'), 'rb').read():
            errs.append('%s: 穿戴层与源不一致' % key)

    if '--deploy' in sys.argv:
        for root, _, files in os.walk(PACK):
            for fn in files:
                s = os.path.join(root, fn)
                dd = os.path.join(DEPLOY, os.path.relpath(s, PACK))
                if not os.path.isfile(dd) or open(s, 'rb').read() != open(dd, 'rb').read():
                    errs.append('源↔游戏 不一致: ' + os.path.relpath(s, PACK))

    if errs:
        print('\n'.join('  ✗ ' + e for e in errs))
        sys.exit('自检未通过, 共 %d 条' % len(errs))
    print('自检通过：覆盖 %d 件 + 新增剑 %d 件 + 新增斧 %d 件 + 盔甲 %d 件 + 副手 %d 件 · '
          '定义全部带 hand_animation_on_swap:false · 模型/贴图可达（图标 16×16 / 穿戴层 64×32）、与源一致'
          % (len(ITEMS), len(ADD), len(AXES), len(ARMOR_SRC.P), len(TOOLS)))


def main():
    if os.path.isdir(PACK):
        shutil.rmtree(PACK)
    os.makedirs(PACK, exist_ok=True)
    print('build ->', PACK)

    write(os.path.join(PACK, 'pack.mcmeta'), json.dumps(MCMETA, ensure_ascii=False, indent=2) + '\n')

    for gname, table, src, _ in GROUPS:
        for ns, item_id, key, parent, icon, cn, vtpl in table:
            model_id = "%s:item/vanilla/%s" % (ns, key)
            # 1) 物品定义：静态指向极简平面模型 + ★ 关掉换手动画（防抽搐）
            write(os.path.join(PACK, 'assets', ns, 'items', item_id + '.json'),
                  json.dumps({"hand_animation_on_swap": False,
                              "model": {"type": "minecraft:model", "model": model_id}},
                             ensure_ascii=False, indent=2) + '\n')
            # 2) 极简模型：原版 2D 物品模型
            write(os.path.join(PACK, 'assets', ns, 'models', 'item', 'vanilla', key + '.json'),
                  json.dumps({"parent": parent,
                              "textures": {"layer0": "%s:item/vanilla/%s" % (ns, key)}},
                             ensure_ascii=False, indent=2) + '\n')
            # 3) 贴图
            dst = os.path.join(PACK, 'assets', ns, 'textures', 'item', 'vanilla', key + '.png')
            os.makedirs(os.path.dirname(dst), exist_ok=True)
            shutil.copyfile(os.path.join(src, icon + '.png'), dst)
            print('  icon  %-14s [%s] -> %s' % (cn, gname, os.path.relpath(dst, PACK)))

    build_armor()

    # 4) pack.png（2×2 拼贴）
    picks = ['angelcore_axe', 'sweetdream_aurora', 'sail_staff', 'sweetdream_look']
    pk = Image.new('RGBA', (64, 64), (28, 30, 36, 255))
    for i, nm in enumerate(picks):
        im = Image.open(os.path.join(SRC_ICONS, nm + '.png')).convert('RGBA').resize((32, 32), Image.NEAREST)
        pk.paste(im, ((i % 2) * 32, (i // 2) * 32), im)
    pk.save(os.path.join(PACK, 'pack.png'))
    print('  write pack.png')

    write(os.path.join(PACK, 'README.md'), README)
    make_preview()

    print('files:', sum(len(f) for _, _, f in os.walk(PACK)))

    if '--deploy' in sys.argv:
        if os.path.isdir(DEPLOY):
            shutil.rmtree(DEPLOY)
        shutil.copytree(PACK, DEPLOY)
        print('deployed ->', DEPLOY)

    print()
    verify()


if __name__ == '__main__':
    main()
