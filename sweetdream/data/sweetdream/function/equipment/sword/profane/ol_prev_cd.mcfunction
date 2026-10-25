# ============================================================
# sweetdream:equipment/sword/profane/ol_prev_cd —— 超限·剖心: "排在剖心前面的武器"冷却 -10 秒
# ------------------------------------------------------------
# 【谁调用它】profane/cast ⑧'(本次清掉 **6 个及以上**「噬心」时)
# 【执行者】施法者玩家   【位置】他所在处
# 【原文】"若本次清除的「噬心」数量大于5个则使该武器前面的武器冷却时间减少10秒。"
# 【"前面"怎么定】
#   剖心能放技能就一定是**拿在手上**的, 所以它必在快捷栏第 0~8 格。
#   读 `SelectedItemSlot` 得到 S, 则"排在它前面"= 快捷栏 Slot **0..S-1**。
#   ★ 只看快捷栏(0..8)。主背包(9..35)没有"前后"概念, 设计说的就是 hotbar 顺序。
#   ★ 每格认人的方式是 `components."minecraft:custom_data".skill` ——
#     包内"有右键主动"的武器才会带这个字段, 和右键进度是 1:1 的;
#     纯被动件没有冷却, 减了也没有意义, 所以不需要特别排除。
# 【怎么减】manacore:api/cooldown/reduce **只减已存在的冷却记录**, 不会凭空创建 ——
#   于是"前面那把武器此刻没在冷却"就是空操作, 正好是要的语义。
# 【为什么手写 8 段而不是宏】
#   ① 宏"写源 + 用 $(i) 同层"有坑(RULES 96), 这里没必要冒;
#   ② 前驱最多 8 个, 手写清清楚楚。写法照 crescent/cap(同样是"遍历快捷栏读 skill")。
# 【★ 不许用 return ★】return 会**整段退出**本函数, 后面 7 个槽就不看了 ——
#   所以"跳过"全部写在**该槽自己那几行**的条件里。
# 【收尸】zx:work pfo.skill 每槽前先 remove, 不留上一格的残值(否则空槽会顶着上一格的
#   skill 再减一次, 同一把武器被减 2~8 次)。
# ============================================================

# ① 剖心在快捷栏第几格(0..8)
execute store result score @s zx.pf_slot run data get entity @s SelectedItemSlot

# ② 公共参数(只设一次; skill 每槽覆盖, seconds 全程 10 秒)
data modify storage manacore:in arg set value {uuid:"",skill:"",seconds:10.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid

# ---- 槽 0(只有剖心在 1..8 号槽时, 它才算"排在前面")----
data remove storage zx:work pfo.skill
execute if score @s zx.pf_slot matches 1.. if data entity @s Inventory[{Slot:0b}].components."minecraft:custom_data".skill run data modify storage zx:work pfo.skill set from entity @s Inventory[{Slot:0b}].components."minecraft:custom_data".skill
execute if data storage zx:work pfo.skill run data modify storage manacore:in arg.skill set from storage zx:work pfo.skill
execute if data storage zx:work pfo.skill run function manacore:api/cooldown/reduce

# ---- 槽 1 ----
data remove storage zx:work pfo.skill
execute if score @s zx.pf_slot matches 2.. if data entity @s Inventory[{Slot:1b}].components."minecraft:custom_data".skill run data modify storage zx:work pfo.skill set from entity @s Inventory[{Slot:1b}].components."minecraft:custom_data".skill
execute if data storage zx:work pfo.skill run data modify storage manacore:in arg.skill set from storage zx:work pfo.skill
execute if data storage zx:work pfo.skill run function manacore:api/cooldown/reduce

# ---- 槽 2 ----
data remove storage zx:work pfo.skill
execute if score @s zx.pf_slot matches 3.. if data entity @s Inventory[{Slot:2b}].components."minecraft:custom_data".skill run data modify storage zx:work pfo.skill set from entity @s Inventory[{Slot:2b}].components."minecraft:custom_data".skill
execute if data storage zx:work pfo.skill run data modify storage manacore:in arg.skill set from storage zx:work pfo.skill
execute if data storage zx:work pfo.skill run function manacore:api/cooldown/reduce

# ---- 槽 3 ----
data remove storage zx:work pfo.skill
execute if score @s zx.pf_slot matches 4.. if data entity @s Inventory[{Slot:3b}].components."minecraft:custom_data".skill run data modify storage zx:work pfo.skill set from entity @s Inventory[{Slot:3b}].components."minecraft:custom_data".skill
execute if data storage zx:work pfo.skill run data modify storage manacore:in arg.skill set from storage zx:work pfo.skill
execute if data storage zx:work pfo.skill run function manacore:api/cooldown/reduce

# ---- 槽 4 ----
data remove storage zx:work pfo.skill
execute if score @s zx.pf_slot matches 5.. if data entity @s Inventory[{Slot:4b}].components."minecraft:custom_data".skill run data modify storage zx:work pfo.skill set from entity @s Inventory[{Slot:4b}].components."minecraft:custom_data".skill
execute if data storage zx:work pfo.skill run data modify storage manacore:in arg.skill set from storage zx:work pfo.skill
execute if data storage zx:work pfo.skill run function manacore:api/cooldown/reduce

# ---- 槽 5 ----
data remove storage zx:work pfo.skill
execute if score @s zx.pf_slot matches 6.. if data entity @s Inventory[{Slot:5b}].components."minecraft:custom_data".skill run data modify storage zx:work pfo.skill set from entity @s Inventory[{Slot:5b}].components."minecraft:custom_data".skill
execute if data storage zx:work pfo.skill run data modify storage manacore:in arg.skill set from storage zx:work pfo.skill
execute if data storage zx:work pfo.skill run function manacore:api/cooldown/reduce

# ---- 槽 6 ----
data remove storage zx:work pfo.skill
execute if score @s zx.pf_slot matches 7.. if data entity @s Inventory[{Slot:6b}].components."minecraft:custom_data".skill run data modify storage zx:work pfo.skill set from entity @s Inventory[{Slot:6b}].components."minecraft:custom_data".skill
execute if data storage zx:work pfo.skill run data modify storage manacore:in arg.skill set from storage zx:work pfo.skill
execute if data storage zx:work pfo.skill run function manacore:api/cooldown/reduce

# ---- 槽 7(剖心在 8 号槽时, 7 号槽才算前面)----
data remove storage zx:work pfo.skill
execute if score @s zx.pf_slot matches 8.. if data entity @s Inventory[{Slot:7b}].components."minecraft:custom_data".skill run data modify storage zx:work pfo.skill set from entity @s Inventory[{Slot:7b}].components."minecraft:custom_data".skill
execute if data storage zx:work pfo.skill run data modify storage manacore:in arg.skill set from storage zx:work pfo.skill
execute if data storage zx:work pfo.skill run function manacore:api/cooldown/reduce

# 表现: 快捷栏方向掠过一道青色冷光, 让"前面的武器被带了一下"看得见
execute at @s run particle minecraft:dust{color:[0.2,0.75,0.85],scale:1.0} ~ ~1 ~ 0.7 0.3 0.7 0.01 16 normal
execute at @s run playsound minecraft:block.amethyst_block.chime player @a ~ ~ ~ 0.5 1.6
