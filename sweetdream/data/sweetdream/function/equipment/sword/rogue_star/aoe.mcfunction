# ============================================================
# sweetdream:equipment/sword/rogue_star/aoe —— 一个锁定点的范围结算(宏 {damage})
# ------------------------------------------------------------
# 【谁调用它】hit_due: `execute at @e[tag=zx.rs_<uuid>] run function ... with storage zx:work rsh`
# 【执行者】施法者(玩家)   【位置】被锁目标所在处(at 改的是坐标, 不改执行者)
# 【★ 为什么执行者不是那只生物 ★】api/damage 靠 @s 是不是玩家来决定"击杀归属";
#   让执行者保持玩家、只把**坐标**搬到目标处, 归属才带得对。
# 【范围】对目标 2 格内的**全部**生物(技能原文: "其 2 格内的全部生物")。
# ============================================================

$data modify storage zx:in arg set value {target:"@e[type=!#sweetdream:no_damage,distance=..2]",damage:$(damage)}
function sweetdream:api/damage

# 【超限·游星】再打**一次**同样的伤害(文案: "造成**两次**相当于自身基础攻击力
#   ×4 的伤害")。zx:in arg 还在, 直接再调一次即可 —— 不用重写入参。
#   ★ 同一 tick 的两段不会互相吃掉: sweetdream:skill 这个伤害类型被加进了
#     原版 minecraft:bypasses_cooldown 标签(见 api/damage 的说明)。
execute if data storage zx:work rsh{ol:1b} run function sweetdream:api/damage

# 表现: 落点一圈星辉炸开
particle minecraft:explosion ~ ~1 ~ 0.3 0.3 0.3 0.05 12 normal
particle minecraft:end_rod ~ ~1 ~ 0.6 0.6 0.6 0.05 20 normal
playsound minecraft:entity.player.attack.crit player @a ~ ~ ~ 0.8 1.2
