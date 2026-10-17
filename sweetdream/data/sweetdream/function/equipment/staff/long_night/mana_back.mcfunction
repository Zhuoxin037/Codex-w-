# ============================================================
# sweetdream:equipment/staff/long_night/mana_back —— 长夜普攻命中带夜火者: 回 30 魔力
# ------------------------------------------------------------
# 【谁调用它】long_night/ball_hit ③(已经换成**发射者**的身份)
# 【执行者】发射者本人
# 【技能原文】"每次普攻命中了附有「夜火」的生物后，为自身恢复 30 点魔力值
#   （2 秒内最多一次）。"
# 【★ "2 秒内最多一次"记在玩家身上 ★】文案的主语是"为**自身**恢复" ——
#   限的是这份收益, 不是某一目标。所以用玩家计分项 zx.ln_gate。
# 【★ 顺序: uuid -> 闸 -> 加魔 ★】先确认能拿到 uuid(拿不到就整条无效),
#   再吃节流闸 —— 反过来会"白吃一次 2 秒闸却没回魔"。
# ============================================================

# ① uuid 拿不到就收工(前置包接口都要它)
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

# ② 2 秒节流: zx.ln_gate = 下一次允许回魔的 #now 时刻(= 现在 + 40 刻)
#   ★ 先 add 0: 计分项"没分数"时 `if score` 判不成立, 第一次永远回不上。
scoreboard players add @s zx.ln_gate 0
execute if score @s zx.ln_gate > #now manacore.meta run return 0
scoreboard players operation @s zx.ln_gate = #now manacore.meta
scoreboard players add @s zx.ln_gate 40

# ③ 回 30 魔力
data modify storage manacore:in arg set value {uuid:"",value:30.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/add

# ④ 表现: 一层魂火亮一下
execute at @s run particle minecraft:soul_fire_flame ~ ~1.2 ~ 0.5 0.6 0.5 0.02 14 normal
