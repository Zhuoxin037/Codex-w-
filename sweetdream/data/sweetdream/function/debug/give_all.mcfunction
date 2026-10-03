# ============================================================
# sweetdream:debug/give_all —— 把「至今全部的东西」打包成潜影盒给自己
# ------------------------------------------------------------
# 【这个文件是生成的】改了物品 / 加了新装备, 重跑:
#     python .workbuddy/_gen_give_all.py
# 【用法】/function sweetdream:debug/give_all   或   /trigger zx.dbg_give
#
# 【为什么是两个盒子】潜影盒只有 27 格, 而东西一共 28 件
#   (21 件装备 + 7 块强化石) —— 所以拆成「装备全集」和「强化材料」两盒。
#
# 【怎么做到的】走一个方块当中转站:
#   ① 0,-60,1 / 0,-60,3 放两个空潜影盒方块(和强化台 0,-59,2 错开、同一个区块)
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

# ---- ① 中转站: 两个潜影盒 + 一个暂存箱 ----
#   【为什么用染色潜影盒】就算名字没写上(见下), 颜色也能一眼分清哪个是哪个。
setblock 0 -60 1 minecraft:yellow_shulker_box replace
setblock 0 -60 3 minecraft:purple_shulker_box replace
setblock 0 -60 2 minecraft:chest replace
data modify block 0 -60 1 Items set value []
data modify block 0 -60 3 Items set value []
data modify block 0 -60 2 Items set value []
data modify block 0 -60 1 CustomName set value {"text":"sweetdream · 装备全集 (21)","color":"gold","italic":false}
data modify block 0 -60 3 CustomName set value {"text":"sweetdream · 强化材料 (7)","color":"light_purple","italic":false}
#   【兜底提示】要是中转站没建成(区块没加载 / 你不在主世界), 后面全都会
#   静默失败 —— 与其让你以为发了但没给, 不如直接说出来。
execute unless block 0 -60 1 #minecraft:shulker_boxes run tellraw @s [{"text":"[调试] 中转站没建成: 两个盒子都没发出去。这条只支持主世界, 且那个坐标的区块得是加载的。","color":"red"}]

# ---- ② 借 hotbar.0 当过路位(先把它原本的东西存起来) ----
item replace block 0 -60 2 container.0 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air

# ---- ③ 盒 A: 装备全集 (21 件) ----
function sweetdream:equipment/armor/brain_leech/give
item replace block 0 -60 1 container.0 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/armor/dionysus_helmet/give
item replace block 0 -60 1 container.1 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/armor/dusk_dawn/give
item replace block 0 -60 1 container.2 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/armor/ember/give
item replace block 0 -60 1 container.3 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/armor/external_power/give
item replace block 0 -60 1 container.4 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/armor/immolate/give
item replace block 0 -60 1 container.5 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/armor/intravenous_pump/give
item replace block 0 -60 1 container.6 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/armor/iridescent/give
item replace block 0 -60 1 container.7 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/armor/mirage/give
item replace block 0 -60 1 container.8 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/armor/spine_symbiote/give
item replace block 0 -60 1 container.9 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/armor/stellar_elegy/give
item replace block 0 -60 1 container.10 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/sword/deepsea_echo/give
item replace block 0 -60 1 container.11 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/sword/flame_brokenbody/give
item replace block 0 -60 1 container.12 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/sword/hengdao/give
item replace block 0 -60 1 container.13 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/sword/liaoyuan/give
item replace block 0 -60 1 container.14 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/sword/liuguang/give
item replace block 0 -60 1 container.15 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/sword/sickle_dreams/give
item replace block 0 -60 1 container.16 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/axe/charge/give
item replace block 0 -60 1 container.17 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/bow/cold_crow/give
item replace block 0 -60 1 container.18 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/staff/wind_ontheground/give
item replace block 0 -60 1 container.19 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:equipment/tool/look/give
item replace block 0 -60 1 container.20 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air

# ---- ④ 盒 B: 强化材料 (7 块) ----
function sweetdream:upgrade/item/mana_gain_a
item replace block 0 -60 3 container.0 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:upgrade/item/mana_gain_b
item replace block 0 -60 3 container.1 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:upgrade/item/mana_gain_o
item replace block 0 -60 3 container.2 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:upgrade/item/mana_up_a
item replace block 0 -60 3 container.3 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:upgrade/item/mana_up_b
item replace block 0 -60 3 container.4 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:upgrade/item/mana_up_o
item replace block 0 -60 3 container.5 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air
function sweetdream:overlimit/item/liuguang
item replace block 0 -60 3 container.6 from entity @s hotbar.0
item replace entity @s hotbar.0 with minecraft:air

# ---- ⑤ 先把玩家原本的 hotbar.0 还回去(再发盒子, 免得被顶掉) ----
item replace entity @s hotbar.0 from block 0 -60 2 container.0

# ---- ⑥ 把两个盒子挖下来给自己 ----
loot give @s mine 0 -60 1 minecraft:diamond_pickaxe
loot give @s mine 0 -60 3 minecraft:diamond_pickaxe

# ---- ⑦ 收尾: 拆掉中转站 ----
setblock 0 -60 1 minecraft:air replace
setblock 0 -60 2 minecraft:air replace
setblock 0 -60 3 minecraft:air replace
tellraw @s [{"text":"[调试] 已发: ","color":"dark_gray"},{"text":"装备全集","color":"gold"},{"text":" ×1 (21 件)  +  ","color":"dark_gray"},{"text":"强化材料","color":"light_purple"},{"text":" ×1 (7 块)","color":"dark_gray"}]
