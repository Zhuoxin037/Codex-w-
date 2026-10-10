# ------------------------------------------------------------
# internal/session/verify —— 判"索引里我的槽位记的是不是我"
# 【宏参数】manacore:work.id {u0,u1,u2,u3,slot,ok}
# 【做法】用 UUID 四个 int 精确匹配 index."<slot>"。
#   光判"这一格在不在"不够 —— 槽位被回收后可能分给别人, 那一格记的就是**别人的**
#   UUID; 只有逐 u0..u3 比过才能确认"这个槽位现在属于我"。
# 【出参】命中时把 work.id.ok 置 1b(默认 0b, 由 tick_self 预置)。
# 【注】u0..u3 是 UUID 的四个 32 位整数, 宏拼进 NBT 匹配器天然合法
#   (同型先例: internal/damage/mk_from 的 @a[nbt={UUID:[I;$(u0),...]}]、
#    sweetdream 的 lightless_sea/cap 的 {u0:$(u0),...})。
# 【F01 修(2026-10-10)】本函数是"每秒心跳"与"完整注册"之间的分水岭:
#   命中 -> 只更新心跳; 未命中 -> 走完整注册。
# ------------------------------------------------------------
$execute if data storage manacore:index "$(slot)"{u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)} run data modify storage manacore:work id.ok set value 1b
