# ------------------------------------------------------------
# internal/cooldown/increase —— 增加剩余冷却(惩罚机制)
# 【宏参数】manacore:work.a {uuid,skill,ticks,seconds}
# 【用途】"技能冷却增加"需求: 例如被某种控制命中后, 某技能 CD 变长。
# 【注意】只对"正在冷却"的技能生效; 想让一个没在冷却的技能直接进入
#         冷却, 请用 api/cooldown/start。
# ------------------------------------------------------------
execute store result score #amt manacore.math run data get storage manacore:work a.ticks
execute if score #amt manacore.math matches ..0 run function manacore:internal/cooldown/increase_sec
execute if score #amt manacore.math matches 1.. run function manacore:internal/cooldown/increase_body with storage manacore:work a
