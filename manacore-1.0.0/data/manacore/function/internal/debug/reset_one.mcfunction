# ------------------------------------------------------------
# internal/debug/reset_one —— 把某玩家重置为默认模板
# 【宏参数】manacore:work.a {uuid}
# 【会丢失什么】属性成长、术阵、冷却、恢复修正全部清空;
#   索引用的 u0..u3 也会被清掉, 所以该玩家下次上线会重新占槽(自愈)。
# 【注意】不可撤销, 建议先 dump 一份备份。
# ------------------------------------------------------------
data modify storage manacore:work record set from storage manacore:config defaults
$data modify storage manacore:work record.uuid set value "$(uuid)"
$data modify storage manacore:players "$(uuid)" set from storage manacore:work record
