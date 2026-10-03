# ============================================================
# sweetdream:debug/diff —— 数值快照: "和上次比, 变了什么"
# ------------------------------------------------------------
# 【用法】/function sweetdream:debug/diff   或   /trigger zx.dbg_diff
# 【怎么用】
#   ① 换装备**之前**按一次  -> 提示"已存快照"
#   ② 换完装备再按一次      -> 逐行列出哪一项从多少变成多少
#   ③ 之后每按一次都比上一次, 所以可以连着盯
# 【为什么需要它】装备加成是"账本差值"式的: 穿上加多少、脱下减多少, 全记在
#   各自的计分项里。想知道"这件装备到底生没生效", 盯着账本变没变最快 ——
#   以前只能自己一项项记, 现在按两下就行。
# 【比哪些项】注册表 b/a 表里的全部账本 + 面板/原版那几个关键数值。
#   具体清单见 .workbuddy/gen_diff.py。
# 【它写哪里】只写 zx:data snap."<uuid>"(自己那一格), 不碰面板属性。
# 【为什么逻辑在 diff_go】"你这个人存过快照没有"要按 uuid 判断, 只能用宏;
#   这一层负责拿到 uuid。
# ============================================================

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run tellraw @s [{"text":"还没注册完成(uuid 是空的) —— 等一秒再试","color":"red"}]
execute unless data storage zx:data self{ok:1b} run return fail

# 【★ 为什么先抄一份到 zx:work df ★】
#   宏参数只能从"一个复合标签"来。实测直接 `with storage zx:data self`
#   会让被调用的宏函数**一条命令都不跑**(静默, 日志都不报)。
#   全项目能正常工作的调用都是 `with storage zx:work <临时节点>`, 照抄这个形态。
data modify storage zx:work df set value {uuid:""}
data modify storage zx:work df.uuid set from storage zx:data self.uuid

function sweetdream:debug/diff_go with storage zx:work df
