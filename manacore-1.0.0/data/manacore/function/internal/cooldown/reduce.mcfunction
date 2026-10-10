# ------------------------------------------------------------
# internal/cooldown/reduce —— 减少当前剩余冷却
# 【宏参数】manacore:work.a {uuid,skill,ticks,seconds}
# 【单位】ticks 优先; ticks <= 0 时用 seconds x20。
# 【语义】把 end 往前推 #amt 刻 —— 注意推过头(end < #now)也不会立刻
#         清记录, 下一次 check 时会判定就绪并顺手删除。
# 【典型用途】"技能冷却减少"道具、连击奖励、天赋触发。
# 【★★ 2026-10-08 修: 这里曾经让"减冷却"翻倍 ★★】
#   下面三条命令的**顺序**是"先换算、后减", 而且 reduce_body 全包**只有这一处**调用点 ——
#   千万别把后两条对调, 也别再让 reduce_sec 自己去调 reduce_body:
#   那会让 #amt(既当守卫又当结果) 被中途改写, 于是两条守卫同时成立、减两遍。
#   (完整事故与波及面见 internal/cooldown/reduce_sec 头部。)
# ------------------------------------------------------------
# ① 取"要减多少刻": 直接给 ticks 就用它
execute store result score #amt manacore.math run data get storage manacore:work a.ticks
# ② ticks<=0 -> 改从 seconds 换算(x20); 该函数只写 #amt, 不调用 reduce_body
execute if score #amt manacore.math matches ..0 run function manacore:internal/cooldown/reduce_sec
# ③ 唯一的"减"发生在这里(#amt 此刻一定已经是"刻")
execute if score #amt manacore.math matches 1.. run function manacore:internal/cooldown/reduce_body with storage manacore:work a
