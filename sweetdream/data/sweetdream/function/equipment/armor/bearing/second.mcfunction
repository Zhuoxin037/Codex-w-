# ============================================================
# sweetdream:equipment/armor/bearing/second —— 「承」每秒结算
# ------------------------------------------------------------
# 【执行者】玩家（lib/fm/read 之后）
# 【文案】魔力 +140（armor_mana 登记）；每占用 1 个术阵位 → 护甲 +2 / 韧性 +1（最多 3 层）；
#   术阵为空时移速 +6%。
#   套装（枢 + 承）：术阵位全满 → 8 秒「阵成」（技能伤害 +15% 独立乘区、技能冷却 −10%）；
#   术阵自然结束或主动归还时返还 25 点魔力值；每 12 秒最多进入一次。
# 【★ 层数怎么来 ★】zx.fm_u（lib/fm/read 每秒下发），n = min(fm_u, 3)。
# 【★ 换档必须先摘后挂 ★】同 id modifier 重复 add 会失败，且失败会**截断**后续命令
#   （attribute 的 remove 不存在虽不截断，但 add 重复一定失败）⇒ 用账本 zx.br_a / zx.br_t
#   记"当前挂的是几"，档位没变就一条 attribute 都不发。
# 【★ 「阵成」的触发是"边沿"不是"电平" ★】zx.br_full 记上一秒是否满，只有 0→1 才触发。
# 【★ 「返还 25 魔力」为什么用"占用下降"判 ★】前置包的 formation_remove 事件带的是
#   **uuid 文本**，反查玩家要序列化 NBT（卡顿坑 1）；而占用数本来每秒就在读 ⇒
#   直接看 zx.fm_u 掉了几个，掉 N 个返还 25×N。"自然结束/主动归还"都表现为占用下降。
# ============================================================

# ⓪ 没穿 → 全部撤掉
execute unless items entity @s armor.legs *[minecraft:custom_data~{zx:["bearing"]}] run function sweetdream:equipment/armor/bearing/off
execute unless items entity @s armor.legs *[minecraft:custom_data~{zx:["bearing"]}] run return 0

# ① 层数 n = min(fm_u, 3)
scoreboard players set #br_n zx.meta 0
scoreboard players operation #br_n zx.meta = @s zx.fm_u
scoreboard players set #br_3 zx.meta 3
execute if score #br_n zx.meta > #br_3 zx.meta run scoreboard players set #br_n zx.meta 3
execute if score #br_n zx.meta matches ..0 run scoreboard players set #br_n zx.meta 0

# ② 护甲 = 2n
scoreboard players set #br_a zx.meta 0
scoreboard players operation #br_a zx.meta = #br_n zx.meta
scoreboard players set #br_2 zx.meta 2
scoreboard players operation #br_a zx.meta *= #br_2 zx.meta

# ③ 换档（护甲）
execute unless score #br_a zx.meta = @s zx.br_a run function sweetdream:equipment/armor/bearing/attr_arm
# ④ 换档（韧性 = n，整数点）
execute unless score #br_n zx.meta = @s zx.br_t run function sweetdream:equipment/armor/bearing/attr_tou

# ⑤ 套装：返还魔力 + 「阵成」（放在移速换档**之前** —— 下面那段会 return）
function sweetdream:equipment/armor/bearing/refund
function sweetdream:equipment/armor/bearing/set_full

# ⑥ 术阵为空 → 移速 +6%
scoreboard players set #br_s zx.meta 0
execute if score @s zx.fm_u matches 0 run scoreboard players set #br_s zx.meta 1
execute if score #br_s zx.meta = @s zx.br_spd run return 0
execute if score @s zx.br_spd matches 1 run attribute @s minecraft:movement_speed modifier remove sweetdream:br_spd
scoreboard players set @s zx.br_spd 0
execute if score #br_s zx.meta matches 1 run attribute @s minecraft:movement_speed modifier add sweetdream:br_spd 0.06 add_multiplied_total
scoreboard players operation @s zx.br_spd = #br_s zx.meta
