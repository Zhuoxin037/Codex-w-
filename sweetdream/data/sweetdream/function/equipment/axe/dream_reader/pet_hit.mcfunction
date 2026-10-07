# ============================================================
# sweetdream:equipment/axe/dream_reader/pet_hit —— “入梦体”够到目标, 结算并自毁
# ------------------------------------------------------------
# 【谁调用它】dream_reader/pet_tick(④, 进 1.4 格时)
# 【执行者】入梦体(marker)  【位置】目标生物附近
# 【做什么】① 造成 施法者当前魔力 ×0.1(施法那刻算好, 存在自己 NBT data.zx.dmg)
#   ② 使其时停 3 秒(lib/timestop 60 tick)  ③ 附加「白昼梦」(tag/mark dream)
#   ④ 自毁
# 【归属】用自己 NBT 里的 data.zx.u 四个整数走 internal/damage/with_from —— 不用反查玩家实体,
#   施法者离线也照样算他的伤害/击杀。
# 【★ 所有 @e 都带位置参数 ★】本函数在 core/tick 的"每维度"链上, 裸 @e 会跨维度重复处理。
# ============================================================

# ① 伤害 = 当前魔力(施法那刻) ×0.1, 带施法者归属
data modify storage zx:work a.num set value 0.0
data modify storage zx:work a.num set from entity @s data.zx.dmg
function sweetdream:lib/num/plain
data modify storage zx:work a.target set value "@e[tag=zx.dr_claim,distance=..2,sort=nearest,limit=1]"
data modify storage zx:work a.type set value "minecraft:player_attack"
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
data modify storage zx:work a.u0 set from entity @s data.zx.u[0]
data modify storage zx:work a.u1 set from entity @s data.zx.u[1]
data modify storage zx:work a.u2 set from entity @s data.zx.u[2]
data modify storage zx:work a.u3 set from entity @s data.zx.u[3]
function sweetdream:internal/damage/with_from with storage zx:work a

# ② 时停 3 秒
data modify storage zx:work fz.target set value "@e[tag=zx.dr_claim,distance=..2,sort=nearest,limit=1]"
data modify storage zx:work fz.ticks set value 60
function sweetdream:lib/timestop with storage zx:work fz

# ③ 附加「白昼梦」
data modify storage zx:work ic.target set value "@e[tag=zx.dr_claim,distance=..2,sort=nearest,limit=1]"
data modify storage zx:work ic.mark set value "dream"
function sweetdream:tag/mark with storage zx:work ic

# ④ 表现 + 自毁
execute at @e[tag=zx.dr_claim,distance=..2,sort=nearest,limit=1] run particle minecraft:soul ~ ~1 ~ 0.4 0.5 0.4 0.03 14 normal
execute at @e[tag=zx.dr_claim,distance=..2,sort=nearest,limit=1] run playsound minecraft:block.respawn_anchor.deplete player @a ~ ~ ~ 0.6 1.3
kill @s
