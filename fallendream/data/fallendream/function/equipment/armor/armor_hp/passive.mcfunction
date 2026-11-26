# ============================================================
# fallendream:equipment/armor/armor_hp/passive —— 重算"该有多少生命上限加成"
# ------------------------------------------------------------
# 【执行者】每个玩家（second 用 `as @a` 送进来）
# 【入参/出参】#want = 本秒该有的总加成；与账本 @s zx.ah_hp 比差值 -> apply
# 【口径(逐字对 lore)】
#   · 沸痕(胸甲) +4
#   ★ 每加一件，往 ① 里加一行 + 在注释里补一行；账本是差值制的，不必改别处。
# 【★ 生命上限要改两个地方 ★】(同 external_power/apply_hp 的说明)
#   ① 面板 max_health（技能伤害公式读它）
#   ② 原版属性 minecraft:max_health（真正的血条长度）
#   只有面板变了是"账本好看而已"，血条不会变长。
# ============================================================

function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ---- ① 各件加成 ----
scoreboard players set #want zx.meta 0
execute if items entity @s armor.chest *[minecraft:custom_data~{zx:["boil_trace"]}] run scoreboard players add #want zx.meta 4
#   超限·沸痕 +8（基础 4 之上再加 4）；另有一条"额外 +10%"，见 ⑤
execute if items entity @s armor.chest *[minecraft:custom_data~{zx:["boil_trace"],ol:"boil_trace"}] run scoreboard players add #want zx.meta 4
#   涤火 +4（2026-11-22 补登，同 armor_mana 里的说明）；超限·涤火 +8
execute if items entity @s armor.chest *[minecraft:custom_data~{zx:["purge_fire"]}] run scoreboard players add #want zx.meta 4
execute if items entity @s armor.chest *[minecraft:custom_data~{zx:["purge_fire"],ol:"purge_fire"}] run scoreboard players add #want zx.meta 4
# ---- 批 15-4(2026-10-16): 绯缝(胸甲) +4；超限 +2（共 +6）----
execute if items entity @s armor.chest *[minecraft:custom_data~{zx:["crimson_seam"]}] run scoreboard players add #want zx.meta 4
execute if items entity @s armor.chest *[minecraft:custom_data~{zx:["crimson_seam"],ol:"crimson_seam"}] run scoreboard players add #want zx.meta 2
# ---- 批 14(2026-10-25): 剖面(护腿) +6 ----
execute if items entity @s armor.legs *[minecraft:custom_data~{zx:["profile"]}] run scoreboard players add #want zx.meta 6

# ---- ①.5 超限·沸痕「最大生命值额外 +10%」----
#   比例修饰符不参与 ① 的**整点**账本(账本记的是"加了几点") ⇒ 单独用 zx.bt_hp_p 记挂没挂。
#   ★ 必须排在 ② 的 `#diff == 0 -> return` **之前** ★ 否则穿着期间差值恒 0, 永远走不到这里。
#   ★ modifier 的数值是字面量 ⇒ 只能"摘了重挂"; 而 remove 对不存在的 id 会失败并
#     **截断整个函数**, 所以两个动作都用账本门控。
#   ★ 与「蓄意」同一口径(add_multiplied_total): 基数是含 flat 加成后的总上限。
scoreboard players add @s zx.bt_hp_p 0
scoreboard players set #bt_pct zx.meta 0
execute if items entity @s armor.chest *[minecraft:custom_data~{zx:["boil_trace"],ol:"boil_trace"}] run scoreboard players set #bt_pct zx.meta 1
execute if score @s zx.bt_hp_p matches 1 unless score #bt_pct zx.meta matches 1 run attribute @s minecraft:max_health modifier remove fallendream:eqp_bt_hp
execute if score @s zx.bt_hp_p matches 1 unless score #bt_pct zx.meta matches 1 run scoreboard players set @s zx.bt_hp_p 0
execute if score @s zx.bt_hp_p matches 0 if score #bt_pct zx.meta matches 1 run attribute @s minecraft:max_health modifier add fallendream:eqp_bt_hp 0.1 add_multiplied_total
execute if score @s zx.bt_hp_p matches 0 if score #bt_pct zx.meta matches 1 run scoreboard players set @s zx.bt_hp_p 1

# ---- ①.5b 超限·息土「最大生命值 +20%」----
#   比例修饰符不参与整点账本, 单独用 zx.so_hp_p 记挂没挂（与沸痕同款, 见 ①.5）。
scoreboard players add @s zx.so_hp_p 0
scoreboard players set #so_pct zx.meta 0
execute if items entity @s armor.chest *[minecraft:custom_data~{zx:["breathing_soil"],ol:"breathing_soil"}] run scoreboard players set #so_pct zx.meta 1
execute if score @s zx.so_hp_p matches 1 unless score #so_pct zx.meta matches 1 run attribute @s minecraft:max_health modifier remove fallendream:eqp_so_hp
execute if score @s zx.so_hp_p matches 1 unless score #so_pct zx.meta matches 1 run scoreboard players set @s zx.so_hp_p 0
execute if score @s zx.so_hp_p matches 0 if score #so_pct zx.meta matches 1 run attribute @s minecraft:max_health modifier add fallendream:eqp_so_hp 0.2 add_multiplied_total
execute if score @s zx.so_hp_p matches 0 if score #so_pct zx.meta matches 1 run scoreboard players set @s zx.so_hp_p 1

# ---- ② 与账本比差值（差值制：换装那一秒自动补/退） ----
#   ★ 先 `add 0` 把没分数的玩家补成 0 —— 计分项"没分数"时 `if score` 判**不成立**,
#     不能靠"没分数"表达"没加过"(那样第一次永远加不上)。
scoreboard players add @s zx.ah_hp 0
scoreboard players operation #diff zx.meta = #want zx.meta
scoreboard players operation #diff zx.meta -= @s zx.ah_hp
execute if score #diff zx.meta matches 0 run return 0

# ---- ③ 面板 max_health 加差值 ----
data modify storage manacore:in arg set value {uuid:"",key:"max_health",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 1 run scoreboard players get #diff zx.meta
function manacore:api/stats/add

# ---- ④ 原版属性：先按旧账摘，再按新账加 ----
#   ★ 旧账为 0 时**不能** remove —— 没挂过的 modifier 去 remove 会失败,
#     而失败会**截断整个函数**(后面都不跑)。所以两处都带门控。
execute if score @s zx.ah_hp matches 1.. run attribute @s minecraft:max_health modifier remove fallendream:eqp_ah_hp
scoreboard players operation @s zx.ah_hp += #diff zx.meta
execute store result storage zx:work ah.amt int 1 run scoreboard players get @s zx.ah_hp
execute if score @s zx.ah_hp matches 1.. run function fallendream:equipment/armor/armor_hp/apply with storage zx:work ah
