# ============================================================
# internal/formation/create —— 创建术阵(带数量上限检查)
# ------------------------------------------------------------
# 【宏参数】manacore:work.a {uuid,id,type,duration,duration_seconds,data}
# 【术阵数据格式】players."uuid".formations[i] = {
#       id      : 术阵唯一标识(删除/查询都用它)
#       type    : 术阵类型(你自己定义, 例如 "fire"/"support")
#       owner   : 所属玩家 UUID —— 术阵归属关系的落点
#       data    : 自由载荷(半径/伤害/颜色等, 由你的包自己解释)
#       start   : 生成的绝对时刻
#       end     : 到期时刻(没有 end 表示永久术阵)
#   }
# 【存在形式】8 个固定槽位的数组, 空槽为 {}。用固定槽位而不是 append,
#   是因为"删除/遍历/按 id 查找"都要能确定下标, 见 regen_driver 注释。
# 【上限检查】count(已用槽位) 与 stats.formation_limit 比较 ——
#   上限存在每个玩家自己的属性里, 所以"未来会有可更改术阵数量的道具"
#   只需要调 api/formation/limit/set, 不需要改任何判断逻辑。
# 【出参】out.success / out.reason("formation_limit") / out.count / out.limit
# ============================================================
$data modify storage manacore:work entry set value {uuid:"$(uuid)",i:0}
function manacore:internal/formation/count_driver with storage manacore:work entry
execute store result storage manacore:out r.count int 1 run scoreboard players get #count manacore.math
$execute store result score #limit manacore.math run data get storage manacore:players "$(uuid)".stats.formation_limit
execute store result storage manacore:out r.limit int 1 run scoreboard players get #limit manacore.math
execute if score #count manacore.math >= #limit manacore.math run function manacore:internal/formation/create_full with storage manacore:work a
execute if score #count manacore.math < #limit manacore.math run function manacore:internal/formation/create_go with storage manacore:work a
