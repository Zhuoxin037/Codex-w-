# ============================================================
# fallendream:equipment/bow/ablation/hook_victim —— 消融命中回调
# ------------------------------------------------------------
# 【谁调用】enchantment/ablation.json 的 post_attack -> affected:"victim"
# 【执行者】@s = 被打中的那只生物
# 【文案逐字】每次射击后若目标有「渊海」, 则消耗「渊海」并使其受到一次
#   相当于自身最大魔力值 x 0.08 的伤害。若其同时拥有「流火」则额外消耗
#   「流火」并使本次伤害类型变为真实伤害。
# 【一轮只结算一次】zx.ab_paid 在全部条件通过后消费(置 0);
#   多重射击后续箭命中读到 0 直接收工, 整轮最多结算一次。
# ============================================================

# ⓪ 近战门控: 必须先有 hook_arrow 打上的 zx.ab_arr(那支箭)
execute unless entity @e[tag=zx.ab_arr,limit=1] run return 0

# ⓪.5 已付账门控(先置零再取值, 坑 141 —— 不能写 on attacker unless … return)
scoreboard players set #ab_p zx.meta 0
execute on attacker store result score #ab_p zx.meta run scoreboard players get @s zx.ab_paid
execute unless score #ab_p zx.meta matches 1 run return 0

# ① 受害者必须是生物(排除玩家)
execute if entity @s[type=minecraft:player] run return 0

# ② 目标必须带「渊海」—— 否则这一箭平凡收工, 不消费付账
execute unless entity @s[tag=zx.status.yuanhai] run return 0

# ③ 标出受害者(fire 里的选择器要用)
tag @e[tag=zx.ab_v,distance=0..] remove zx.ab_v
tag @s add zx.ab_v

# ④ 消费付账 -> 本轮只结算一次
execute on attacker run scoreboard players set @s zx.ab_paid 0

# ⑤ 结算(切回射手: 算伤害要射手 uuid; 消耗标签的 by 也是射手)
execute on attacker at @s run function fallendream:equipment/bow/ablation/fire

# ⑥ 收尾
tag @e[tag=zx.ab_v,distance=0..] remove zx.ab_v
