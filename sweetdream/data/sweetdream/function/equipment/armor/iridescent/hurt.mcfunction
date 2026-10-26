# ============================================================
# sweetdream:equipment/armor/iridescent/hurt —— 异彩: 受伤后反制周围生物
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/armor/iridescent_hurt
#   触发器 entity_hurt_player —— "玩家受到了伤害"(原版连摔落/窒息这种没有
#    攻击者的伤害也会触发, 正合文案"自身受到伤害后")。
# 【执行者】玩家(被打的那个人)
# 【文案上写的】对自身 6 格内至多 3 个生物**随机施加两种效果**:
#   ① 5 秒缓慢 III    ② 施加者基础攻击力 ×2 的无来源真实伤害
#   ③ 被击退一格      ④ 5 秒虚弱 III    ⑤ 时停 1 秒 + 附加「白昼梦」
# 【★ 为什么是"受伤后"而不是"攻击后" ★】原版没有"任意实体受伤"这种触发器,
#   只有"玩家受伤"和"玩家造成伤害"两个方向。本件是反制型, 用前者。
# 【★ 箭已经离弦那类问题在这里不存在 ★】进度是**伤害结算之后**才触发的,
#   不像寒鸦那样"事件发生在结果之前", 所以不需要清残留数据那套。
# ============================================================

advancement revoke @s only sweetdream:equipment/armor/iridescent_hurt

# ① 没戴异彩就没这事
execute unless items entity @s armor.head netherite_helmet[custom_data~{zx:["iridescent"]}] run return 0

# ② 标出"施加者": 击退要知道背离谁, 效果二要读他的基础攻击力
tag @a[tag=zx.ir_src] remove zx.ir_src
tag @s add zx.ir_src

# ③ 先把效果二的数值算好: 施加者基础攻击力 ×2 -> 纯数字字符串
#    【为什么在这里算, 不在 eff_2 里算】eff_2 的执行者是**被打的那只生物**,
#      那时读玩家的面板要绕一圈; 而且 3 只生物共享同一个数值, 算一次就够。
#    【为什么不是 0】取不到面板时 #ir_atk 保持 0, 打 0 点伤害(不会报错)。
function sweetdream:lib/in_bak
function sweetdream:lib/uuid
data modify storage manacore:in arg set value {uuid:"",key:"base_attack"}
execute if data storage zx:data self{ok:1b} run data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute if data storage zx:data self{ok:1b} run function manacore:api/stats/get
scoreboard players set #ir_atk zx.meta 0
execute if data storage zx:data self{ok:1b} run execute store result score #ir_atk zx.meta run data get storage manacore:out r.value
function sweetdream:lib/in_restore

# 【兜底: 读不到面板就退回原版属性】面板 base_attack 取不到时会是 0,
#   0×2 还是 0, 而 /damage 打 0 点**不报错** —— 表现就是"什么都没发生"。
#   所以 0 或负数时改用原版 minecraft:attack_damage, 再兜一个 1。
execute if score #ir_atk zx.meta matches ..0 run execute store result score #ir_atk zx.meta run attribute @s minecraft:attack_damage get 1
execute if score #ir_atk zx.meta matches ..0 run scoreboard players set #ir_atk zx.meta 1

scoreboard players operation #ir_atk zx.meta *= #2 zx.meta
data modify storage zx:work a set value {damage:0.0}
execute store result storage zx:work a.damage double 1 run scoreboard players get #ir_atk zx.meta
data modify storage zx:work a.num set from storage zx:work a.damage
function sweetdream:lib/num/plain

# ④ 圈出 6 格内至多 3 只
#   【为什么用判定箱相交, 不用 distance】distance 量的是到生物**脚底**的距离,
#     人偶/坚守者这种高个子会因为"脚太远"被漏掉(法球踩过这个坑, 寒鸦也是
#     改成盒子的)。12×12×12 的盒子以自己为中心, 大致就是 ±6 格。
tag @e[tag=zx.ir_t] remove zx.ir_t
execute at @s positioned ~-6 ~-6 ~-6 as @e[type=!#sweetdream:no_damage,dx=12.0,dy=12.0,dz=12.0,sort=random,limit=3] run tag @s add zx.ir_t

# ⑤ 逐只随机挑两种效果(随机源见 roll; 已经和坐标/节奏无关, 不用再传 tick 进去)
data modify storage zx:work ir_owner set value {}
execute store result storage zx:work ir_owner.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage zx:work ir_owner.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage zx:work ir_owner.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage zx:work ir_owner.u3 int 1 run scoreboard players get @s manacore.u3
function sweetdream:equipment/armor/iridescent/dispatch with storage zx:work ir_owner

tag @e[tag=zx.ir_t] remove zx.ir_t
tag @a[tag=zx.ir_src] remove zx.ir_src
