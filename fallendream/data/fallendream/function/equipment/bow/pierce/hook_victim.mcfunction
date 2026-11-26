# ============================================================
# fallendream:equipment/bow/pierce/hook_victim —— 穿孔命中回调
# ------------------------------------------------------------
# 【谁调用】enchantment/pierce.json 的 post_attack -> affected:"victim"
# 【执行者】@s = 被打中的那只生物
# 【文案逐字】每次射击时消耗 1 个法球, 本次贯穿路径上的全部生物并对命中的生物
#   额外附加一次相当于自身最大魔力值 x 0.03 的伤害。
# 【一轮只结算一次】zx.pi_paid 消费后置 0; 多重射击后续箭命中读到 0 直接收工。
# 【走廊】以射手为起点, 朝向被命中者, 沿该方向一直步进(scan)把路径上全部
#   非玩家生物标成 zx.pi_on, 再一次性对每只结算一次额外伤害。
# ============================================================

# ⓪ 近战门控: 必须先有 hook_arrow 打上的 zx.pi_arr(那支箭)
execute unless entity @e[tag=zx.pi_arr,limit=1] run return 0

# ⓪.5 已付账门控(先置零再取值, 坑 141 —— 不能写 on attacker unless … return)
scoreboard players set #pi_p zx.meta 0
execute on attacker store result score #pi_p zx.meta run scoreboard players get @s zx.pi_paid
execute unless score #pi_p zx.meta matches 1 run return 0

# ① 受害者必须是生物(排除玩家)
execute if entity @s[type=minecraft:player] run return 0

# ② 标出被命中者(走廊朝向要用)
tag @e[tag=zx.pi_v,distance=0..] remove zx.pi_v
tag @s add zx.pi_v

# ③ 消费付账 -> 本轮只结算一次
execute on attacker run scoreboard players set @s zx.pi_paid 0
execute on attacker run scoreboard players set @s zx.pi_step 0
tag @e[tag=zx.pi_on,distance=0..] remove zx.pi_on

# ④ 走廊扫描(以射手为起点, 朝向被命中者, 沿该方向步进)
#   ★ 用 feet 不用 eyes：朝向脚底再 rotated ~ 0 归零俯仰，水平走廊不会斜钻进地里；
#     用 eyes 会让"眼睛→眼睛"的斜线在长走廊上逐渐下沉（且触发守门的瞄眼规则）。
execute on attacker at @s facing entity @e[tag=zx.pi_v,limit=1,sort=nearest] feet rotated ~ 0 run function fallendream:equipment/bow/pierce/scan

# ⑤ 对路径上全部生物结算额外伤害(切回射手: 算伤害要射手 uuid)
execute on attacker at @s run function fallendream:equipment/bow/pierce/fire

# ⑥ 收尾
tag @e[tag=zx.pi_on,distance=0..] remove zx.pi_on
tag @e[tag=zx.pi_v,distance=0..] remove zx.pi_v
