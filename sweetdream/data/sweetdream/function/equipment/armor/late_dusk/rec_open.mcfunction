# ============================================================
# sweetdream:equipment/armor/late_dusk/rec_open —— 打开 5 秒「伤害记录」窗口
# ------------------------------------------------------------
# 【执行者】@s = 受害者生物（at @s）
# 【★ 文案(逐字) ★】"……之后使其时停 2 秒并记录接下来 5 秒其受到的伤害。"
# 【★ 时停走公共原语 ★】lib/timestop（宏参数 target/ticks）, 别自己写 NoAI。
#   2 秒 = 40 刻。
# 【★ 记录写在**受害者**身上 ★】计分项 zx.ld_rt（剩余刻）/ zx.ld_rec（累计伤害×1000）,
#   由 core/tick 每刻驱动（见 rec_tick）, 由 internal/damage/one 喂数（见 record）。
#   ★ 生物身上的临时分数必须由 core/load 三维度兜底清（见那一处）。
# 【★ 归属也要存 ★】结算时这笔伤害要算成**攻击者**的(进账本/触发他身上的被动),
#   所以把 ob 的 u0..u3 抄到生物身上。
# ============================================================

# ① 时停 2 秒 = 40 刻
data modify storage zx:work fz set value {target:"@s", ticks:40}
function sweetdream:lib/timestop with storage zx:work fz

# ② 开窗口：5 秒 = 100 刻，记录量清零
#   ★ 先清零再打标签: 同一只生物被连续挂两次时, 旧记录必须丢掉（否则第一次的
#     累计会并进第二次, 结算成一笔莫名其妙的巨额）。
scoreboard players set @s zx.ld_rec 0
scoreboard players set @s zx.ld_rt 100
tag @s add zx.ld_rec_on

# ③ 抄归属（由 late_dusk/hit 先写进 zx:work ld; 拿不到就留 0 = 无归属,
#    结算仍能打出来, 只是不进玩家账本）
#   ★ 不去读 zx:work ob —— 那是 internal/damage 专用基准节点（obnode 规则）。
execute store result score @s zx.ld_u0 run data get storage zx:work ld.u0
execute store result score @s zx.ld_u1 run data get storage zx:work ld.u1
execute store result score @s zx.ld_u2 run data get storage zx:work ld.u2
execute store result score @s zx.ld_u3 run data get storage zx:work ld.u3

# ④ 表现
particle minecraft:dust{color:[0.45,0.35,0.6],scale:1.5} ~ ~1.0 ~ 0.5 0.6 0.5 0.02 20
playsound minecraft:block.beacon.deactivate player @s ~ ~ ~ 0.4 0.8
