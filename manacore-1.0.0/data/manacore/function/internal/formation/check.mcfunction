# ------------------------------------------------------------
# internal\formation\check —— 是否还能再放一个术阵
# 【宏参数】manacore:work.a {uuid}
# 【出参】out.can_create = 1b/0b(另外也会带出 count/limit, 因为内部复用了 count)
# 【用途】技能前置判断: "能不能召唤新术阵", 避免先扣魔力再失败。
# ------------------------------------------------------------
function manacore:internal/formation/count with storage manacore:work a
execute if score #count manacore.math < #limit manacore.math run data modify storage manacore:out r.can_create set value 1b
