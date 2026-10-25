# ============================================================
# sweetdream:equipment/sword/gousi/ol_cast —— 超限·钩丝 的主动(右键)
# ------------------------------------------------------------
# 【设计原文(超限段)】
#   "使用后选中自身 8 格内最近的三个生物，以每 0.25 秒 0.8 格的速度将其拉向自身，
#    期间使其获得常态的缓慢Ⅰ效果。在抵达身前 2 格或撞上不可替换的方块时停下。
#    拉到位置后，使其获得 5 秒缓慢Ⅱ，并对其造成一次相当于自身最大魔力值 ×0.12 的伤害，
#    同时每拉到一个都会使自身下三次技能伤害 +10%（独立乘区）。
#    若中途未能拉到，则改为造成一次相当于自身最大魔力值 ×0.08 的伤害，
#    且使自身下一次技能伤害 +10%。"
# 【与原版的六处差别】
#   ① 1 个目标 → **最近 3 个**
#   ② 每步 0.5 格 → **0.8 格**(每 0.25 秒一次不变)
#   ③ 拉动期间给**缓慢Ⅰ**(原版没有)
#   ④ 到位后缓慢Ⅱ **3 秒 → 5 秒**
#   ⑤ 没拉到 0.04 → **0.08**
#   ⑥ 加成从"下一次最大魔力类技能 +10%"(原版走 zx.mm_add) → **下三次技能伤害 +10%，
#      独立乘区，可叠到 +30%**(走 zx.gs3p / zx.gs3n，见 gousi/hook_calc)
# 【魔力 / 冷却不变】文案没写，沿用 180 / 28 秒。
# 【★ 为什么另开一套 ol_* 而不是改原版】原版那套是"单目标 + zx.gs_st 步数"的闭环，
#   并且 landed/miss 会直接清全局状态。三目标并行需要"每只各自结算、全部结束才清状态"，
#   硬塞进原文件会把两条路径的收尾条件缠在一起 —— 原版那条路径一个字都不动更安全。
# 【★ 存储键是 zx:work gs3 而不是 gs ★】zx:work gs 是原版钩丝在用的键
#   (pull_go 会 `set value {own:0}` 整段覆盖)。两套同时被扫到一次就是静默变 0。
# ============================================================
advancement revoke @s only sweetdream:equipment/sword/gousi

# ① 先看有没有目标(一只都没有就不扣费、不进冷却)
execute unless entity @e[type=!#sweetdream:no_damage,distance=0.1..8] run tellraw @s [{"text":"附近没有目标","color":"red"}]
execute unless entity @e[type=!#sweetdream:no_damage,distance=0.1..8] run return fail

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 只读检查: 冷却 28 秒 + 魔力 180
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:gousi",mana:180.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"钩丝冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 180）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 扣 180
data modify storage manacore:in arg set value {uuid:"",value:180.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足（需要 180）","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ④ 冷却 28 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:gousi",cooldown_seconds:28.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑤ 开锁: 记自己是谁 + 12 步(0.8 格/步 = 9.6 格, 盖住 8 格锁敌半径)
scoreboard players set #gs_own zx.meta 0
execute store result score #gs_own zx.meta run data get entity @s UUID[0]
scoreboard players operation @s zx.gs_own = #gs_own zx.meta
scoreboard players set @s zx.gs_st 12
scoreboard players set @s zx.gs3 1

# ⑥ 宏参数: own 拼 tag; uu/u0..u3 给"拉到位那一发"算伤害与归属用
#   ★ 这四个整数必须在**施法这一刻**拍好 ★ 拉动途中 @s 会变成被拉的那只生物,
#     那时再读 UUID 读到的是怪物的。也正因为如此, 收尾时不能靠 lib/find_by 反查 ——
#     手上只有 own(UUID[0]) 一个整数, 拼不出选择器。
data modify storage zx:work gs3 set value {own:0,uu:"",u0:0,u1:0,u2:0,u3:0}
execute store result storage zx:work gs3.own int 1 run scoreboard players get #gs_own zx.meta
data modify storage zx:work gs3.uu set from storage zx:data self.uuid
execute store result storage zx:work gs3.u0 int 1 run data get entity @s UUID[0]
execute store result storage zx:work gs3.u1 int 1 run data get entity @s UUID[1]
execute store result storage zx:work gs3.u2 int 1 run data get entity @s UUID[2]
execute store result storage zx:work gs3.u3 int 1 run data get entity @s UUID[3]

execute at @s run function sweetdream:equipment/sword/gousi/ol_lock with storage zx:work gs3

playsound minecraft:entity.fishing_bobber.throw player @a ~ ~ ~ 0.8 1.1
playsound minecraft:block.chain.step player @a ~ ~ ~ 0.6 1.3
