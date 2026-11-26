# ============================================================
# fallendream:equipment/bow/bone_breaker/burst —— 碎骨·超限：累计 6 次的骨裂回响
# ------------------------------------------------------------
# 【执行者】被打中那只生物
# 【入参】zx:work bbb {base1000, u0..u3}
# 【文案】"同一生物每累计受到 6 次碎刀伤害, 则额外受到一次基础攻击力 ×3 的真实伤害
#   并获得 2 秒缓慢Ⅲ, 之后使其附加「噬心」。"
# 【★ 为什么用 uncapped ★】回响与第 6 次刀刃伤害**同一刻**打在同一只身上。默认
#   fallendream:true_damage 吃原版受伤无敌帧, 会被那一刀吃掉 ⇒ 走 uncapped, 让
#   internal/damage/deal 改投 fallendream:parallel_true_damage(在 bypasses_cooldown 里)。
# 【★ 计数清零放在最前 ★】回响一旦发出去就重新攒, 否则第 7 次起每一下都会再触发。
# ============================================================

# ① 重新攒
scoreboard players set @s zx.bb_cnt 0

# ② 表现: 骨头裂开
execute at @s run particle minecraft:dust{color:[0.92,0.88,0.78],scale:1.5} ~ ~1 ~ 0.5 0.6 0.5 0.06 24 normal
execute at @s run playsound minecraft:block.bone_block.break player @a ~ ~ ~ 1.0 0.85
execute at @s run playsound minecraft:entity.player.attack.crit player @a ~ ~ ~ 0.9 0.7

# ③ 真实伤害 = 基础攻击力 ×3
scoreboard players set #bb_r zx.meta 0
execute store result score #bb_r zx.meta run data get storage zx:work bbb.base1000
# 【★ R05 整数上界保护 ★】#bb_r 是 ×1000 定点, 下面要 ×3; 越过 int32 上界会静默回绕。
scoreboard players set #bb_cap zx.meta 2147483647
scoreboard players operation #bb_cap zx.meta /= #3 zx.meta
execute if score #bb_r zx.meta > #bb_cap zx.meta run scoreboard players operation #bb_r zx.meta = #bb_cap zx.meta
scoreboard players operation #bb_r zx.meta *= #3 zx.meta

data modify storage zx:work a set value {target:"@s",type:"fallendream:true_damage",uncapped:1b,damage:0.0,u0:0,u1:0,u2:0,u3:0}
execute store result storage zx:work a.damage double 0.001 run scoreboard players get #bb_r zx.meta
data modify storage zx:work a.num set from storage zx:work a.damage
data modify storage zx:work a.s2_b_num set value {n:0,d:1}
data modify storage zx:work a.u0 set from storage zx:work bbb.u0
data modify storage zx:work a.u1 set from storage zx:work bbb.u1
data modify storage zx:work a.u2 set from storage zx:work bbb.u2
data modify storage zx:work a.u3 set from storage zx:work bbb.u3
function fallendream:lib/num/plain
function fallendream:internal/attack/submit_extra

# ④ 2 秒缓慢Ⅲ(amplifier 2 = Ⅲ)
effect give @s minecraft:slowness 2 2 true

# ⑤ 附加「噬心」
data modify storage zx:work ic set value {target:"@s",mark:"shixin"}
function fallendream:tag/mark with storage zx:work ic
