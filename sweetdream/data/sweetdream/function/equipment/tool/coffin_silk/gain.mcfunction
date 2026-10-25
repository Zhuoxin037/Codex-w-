# ============================================================
# sweetdream:equipment/tool/coffin_silk/gain —— 殓丝: 获得「殓结」
# ------------------------------------------------------------
# 【谁调用它】coffin_silk/on_true_hit（以玩家身份）
# 【执行者】持殓丝的那个玩家
# 【入参】zx:work cfs.target = 被打中那只（带「噬心」）的选择器
# 【门控（文案逐条）】① 未持有「殓结」 ② 魔力足够（≥ 80） ③ 12 秒内最多触发一次
# ============================================================

# ① 先清除过期/已移走的殓结，再判定是否重复获取。
function sweetdream:equipment/tool/coffin_silk/keep
execute if entity @s[tag=zx.cfs_knot] run return 0

# ② 12 秒节流（账本存"下次可触发刻"；先置零再取值，坑 141 同款）
scoreboard players set #cfs_due zx.meta 0
execute store result score #cfs_due zx.meta run scoreboard players get @s zx.cfs_cd
execute if score #cfs_due zx.meta > #now manacore.meta run return 0

# ③ 魔力足够才扣（不够就整段不发生 —— 文案"若…魔力足够"）
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:"",value:80.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay_pas
execute if data storage manacore:out r{success:0b} run return 0

# ④ 消耗目标身上的「噬心」（装备被动消耗 -> src:"equip"，别触发"技能消耗"那几件）
data modify storage zx:work a set value {target:"@e[tag=zx.cfs_v,limit=1]",mark:"shixin",by:"@s",src:"equip"}
function sweetdream:lib/mark_consume

# ⑤ 获得「殓结」，持续 8 秒（keep 每刻清理到期/移走副手）。
tag @s add zx.cfs_knot
scoreboard players operation @s zx.cfs_end = #now manacore.meta
scoreboard players operation @s zx.cfs_end += #160 zx.meta

# ⑥ 记下"下次可触发刻"（现在 + 240 刻 = 12 秒）
scoreboard players operation @s zx.cfs_cd = #now manacore.meta
scoreboard players operation @s zx.cfs_cd += #240 zx.meta

# ⑦ 表现：缠上一圈丧仪丝线
execute at @s run particle minecraft:soul_fire_flame ~ ~1 ~ 0.35 0.5 0.35 0.01 10 normal
execute at @s run playsound minecraft:block.soul_soil.break player @a ~ ~ ~ 0.6 1.2
