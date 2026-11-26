# ============================================================
# fallendream:debug/give_all —— 把「至今全部的东西」打包成潜影盒给自己
# ------------------------------------------------------------
# 【这个文件是生成的】改了物品 / 加了新装备, 重跑:
#     python .workbuddy/_gen_give_all.py
# 【用法】/function fallendream:debug/give_all   或   /trigger zx.dbg_give
#
# 【为什么是 15 个盒子】潜影盒只有 27 格, 而东西一共 378 件
#   (233 件装备 + 145 块强化石) —— 按每盒 27 件自动分包。
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
setblock 0 -60 13 minecraft:orange_shulker_box replace
setblock 0 -60 15 minecraft:pink_shulker_box replace
setblock 2 -60 1 minecraft:light_gray_shulker_box replace
setblock 2 -60 3 minecraft:magenta_shulker_box replace
setblock 2 -60 5 minecraft:brown_shulker_box replace
setblock 2 -60 7 minecraft:green_shulker_box replace
setblock 2 -60 9 minecraft:white_shulker_box replace
setblock 2 -60 11 minecraft:black_shulker_box replace
setblock 2 -60 13 minecraft:yellow_shulker_box replace
setblock 0 -60 2 minecraft:chest replace
data modify block 0 -60 1 Items set value []
data modify block 0 -60 3 Items set value []
data modify block 0 -60 5 Items set value []
data modify block 0 -60 7 Items set value []
data modify block 0 -60 9 Items set value []
data modify block 0 -60 11 Items set value []
data modify block 0 -60 13 Items set value []
data modify block 0 -60 15 Items set value []
data modify block 2 -60 1 Items set value []
data modify block 2 -60 3 Items set value []
data modify block 2 -60 5 Items set value []
data modify block 2 -60 7 Items set value []
data modify block 2 -60 9 Items set value []
data modify block 2 -60 11 Items set value []
data modify block 2 -60 13 Items set value []
data modify block 0 -60 2 Items set value []
data modify block 0 -60 1 CustomName set value {"text":"fallendream · 盒1 (27 件)","color":"yellow","italic":false}
data modify block 0 -60 3 CustomName set value {"text":"fallendream · 盒2 (27 件)","color":"light_purple","italic":false}
data modify block 0 -60 5 CustomName set value {"text":"fallendream · 盒3 (27 件)","color":"aqua","italic":false}
data modify block 0 -60 7 CustomName set value {"text":"fallendream · 盒4 (27 件)","color":"red","italic":false}
data modify block 0 -60 9 CustomName set value {"text":"fallendream · 盒5 (27 件)","color":"green","italic":false}
data modify block 0 -60 11 CustomName set value {"text":"fallendream · 盒6 (27 件)","color":"blue","italic":false}
data modify block 0 -60 13 CustomName set value {"text":"fallendream · 盒7 (27 件)","color":"gold","italic":false}
data modify block 0 -60 15 CustomName set value {"text":"fallendream · 盒8 (27 件)","color":"light_purple","italic":false}
data modify block 2 -60 1 CustomName set value {"text":"fallendream · 盒9 (27 件)","color":"gray","italic":false}
data modify block 2 -60 3 CustomName set value {"text":"fallendream · 盒10 (27 件)","color":"light_purple","italic":false}
data modify block 2 -60 5 CustomName set value {"text":"fallendream · 盒11 (27 件)","color":"gold","italic":false}
data modify block 2 -60 7 CustomName set value {"text":"fallendream · 盒12 (27 件)","color":"green","italic":false}
data modify block 2 -60 9 CustomName set value {"text":"fallendream · 盒13 (17 件)","color":"white","italic":false}
data modify block 2 -60 11 CustomName set value {"text":"fallendream · 职业装备（27 件）","color":"light_purple","italic":false}
data modify block 2 -60 13 CustomName set value {"text":"fallendream · 职业装备（10 件）","color":"light_purple","italic":false}
#   【兜底提示】要是中转站没建成(区块没加载 / 你不在主世界), 后面全都会
#   静默失败 —— 与其让你以为发了但没给, 不如直接说出来。
execute unless block 0 -60 1 #minecraft:shulker_boxes run tellraw @s [{"text":"[调试] 中转站没建成: 盒子都没发出去。这条只支持主世界, 且那个坐标的区块得是加载的。","color":"red"}]

# ---- ② 借 hotbar.0 当过路位(先把它原本的东西存起来) ----
item replace block 0 -60 2 container.0 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air

# ---- ③ 盒 1: 27 件 ----
function fallendream:equipment/armor/air_step/give
item replace block 0 -60 1 container.0 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/backlight/give
item replace block 0 -60 1 container.1 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/beach_vein/give
item replace block 0 -60 1 container.2 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/bearing/give
item replace block 0 -60 1 container.3 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/blaze_armor/give
item replace block 0 -60 1 container.4 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/boil_trace/give
item replace block 0 -60 1 container.5 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/borrow_fire/give
item replace block 0 -60 1 container.6 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/brain_leech/give
item replace block 0 -60 1 container.7 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/breath_hold/give
item replace block 0 -60 1 container.8 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/breathing_soil/give
item replace block 0 -60 1 container.9 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/bright_candle/give
item replace block 0 -60 1 container.10 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/candle_step/give
item replace block 0 -60 1 container.11 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/char_coat/give
item replace block 0 -60 1 container.12 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/condensed_shell/give
item replace block 0 -60 1 container.13 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/crimson_seam/give
item replace block 0 -60 1 container.14 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/cross_dream/give
item replace block 0 -60 1 container.15 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/dionysus_helmet/give
item replace block 0 -60 1 container.16 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/dongtu/give
item replace block 0 -60 1 container.17 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/dusk_dawn/give
item replace block 0 -60 1 container.18 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/ebb_tide/give
item replace block 0 -60 1 container.19 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/ember/give
item replace block 0 -60 1 container.20 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/empty_camp/give
item replace block 0 -60 1 container.21 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/empty_cicada/give
item replace block 0 -60 1 container.22 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/empty_pillow/give
item replace block 0 -60 1 container.23 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/eternity/give
item replace block 0 -60 1 container.24 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/external_power/give
item replace block 0 -60 1 container.25 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/fade/give
item replace block 0 -60 1 container.26 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air

# ---- ③ 盒 2: 27 件 ----
function fallendream:equipment/armor/falling_deep/give
item replace block 0 -60 3 container.0 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/flesh_mill/give
item replace block 0 -60 3 container.1 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/flint_hat/give
item replace block 0 -60 3 container.2 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/frost_step/give
item replace block 0 -60 3 container.3 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/furnace_core/give
item replace block 0 -60 3 container.4 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/glimmer/give
item replace block 0 -60 3 container.5 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/gyre/give
item replace block 0 -60 3 container.6 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/heart_vein/give
item replace block 0 -60 3 container.7 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/hex_belt/give
item replace block 0 -60 3 container.8 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/huilan/give
item replace block 0 -60 3 container.9 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/immolate/give
item replace block 0 -60 3 container.10 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/intent/give
item replace block 0 -60 3 container.11 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/intravenous_pump/give
item replace block 0 -60 3 container.12 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/iridescent/give
item replace block 0 -60 3 container.13 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/last_breath/give
item replace block 0 -60 3 container.14 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/late_dusk/give
item replace block 0 -60 3 container.15 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/lethe_shore/give
item replace block 0 -60 3 container.16 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/light_pillow/give
item replace block 0 -60 3 container.17 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/lightless_sea/give
item replace block 0 -60 3 container.18 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/lone_walk/give
item replace block 0 -60 3 container.19 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/long_blessing/give
item replace block 0 -60 3 container.20 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/lvshuang/give
item replace block 0 -60 3 container.21 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/mana_helm/give
item replace block 0 -60 3 container.22 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/mana_plate/give
item replace block 0 -60 3 container.23 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/mirage/give
item replace block 0 -60 3 container.24 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/mirror_sleep/give
item replace block 0 -60 3 container.25 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/mottle_vein/give
item replace block 0 -60 3 container.26 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air

# ---- ③ 盒 3: 27 件 ----
function fallendream:equipment/armor/needle_sleep/give
item replace block 0 -60 5 container.0 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/overflow/give
item replace block 0 -60 5 container.1 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/pivot/give
item replace block 0 -60 5 container.2 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/profile/give
item replace block 0 -60 5 container.3 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/purge_fire/give
item replace block 0 -60 5 container.4 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/rain_trace/give
item replace block 0 -60 5 container.5 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/resonance/give
item replace block 0 -60 5 container.6 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/smoke_step/give
item replace block 0 -60 5 container.7 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/spine_symbiote/give
item replace block 0 -60 5 container.8 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/spirit_sight/give
item replace block 0 -60 5 container.9 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/stellar_elegy/give
item replace block 0 -60 5 container.10 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/styx_walk/give
item replace block 0 -60 5 container.11 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/thorn_vein/give
item replace block 0 -60 5 container.12 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/tide_fold/give
item replace block 0 -60 5 container.13 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/tide_watch/give
item replace block 0 -60 5 container.14 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/tread_ash/give
item replace block 0 -60 5 container.15 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/withered_garden/give
item replace block 0 -60 5 container.16 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/zhuzu/give
item replace block 0 -60 5 container.17 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/sword/aurora_dream/give
item replace block 0 -60 5 container.18 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/sword/backflow_tide/give
item replace block 0 -60 5 container.19 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/sword/blind_candle/give
item replace block 0 -60 5 container.20 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/sword/blood_loss/give
item replace block 0 -60 5 container.21 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/sword/chengxing/give
item replace block 0 -60 5 container.22 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/sword/crescent/give
item replace block 0 -60 5 container.23 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/sword/deepsea_echo/give
item replace block 0 -60 5 container.24 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/sword/empty_seat/give
item replace block 0 -60 5 container.25 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/sword/everfrost/give
item replace block 0 -60 5 container.26 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air

# ---- ③ 盒 4: 27 件 ----
function fallendream:equipment/sword/flame_brokenbody/give
item replace block 0 -60 7 container.0 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/sword/gousi/give
item replace block 0 -60 7 container.1 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/sword/grayscale/give
item replace block 0 -60 7 container.2 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/sword/hengdao/give
item replace block 0 -60 7 container.3 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/sword/hush/give
item replace block 0 -60 7 container.4 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/sword/liaoyuan/give
item replace block 0 -60 7 container.5 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/sword/liuguang/give
item replace block 0 -60 7 container.6 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/sword/myriad/give
item replace block 0 -60 7 container.7 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/sword/oath_victory/give
item replace block 0 -60 7 container.8 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/sword/profane/give
item replace block 0 -60 7 container.9 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/sword/qiansan/give
item replace block 0 -60 7 container.10 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/sword/rebound/give
item replace block 0 -60 7 container.11 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/sword/remelt/give
item replace block 0 -60 7 container.12 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/sword/rogue_star/give
item replace block 0 -60 7 container.13 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/sword/shadow_blade/give
item replace block 0 -60 7 container.14 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/sword/sickle_dreams/give
item replace block 0 -60 7 container.15 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/sword/stance/give
item replace block 0 -60 7 container.16 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/sword/thunder_wedge/give
item replace block 0 -60 7 container.17 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/sword/tidemark/give
item replace block 0 -60 7 container.18 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/sword/tinder/give
item replace block 0 -60 7 container.19 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/sword/verdict/give
item replace block 0 -60 7 container.20 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/sword/way_back/give
item replace block 0 -60 7 container.21 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/sword/yebu/give
item replace block 0 -60 7 container.22 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/axe/agony/give
item replace block 0 -60 7 container.23 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/axe/anchor/give
item replace block 0 -60 7 container.24 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/axe/angel_core/give
item replace block 0 -60 7 container.25 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/axe/anion/give
item replace block 0 -60 7 container.26 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air

# ---- ③ 盒 5: 27 件 ----
function fallendream:equipment/axe/azure_star/give
item replace block 0 -60 9 container.0 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/axe/ballad/give
item replace block 0 -60 9 container.1 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/axe/bind_ember/give
item replace block 0 -60 9 container.2 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/axe/broken_page/give
item replace block 0 -60 9 container.3 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/axe/charge/give
item replace block 0 -60 9 container.4 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/axe/chenyuan/give
item replace block 0 -60 9 container.5 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/axe/death_bell/give
item replace block 0 -60 9 container.6 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/axe/deep_brine/give
item replace block 0 -60 9 container.7 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/axe/draught/give
item replace block 0 -60 9 container.8 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/axe/dream_reader/give
item replace block 0 -60 9 container.9 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/axe/fissure/give
item replace block 0 -60 9 container.10 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/axe/frost_carve/give
item replace block 0 -60 9 container.11 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/axe/grace_axe/give
item replace block 0 -60 9 container.12 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/axe/grave_tablet/give
item replace block 0 -60 9 container.13 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/axe/meteor/give
item replace block 0 -60 9 container.14 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/axe/pyre/give
item replace block 0 -60 9 container.15 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/axe/red_lotus/give
item replace block 0 -60 9 container.16 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/axe/sacred_relic/give
item replace block 0 -60 9 container.17 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/axe/scorch_bone/give
item replace block 0 -60 9 container.18 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/axe/skyvault/give
item replace block 0 -60 9 container.19 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/axe/spindle/give
item replace block 0 -60 9 container.20 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/axe/sunken_weight/give
item replace block 0 -60 9 container.21 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/axe/thunderclap/give
item replace block 0 -60 9 container.22 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/axe/xiugou/give
item replace block 0 -60 9 container.23 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/bow/ablation/give
item replace block 0 -60 9 container.24 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/bow/arc/give
item replace block 0 -60 9 container.25 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/bow/backstring/give
item replace block 0 -60 9 container.26 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air

# ---- ③ 盒 6: 27 件 ----
function fallendream:equipment/bow/bone_breaker/give
item replace block 0 -60 11 container.0 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/bow/bone_erode/give
item replace block 0 -60 11 container.1 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/bow/burst_dawn/give
item replace block 0 -60 11 container.2 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/bow/cloudtrail/give
item replace block 0 -60 11 container.3 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/bow/cold_crow/give
item replace block 0 -60 11 container.4 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/bow/dark_sun/give
item replace block 0 -60 11 container.5 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/bow/dragon_tongue/give
item replace block 0 -60 11 container.6 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/bow/ember_string/give
item replace block 0 -60 11 container.7 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/bow/feather_sleep/give
item replace block 0 -60 11 container.8 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/bow/lianshi/give
item replace block 0 -60 11 container.9 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/bow/lucid_dream/give
item replace block 0 -60 11 container.10 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/bow/night_bind/give
item replace block 0 -60 11 container.11 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/bow/rainbow/give
item replace block 0 -60 11 container.12 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/bow/reverse_string/give
item replace block 0 -60 11 container.13 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/bow/sculk_echo/give
item replace block 0 -60 11 container.14 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/bow/tiejili/give
item replace block 0 -60 11 container.15 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/staff/apocalypse/give
item replace block 0 -60 11 container.16 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/staff/begonia/give
item replace block 0 -60 11 container.17 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/staff/bent_ray/give
item replace block 0 -60 11 container.18 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/staff/burst_bank/give
item replace block 0 -60 11 container.19 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/staff/cage_day/give
item replace block 0 -60 11 container.20 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/staff/chime/give
item replace block 0 -60 11 container.21 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/staff/delusion/give
item replace block 0 -60 11 container.22 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/staff/eight_tail/give
item replace block 0 -60 11 container.23 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/staff/exalted/give
item replace block 0 -60 11 container.24 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/staff/fallen_dream/give
item replace block 0 -60 11 container.25 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/staff/fate_thread/give
item replace block 0 -60 11 container.26 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air

# ---- ③ 盒 7: 27 件 ----
function fallendream:equipment/staff/final_revelation/give
item replace block 0 -60 13 container.0 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/staff/firefly_staff/give
item replace block 0 -60 13 container.1 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/staff/five_curses/give
item replace block 0 -60 13 container.2 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/staff/gu_poison/give
item replace block 0 -60 13 container.3 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/staff/late_court/give
item replace block 0 -60 13 container.4 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/staff/long_night/give
item replace block 0 -60 13 container.5 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/staff/long_wish/give
item replace block 0 -60 13 container.6 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/staff/other_shore/give
item replace block 0 -60 13 container.7 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/staff/palette/give
item replace block 0 -60 13 container.8 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/staff/polarized_light/give
item replace block 0 -60 13 container.9 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/staff/pour_sack/give
item replace block 0 -60 13 container.10 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/staff/renew_fire/give
item replace block 0 -60 13 container.11 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/staff/sail/give
item replace block 0 -60 13 container.12 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/staff/stop_needle/give
item replace block 0 -60 13 container.13 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/staff/symphony/give
item replace block 0 -60 13 container.14 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/staff/thunderrod/give
item replace block 0 -60 13 container.15 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/staff/triad/give
item replace block 0 -60 13 container.16 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/staff/twilight/give
item replace block 0 -60 13 container.17 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/staff/wake_bell/give
item replace block 0 -60 13 container.18 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/staff/wind_ontheground/give
item replace block 0 -60 13 container.19 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/tool/bitter_cold/give
item replace block 0 -60 13 container.20 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/tool/blaze_plume/give
item replace block 0 -60 13 container.21 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/tool/coffin_silk/give
item replace block 0 -60 13 container.22 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/tool/everlit/give
item replace block 0 -60 13 container.23 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/tool/frostmirror/give
item replace block 0 -60 13 container.24 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/tool/look/give
item replace block 0 -60 13 container.25 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/tool/mana_pump/give
item replace block 0 -60 13 container.26 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air

# ---- ③ 盒 8: 27 件 ----
function fallendream:equipment/tool/nullify/give
item replace block 0 -60 15 container.0 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/tool/retro_shine/give
item replace block 0 -60 15 container.1 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/tool/seraph_wing/give
item replace block 0 -60 15 container.2 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/tool/sip_frost/give
item replace block 0 -60 15 container.3 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/tool/thunder/give
item replace block 0 -60 15 container.4 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/tool/tide_buckle/give
item replace block 0 -60 15 container.5 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/tool/wrath/give
item replace block 0 -60 15 container.6 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:upgrade/item/boil
item replace block 0 -60 15 container.7 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:upgrade/item/breach_a
item replace block 0 -60 15 container.8 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:upgrade/item/breach_b
item replace block 0 -60 15 container.9 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:upgrade/item/breach_o
item replace block 0 -60 15 container.10 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:upgrade/item/coolant_a
item replace block 0 -60 15 container.11 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:upgrade/item/coolant_b
item replace block 0 -60 15 container.12 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:upgrade/item/coolant_o
item replace block 0 -60 15 container.13 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:upgrade/item/harden_a
item replace block 0 -60 15 container.14 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:upgrade/item/harden_b
item replace block 0 -60 15 container.15 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:upgrade/item/harden_o
item replace block 0 -60 15 container.16 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:upgrade/item/life_up_a
item replace block 0 -60 15 container.17 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:upgrade/item/life_up_b
item replace block 0 -60 15 container.18 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:upgrade/item/life_up_o
item replace block 0 -60 15 container.19 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:upgrade/item/mana_gain_a
item replace block 0 -60 15 container.20 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:upgrade/item/mana_gain_b
item replace block 0 -60 15 container.21 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:upgrade/item/mana_gain_o
item replace block 0 -60 15 container.22 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:upgrade/item/mana_surge_a
item replace block 0 -60 15 container.23 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:upgrade/item/mana_surge_b
item replace block 0 -60 15 container.24 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:upgrade/item/mana_surge_o
item replace block 0 -60 15 container.25 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:upgrade/item/mana_up_a
item replace block 0 -60 15 container.26 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air

# ---- ③ 盒 9: 27 件 ----
function fallendream:upgrade/item/mana_up_b
item replace block 2 -60 1 container.0 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:upgrade/item/mana_up_o
item replace block 2 -60 1 container.1 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:upgrade/item/neuro_a
item replace block 2 -60 1 container.2 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:upgrade/item/neuro_b
item replace block 2 -60 1 container.3 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:upgrade/item/neuro_o
item replace block 2 -60 1 container.4 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:upgrade/item/night_vision
item replace block 2 -60 1 container.5 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:upgrade/item/torch
item replace block 2 -60 1 container.6 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:upgrade/item/uncolor
item replace block 2 -60 1 container.7 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:upgrade/item/vision_a
item replace block 2 -60 1 container.8 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:upgrade/item/vision_b
item replace block 2 -60 1 container.9 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:upgrade/item/vision_o
item replace block 2 -60 1 container.10 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/agony
item replace block 2 -60 1 container.11 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/air_step
item replace block 2 -60 1 container.12 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/anchor
item replace block 2 -60 1 container.13 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/angel_core
item replace block 2 -60 1 container.14 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/anion
item replace block 2 -60 1 container.15 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/apocalypse
item replace block 2 -60 1 container.16 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/arc
item replace block 2 -60 1 container.17 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/backflow_tide
item replace block 2 -60 1 container.18 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/backstring
item replace block 2 -60 1 container.19 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/ballad
item replace block 2 -60 1 container.20 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/beach_vein
item replace block 2 -60 1 container.21 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/bearing
item replace block 2 -60 1 container.22 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/begonia
item replace block 2 -60 1 container.23 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/bent_ray
item replace block 2 -60 1 container.24 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/bind_ember
item replace block 2 -60 1 container.25 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/blaze_armor
item replace block 2 -60 1 container.26 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air

# ---- ③ 盒 10: 27 件 ----
function fallendream:overlimit/item/boil_trace
item replace block 2 -60 3 container.0 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/bone_breaker
item replace block 2 -60 3 container.1 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/bone_erode
item replace block 2 -60 3 container.2 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/brain_leech
item replace block 2 -60 3 container.3 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/breath_hold
item replace block 2 -60 3 container.4 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/breathing_soil
item replace block 2 -60 3 container.5 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/burst_bank
item replace block 2 -60 3 container.6 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/cage_day
item replace block 2 -60 3 container.7 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/cease_war
item replace block 2 -60 3 container.8 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/char_coat
item replace block 2 -60 3 container.9 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/charge
item replace block 2 -60 3 container.10 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/chengxing
item replace block 2 -60 3 container.11 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/chenyuan
item replace block 2 -60 3 container.12 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/chime
item replace block 2 -60 3 container.13 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/cold_crow
item replace block 2 -60 3 container.14 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/condensed_shell
item replace block 2 -60 3 container.15 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/crimson_seam
item replace block 2 -60 3 container.16 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/cross_dream
item replace block 2 -60 3 container.17 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/dark_sun
item replace block 2 -60 3 container.18 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/death_bell
item replace block 2 -60 3 container.19 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/deep_brine
item replace block 2 -60 3 container.20 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/deepsea_echo
item replace block 2 -60 3 container.21 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/detach
item replace block 2 -60 3 container.22 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/dionysus_helmet
item replace block 2 -60 3 container.23 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/dragon_tongue
item replace block 2 -60 3 container.24 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/draught
item replace block 2 -60 3 container.25 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/dream_reader
item replace block 2 -60 3 container.26 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air

# ---- ③ 盒 11: 27 件 ----
function fallendream:overlimit/item/dusk_dawn
item replace block 2 -60 5 container.0 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/eagle_hat
item replace block 2 -60 5 container.1 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/ember_string
item replace block 2 -60 5 container.2 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/empty_camp
item replace block 2 -60 5 container.3 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/empty_cicada
item replace block 2 -60 5 container.4 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/everfrost
item replace block 2 -60 5 container.5 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/external_power
item replace block 2 -60 5 container.6 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/fade
item replace block 2 -60 5 container.7 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/fallen_dream
item replace block 2 -60 5 container.8 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/fate_thread
item replace block 2 -60 5 container.9 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/feather_sleep
item replace block 2 -60 5 container.10 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/firefly_staff
item replace block 2 -60 5 container.11 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/fissure
item replace block 2 -60 5 container.12 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/five_curses
item replace block 2 -60 5 container.13 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/flame_brokenbody
item replace block 2 -60 5 container.14 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/flesh_mill
item replace block 2 -60 5 container.15 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/flint_hat
item replace block 2 -60 5 container.16 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/frost_carve
item replace block 2 -60 5 container.17 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/furnace_core
item replace block 2 -60 5 container.18 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/gather_energy
item replace block 2 -60 5 container.19 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/gousi
item replace block 2 -60 5 container.20 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/grayscale
item replace block 2 -60 5 container.21 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/hengdao
item replace block 2 -60 5 container.22 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/intent
item replace block 2 -60 5 container.23 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/intone
item replace block 2 -60 5 container.24 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/intravenous_pump
item replace block 2 -60 5 container.25 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/last_breath
item replace block 2 -60 5 container.26 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air

# ---- ③ 盒 12: 27 件 ----
function fallendream:overlimit/item/light_pillow
item replace block 2 -60 7 container.0 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/liuguang
item replace block 2 -60 7 container.1 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/lvshuang
item replace block 2 -60 7 container.2 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/magic_theory
item replace block 2 -60 7 container.3 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/mana_imbue
item replace block 2 -60 7 container.4 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/meteor
item replace block 2 -60 7 container.5 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/mirror_sleep
item replace block 2 -60 7 container.6 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/mottle_vein
item replace block 2 -60 7 container.7 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/myriad
item replace block 2 -60 7 container.8 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/needle_sleep
item replace block 2 -60 7 container.9 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/overflow
item replace block 2 -60 7 container.10 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/pierce
item replace block 2 -60 7 container.11 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/pivot
item replace block 2 -60 7 container.12 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/polarized_light
item replace block 2 -60 7 container.13 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/pour_sack
item replace block 2 -60 7 container.14 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/profane
item replace block 2 -60 7 container.15 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/purge_fire
item replace block 2 -60 7 container.16 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/rain_trace
item replace block 2 -60 7 container.17 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/rebirth_veil
item replace block 2 -60 7 container.18 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/rebound
item replace block 2 -60 7 container.19 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/red_lotus
item replace block 2 -60 7 container.20 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/resonance
item replace block 2 -60 7 container.21 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/reverse_string
item replace block 2 -60 7 container.22 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/rogue_star
item replace block 2 -60 7 container.23 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/scorch_bone
item replace block 2 -60 7 container.24 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/sculk_echo
item replace block 2 -60 7 container.25 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/shadow_blade
item replace block 2 -60 7 container.26 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air

# ---- ③ 盒 13: 17 件 ----
function fallendream:overlimit/item/sickle_dreams
item replace block 2 -60 9 container.0 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/skyvault
item replace block 2 -60 9 container.1 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/smoke_step
item replace block 2 -60 9 container.2 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/spine_symbiote
item replace block 2 -60 9 container.3 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/spirit_sight
item replace block 2 -60 9 container.4 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/stellar_elegy
item replace block 2 -60 9 container.5 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/still_sky
item replace block 2 -60 9 container.6 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/thorn_vein
item replace block 2 -60 9 container.7 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/thunder_wedge
item replace block 2 -60 9 container.8 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/thunderrod
item replace block 2 -60 9 container.9 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/tide_watch
item replace block 2 -60 9 container.10 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/tidemark
item replace block 2 -60 9 container.11 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/tinder
item replace block 2 -60 9 container.12 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/tread_ash
item replace block 2 -60 9 container.13 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/way_back
item replace block 2 -60 9 container.14 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/xiugou
item replace block 2 -60 9 container.15 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:overlimit/item/yebu
item replace block 2 -60 9 container.16 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air

# ---- ③ 盒 14: 27 件 ----
function fallendream:equipment/armor/bulwark/give
item replace block 2 -60 11 container.0 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/cease_war/give
item replace block 2 -60 11 container.1 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/eagle_hat/give
item replace block 2 -60 11 container.2 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/rebirth_veil/give
item replace block 2 -60 11 container.3 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/armor/still_sky/give
item replace block 2 -60 11 container.4 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/sword/aftersound/give
item replace block 2 -60 11 container.5 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/sword/contract_rift/give
item replace block 2 -60 11 container.6 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/sword/empathy/give
item replace block 2 -60 11 container.7 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/sword/gather_energy/give
item replace block 2 -60 11 container.8 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/sword/illusion/give
item replace block 2 -60 11 container.9 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/sword/mana_imbue/give
item replace block 2 -60 11 container.10 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/sword/mirrored_scene/give
item replace block 2 -60 11 container.11 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/sword/refrain/give
item replace block 2 -60 11 container.12 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/sword/sacrifice/give
item replace block 2 -60 11 container.13 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/sword/wound_stack/give
item replace block 2 -60 11 container.14 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/sword/wound_stitch/give
item replace block 2 -60 11 container.15 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/axe/chase_deer/give
item replace block 2 -60 11 container.16 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/axe/detach/give
item replace block 2 -60 11 container.17 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/axe/no_return/give
item replace block 2 -60 11 container.18 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/axe/throe/give
item replace block 2 -60 11 container.19 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/bow/pierce/give
item replace block 2 -60 11 container.20 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/staff/chorus/give
item replace block 2 -60 11 container.21 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/staff/foresight/give
item replace block 2 -60 11 container.22 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/staff/indwell/give
item replace block 2 -60 11 container.23 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/staff/intone/give
item replace block 2 -60 11 container.24 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/staff/lucid_illusion/give
item replace block 2 -60 11 container.25 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/staff/magic_theory/give
item replace block 2 -60 11 container.26 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air

# ---- ③ 盒 15: 10 件 ----
function fallendream:equipment/staff/mana_crystal/give
item replace block 2 -60 13 container.0 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/staff/self_mind/give
item replace block 2 -60 13 container.1 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/staff/skyfire/give
item replace block 2 -60 13 container.2 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/staff/star_burial/give
item replace block 2 -60 13 container.3 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/staff/star_weave/give
item replace block 2 -60 13 container.4 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/staff/surge_ebb/give
item replace block 2 -60 13 container.5 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/staff/world_parting/give
item replace block 2 -60 13 container.6 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/tool/dream_waker/give
item replace block 2 -60 13 container.7 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/tool/echo_harmony/give
item replace block 2 -60 13 container.8 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function fallendream:equipment/tool/grimoire/give
item replace block 2 -60 13 container.9 from entity @s hotbar.0
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
loot give @s mine 0 -60 13 minecraft:diamond_pickaxe
loot give @s mine 0 -60 15 minecraft:diamond_pickaxe
loot give @s mine 2 -60 1 minecraft:diamond_pickaxe
loot give @s mine 2 -60 3 minecraft:diamond_pickaxe
loot give @s mine 2 -60 5 minecraft:diamond_pickaxe
loot give @s mine 2 -60 7 minecraft:diamond_pickaxe
loot give @s mine 2 -60 9 minecraft:diamond_pickaxe
loot give @s mine 2 -60 11 minecraft:diamond_pickaxe
loot give @s mine 2 -60 13 minecraft:diamond_pickaxe

# ---- ⑥ 收尾: 拆掉中转站 ----
setblock 0 -60 1 minecraft:air replace
setblock 0 -60 3 minecraft:air replace
setblock 0 -60 5 minecraft:air replace
setblock 0 -60 7 minecraft:air replace
setblock 0 -60 9 minecraft:air replace
setblock 0 -60 11 minecraft:air replace
setblock 0 -60 13 minecraft:air replace
setblock 0 -60 15 minecraft:air replace
setblock 2 -60 1 minecraft:air replace
setblock 2 -60 3 minecraft:air replace
setblock 2 -60 5 minecraft:air replace
setblock 2 -60 7 minecraft:air replace
setblock 2 -60 9 minecraft:air replace
setblock 2 -60 11 minecraft:air replace
setblock 2 -60 13 minecraft:air replace
setblock 0 -60 2 minecraft:air replace
tellraw @s [{"text":"[调试] 已发: 378 件东西, 共 15 个盒子。","color":"dark_gray"}]
