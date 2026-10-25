# ============================================================
# sweetdream:equipment/axe/ballad/ol_note_spawn —— 召唤一个「音符」(宏)
# ------------------------------------------------------------
# 【宏参数】zx:work nt {dmg,sx,sy,sz,u0..u3}
#   dmg = 这一发路径伤害(整点) / sx..sz = **起点**(施法者位置) / u* = 施法者 UUID
# 【执行者】被锁定的生物   【位置】它的位置 —— 这就是"该生物原先的位置"(终点)
# 【★ 为什么终点要用 marker 自己站 ★】歌词写"到达该生物**原先**的位置后自毁" ——
#   锁定那一刻的位置就够了, 不需要追踪生物(每刻追踪 = 每刻读实体位置, 热路径)。
# 【★ marker NBT 里 u* 必须是四个独立 int ★】写成 u:[I;a,b,c,d] 数组时,
#   ol_note_go 的 $(u0) 在 storage 里找不到同名键 -> 整条宏失败、伤害静默消失。
# 【★ 只有计分项参与每刻推进 ★】zx.nt_t 倒计时、zx.nt_d 伤害值; marker 的 NBT
#   (起点坐标 / UUID)只在**召唤那一次**写、**结算那一次**读 —— 中间 20 刻不碰,
#   所以不会把区块标脏(卡顿条目 1)。
# ============================================================

$summon minecraft:marker ~ ~ ~ {Tags:["zx.bd_note","zx.bd_nnew"],data:{zx:{dmg:$(dmg),sx:$(sx),sy:$(sy),sz:$(sz),u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}}}
scoreboard players set @e[type=marker,tag=zx.bd_nnew,distance=..1,limit=1] zx.nt_t 20
execute store result score @e[type=marker,tag=zx.bd_nnew,distance=..1,limit=1] zx.nt_d run data get storage zx:work nt.dmg
tag @e[type=marker,tag=zx.bd_nnew,distance=..1] remove zx.bd_nnew
execute at @e[type=marker,tag=zx.bd_note,distance=..1,limit=1] run particle minecraft:note ~ ~0.5 ~ 0.2 0.2 0.2 0.01 4 normal
