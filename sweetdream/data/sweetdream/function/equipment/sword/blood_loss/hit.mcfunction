# ============================================================
# sweetdream:equipment/sword/blood_loss/hit —— 失血 · 平A命中入口
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/sword/blood_loss_hit(player_hurt_entity, 只算平A)
# 【执行者】动手的玩家
# 【只做三件事】① 撤销自己的进度 ② 蓄力闸门 ③ 确认手里握的是失血 -> 交给 hit_go
# 【★ 为什么要判手持 ★】player_hurt_entity 是**全包共用**的进度, 拿任何武器打任何
#   生物都会进来。判据一律写 `custom_data~{zx:["blood_loss"]}`(**部分匹配 `~`**;
#   写成 `=` 会静默失效)。主手/副手都查 —— 副手也能平A。
# ============================================================

# ① 撤销自己的进度(自撤销型进度首行必须 revoke, 否则只触发一次)
advancement revoke @s only sweetdream:equipment/sword/blood_loss_hit

# ② 蓄力闸门: 只认满蓄力平A(出参在 @s zx.atk_ok)
function sweetdream:lib/atk_charge
execute unless score @s zx.atk_ok matches 1 run return 0

# ③ 手里是失血吗?
execute if items entity @s weapon.mainhand diamond_sword[custom_data~{zx:["blood_loss"]}] run function sweetdream:equipment/sword/blood_loss/hit_go
execute if items entity @s weapon.offhand diamond_sword[custom_data~{zx:["blood_loss"]}] run function sweetdream:equipment/sword/blood_loss/hit_go
