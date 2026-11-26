# ============================================================
# fallendream:equipment/axe/angel_core/ol_layer —— 超限被动: 给一只圣痕者叠"额外一层"
# ------------------------------------------------------------
# 【谁调用它】hit_go ⑦（超限分支，⑥ 挂完新圣痕之后）
# 【执行者】动手的玩家   【位置】玩家所在
# 【文案】"之后使自身 3 格内 1 个有「圣痕」的生物额外附加一层并重置其「圣痕」持续
#   时间，最多额外附加 1 层。"
# 【★ 排在 ⑥ 之后 ★】文案是"…并使…附加「圣痕」，**之后**使自身 3 格内 1 个有圣痕的…"
#   ⇒ 这一层是在本次新挂的圣痕上再挑一只，所以必须排在新圣痕落地之后，
#     否则本次刚挂上的那几只根本没资格被挑中。
# 【★ "1 个"取最近的 1 只 ★】文案没写排序，但必须有个确定的挑法；
#   与同句前半段"最近的 3 个"同一口径。
# 【★ 最多 1 层 ★】已经有 1 层的只做"重置时长"，不再叠加；zx.sh_x 值域就是 0/1。
# ============================================================

tag @e[tag=zx.ac_l1] remove zx.ac_l1
execute at @s run tag @e[type=!#fallendream:no_damage,distance=0.1..3,tag=zx.status.shenghen,sort=nearest,limit=1] add zx.ac_l1
execute unless entity @e[tag=zx.ac_l1,distance=0..,limit=1] run return 0

# ① 重置持续时间（超限 20 秒 = 基础 15 + 5，与 mark 里同一个写法，改一处要一起改）
scoreboard players set @e[tag=zx.ac_l1,distance=0..] zx.sh_t 15
scoreboard players add @e[tag=zx.ac_l1,distance=0..] zx.sh_t 5

# ② 叠加额外层（上限 1）
#   ★ 先 `add 0` 把"没分数"变成 0：计分项**没分数**不是 0，
#     `if score @s zx.sh_x matches ..0` 对不存在的分数恒假（老存档/第一次挂上）。
scoreboard players add @e[tag=zx.ac_l1,distance=0..] zx.sh_x 0
execute as @e[tag=zx.ac_l1,distance=0..] if score @s zx.sh_x matches ..0 run scoreboard players set @s zx.sh_x 1

# ③ 表现：额外层用"更密更亮"的一记刻印，和普通挂痕区分开
#   （常态特效仍由 status/aura_shenghen 统一画，这里只管这一下的反馈）
execute at @e[tag=zx.ac_l1,distance=0..,limit=1] run particle minecraft:end_rod ~ ~1.1 ~ 0.22 0.40 0.22 0.02 14 normal
execute at @e[tag=zx.ac_l1,distance=0..,limit=1] run particle minecraft:dust{color:[1.0,0.93,0.58],scale:1.9} ~ ~1.0 ~ 0.30 0.45 0.30 0.0 14 normal
execute at @e[tag=zx.ac_l1,distance=0..,limit=1] run playsound minecraft:block.amethyst_block.chime player @a ~ ~ ~ 0.85 1.65

tag @e[tag=zx.ac_l1,distance=0..] remove zx.ac_l1
