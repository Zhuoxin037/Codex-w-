# ============================================================
# api/formation/create —— 创建一个术阵
# ------------------------------------------------------------
# 【调用模板】
#   data modify storage manacore:in arg set value {uuid:"<UUID>", id:"mypack:fire_array",
#       type:"fire", duration_seconds:15, data:{radius:4.0}}
#   function manacore:api/formation/create
#   /execute if data storage manacore:out r {success:1b} run <生成显示实体等>
# 【字段】
#   uuid     : 归属玩家(术阵一定是某个玩家的)
#   id       : 术阵唯一 id(同一玩家身上不要重复, 删除/查询都靠它)
#   type     : 自定义类型字符串, 自己解释
#   duration : tick 时长; duration_seconds : 秒时长(两者取先满足的那个)
#   data     : 自由载荷, 你的包自己解释(半径/伤害/颜色……)
# 【上限】受该玩家 stats.formation_limit 约束(默认 3, 可被道具修改)。
# 【出参】out.success / out.reason("formation_limit") / out.count / out.limit / out.index
# 【失败时】什么都不写, 你可以安全地在 skill/cast 之后再调它。
# 【视觉表现】本接口只登记数据; 生成实体/粒子请在
#   #manacore:event/formation_create 里做。
# ============================================================
# 出参: manacore:out.success / out.reason / out.index
# 【★ 默认值里不要写 id:"" ★】空串在 `if data` 里算"存在" —— 调用方忘给 id 时会静默
#   建出一个 `id:""` 的术阵白占一个槽位(slot_one 只判 .id 在不在, count_one 照收)。
data modify storage manacore:work a set value {uuid:"",type:"default",duration:0,duration_seconds:0.0}
data modify storage manacore:work a merge from storage manacore:in arg
data modify storage manacore:out r.success set value 0b
data modify storage manacore:out r.reason set value ""
function manacore:api/player/ensure
execute if data storage manacore:work a.uuid if data storage manacore:work a.id run function manacore:internal/formation/create with storage manacore:work a
