# sweetdream_rp_原版风

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
