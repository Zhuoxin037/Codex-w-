# ============================================================
# fallendream:equipment/axe/bind_ember/cd —— 新获得流火 / 夜火 ⇒ 减全技能冷却
# ------------------------------------------------------------
# 【原版】每有一个目标新获得「流火」 ⇒ 所有已声明技能的现存冷却 -1 秒。
# 【超限】每有一个目标新获得「夜火」 ⇒ 再 -2 秒
#   （两类互不冲突：原本没流火的记一次流火；原本带流火的换夜火记一次夜火）。
# 【★ 为什么走 stop_needle/cd_all ★】包内没有"遍历全部冷却"的公开接口，
#   但针眠的 cd_all 就是干这件事的既有实现（按 uuid 扫 manacore 的冷却记录）。
#   这里只把秒数换成"流火数 + 夜火数 × 2"，其他一个字不动。
# ============================================================

scoreboard players set #be_sec zx.meta 0
execute if score #be_new zx.meta matches 1.. run scoreboard players operation #be_sec zx.meta = #be_new zx.meta

scoreboard players set #be_ny zx.meta 0
execute if score #be_newye zx.meta matches 1.. run scoreboard players operation #be_ny zx.meta = #be_newye zx.meta
scoreboard players operation #be_ny zx.meta *= #2 zx.meta
scoreboard players operation #be_sec zx.meta += #be_ny zx.meta

execute if score #be_sec zx.meta matches ..0 run return 0

data modify storage manacore:in arg set value {uuid:"",skill:"fallendream:bind_ember",seconds:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.seconds double 1.0 run scoreboard players get #be_sec zx.meta
function fallendream:equipment/staff/stop_needle/cd_all

execute at @s run particle minecraft:dust{color:[0.9,0.5,0.15],scale:0.9} ~ ~1 ~ 0.5 0.6 0.5 0.01 10 normal
