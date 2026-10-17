# ============================================================
# sweetdream:equipment/armor/mirror_sleep/hit —— 镜寐: 每 3 次攻击给下一个目标点「白昼梦」
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/armor/mirror_sleep_hit（player_hurt_entity）
# 【执行者】玩家（动手的那个人）
# 【文案(lore 逐字)】自身魔力值上限 +60。自身每攻击 3 次生物后，若自身魔力足够则消耗
#   30 魔力并对下一个攻击且未附有「白昼梦」的生物附加「白昼梦」。
# 【★ 两个状态 ★】
#     zx.ms_cnt = 已经攻击了几次(0..2, 满 3 归零)
#     zx.ms_arm = 1 = "攒满了、等着下一个目标兑现"
#   ★ 先兑现、后计数 ★ 计数满 3 是在"第 3 次攻击"那一刻武装的, 兑现只能发生在
#     **那之后**的某一次命中 —— 同一次命中不可能既"刚数满 3"又"兑现"（除非早已武装）。
#     所以顺序必须是 ③ 兑现 → ④ 计数。
# 【★ 目标带白昼梦时**不兑现、也不清武装** ★】文案要的是"下一个**未附有**白昼梦的
#   生物"; 打到已带梦的目标不算数, 武装留着等下一次(计数照常推进)。
# 【★ 附加是"附着"不是"消耗" ★】走 tag/mark。
# ============================================================

advancement revoke @s only sweetdream:equipment/armor/mirror_sleep_hit

# ---- 满蓄力闸（全包统一口径：平A 没蓄满力这一发不触发；见 lib/atk_charge 头部） ----
function sweetdream:lib/atk_charge
execute unless score @s zx.atk_ok matches 1 run return 0

# ① 没穿镜寐就没这事（护腿）
execute unless items entity @s armor.legs *[minecraft:custom_data~{zx:["mirror_sleep"]}] run return 0

# ② 定位命中的那一只（定位不到就当这一发没发生 —— 宁可少算一次，也不乱计数）
function sweetdream:lib/victim
execute unless entity @e[tag=zx.victim,distance=0..,limit=1] run return 0

# ③ 【兑现】攒满了吗 + 目标未带白昼梦吗 -> 扣 30 魔力并附加
execute if score @s zx.ms_arm matches 1 unless entity @e[tag=zx.victim,distance=0..,limit=1,tag=zx.status.dream] run function sweetdream:equipment/armor/mirror_sleep/apply

# ④ 【计数】攻击次数 +1；满 3 则归零并武装
scoreboard players add @s zx.ms_cnt 1
execute if score @s zx.ms_cnt matches 3.. run scoreboard players set @s zx.ms_cnt 0
execute if score @s zx.ms_cnt matches 0 run scoreboard players set @s zx.ms_arm 1

# ⑤ 收尾
tag @e[tag=zx.victim] remove zx.victim
