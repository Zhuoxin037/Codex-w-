# ============================================================
# sweetdream:debug/wind —— 「风行于大地之上」专用自检(只读)
# ------------------------------------------------------------
# 【用法】/function sweetdream:debug/wind       (以玩家身份执行)
# 【打印什么】
#   风声 / 回响剩余秒数 / 回响期间加了多少最大魔力 /
#   下次技能加成(攒到没攒到) / 上一次"3 轮爆发"每跳的伤害 /
#   上一次"回响"每跳的伤害 / 术阵占用 / 当前与最大魔力
# 【为什么要它】风声这套东西大多在"看不见的地方"跑:
#   · 风声要超过 60 才产生加成 —— 打两三只怪是攒不到的
#   · 加成是"一次性"的: 谁先用谁吃掉, 光看存储基本看不到
#   · 回响每 4 秒才打一下, 想确认它到底打出了多少, 只能靠这里的记录
# 【它是只读的】不会改任何数据。
# ============================================================

tellraw @s [{"text":"===== 风行于大地之上 · 自检 =====","color":"aqua","bold":true}]

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run tellraw @s [{"text":"还没注册完成(uuid 是空的), 等一秒再试","color":"red"}]
execute unless data storage zx:data self{ok:1b} run return fail

# ⚠️ 宏参数一律先抄进 zx:work 再传 —— 直接写 `with storage zx:data self`
#    会让 wind_macro **一条命令都不跑**(静默, 日志都不报)。2026-10-03 修。
data modify storage zx:work sd set value {uuid:""}
data modify storage zx:work sd.uuid set from storage zx:data self.uuid
function sweetdream:debug/wind_macro with storage zx:work sd
