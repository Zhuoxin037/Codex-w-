# ============================================================
# fallendream:equipment/armor/purge_fire/buff —— 涤火：基础攻击力加成（基础 +20%/5 秒，超限 +30%/8 秒）
# ------------------------------------------------------------
# 【谁调用它】purge_fire/resolve ③（仅"第二档"：攻击者同时带「流火」+「夜火」）
# 【执行者】受伤的玩家   【入参】#pf_ol zx.meta（1 = 超限·涤火）
# 【账本】
#   zx.pf_atk = 触发时的 base_attack ×100（只做中间量）
#   zx.pf_add = 实际加在面板上的量 ×1000（到期按它取负退回, 成对加减）
#   zx.pf_until = #now + 100 / 160；zx.pf_on = 1 表示"挂着一份"
# 【★ 2026-11-22 改: 加成量不再写死 0.002 倍 ★】
#   原来用 `double 0.002` 把 base×100 变成 base×0.2, 超限要 +30% 就没法一套写法了,
#   改成先算出 ×1000 定点的加成量存进账本, 写回时统一 `double 0.001`。
# 【★ 重入要先退旧的 ★】同一份加成在 5/8 秒内再次触发时, 旧的那份还挂在面板上;
#   不退直接加新的 = 到期只退一份, 永久多出一截（静默变强）。
# ============================================================

function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ---- ① 上一份还在生效 -> 先按账本退掉 ----
scoreboard players set #pf_neg zx.meta 0
execute if score @s zx.pf_on matches 1 run scoreboard players operation #pf_neg zx.meta -= @s zx.pf_add
execute if score @s zx.pf_on matches 1 run data modify storage manacore:in arg set value {uuid:"",key:"base_attack",value:0.0}
execute if score @s zx.pf_on matches 1 run data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute if score @s zx.pf_on matches 1 run execute store result storage manacore:in arg.value double 0.001 run scoreboard players get #pf_neg zx.meta
execute if score @s zx.pf_on matches 1 run function manacore:api/stats/add
scoreboard players set @s zx.pf_add 0

# ---- ② 读当前基础攻击力（×100） ----
data modify storage manacore:in arg set value {uuid:"",key:"base_attack"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
scoreboard players set @s zx.pf_atk 0
execute store result score @s zx.pf_atk run data get storage manacore:out r.value 100

# ---- ③ 加成量(×1000 定点) = 基础攻击力 × 百分比 ÷ 100 ----
#   pf_atk = base×100 ⇒ (base×100) × k ÷ 10 = base × k × 10 = 加成量 ×1000 ✅
scoreboard players set #pf_pct zx.meta 20
execute if score #pf_ol zx.meta matches 1 run scoreboard players set #pf_pct zx.meta 30
scoreboard players operation @s zx.pf_add = @s zx.pf_atk
scoreboard players operation @s zx.pf_add *= #pf_pct zx.meta
scoreboard players set #pf_10 zx.meta 10
scoreboard players operation @s zx.pf_add /= #pf_10 zx.meta

data modify storage manacore:in arg set value {uuid:"",key:"base_attack",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 0.001 run scoreboard players get @s zx.pf_add
function manacore:api/stats/add

# ---- ④ 计时（基础 5 秒 / 超限 8 秒） ----
scoreboard players set #pf_dur zx.meta 100
execute if score #pf_ol zx.meta matches 1 run scoreboard players set #pf_dur zx.meta 160
scoreboard players operation @s zx.pf_until = #now manacore.meta
scoreboard players operation @s zx.pf_until += #pf_dur zx.meta
scoreboard players set @s zx.pf_on 1
