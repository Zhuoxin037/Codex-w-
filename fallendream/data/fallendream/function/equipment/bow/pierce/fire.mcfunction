# ============================================================
# fallendream:equipment/bow/pierce/fire —— 穿孔结算
# ------------------------------------------------------------
# 【执行者】射手(玩家), 由 hook_victim 的 execute on attacker at @s 送进来
# 【前置】贯穿路径上的全部生物已打 zx.pi_on
# 【文案·原版】对命中的生物额外附加一次相当于自身最大魔力值 x 0.03 的伤害。
# 【文案·超限】魔力 50; 每只 x 0.04; 同一箭命中 >=3 个生物时, "该箭**接下来的**
#   伤害提升为 x 0.08"; 命中后使其护甲值与护甲韧性 -30%, 持续 5 秒。
# 【★ 0.08 是"接下来的", 不是"整条走廊都变 0.08" ★】按**距射手从近到远**逐只结算:
#   第 1~3 只仍是 0.04, 第 4 只起才 0.08。所以这里不能再"算一次、批量投"
#   (原来的写法每只同伤), 改成 one 逐只递归。
# 【★ 顺序为什么按距离 ★】箭是沿走廊飞过去的, "接下来"天然就是离射手更远的那些;
#   按距离排能复现"打穿前三个之后箭势更猛"的画面, 而且结果可复现(不依赖选择器随机序)。
# ============================================================

# ⓪ 走廊里一个目标都没有 -> 收工(贯穿落空是合法结果)
execute unless entity @e[tag=zx.pi_on,limit=1] run return 0

# ① 档位从射手身上抄到伪玩家(后面 @s 会切走, 读不到射手的分)
scoreboard players set #pi_ol zx.meta 0
execute if score @s zx.pi_ol matches 1 run scoreboard players set #pi_ol zx.meta 1

# ② 算"每只"的伤害两份: 0.03 / 0.04(主档) 与 0.08(超限第 4 只起)
function fallendream:lib/uuid
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.03}
execute if score #pi_ol zx.meta matches 1 run data modify storage manacore:in arg.max_mana_mul set value 0.04
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:work pi.dmg4 set from storage manacore:out r.damage
data modify storage zx:work pi.s2b4 set from storage manacore:out r.s2_b_damage
#   0.08 那份先给个安全默认(原版不会用到; 若 calc 没跑, 投递也不会拿到空值)
data modify storage zx:work pi.dmg8 set value 0.0
data modify storage zx:work pi.s2b8 set value {n:0,d:1}
execute if score #pi_ol zx.meta matches 1 run data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.08}
execute if score #pi_ol zx.meta matches 1 run data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute if score #pi_ol zx.meta matches 1 run function manacore:api/damage/calc
execute if score #pi_ol zx.meta matches 1 run data modify storage zx:work pi.dmg8 set from storage manacore:out r.damage
execute if score #pi_ol zx.meta matches 1 run data modify storage zx:work pi.s2b8 set from storage manacore:out r.s2_b_damage

# ③ 走廊里一共几只(超限的"至少 3 个"要它)
scoreboard players set #pi_n zx.meta 0
execute as @e[tag=zx.pi_on,distance=0..] run scoreboard players add #pi_n zx.meta 1

# ④ 逐只结算(从近到远; 每只结算完打 zx.pi_done, 递归到没有为止)
tag @e[tag=zx.pi_done,distance=0..] remove zx.pi_done
scoreboard players set #pi_done zx.meta 0
function fallendream:equipment/bow/pierce/one
