# ============================================================
# fallendream:equipment/armor/breathing_soil/on_hurt —— 息土（钻胸甲 · 被动）
# ------------------------------------------------------------
# 【触发】玩家受到伤害（advancement entity_hurt_player）
# 【技能原文】
#   "自身生命值降至最大生命值 30% 以下时，召唤一个术阵，之后召唤一个半径 8 格的领域，
#    持续 12 秒。该效果 60 秒内最多触发一次。
#    在领域中自身每秒恢复 3 点生命值；每次受到伤害时恢复 1 点生命值，该效果 2 秒内最多触发一次。"
# 【★ 领域实现：跟随自身，不用 marker ★】
#   半径 8 的判定在命令里要靠"圆心"，而设计原文是"脚下长出一圈地，你站在里面回血"——
#   把这个圆挂在自己脚上（每秒以自身位置为圆心判定/显示）比钉死一个 marker 更贴文案，
#   也省掉一层"marker → 找 owner 玩家"的宏查询。计时用 zx.so_ft（秒），见 lib/second。
# 【血量判定】Health×100 < max_health×30（定点比较，不用浮点）。
#   ★ max_health 读**原版属性当前值**，所以被 lib/heal 临时压低上限时不会误判 ——
#     但那种窗口只有 1~2 拍，且本函数只在自己掉血时被调用，实际碰不到。
# ============================================================
advancement revoke @s only fallendream:equipment/armor/breathing_soil_hurt

execute unless items entity @s armor.chest *[minecraft:custom_data~{zx:["breathing_soil"]}] run return 0

# ①.5 分档: 超限·息土(2026-11-22)
#   【文案(逐字)】"自身最大生命值 +20%。自身生命值降至最大生命值 30% 以下时，召唤一个
#     术阵，之后召唤一个半径 8 格的领域，持续 12 秒。该效果 40 秒内最多触发一次。
#     在领域中自身每秒恢复 4 点生命值；每次受到伤害时恢复 1 点生命值，之后使该装备的
#     冷却时间 -1 秒，该效果 0.5 秒内最多触发一次。领域结束时自身若还在领域内则自身
#     恢复 12% 生命值，若生命值已满则该装备的冷却时间 -10 秒。"
#   与基础版差: 多 +20% 生命 / 节流 60->40 秒 / 每秒 3->4 点 / 受伤回血节流 2->0.5 秒
#               并额外减 1 秒冷却 / 领域结束结算(回 12% 或减 10 秒冷却)。
scoreboard players set #so_ol zx.meta 0
execute if items entity @s armor.chest *[minecraft:custom_data~{zx:["breathing_soil"],ol:"breathing_soil"}] run scoreboard players set #so_ol zx.meta 1

# 领域已经在：每次受伤回 1 点（2 秒一次），走 lib/heal（坑 199）
execute if score @s zx.so_ft matches 1.. run function fallendream:equipment/armor/breathing_soil/hurt_heal

# 已经在领域里就不重复触发
execute if score @s zx.so_ft matches 1.. run return 0

# 60 秒限频
execute if score @s zx.so_cd > #now manacore.meta run return 0

# 血量 ≤ 30% 才触发
scoreboard players set #so_hp zx.meta 0
execute store result score #so_hp zx.meta run data get entity @s Health 1000
scoreboard players set #so_mx zx.meta 0
execute store result score #so_mx zx.meta run attribute @s minecraft:max_health get 1000
execute if entity @s[tag=zx.nr_clamp] run function fallendream:lib/max_health_score
execute if entity @s[tag=zx.nr_clamp] run scoreboard players operation #so_mx zx.meta = #max_hp zx.meta
scoreboard players operation #so_l zx.meta = #so_hp zx.meta
scoreboard players operation #so_l zx.meta *= #100 zx.meta
scoreboard players operation #so_m zx.meta = #so_mx zx.meta
scoreboard players operation #so_m zx.meta *= #30 zx.meta
execute if score #so_l zx.meta >= #so_m zx.meta run return 0

# ---- 触发 ----
function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

scoreboard players set @s zx.so_ft 12
scoreboard players operation @s zx.so_cd = #now manacore.meta
scoreboard players add @s zx.so_cd 1200
# 超限: 节流 60 秒 -> 40 秒（= 800 刻）
execute if score #so_ol zx.meta matches 1 run scoreboard players operation @s zx.so_cd = #now manacore.meta
execute if score #so_ol zx.meta matches 1 run scoreboard players add @s zx.so_cd 800

# 超限第三段要判"领域结束时还在不在领域内" ⇒ 把开阵这一刻的坐标记账(x100 定点)。
#   ★ 领域是"半径 8 格" ⇒ 结束时三个轴都在 ±800 以内就算还在里面。
#   ★ zx.so_ol 是"这一轮领域是不是超限档"的快照 —— 领域结束那一刻玩家可能已经换掉胸甲,
#     不能到那时再读 items(那会让结算凭空消失)。
scoreboard players set @s zx.so_ol 0
execute if score #so_ol zx.meta matches 1 run scoreboard players set @s zx.so_ol 1
execute if score #so_ol zx.meta matches 1 store result score @s zx.so_x run data get entity @s Pos[0] 100
execute if score #so_ol zx.meta matches 1 store result score @s zx.so_y run data get entity @s Pos[1] 100
execute if score #so_ol zx.meta matches 1 store result score @s zx.so_z run data get entity @s Pos[2] 100

# 术阵（框架登记；上限满不影响技能本身，与长夜同一口径）
data modify storage manacore:in arg set value {uuid:"",id:"fallendream:breathing_soil",type:"soil",duration_seconds:12.0,data:{radius:8.0}}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/formation/create

execute at @s run playsound minecraft:block.rooted_dirt.break player @a ~ ~ ~ 0.9 0.7
execute at @s run particle minecraft:block{block_state:"minecraft:moss_block"} ~ ~0.1 ~ 4.0 0.1 4.0 0.02 40 normal
execute at @s run particle minecraft:dust{color:[0.35,0.55,0.3],scale:1.4} ~ ~0.3 ~ 6.0 0.3 6.0 0.01 40 normal
