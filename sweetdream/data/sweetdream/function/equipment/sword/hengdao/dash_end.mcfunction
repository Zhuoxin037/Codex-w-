# ============================================================
# sweetdream:equipment/sword/hengdao/dash_end —— 落点结算
# ------------------------------------------------------------
# 【谁调用它】dash_tick 在"走完 / 被挡住"的那一 tick
# 【执行者】施法者本人, 位置就是他停下来的地方
# 【为什么结算要放这儿, 而不是 cast 里】突进是分 12 刻走完的, cast 那一瞬间
#   人还在起点 —— 在 cast 里打伤害 = 打起点周围 2 格。所以必须等走完再算。
# 【步骤】① 拿 UUID ② 落点表现(粒子 + 刀风音效) ③ 算伤害 ④ 打 2 格内全部生物
# ============================================================

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 落点表现
#   音效 id 是拿真实的 assets/minecraft/sounds.json 核对过的, 不会踩
#   "音效不存在 -> 报错截断函数"的坑; 粒子用的是本包已在用的三个。
execute at @s run particle minecraft:end_rod ~ ~1 ~ 1.0 0.4 1.0 0.05 30 normal
execute at @s run particle minecraft:enchanted_hit ~ ~1 ~ 0.6 0.6 0.6 0.1 25 normal
execute at @s run playsound minecraft:entity.player.attack.strong player @a ~ ~ ~ 0.9 0.85
execute at @s run playsound minecraft:entity.player.attack.crit player @a ~ ~ ~ 0.6 1.4

# ③ 伤害 = 自身最大魔力 x 0.08
#   原理见 使用教程 §7.8: base_attack 可以自己指定(传 -1 才是"用面板攻击力"),
#   所以先读出 max_mana, 把它当 base_attack 传进去, 倍率写 0.08。
data modify storage manacore:in arg set value {uuid:"",key:"max_mana"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
# 此刻 manacore:out r.value = 最大魔力

data modify storage manacore:in arg set value {uuid:"",base_attack:-1.0,skill_multiplier:0.08,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage manacore:in arg.base_attack set from storage manacore:out r.value
function manacore:api/damage/calc
# 此刻 manacore:out r.damage = 最大魔力 x 0.08

# ④ 打落点 2 格内全部生物
#   target 可以写范围选择器 —— sweetdream:api/damage 内部会用 execute as 逐个展开。
#   type=!#sweetdream:no_damage 已经把玩家、盔甲架、雪球、鸡蛋这类排掉了。
data modify storage zx:in arg set value {target:"@e[type=!#sweetdream:no_damage,distance=0.1..2]",damage:0.0,type:"minecraft:player_attack"}
data modify storage zx:in arg.damage set from storage manacore:out r.damage
function sweetdream:api/damage
