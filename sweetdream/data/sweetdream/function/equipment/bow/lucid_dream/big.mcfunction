# ============================================================
# sweetdream:equipment/bow/lucid_dream/big —— 大效果: 白昼梦 + 梦回≥3 的那一发
# ------------------------------------------------------------
# 【谁调它】fire ③(宏 {target,shooter,uuid,arrow,snap}); 执行者 = 被打中的那只生物
# 【文案】"当「梦回」达到 3 层及以上后, 再次射击附有「白昼梦」的生物时对其造成
#   相当于自身当前魔力值 ×0.X 的伤害, 之后清除该生物的「白昼梦」并清除自身「梦回」,
#   之后召唤一个术阵。召唤术阵后该生物每次受到攻击都会使自身 2 格内的全部生物
#   额外受到一次相当于自身最大魔力值 ×0.0X 的真实伤害, 持续 X 秒。
#   若持续时间内该生物被附加了「白昼梦」效果, 则时间延长至该生物的「白昼梦」效果结束。
#   (X 为「梦回」层数)"
# 【X = combo】本发快照里的 combo(= 射击那一刻的梦回层数, 3..5)。
# 【伤害归属】用快照 u0..u3 反查施法者(射手), 走 internal/damage/with_from(带击杀归属)。
# 【顺序】先结算伤害(射手还活着/白昼梦还在), 再清白昼梦 + 清梦回 + 建术阵 + 标记。
# ============================================================

# ① 取出 X(= 本发梦回层数)
scoreboard players set #ld_x zx.meta 0
execute store result score #ld_x zx.meta run data get storage zx:work ld.snap.combo

# ② 反查射手的"当前魔力值"
#    先把快照 u0..u3 摊平到顶层(宏参数只能取顶层字段), 再用 nbt 选择器反查玩家
scoreboard players set #ld_mana zx.meta 0
data modify storage zx:work ldflat set value {u0:0,u1:0,u2:0,u3:0}
data modify storage zx:work ldflat.u0 set from storage zx:work ld.snap.u0
data modify storage zx:work ldflat.u1 set from storage zx:work ld.snap.u1
data modify storage zx:work ldflat.u2 set from storage zx:work ld.snap.u2
data modify storage zx:work ldflat.u3 set from storage zx:work ld.snap.u3
function sweetdream:equipment/bow/lucid_dream/find_shooter with storage zx:work ldflat

# ③ 伤害 = 当前魔力 ×0.01×X -> 整数 #ld_dmg = 魔力 × X ÷100
scoreboard players set #ld_dmg zx.meta 0
scoreboard players operation #ld_dmg zx.meta = #ld_mana zx.meta
scoreboard players operation #ld_dmg zx.meta *= #ld_x zx.meta
scoreboard players set #100 zx.meta 100
scoreboard players operation #ld_dmg zx.meta /= #100 zx.meta

# ④ 打伤害(带射手归属)
execute if score #ld_dmg zx.meta matches 1.. run function sweetdream:equipment/bow/lucid_dream/big_dmg

# ⑤ 消耗该生物「白昼梦」(统一入口; by = 射手本人 —— 他穿「永恒」时会扣他 50 魔力刷回来)
data modify storage zx:work a set value {target:"",mark:"dream",by:""}
data modify storage zx:work a.target set from storage zx:work ld.target
$data modify storage zx:work a.by set value "$(shooter)"
function sweetdream:lib/mark_consume

# ⑥ 清射手「梦回」
$execute as $(shooter) run scoreboard players set @s zx.ld_dream 0

# ⑦ 召唤一个术阵(满上限会失败, 不影响技能)
#   【★ duration 必须给正数 ★】前置包 internal/formation/create_prep 的原话是
#     "duration > 0 -> end = #now + duration; **否则不写 end(永久术阵)**"。
#     以前这里写死 0.0 -> 术阵**永不过期**, 会一直占着术阵槽(上限 3),
#     观测镜上的 "✡ n/3" 再也降不回去 —— 玩家报"效果结束后术阵不消失"。
#     给 X 秒(= 梦回层数), 和⑧的标记时长对齐; 漫彩被「白昼梦」续期时
#     由 hit_extra_dream 同步刷新, 两者一起结束。
data modify storage manacore:in arg set value {uuid:"",id:"sweetdream:lucid_dream",type:"lucid_dream",duration_seconds:0.0}
data modify storage manacore:in arg.uuid set from storage zx:work ld.uuid
execute store result storage manacore:in arg.duration_seconds double 1 run scoreboard players get #ld_x zx.meta
function manacore:api/formation/create

# ⑧ 标记该生物: 受击额外真伤, 持续 X 秒
#    标签 zx.ld_mark = "被标记" / ld_end = now + X*20 / ld_x = X / ld_u0..u3 = 射手 UUID
$execute as $(target) run tag @s add zx.ld_mark
$execute as $(target) run scoreboard players operation @s zx.ld_end = #now manacore.meta
scoreboard players operation #ld_dur zx.meta = #ld_x zx.meta
scoreboard players set #20 zx.meta 20
scoreboard players operation #ld_dur zx.meta *= #20 zx.meta
$execute as $(target) run scoreboard players operation @s zx.ld_end += #ld_dur zx.meta
$execute as $(target) run scoreboard players operation @s zx.ld_x = #ld_x zx.meta
data modify storage zx:work ldu set value {u0:0,u1:0,u2:0,u3:0}
data modify storage zx:work ldu.u0 set from storage zx:work ld.snap.u0
data modify storage zx:work ldu.u1 set from storage zx:work ld.snap.u1
data modify storage zx:work ldu.u2 set from storage zx:work ld.snap.u2
data modify storage zx:work ldu.u3 set from storage zx:work ld.snap.u3
$execute as $(target) run function sweetdream:equipment/bow/lucid_dream/mark_owner with storage zx:work ldu

# ⑨ 表现
$execute at $(target) run particle minecraft:soul_fire_flame ~ ~1 ~ 1.2 0.8 1.2 0.1 40 normal
$execute at $(target) run particle minecraft:end_rod ~ ~1 ~ 1.5 1.0 1.5 0.2 30 normal
$execute at $(target) run playsound minecraft:entity.evoker.cast_spell player @a ~ ~ ~ 1.2 0.8
$execute at $(target) run playsound minecraft:block.beacon.activate player @a ~ ~ ~ 1.0 1.6
