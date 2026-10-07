# ============================================================
# sweetdream:projectile/ball/fire —— 射出一颗「法球」
# ------------------------------------------------------------
# 【谁调用它】法杖类的普攻: sweetdream:equipment/staff/attack
# 【入参】zx:work ball {dmg, style}  —— 调用者只写这两个就够了
#   dmg   命中时打出的伤害。**发射那一刻就定死**, 之后你换装/嗑药都不影响它,
#         因为它是"跟着球飞的一个数字", 不是命中时再算一遍。
#   style 外观代号(现在支持 "wind"; 不写或者不认识就走朴素白球)
# 【执行者】必须是玩家(要取 @s 的 uuid、UUID 四个整数、视线朝向)
#
# 【载体为什么用 minecraft:marker】
#   · 没有碰撞箱、不能右键、不会被推动、也不在可伤害名单里 —— 不会挡路,
#     不会像盔甲架那样被右键交互, 也不会被自己的法球打到
#   · 位置是实体自带的, 每刻只要 tp @s ^ ^ ^0.75 就够了, 不用自己算向量
#   · 它自带一个 data 复合, 正好拿来存 uuid / 伤害 / 外观 / 朝向 / 归属
#
# 【射程 30 格存在哪】计分项 zx.ball_dist, 一格 = 100(定点 2 位小数)。
#   起步 3000, 每刻 -75, 减到 0 自己消失 —— 正好 30 格 / 40 刻。
#   (NBT 里的 double 不能用命令做加减, 定点计分板是最省事的办法;
#    横刀的"还剩几步"也是同一个思路。)
#
# 【朝向为什么存 int 而不是 double】
#   宏渲染时 DoubleTag 会渲染成 "37.5d"(末尾的 d 是 NBT 类型标记),
#   而 rotated / positioned 这类参数不认那个后缀(详见 lib/num/plain 的说明)。
#   存成 int 就只会渲染出 "38", 干干净净。
#   代价只是角度取整: 30 格距离上 0.5° 的偏差约 0.26 格, 肉眼看不出来。
# ============================================================

# ① 拿 uuid + 把参数表补全(u0..u3 是归属, yaw/pitch 是朝向)
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
data modify storage zx:work ball.uuid set from storage zx:data self.uuid
data modify storage zx:work ball merge value {u0:0,u1:0,u2:0,u3:0,yaw:0,pitch:0}
# ★ hit(命中回调)只"缺了才补默认", 绝不能在 merge 里写死成 "" ★
#   以前这行是 merge value {...,hit:""} —— merge 会**覆盖**已有键, 于是调用方
#   (堕梦 attack 里)装好的 hit:".../fallen_dream/ball_hit" 被抹成空串,
#   ball/hit 第 ⑥ 步 `unless data entity @s data{hit:""}` 直接跳过回调
#   → 堕梦普攻的伤害全在回调里结算, 于是**一点伤害都没有**(2026-10-05 玩家报)。
#   【调用方约定】装球一律用 `set value`(整份替换), 别用 merge —— 否则上一发
#   留在 zx:work ball 里的 hit / fdmg 会串到下一发上。
execute unless data storage zx:work ball.hit run data modify storage zx:work ball.hit set value ""

# ② 归属: 玩家 UUID 的四个整数(打伤害时用它拼 by, 击杀才算在你头上)
#    —— 直接从实体读, 不用按 uuid 去翻 manacore 的记录, 所以这里不需要宏
execute store result storage zx:work ball.u0 int 1 run data get entity @s UUID[0]
execute store result storage zx:work ball.u1 int 1 run data get entity @s UUID[1]
execute store result storage zx:work ball.u2 int 1 run data get entity @s UUID[2]
execute store result storage zx:work ball.u3 int 1 run data get entity @s UUID[3]

# ③ 朝向: 记下发射那一刻的视线(yaw = 左右, pitch = 上下)
#    记下来之后这颗球就直线飞, 你发射完回头/抬头都不会影响它
execute store result storage zx:work ball.yaw int 1 run data get entity @s Rotation[0]
execute store result storage zx:work ball.pitch int 1 run data get entity @s Rotation[1]

# ④ 软锁(让普攻"好命中"的关键一步)
#   为什么要它: 法球又小又快, 纯直线飞的话手感上很难命中 —— 特别是打人偶、
#   或者打会走位的怪。所以发射瞬间先沿准星找一只"值得追"的生物,
#   把它的 UUID 四个整数记进球里; 之后球会一边飞一边朝它拐。
#   探针是 3 步(眼前 2 / 5 / 10 格各找一次), 只认离准星够近的那一只 ——
#   所以"大致对准了"才会锁上, 不是无脑自瞄。锁不到也没关系:
#   t0..t3 全是 0, 法球就按原朝向直线飞(和以前一样)。
#   (UUID 用四个整数记, 是因为选择器里没法写 UUID 文本 —— 和 with_from 一个道理)
tag @e[tag=zx.bt] remove zx.bt
execute anchored eyes positioned ^ ^ ^2 run tag @e[type=!#sweetdream:no_damage,distance=..1.8,sort=nearest,limit=1] add zx.bt
execute unless entity @e[tag=zx.bt,limit=1] anchored eyes positioned ^ ^ ^5 run tag @e[type=!#sweetdream:no_damage,distance=..2.5,sort=nearest,limit=1] add zx.bt
execute unless entity @e[tag=zx.bt,limit=1] anchored eyes positioned ^ ^ ^10 run tag @e[type=!#sweetdream:no_damage,distance=..3.0,sort=nearest,limit=1] add zx.bt
data modify storage zx:work ball merge value {t0:0,t1:0,t2:0,t3:0}
execute if entity @e[tag=zx.bt,limit=1] store result storage zx:work ball.t0 int 1 run data get entity @e[tag=zx.bt,limit=1] UUID[0]
execute if entity @e[tag=zx.bt,limit=1] store result storage zx:work ball.t1 int 1 run data get entity @e[tag=zx.bt,limit=1] UUID[1]
execute if entity @e[tag=zx.bt,limit=1] store result storage zx:work ball.t2 int 1 run data get entity @e[tag=zx.bt,limit=1] UUID[2]
execute if entity @e[tag=zx.bt,limit=1] store result storage zx:work ball.t3 int 1 run data get entity @e[tag=zx.bt,limit=1] UUID[3]
tag @e[tag=zx.bt] remove zx.bt

# ⑤ 生成载体: 眼睛前方 1.5 格处, 先挂临时标签方便定位
execute anchored eyes run summon minecraft:marker ^ ^ ^1.5 {Tags:["zx.ball","zx.ball_new"],data:{}}

# ⑥ 把参数整体灌进载体, 顺便挂上射程分数, 最后摘掉临时标签
data modify entity @e[tag=zx.ball_new,limit=1] data set from storage zx:work ball
scoreboard players set @e[tag=zx.ball_new] zx.ball_dist 3000
tag @e[tag=zx.ball_new] remove zx.ball_new

# ⑦ 出膛的一小团风(音效交给类别默认件, 每把武器想换就换)
execute anchored eyes run particle minecraft:small_gust ^ ^ ^1.2 0.15 0.15 0.15 0.02 6 normal
