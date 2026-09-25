# ------------------------------------------------------------
# internal/damage/from_auto —— 攻击者选择器自动推导
# 【宏参数】manacore:work.a {uuid}
# 【逻辑】1) 玩家记录里有 u0..u3 -> 用 mk_from 拼出
#            @a[nbt={UUID:[I;u0,u1,u2,u3]},limit=1]
#         2) 推导失败(例如传了不存在的 UUID) -> 退化为 @s
# 【为什么需要它】/damage 的 by 参数必须是实体选择器, 不能直接写 UUID;
#   这个函数就是"UUID -> 选择器"的桥梁, 击杀归属/仇恨/击退方向都靠它。
# ------------------------------------------------------------
$execute if data storage manacore:players "$(uuid)".uuid run function manacore:internal/damage/mk_from with storage manacore:players "$(uuid)"
execute unless data storage manacore:work a.from run data modify storage manacore:work a.from set value "@s"
function manacore:internal/damage/apply_go with storage manacore:work a
