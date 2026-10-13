# ============================================================
# sweetdream:equipment/sword/crescent/hit —— 缺月 · 被动(每次平A)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/sword/crescent_hit(player_hurt_entity, 只算平A)
# 【执行者】动手的玩家
# 【技能原文(必须和这里对上)】
#   "主手持有缺月时，快捷栏中若有正在冷却的主动技能（不包括该武器）则触发以下效果
#    ● 只有 1 个技能正在冷却：普通攻击额外造成相当于自身基础攻击力 ×2 的伤害。
#    ● 有 2 个技能正在冷却：普通攻击在以上基础上再额外造成相当于基础攻击力 ×2 的伤害，
#      并使自身所有技能冷却时间 -0.5 秒。
#    ● 有 3 个及以上技能正在冷却：缺月不再获得上述效果。普通攻击改为造成最大魔力 ×0.08，
#      但每次攻击随机使一个正在冷却的技能剩余冷却 +1 秒。"
# 【★ 四要素逐个落实 ★】
#   ① 触发: 每次平A(满蓄力闸 + 按游戏刻去重, 横扫多命中不重复)。
#   ② 目标范围: 被击中的那一只。
#   ③ 次数: 一次平A一次。
#   ④ 时长: —(瞬发)。
# 【★ 读法说明(待用户确认)】"普通攻击改为造成最大魔力 ×0.08" 取**追加一段伤害**
#   (与原版平A伤害叠加), 而不是"替换原版伤害"—— 数据包无法取消原版那一刀。
# 【口径】层数 = 快捷栏里"正在冷却、且不是缺月自己"的技能条数(见 count/slot)。
# ============================================================

advancement revoke @s only sweetdream:equipment/sword/crescent_hit

# ---- 满蓄力闸(全包统一口径, 见 lib/atk_charge) ----
function sweetdream:lib/atk_charge
execute unless score @s zx.atk_ok matches 1 run return 0

# 武器门控: 主手或副手是缺月才继续
scoreboard players set #cr_ok zx.meta 0
execute if items entity @s weapon.mainhand *[custom_data~{zx:["crescent"]}] run scoreboard players set #cr_ok zx.meta 1
execute if items entity @s weapon.offhand *[custom_data~{zx:["crescent"]}] run scoreboard players set #cr_ok zx.meta 1
execute unless score #cr_ok zx.meta matches 1 run return 0

# 【★ "每次攻击"去重 ★】同刻已结算过就退出
execute if score @s zx.cr_lt = #now manacore.meta run return 0
scoreboard players operation @s zx.cr_lt = #now manacore.meta

# 钉死"刚才这一下打的是哪一只"
function sweetdream:lib/victim
execute unless entity @e[tag=zx.victim,limit=1] run return 0

# uuid(读快捷栏技能 / 查冷却都要)
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

# 数"快捷栏里正在冷却的其它主动技能"
function sweetdream:equipment/sword/crescent/count

# 分档
execute if score #cr_n zx.meta matches 0 run return 0
execute if score #cr_n zx.meta matches 1 run function sweetdream:equipment/sword/crescent/pass1
execute if score #cr_n zx.meta matches 2 run function sweetdream:equipment/sword/crescent/pass2
execute if score #cr_n zx.meta matches 3.. run function sweetdream:equipment/sword/crescent/pass3
