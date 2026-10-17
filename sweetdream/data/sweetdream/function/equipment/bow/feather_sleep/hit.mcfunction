# ============================================================
# sweetdream:equipment/bow/feather_sleep/hit —— 一枚羽箭的落地结算
# ------------------------------------------------------------
# 【执行者】被这一枚羽箭打中的那只生物(由 fire 用 as/at 送进来)
# 【入参】zx:work fs {dmg, u0..u3}(伤害已按本发口径算好; u0..u3 = 射手 UUID)
# 【做什么】① 羽箭落点表现 ② 打一份带射手归属的伤害 ③ 3 秒缓慢Ⅱ
# 【★ 伤害归属必须带 u0..u3 ★】不然击杀算不到射手头上(死亡信息/掉落归属会丢)。
#   走 internal/damage/with_from, 它会在 /damage 后面补 by <攻击者>。
# ============================================================

# ① 表现: 一片羽毛 + 半透明的白羽拖影(文案的"半透明羽箭")
execute at @s run particle minecraft:item{item:{id:"minecraft:feather",count:1}} ~ ~1 ~ 0.2 0.4 0.2 0.02 6 normal
execute at @s run particle minecraft:cloud ~ ~1 ~ 0.15 0.3 0.15 0.01 4 normal
execute at @s run playsound minecraft:entity.arrow.hit_player player @a ~ ~ ~ 0.6 1.7

# ② 伤害(带射手归属; 类型沿用 zx:config damage_type 的口径, 缺省走玩家攻击)
data modify storage zx:work a set value {target:"@s",damage:0.0,type:"minecraft:player_attack",u0:0,u1:0,u2:0,u3:0}
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
data modify storage zx:work a.damage set from storage zx:work fs.dmg
data modify storage zx:work a.u0 set from storage zx:work fs.u0
data modify storage zx:work a.u1 set from storage zx:work fs.u1
data modify storage zx:work a.u2 set from storage zx:work fs.u2
data modify storage zx:work a.u3 set from storage zx:work fs.u3
data modify storage zx:work a.num set from storage zx:work a.damage
function sweetdream:lib/num/plain
function sweetdream:internal/damage/with_from with storage zx:work a

# ③ 「获得 3 秒缓慢Ⅱ」—— amp 1 = Ⅱ; hideParticles=true(与包内 debuff 同款)
effect give @s minecraft:slowness 3 1 true
