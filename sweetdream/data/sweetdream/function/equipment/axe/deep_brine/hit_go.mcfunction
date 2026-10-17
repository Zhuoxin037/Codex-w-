# ============================================================
# sweetdream:equipment/axe/deep_brine/hit_go —— 重溟被动主体
# ------------------------------------------------------------
# 【技能原文(必须和这里对上)】
#   "每次普通攻击命中了附有「渊海」的生物后，额外造成一次相当于自身最大魔力值
#    ×0.05 的伤害，并使其获得 2 秒缓慢Ⅲ。该效果对同一个生物 10 秒内最多触发一次。"
# 【【执行者】动手的玩家
# 【四步】
#   ① 钉死刚打中的那只(lib/victim)
#   ② 它带「渊海」吗? 不带就收工
#   ③ 逐目标节流: 同一只 10 秒内只触发一次(见 passive_gate)
#   ④ 算伤(最大魔力 ×0.05) -> 打它 -> 2 秒缓慢Ⅲ
# 【★ 节流为什么必须在生物身上 ★】文案是"对**同一个生物** 10 秒内最多触发一次";
#   记在玩家身上挡不住"换一只接着打"。
# 【★ 缓慢的 amplifier ★】缓慢Ⅲ = amplifier 2(Ⅰ=0)。用原版效果(带尾随 true 隐藏粒子),
#   与「渊海」附着时给的缓慢Ⅱ 互不冲突: 同 id 效果取等级高者、时长短者覆盖 —— 这里
#   命中瞬间给 Ⅲ 正好压过 mark_one 的 Ⅱ(2026-10-16 实装口径)。
# ============================================================

# ① 钉死刚被自己打中的那只(lib/victim: last_hurt_by_player + HurtTime 反查)
function sweetdream:lib/victim
execute unless entity @e[tag=zx.victim,distance=0..,limit=1] run return 0

# ② 它带不带「渊海」?
scoreboard players set #db_ys zx.meta 0
execute as @e[tag=zx.victim,distance=0..,limit=1] if entity @s[tag=zx.status.yuanhai] run scoreboard players set #db_ys zx.meta 1
execute if score #db_ys zx.meta matches 0 run tag @e[tag=zx.victim] remove zx.victim
execute if score #db_ys zx.meta matches 0 run return 0

# ③ 逐目标节流(记在**那只生物**身上; 通过时它自己会挂上 zx.db_pass)
tag @e[tag=zx.db_pass] remove zx.db_pass
execute as @e[tag=zx.victim,distance=0..,limit=1] run function sweetdream:equipment/axe/deep_brine/passive_gate
execute unless entity @e[tag=zx.db_pass,distance=0..,limit=1] run tag @e[tag=zx.victim] remove zx.victim
execute unless entity @e[tag=zx.db_pass,distance=0..,limit=1] run return 0

# ④-1 算这一次的伤害: 自身最大魔力值 ×0.05
#   ★★ 先重取一次 uuid ★★ damage/calc 是**按 uuid 查这个人的面板**(最大魔力值)来算的,
#   而 zx:data self.uuid 是**全包共用**的"最后一次 lib/uuid 的结果" —— 平A命中这条链
#   本身不经过任何 lib/uuid, 直接读它有可能读到**另一个玩家**的 uuid ⇒ 伤害按别人的魔力算
#   (静默、不报错)。@s 此刻就是动手的玩家, 重取一次即可。
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.05}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:work dba.dmg set from storage manacore:out r.damage

# ④-2 归属: 施法者 UUID 四个整数
data modify storage zx:work dba.u0 set from entity @s UUID[0]
data modify storage zx:work dba.u1 set from entity @s UUID[1]
data modify storage zx:work dba.u2 set from entity @s UUID[2]
data modify storage zx:work dba.u3 set from entity @s UUID[3]

# ④-3 打它(位置搬到它身上; 执行者仍是玩家 -> 击杀归属正确)
execute at @e[tag=zx.db_pass,distance=0..,limit=1] run function sweetdream:equipment/axe/deep_brine/passive_hit

# ④-4 2 秒缓慢Ⅲ(amplifier 2)
execute as @e[tag=zx.db_pass,distance=0..,limit=1] run effect give @s minecraft:slowness 2 2 true

# ⑤ 收尾: 清本轮全部临时标签
tag @e[tag=zx.db_pass,distance=0..] remove zx.db_pass
tag @e[tag=zx.victim] remove zx.victim
