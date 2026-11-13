# ============================================================
# sweetdream:equipment/sword/empty_seat/hit —— 虚位（钻剑 · 被动）
# ------------------------------------------------------------
# 【技能原文】"每个空置的术阵位，使自身每次普攻额外造成 4 点固定伤害。"
# 【空位数】manacore:api/formation/count 出参 r.count（已占） / r.limit（上限）。
#   空位 = limit − count。占用数每件布阵装备不同，所以**每次命中现算**，不缓存
#   （缓存就要维护失效时机，而 count 本来就是一个 O(1) 的接口）。
# 【固定伤害】绕开 api/damage/calc：4 × 空位 直接投递。
# 【★ 注意调用顺序 ★】formation/count 会把 manacore:work a 整份重置
#   （前置包接口的第一行），所以必须先取数、再构建 a —— 反了会把伤害参数冲掉。
# ============================================================
advancement revoke @s only sweetdream:equipment/sword/empty_seat_hit

execute unless items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["empty_seat"]}] unless items entity @s weapon.offhand *[minecraft:custom_data~{zx:["empty_seat"]}] run return 0

function sweetdream:lib/atk_charge
execute unless score @s zx.atk_ok matches 1 run return 0

function sweetdream:lib/victim
execute unless data storage zx:victim context.vx_uuid run return 0
data modify storage zx:work vx_frames append value {context:{}}
data modify storage zx:work vx_frames[-1].context set from storage zx:victim context
function sweetdream:equipment/sword/empty_seat/hit/victim_body with storage zx:work vx_frames[-1].context
data modify storage zx:victim context set from storage zx:work vx_frames[-1].context
data remove storage zx:work vx_frames[-1]
