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
# 【★ 登记"终身清单"(修 F16)★】见 internal/player/create 的说明。
#   这里会把已经不存在的记录**重建**出来, 所以也要登记(重复一条无害:
#   清档时第二次 `data remove` 会因为路径不存在被 `execute if data` 挡掉)。
$data modify storage manacore:players_all list append value "$(uuid)"
