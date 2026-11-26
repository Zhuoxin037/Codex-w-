# ============================================================
# fallendream:equipment/axe/detach/hit_go/victim_body —— 脱离：结算那一次追加伤害
# ------------------------------------------------------------
# 【执行者】玩家（动手的）
# 【伤害投递】a.num → lib/num/plain → internal/damage/with_from（deal 唯一出口）
#   数值 = zx.dt_hp（最大生命值毫点）×0.001 ⇒ 原版 = 最大生命值 ×1.0
#   超限（zx.dtx_ol=1）= ×1.5；若目标带「本质」再 ×1.25（ess_pay 里乘）。
# 【★ 超限倍率在计分项上算完再落 a.num ★】a.num 是 double，直接 `store ... double 0.0015`
#   会引入"1.5 只能用二进制近似"的尾差；先在整数毫点上做 ×15÷10，最后仍用 0.001，
#   与原有那条完全同一条落值路径。
# 【★ 顺序不能动 ★】结算 → 切同生体 → 才发那 15% 临时生命。twin/enter 内部会调
#   set_health（按同生体的血量重设，先摘 heal 修饰符），提前给会被它顺手掀掉。
# 【★「本我者」落在谁身上 ★】文案写的是"为本我者提供/恢复"。沉睡的本我者
#   (villager, zx.j_anchor) 是 Invulnerable:1b + resistance 5，转嫁伤害进不去，
#   给它加临时生命/回血在游戏里完全看不出来 ⇒ 两项都落在**玩家自己**身上
#   （切换之后玩家就是那个"被保护的一侧"）。要改成落在沉睡躯体上，只需要换目标。
# ============================================================

$execute unless entity $(vx_uuid) run return 0

# ★ 确认命中目标之后才清闸门 ★ 先清再找目标的话，一旦定位失败这一次就白扔了，
#   玩家得重新右键蓄力 —— 2026-11-01 调整顺序。
scoreboard players set @s zx.dt_arm 0
scoreboard players set #dto_ess zx.meta 0

# ① 基数（毫点）：原版 ×1.0 / 超限 ×1.5
scoreboard players operation #dto_num zx.meta = @s zx.dt_hp
execute if score @s zx.dtx_ol matches 1 run scoreboard players operation #dto_num zx.meta *= #15 zx.meta
execute if score @s zx.dtx_ol matches 1 run scoreboard players operation #dto_num zx.meta /= #10 zx.meta

# ② 超限 + 目标带「本质」：消耗 1 层 → 本段 +25%（并立 #dto_ess 旗子给 ③ 用）
#   ★ 必须在落 a.num **之前**：那一份加成就是乘在 #dto_num 上的。
$data modify storage zx:work detach set value {u:"$(vx_uuid)"}
$execute if score @s zx.dtx_ol matches 1 if score $(vx_uuid) zx.j_ess matches 1.. run function fallendream:equipment/axe/detach/ess_pay with storage zx:work detach

$data modify storage zx:work a set value {target:"$(vx_uuid)",type:"fallendream:skill",uncapped:1b,u0:0,u1:0,u2:0,u3:0,num:0.0}
execute store result storage zx:work a.num double 0.001 run scoreboard players get #dto_num zx.meta
execute store result storage zx:work a.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage zx:work a.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage zx:work a.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage zx:work a.u3 int 1 run scoreboard players get @s manacore.u3
# ★★ 必须把 a.num 转成 a.num_str 再投递（2026-11-01 修）★★
#   internal/damage/deal 的宏参数是 $(num_str)，只给 a.num 的话宏"缺少传入参数"，
#   整条 damage 静默失败 —— 表现就是"额外伤害未生效"，零日志。这是脱离不生效的主因。
function fallendream:lib/num/plain
function fallendream:internal/attack/submit_extra
$tag $(vx_uuid) remove zx.victim

execute at @s run particle minecraft:crit ~ ~1 ~ 0.4 0.6 0.4 0.1 20 normal

# 之后切换为“同生体”
function fallendream:profession/twin/enter

# ③ 切换之后：15% 临时生命 5 秒 + 记 8 秒窗口
#   ★ 排在 enter 之后是有原因的：enter 会调 set_health（先摘 heal 修饰符再按同生体的
#     血量重设），提前给的临时生命会被那一段顺手掀掉。
execute if score #dto_ess zx.meta matches 1 run function fallendream:equipment/axe/detach/thp5
$data modify storage zx:work detach set value {u:"$(vx_uuid)"}
execute if score #dto_ess zx.meta matches 1 run function fallendream:equipment/axe/detach/win_set with storage zx:work detach
