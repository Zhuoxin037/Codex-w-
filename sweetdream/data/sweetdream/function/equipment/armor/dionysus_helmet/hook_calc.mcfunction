# ============================================================
# sweetdream:equipment/armor/dionysus_helmet/hook_calc —— 超限: 技能伤害 +30%(加算)
# ------------------------------------------------------------
# @calc: add     ← 加算型: 只往加算池里写百分比, 由 lib/dmg_add_apply 统一乘
# 【谁调用它】#manacore:event/damage_calc —— 排在 lib/dmg_add_apply 之前
#   (顺序由 check 规则 dmgord 盯着)。
# 【文案】"…且自身技能伤害提升 30%…" (超限·狄俄尼索斯之桂冠, 攻击触发, 3 秒)
# 【口径】"技能伤害提升 X%" 与「愿景」升级同一套 —— 交给 lib/dmg_add_put_any,
#   由它读 zx:work ch 快照挑"本次技能第一条真正用到的通道"写一份(见其头注释,
#   F14: 旧写法三条各写一份, 多通道技能会重复放大);
#   持续期由 zx.dio_emp 倒计时管(每秒 -1, 见 second), 到 0 自动失效, 不消费、不叠加
#   (触发时 set 3, 不会滚)。
# 【普攻吃不吃的边界】和愿景一致: 走 manacore 伤害计算的都吃 —— 全包对
#   "技能伤害"的既有口径, 不在本件单独收紧。
# ============================================================

# ⓪ 不是玩家 -> 不参与
execute unless entity @s[type=minecraft:player] run return 0

# ① 增益窗口还在吗(攻击触发时 set 3, 每秒 -1)
execute unless score @s zx.dio_emp matches 1.. run return 0

# ② 一份 +30(量纲: 池子里 30 = +30%), 由 dmg_add_put_any 挑通道
scoreboard players set #pct zx.meta 30
execute store result storage zx:work put.pct int 1 run scoreboard players get #pct zx.meta
function sweetdream:lib/dmg_add_put_any
