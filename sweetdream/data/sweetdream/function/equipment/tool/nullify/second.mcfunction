# ============================================================
# sweetdream:equipment/tool/nullify/second —— 无效的每秒入口
# ------------------------------------------------------------
# 【谁调用它】挂在 #manacore:event/second 上(前置包每秒抛一次, 服务器身份)
# 【它做什么】把"刚召唤过术阵"的标记兑现成"下一次最大魔力值技能 +20%"。
# 【为什么兑现不放在 formation_create 事件里】那个事件只带 manacore:ctx.uuid(字符串),
#   要判"这个玩家副手拿没拿「无效」"必须有玩家实体; 而把 uuid 字符串反查成实体
#   只能靠 UUID 四个 int(lib/find_by), ctx 里没有 —— 所以事件只记一个按 uuid 的标记,
#   判定与兑现挪到这里(@s 就是玩家本人, 判定可靠)。
# 【代价】最多 1 秒延迟: 召唤术阵后"下一秒"才挂上加成。
#   "下一次技能"的语义天然容忍这点(除非同一秒内先召唤术阵再放技能)。
# 【不可叠加】在 on_second 里: 当前已有一份待生效加成时就不写
#   (照 armor/lethe_shore/set_bonus 的定式, 连召唤两次术阵也不会变 +40%)。
# ============================================================

function sweetdream:lib/in_bak

execute as @a at @s run function sweetdream:equipment/tool/nullify/on_second

function sweetdream:lib/in_restore
