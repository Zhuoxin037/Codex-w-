# ============================================================
# sweetdream:equipment/axe/charge/hit —— "攻击到生物"之后的追加一击
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/axe/charge_hit(触发器 player_hurt_entity)
#   —— 玩家打到任何生物都会触发。**它不告诉我们打的是谁**, 所以下面要自己找。
# 【① 先撤销进度】进度不撤销, 下次命中就不会再触发(这个坑踩过很多次)。
# 【② 状态没开就直接结束】近战命中数量很大, 绝大多数时候超载根本没开;
#   先看 zx.chg_on, 没开就一条多余命令都不跑。
# 【③ 怎么找"刚被打中的那只"】沿准星做**两步射线**: 先在眼前 1.5 格找(半径 1.2),
#   没有再在 3 格找(半径 1.5) —— 近战本来就要求"看着它才能打中", 所以准星上那一只
#   就是刚被你打中的那只。(和风行老版普攻用的是同一个套路。)
#   ⚠️ 别再用 nbt={HurtTime:10} 那种写法: 实测在 1.21.5 查不到(满 jar 里都找不到它的
#      存取代码), 而且那一行失败会让整个函数直接 return —— 表现就是"命中后什么都没发生"。
# ============================================================

advancement revoke @s only sweetdream:equipment/axe/charge_hit
execute unless score @s zx.chg_on matches 1.. run return 0

# 拿 uuid(改冷却要用)
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# 找出刚被自己打中的那只(准星两步射线)
tag @e[tag=zx.chg_hit] remove zx.chg_hit
execute anchored eyes positioned ^ ^ ^1.5 run tag @e[type=!#sweetdream:no_damage,distance=..1.2,sort=nearest,limit=1] add zx.chg_hit
execute unless entity @e[tag=zx.chg_hit,limit=1] anchored eyes positioned ^ ^ ^3 run tag @e[type=!#sweetdream:no_damage,distance=..1.5,sort=nearest,limit=1] add zx.chg_hit
execute unless entity @e[tag=zx.chg_hit,limit=1] run return 0

# 对它放一次闪电
execute at @e[tag=zx.chg_hit,limit=1] run function sweetdream:equipment/axe/charge/bolt

# 对它 1 格内全部生物造成"当前魔力 ×0.05"的伤害
#   (位置挪到目标身上 -> 里面的 distance=..1 就是"目标 1 格内")
execute at @e[tag=zx.chg_hit,limit=1] run function sweetdream:equipment/axe/charge/hit_area

# 该武器技能冷却 -3 秒(= 60 tick)
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:charge",ticks:60}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/reduce

tag @e[tag=zx.chg_hit] remove zx.chg_hit
