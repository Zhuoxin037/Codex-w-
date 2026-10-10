# ============================================================
# sweetdream:equipment/axe/dream_reader/pet_hit —— “入梦体”够到目标, 结算并自毁
# ------------------------------------------------------------
# 【谁调用它】dream_reader/pet_tick(④, 进 1.4 格时)
# 【执行者】入梦体(marker)  【位置】目标生物附近
# 【做什么】① 造成 施法者当前魔力 ×0.1 / 超限 ×0.12(施法那刻算好, 存在自己 NBT data.zx.dmg)
#   ② 使其时停 2 秒(lib/timestop 40 tick; 基础版与超限版同)  ③ 附加「白昼梦」(tag/mark dream)
#   ④ 表现  ⑤ 记进"本次已打过"(zx.dr_done)  ⑥ 基础版自毁 / **超限版不自毁**(换下一个目标)
# 【★ 超限版为什么不再"打完就走" ★】原文的自毁条件换成了
#   "离施法者 18 格远 或 施法者 12 格内没有未攻击过的目标" —— 不再有"造成伤害后自毁"
#   ⇒ 一只入梦体可以连打多只, 直到附近没新的可打。(用户 2026-10-10 定稿)
# 【归属】用自己 NBT 里的 data.zx.u 四个整数走 internal/damage/with_from —— 不用反查玩家实体,
#   施法者离线也照样算他的伤害/击杀。
# 【★ 目标 = `@e[tag=zx.dr_hit,...]` ★】2026-10-08 改: 以前用 `@e[tag=zx.dr_claim,...]`
#   (通用占位标记), 那会打到"离自己最近的任一被认领者" —— 跟 pet_tick 那个"追同一只"的
#   bug 是同一根线。现在由 pet_follow 按 uuid 精确挑出"我那一只"、临时打上 zx.dr_hit,
#   本函数只认这个标记, 收尾时 pet_follow 会把标记摘掉。
# 【★ 所有 @e 都带位置参数 ★】本函数在 core/tick 的"每维度"链上, 裸 @e 会跨维度重复处理。
# ============================================================

# ① 伤害 = 当前魔力(施法那刻) ×0.1, 带施法者归属
data modify storage zx:work a.num set value 0.0
data modify storage zx:work a.num set from entity @s data.zx.dmg
function sweetdream:lib/num/plain
data modify storage zx:work a.target set value "@e[tag=zx.dr_hit,distance=..2,sort=nearest,limit=1]"
data modify storage zx:work a.type set value "minecraft:player_attack"
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
data modify storage zx:work a.u0 set from entity @s data.zx.u[0]
data modify storage zx:work a.u1 set from entity @s data.zx.u[1]
data modify storage zx:work a.u2 set from entity @s data.zx.u[2]
data modify storage zx:work a.u3 set from entity @s data.zx.u[3]
function sweetdream:internal/damage/with_from with storage zx:work a

# ② 时停 2 秒(= 40 tick) —— 基础版与超限版都是 2 秒(用户 2026-10-10 把基础版从 3 秒改过来)
data modify storage zx:work fz.target set value "@e[tag=zx.dr_hit,distance=..2,sort=nearest,limit=1]"
data modify storage zx:work fz.ticks set value 40
function sweetdream:lib/timestop with storage zx:work fz

# ③ 附加「白昼梦」
data modify storage zx:work ic.target set value "@e[tag=zx.dr_hit,distance=..2,sort=nearest,limit=1]"
data modify storage zx:work ic.mark set value "dream"
function sweetdream:tag/mark with storage zx:work ic

# ④ 表现
execute at @e[tag=zx.dr_hit,distance=..2,sort=nearest,limit=1] run particle minecraft:dust{color:[1.0,0.95,0.76],scale:1.3} ~ ~1 ~ 0.4 0.5 0.4 0.03 14 normal
execute at @e[tag=zx.dr_hit,distance=..2,sort=nearest,limit=1] run playsound minecraft:block.respawn_anchor.deplete player @a ~ ~ ~ 0.6 1.3

# ⑤ 记进"本次已打过"(3 只共享; 由 cast ⑥' 在场上没有入梦体时清掉)
tag @e[tag=zx.dr_hit,distance=..2,sort=nearest,limit=1] add zx.dr_done

# ⑥ 结局: 基础版打完就走(自毁); 超限版**不自毁** —— 摘掉绑定, 下一刻重新认领下一个没打过的
#   (摘了 zx.dr_has 就会走 pet_tick ④b; data.zx.tg 一并清掉, 免得留着旧 uuid 误导)
execute unless entity @s[tag=zx.dr_ol] run kill @s
execute if entity @s[tag=zx.dr_ol] run tag @s remove zx.dr_has
execute if entity @s[tag=zx.dr_ol] run data remove entity @s data.zx.tg
