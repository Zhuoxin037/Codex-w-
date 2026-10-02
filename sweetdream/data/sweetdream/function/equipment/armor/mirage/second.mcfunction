# ============================================================
# sweetdream:equipment/armor/mirage/second —— 幻昼的每秒入口
# ------------------------------------------------------------
# 【谁调用它】#manacore:event/second
# 【为什么对全部玩家跑】魔力上限 +240 和套装加成都是"穿上加、脱下减回去"的
#   差值账本: 只筛穿腿甲的人的话, 脱下那一秒没人执行 passive, 永远减不回去。
# 【★ 为什么这里要先推环形下标 ★】套装的两条加成是"每次触发 +1 层, 每层各活
#   5 / 8 秒"。expire 清的是"下标当前指的那一格", 而这一秒内新加的层也写进
#   同一格 —— 所以下标必须在**任何人结算之前**推进, 且一秒只推一次。
#   放在 passive 里推的话, 每个玩家各推一次, 全场就乱了。
# 【备份公共输入口】passive 里会读面板(写 manacore:in arg), 见 lib/in_bak。
# ============================================================

function sweetdream:lib/in_bak

# ① 推进"每层独立到期"的环形下标(+1 环 6 格 / +2 环 9 格)
scoreboard players add #mr_ra zx.meta 1
scoreboard players operation #mr_ra zx.meta %= #6 zx.meta
scoreboard players add #mr_rb zx.meta 1
scoreboard players operation #mr_rb zx.meta %= #9 zx.meta

execute as @a run function sweetdream:equipment/armor/mirage/passive

function sweetdream:lib/in_restore
