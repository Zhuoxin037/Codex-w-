# ============================================================
# sweetdream:debug/give_all —— 把「至今全部的东西」打包成潜影盒给自己
# ------------------------------------------------------------
# 【这个文件是生成的】改了物品 / 加了新装备, 重跑:
#     python .workbuddy/_gen_give_all.py
# 【用法】/function sweetdream:debug/give_all   或   /trigger zx.dbg_give
#
# 【为什么是 6 个盒子】潜影盒只有 27 格, 而东西一共 154 件
#   (98 件装备 + 56 块强化石) —— 按每盒 27 件自动分包。
#
# 【怎么做到的】走一个方块当中转站:
#   ① 在下面这些坐标放空潜影盒方块(和强化台 0,-59,2 错开、同一个区块)
#   ② 每件东西: 调它自己的 give -> 落到 hotbar.0 -> 抄进盒子 -> 清掉过路位
#   ③ /loot give @s mine 把潜影盒挖下来(战利品表会带上内容和名字)
#
# 【为什么要借 hotbar.0】/give 只丢进「第一个空格」, 槽位不确定;
#   先把 hotbar.0 清空它就必定落这儿。用完**先还原**、再发盒子,
#   顺序反了盒子会占掉 hotbar.0、把玩家原来的东西顶掉。
#
# 【注意】方块坐标用的是**玩家所在维度**。这套坐标是主世界的固定点,
#   在下界/末地跑会失败(和强化台一样的限制)。
# ============================================================

# ---- ① 中转站: 每个盒子一个方块 + 一个暂存箱 ----
#   【为什么用染色潜影盒】就算名字没写上(见下), 颜色也能一眼分清哪个是哪个。
setblock 0 -60 1 minecraft:yellow_shulker_box replace
setblock 0 -60 3 minecraft:purple_shulker_box replace
setblock 0 -60 5 minecraft:cyan_shulker_box replace
setblock 0 -60 7 minecraft:red_shulker_box replace
setblock 0 -60 9 minecraft:lime_shulker_box replace
setblock 0 -60 11 minecraft:blue_shulker_box replace
setblock 0 -60 2 minecraft:chest replace
data modify block 0 -60 1 Items set value []
data modify block 0 -60 3 Items set value []
data modify block 0 -60 5 Items set value []
data modify block 0 -60 7 Items set value []
data modify block 0 -60 9 Items set value []
data modify block 0 -60 11 Items set value []
data modify block 0 -60 2 Items set value []
data modify block 0 -60 1 CustomName set value {"text":"sweetdream · 盒1 (27 件)","color":"yellow","italic":false}
data modify block 0 -60 3 CustomName set value {"text":"sweetdream · 盒2 (27 件)","color":"light_purple","italic":false}
data modify block 0 -60 5 CustomName set value {"text":"sweetdream · 盒3 (27 件)","color":"aqua","italic":false}
data modify block 0 -60 7 CustomName set value {"text":"sweetdream · 盒4 (27 件)","color":"red","italic":false}
data modify block 0 -60 9 CustomName set value {"text":"sweetdream · 盒5 (27 件)","color":"green","italic":false}
data modify block 0 -60 11 CustomName set value {"text":"sweetdream · 盒6 (19 件)","color":"blue","italic":false}
#   【兜底提示】要是中转站没建成(区块没加载 / 你不在主世界), 后面全都会
#   静默失败 —— 与其让你以为发了但没给, 不如直接说出来。
execute unless block 0 -60 1 #minecraft:shulker_boxes run tellraw @s [{"text":"[调试] 中转站没建成: 盒子都没发出去。这条只支持主世界, 且那个坐标的区块得是加载的。","color":"red"}]

# ---- ② 借 hotbar.0 当过路位(先把它原本的东西存起来) ----
item replace block 0 -60 2 container.0 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air

# ---- ③ 盒 1: 27 件 ----
function sweetdream:equipment/armor/blaze_armor/give
item replace block 0 -60 1 container.0 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/armor/brain_leech/give
item replace block 0 -60 1 container.1 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/armor/dionysus_helmet/give
item replace block 0 -60 1 container.2 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/armor/dusk_dawn/give
item replace block 0 -60 1 container.3 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/armor/ember/give
item replace block 0 -60 1 container.4 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/armor/eternity/give
item replace block 0 -60 1 container.5 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/armor/external_power/give
item replace block 0 -60 1 container.6 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/armor/fade/give
item replace block 0 -60 1 container.7 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/armor/flesh_mill/give
item replace block 0 -60 1 container.8 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/armor/furnace_core/give
item replace block 0 -60 1 container.9 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/armor/hex_belt/give
item replace block 0 -60 1 container.10 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/armor/immolate/give
item replace block 0 -60 1 container.11 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/armor/intravenous_pump/give
item replace block 0 -60 1 container.12 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/armor/iridescent/give
item replace block 0 -60 1 container.13 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/armor/lethe_shore/give
item replace block 0 -60 1 container.14 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/armor/lightless_sea/give
item replace block 0 -60 1 container.15 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/armor/mana_helm/give
item replace block 0 -60 1 container.16 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/armor/mana_plate/give
item replace block 0 -60 1 container.17 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/armor/mirage/give
item replace block 0 -60 1 container.18 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/armor/resonance/give
item replace block 0 -60 1 container.19 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/armor/spine_symbiote/give
item replace block 0 -60 1 container.20 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/armor/spirit_sight/give
item replace block 0 -60 1 container.21 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/armor/stellar_elegy/give
item replace block 0 -60 1 container.22 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/armor/styx_walk/give
item replace block 0 -60 1 container.23 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/armor/withered_garden/give
item replace block 0 -60 1 container.24 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/sword/aurora_dream/give
item replace block 0 -60 1 container.25 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/sword/crescent/give
item replace block 0 -60 1 container.26 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air

# ---- ③ 盒 2: 27 件 ----
function sweetdream:equipment/sword/deepsea_echo/give
item replace block 0 -60 3 container.0 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/sword/everfrost/give
item replace block 0 -60 3 container.1 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/sword/flame_brokenbody/give
item replace block 0 -60 3 container.2 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/sword/grayscale/give
item replace block 0 -60 3 container.3 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/sword/hengdao/give
item replace block 0 -60 3 container.4 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/sword/hush/give
item replace block 0 -60 3 container.5 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/sword/liaoyuan/give
item replace block 0 -60 3 container.6 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/sword/liuguang/give
item replace block 0 -60 3 container.7 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/sword/myriad/give
item replace block 0 -60 3 container.8 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/sword/qiansan/give
item replace block 0 -60 3 container.9 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/sword/rebound/give
item replace block 0 -60 3 container.10 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/sword/remelt/give
item replace block 0 -60 3 container.11 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/sword/rogue_star/give
item replace block 0 -60 3 container.12 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/sword/shadow_blade/give
item replace block 0 -60 3 container.13 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/sword/sickle_dreams/give
item replace block 0 -60 3 container.14 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/sword/tidemark/give
item replace block 0 -60 3 container.15 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/sword/tinder/give
item replace block 0 -60 3 container.16 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/sword/verdict/give
item replace block 0 -60 3 container.17 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/axe/agony/give
item replace block 0 -60 3 container.18 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/axe/anchor/give
item replace block 0 -60 3 container.19 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/axe/angel_core/give
item replace block 0 -60 3 container.20 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/axe/anion/give
item replace block 0 -60 3 container.21 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/axe/azure_star/give
item replace block 0 -60 3 container.22 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/axe/ballad/give
item replace block 0 -60 3 container.23 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/axe/charge/give
item replace block 0 -60 3 container.24 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/axe/chenyuan/give
item replace block 0 -60 3 container.25 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/axe/draught/give
item replace block 0 -60 3 container.26 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air

# ---- ③ 盒 3: 27 件 ----
function sweetdream:equipment/axe/dream_reader/give
item replace block 0 -60 5 container.0 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/axe/fissure/give
item replace block 0 -60 5 container.1 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/axe/meteor/give
item replace block 0 -60 5 container.2 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/axe/pyre/give
item replace block 0 -60 5 container.3 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/axe/red_lotus/give
item replace block 0 -60 5 container.4 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/axe/sacred_relic/give
item replace block 0 -60 5 container.5 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/axe/scorch_bone/give
item replace block 0 -60 5 container.6 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/axe/skyvault/give
item replace block 0 -60 5 container.7 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/axe/thunderclap/give
item replace block 0 -60 5 container.8 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/bow/arc/give
item replace block 0 -60 5 container.9 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/bow/backstring/give
item replace block 0 -60 5 container.10 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/bow/bone_erode/give
item replace block 0 -60 5 container.11 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/bow/burst_dawn/give
item replace block 0 -60 5 container.12 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/bow/cloudtrail/give
item replace block 0 -60 5 container.13 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/bow/cold_crow/give
item replace block 0 -60 5 container.14 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/bow/dragon_tongue/give
item replace block 0 -60 5 container.15 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/bow/lucid_dream/give
item replace block 0 -60 5 container.16 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/bow/rainbow/give
item replace block 0 -60 5 container.17 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/bow/sculk_echo/give
item replace block 0 -60 5 container.18 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/staff/apocalypse/give
item replace block 0 -60 5 container.19 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/staff/begonia/give
item replace block 0 -60 5 container.20 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/staff/chime/give
item replace block 0 -60 5 container.21 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/staff/delusion/give
item replace block 0 -60 5 container.22 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/staff/fallen_dream/give
item replace block 0 -60 5 container.23 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/staff/final_revelation/give
item replace block 0 -60 5 container.24 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/staff/five_curses/give
item replace block 0 -60 5 container.25 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/staff/gu_poison/give
item replace block 0 -60 5 container.26 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air

# ---- ③ 盒 4: 27 件 ----
function sweetdream:equipment/staff/palette/give
item replace block 0 -60 7 container.0 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/staff/polarized_light/give
item replace block 0 -60 7 container.1 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/staff/sail/give
item replace block 0 -60 7 container.2 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/staff/thunderrod/give
item replace block 0 -60 7 container.3 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/staff/triad/give
item replace block 0 -60 7 container.4 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/staff/twilight/give
item replace block 0 -60 7 container.5 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/staff/wind_ontheground/give
item replace block 0 -60 7 container.6 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/tool/bitter_cold/give
item replace block 0 -60 7 container.7 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/tool/blaze_plume/give
item replace block 0 -60 7 container.8 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/tool/everlit/give
item replace block 0 -60 7 container.9 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/tool/frostmirror/give
item replace block 0 -60 7 container.10 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/tool/look/give
item replace block 0 -60 7 container.11 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/tool/mana_pump/give
item replace block 0 -60 7 container.12 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/tool/nullify/give
item replace block 0 -60 7 container.13 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/tool/seraph_wing/give
item replace block 0 -60 7 container.14 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/tool/thunder/give
item replace block 0 -60 7 container.15 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/tool/wrath/give
item replace block 0 -60 7 container.16 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:upgrade/item/boil
item replace block 0 -60 7 container.17 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:upgrade/item/coolant_a
item replace block 0 -60 7 container.18 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:upgrade/item/coolant_b
item replace block 0 -60 7 container.19 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:upgrade/item/coolant_o
item replace block 0 -60 7 container.20 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:upgrade/item/harden_a
item replace block 0 -60 7 container.21 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:upgrade/item/harden_b
item replace block 0 -60 7 container.22 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:upgrade/item/harden_o
item replace block 0 -60 7 container.23 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:upgrade/item/life_up_a
item replace block 0 -60 7 container.24 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:upgrade/item/life_up_b
item replace block 0 -60 7 container.25 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:upgrade/item/life_up_o
item replace block 0 -60 7 container.26 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air

# ---- ③ 盒 5: 27 件 ----
function sweetdream:upgrade/item/mana_gain_a
item replace block 0 -60 9 container.0 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:upgrade/item/mana_gain_b
item replace block 0 -60 9 container.1 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:upgrade/item/mana_gain_o
item replace block 0 -60 9 container.2 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:upgrade/item/mana_surge_a
item replace block 0 -60 9 container.3 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:upgrade/item/mana_surge_b
item replace block 0 -60 9 container.4 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:upgrade/item/mana_surge_o
item replace block 0 -60 9 container.5 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:upgrade/item/mana_up_a
item replace block 0 -60 9 container.6 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:upgrade/item/mana_up_b
item replace block 0 -60 9 container.7 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:upgrade/item/mana_up_o
item replace block 0 -60 9 container.8 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:upgrade/item/neuro_a
item replace block 0 -60 9 container.9 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:upgrade/item/neuro_b
item replace block 0 -60 9 container.10 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:upgrade/item/neuro_o
item replace block 0 -60 9 container.11 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:upgrade/item/night_vision
item replace block 0 -60 9 container.12 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:upgrade/item/torch
item replace block 0 -60 9 container.13 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:upgrade/item/uncolor
item replace block 0 -60 9 container.14 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:upgrade/item/vision_a
item replace block 0 -60 9 container.15 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:upgrade/item/vision_b
item replace block 0 -60 9 container.16 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:upgrade/item/vision_o
item replace block 0 -60 9 container.17 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:overlimit/item/anion
item replace block 0 -60 9 container.18 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:overlimit/item/arc
item replace block 0 -60 9 container.19 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:overlimit/item/begonia
item replace block 0 -60 9 container.20 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:overlimit/item/bone_erode
item replace block 0 -60 9 container.21 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:overlimit/item/brain_leech
item replace block 0 -60 9 container.22 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:overlimit/item/charge
item replace block 0 -60 9 container.23 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:overlimit/item/chime
item replace block 0 -60 9 container.24 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:overlimit/item/cold_crow
item replace block 0 -60 9 container.25 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:overlimit/item/deepsea_echo
item replace block 0 -60 9 container.26 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air

# ---- ③ 盒 6: 19 件 ----
function sweetdream:overlimit/item/dionysus_helmet
item replace block 0 -60 11 container.0 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:overlimit/item/dream_reader
item replace block 0 -60 11 container.1 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:overlimit/item/dusk_dawn
item replace block 0 -60 11 container.2 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:overlimit/item/everfrost
item replace block 0 -60 11 container.3 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:overlimit/item/fissure
item replace block 0 -60 11 container.4 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:overlimit/item/flame_brokenbody
item replace block 0 -60 11 container.5 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:overlimit/item/furnace_core
item replace block 0 -60 11 container.6 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:overlimit/item/hengdao
item replace block 0 -60 11 container.7 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:overlimit/item/liuguang
item replace block 0 -60 11 container.8 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:overlimit/item/myriad
item replace block 0 -60 11 container.9 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:overlimit/item/polarized_light
item replace block 0 -60 11 container.10 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:overlimit/item/red_lotus
item replace block 0 -60 11 container.11 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:overlimit/item/rogue_star
item replace block 0 -60 11 container.12 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:overlimit/item/sculk_echo
item replace block 0 -60 11 container.13 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:overlimit/item/shadow_blade
item replace block 0 -60 11 container.14 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:overlimit/item/sickle_dreams
item replace block 0 -60 11 container.15 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:overlimit/item/spine_symbiote
item replace block 0 -60 11 container.16 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:overlimit/item/stellar_elegy
item replace block 0 -60 11 container.17 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:overlimit/item/tinder
item replace block 0 -60 11 container.18 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air

# ---- ④ 先把玩家原本的 hotbar.0 还回去(再发盒子, 免得被顶掉) ----
item replace entity @s hotbar.0 from block 0 -60 2 container.0

# ---- ⑤ 把盒子挖下来给自己 ----
loot give @s mine 0 -60 1 minecraft:diamond_pickaxe
loot give @s mine 0 -60 3 minecraft:diamond_pickaxe
loot give @s mine 0 -60 5 minecraft:diamond_pickaxe
loot give @s mine 0 -60 7 minecraft:diamond_pickaxe
loot give @s mine 0 -60 9 minecraft:diamond_pickaxe
loot give @s mine 0 -60 11 minecraft:diamond_pickaxe

# ---- ⑥ 收尾: 拆掉中转站 ----
setblock 0 -60 1 minecraft:air replace
setblock 0 -60 3 minecraft:air replace
setblock 0 -60 5 minecraft:air replace
setblock 0 -60 7 minecraft:air replace
setblock 0 -60 9 minecraft:air replace
setblock 0 -60 11 minecraft:air replace
setblock 0 -60 2 minecraft:air replace
tellraw @s [{"text":"[调试] 已发: 154 件东西, 共 6 个盒子。","color":"dark_gray"}]
