# ============================================================
# sweetdream:equipment/armor/mirage/dream_roll —— 20% 附加白昼梦 + 20% 时停连锁
# ------------------------------------------------------------
# 【执行者】刚刚被打的那只生物
# 【20% 怎么来】随机源取模 5, 命中 0 就是 1/5 = 20%。
# 【★ 随机源换掉了(2026-10-03) ★】以前是"自己的坐标小数位 + 当前 tick"。
#   那样会和**攻击节奏**耦合: 站着不动的那只被连打时坐标不变, 攻击间隔只要
#   是 5 的倍数, tick 取模就不动 —— 表现是"要么一直中、要么一直不中",
#   玩家能数出规律(审查第 5 条)。现在换成 lib/rnd(全局 LCG, 序列自己往前走),
#   和坐标、节奏彻底脱钩。
# 【★ 两个 20% 各掷各的 ★】文案是两个独立的概率:
#     "攻击生物后 20% 附加白昼梦" 和 "带白昼梦的生物受伤后 20% 时停 1 秒"。
#   所以必须抽**两次**, 不能共用一次结果 —— 共用就变成"中了白昼梦才可能时停",
#   概率塌成 4%。lib/rnd 每调用一次就推进一步, 天然是两次互相独立的抽样。
# 【时停为什么不看"白昼梦是不是刚附上的"】文案是"附带白昼梦的生物**受到
#   伤害后**时停" —— 不管这个白昼梦是刚附上的还是早就有的, 都该掷这一下。
# 【时停 1 秒之后】由 #sweetdream:event/timestop_end 接住, 见 ts_end。
# ============================================================

# ① 第一掷: 0..4 —— 附加「白昼梦」
function sweetdream:lib/rnd
scoreboard players operation #mr_r zx.meta = #rnd zx.meta
scoreboard players operation #mr_r zx.meta %= #5 zx.meta

# ② 命中 0 -> 附加「白昼梦」(五状态图标系统的 "dream", 公共接口)
$execute if score #mr_r zx.meta matches 0 run data modify storage zx:work ic set value {target:"@s",mark:"dream",u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
execute if score #mr_r zx.meta matches 0 run function sweetdream:tag/mark_owned with storage zx:work ic

# ③ 没带白昼梦(这一下没中、以前也没有) -> 到此为止, 不掷时停
execute unless entity @s[tag=zx.status.dream] run return 0

# ④ 第二掷: 0..4 —— 20% 时停 1 秒(再推进一步, 和上面那掷独立)
function sweetdream:lib/rnd
scoreboard players operation #mr_r3 zx.meta = #rnd zx.meta
scoreboard players operation #mr_r3 zx.meta %= #5 zx.meta

execute if score #mr_r3 zx.meta matches 0 run data modify storage zx:work fz set value {target:"@s",ticks:20}
execute if score #mr_r3 zx.meta matches 0 run function sweetdream:lib/timestop with storage zx:work fz
