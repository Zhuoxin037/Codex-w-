# ============================================================
# sweetdream:equipment/staff/stop_needle/skill —— 停针（钻法杖 · 主动技能）
# ------------------------------------------------------------
# 【技能原文】
#   魔力 260 · 冷却 45 秒
#   "使用后选中自身 5 格内最近的最多 5 个生物。若选中至少 3 个，则使其时停 2 秒，
#    每个目标使自身全部技能的冷却时间减少 2 秒（最多 10 秒）；
#    若不足 3 个，则仅使自身获得 3 秒迅捷Ⅱ，不施加时停，也不减少冷却。"
# 【四要素】
#   ① 触发：潜行 + 右键。
#   ② 范围：自身 5 格内、最多 5 个（sort=nearest,limit=5）。
#   ③ 次数：立即 1 次。
#   ④ 时长：时停 2 秒 = 40 刻（走 lib/timestop，NoAI 完全定格）。
# 【★ 计数用"标记后数实体"，不做施加前后差值 ★】
#   `execute store result score … if entity @e[tag=…]` 存的就是匹配数量；
#   先打 zx.sn_hit 再数，比"施加前后两次 @e 计数相减"少一次全表扫描，也不会因为
#   同一刻别的东西也在时停而算错（坑 134/135 的老问题）。
# 【双分支】先选人、计数，再执行一个分支；目标少时不能先时停再补迅捷。
# 【减冷却口径】全部包内技能，包含本次停针；cd_all 清单覆盖已收起的装备。
# ============================================================
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 只读检查：冷却 + 魔力 260
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:stop_needle",mana:260.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"停针冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 260）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 扣 260
data modify storage manacore:in arg set value {uuid:"",value:260.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run return fail

# ④ 起冷却 45 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:stop_needle",cooldown_seconds:45.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑤ 圈定目标并计数
tag @e[tag=zx.sn_hit] remove zx.sn_hit
execute at @s run tag @e[type=!#sweetdream:no_damage,distance=..5,sort=nearest,limit=5] add zx.sn_hit
scoreboard players set #sn_n zx.meta 0
execute store result score #sn_n zx.meta if entity @e[tag=zx.sn_hit]

# ⑥ 不足 3 个：只给迅捷，清理本次名单后直接结束
execute if score #sn_n zx.meta matches ..2 run effect give @s minecraft:speed 3 1 true
execute if score #sn_n zx.meta matches ..2 run tag @e[tag=zx.sn_hit] remove zx.sn_hit
execute if score #sn_n zx.meta matches ..2 at @s run particle minecraft:cloud ~ ~0.5 ~ 0.5 0.3 0.5 0.02 12 normal
execute if score #sn_n zx.meta matches ..2 run return 0

# ⑦ 至少 3 个：时停 2 秒，并减少全部包内技能冷却 2N 秒（最多 10 秒）
data modify storage zx:work fz.target set value "@e[tag=zx.sn_hit]"
data modify storage zx:work fz.ticks set value 40
function sweetdream:lib/timestop with storage zx:work fz
function sweetdream:equipment/staff/stop_needle/cd

execute at @s run particle minecraft:dust{color:[0.55,0.6,0.75],scale:1.2} ~ ~1 ~ 2.4 0.6 2.4 0.02 30 normal
execute at @s run playsound minecraft:block.amethyst_block.resonate player @a ~ ~ ~ 1.0 0.7
tag @e[tag=zx.sn_hit] remove zx.sn_hit
