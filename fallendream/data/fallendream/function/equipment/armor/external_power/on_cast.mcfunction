# ============================================================
# fallendream:equipment/armor/external_power/on_cast —— 超限·体外供能装置: 技能返还 10% 魔力
# ------------------------------------------------------------
# 【谁调用它】#manacore:event/cooldown_start（前置包在冷却写入之后抛出；
#   此刻 manacore:work a 仍是本次技能参数，a.mana = 本次实际消耗的魔力）
# 【文案】"自身魔力值大于 70% 时…使用技能后返还 10% 所消耗的魔力"
# 【★ 返还门槛 = 施法那一刻魔力 >70% ★】cooldown_start 时魔力已扣过, 此刻读当前比判定。
# 【★ 顺序铁律 ★】a.mana 必须在任何会写 manacore:work a 的调用之前读
#   (lib/uuid → api/player/self_uuid 就会写 a.i / a.uuid)。
# 【★ 备份/还原 ★】api/mana/add 会整份重置 manacore:work a, 而 skill/go 在本事件
#   之后还有 damage/calc with a —— 不还原那一次技能算不出伤害(backlight 同坑)。
#   拆 on_cast / on_cast_go 两层: 做事层可 early return, 本层无条件还原。
# ============================================================

execute unless entity @s[type=minecraft:player] run return 0
execute unless items entity @s armor.legs *[minecraft:custom_data~{zx:["external_power"],ol:"external_power"}] run return 0

# ① 先读本次实际消耗魔力（×1000）——必须排在 lib/uuid 之前
#   ★ 先复位: data get 取不到时 store result 不执行, 会留着上一次的值。
scoreboard players set #ep_mana zx.meta 0
execute unless score @s zx.j_pay_t = #now manacore.meta run return 0
scoreboard players operation #ep_mana zx.meta = @s zx.ep_paid
execute if score #ep_mana zx.meta matches ..0 run return 0

# ② 整份备份技能参数节点 + 公共输入口（做事层随意 early return，不影响还原）
data modify storage zx:work ep_bak set from storage manacore:work a
function fallendream:lib/in_bak
function fallendream:equipment/armor/external_power/on_cast_go
function fallendream:lib/in_restore
data modify storage manacore:work a set from storage zx:work ep_bak
data remove storage zx:work ep_bak
