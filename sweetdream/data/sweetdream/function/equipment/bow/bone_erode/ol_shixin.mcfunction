# ============================================================
# sweetdream:equipment/bow/bone_erode/ol_shixin —— 超限·蚀骨: 带「噬心」的额外来一下
# ------------------------------------------------------------
# 【谁调用它】fire ④, 且这一发是超限版(be.snap.ol=1):
#     `as @e[tag=zx.be_aoe,tag=zx.status.shixin]` —— 逐只带噬心的送进来
# 【执行者】带「噬心」的那一只生物(@s)
# 【文案】"若生物上附有「噬心」则额外受到一次相当于本次伤害 80% 的真实伤害"
# 【"本次伤害"取多少】= 本次射击所消耗的魔力值 ×0.5 = `#be_dmg`
#   (fire ① 已从快照读好, 存成 ×100 的整数)。这里 ×80 ÷100 即 ×0.8。
#   ★ 取的是**名义值**, 不含通用标签那层: 「噬心」本身对真实伤害有 +15%(全局规则,
#     见 internal/damage/one), 那是结算时自动叠的, 不算在"本次伤害"里。
# 【伤害归属】带射手 by(u0..u3 从 be.snap 抄) —— 击杀才算玩家头上、走同一套掉率/记账。
# 【★ 为什么这里不用范围选择器 ★】本函数的 @s 就是"那一只", 直接打 @s 最省;
#   internal/damage/with_from 内部会 `execute as` 逐个展开, 传选择器也行, 没必要。
# ============================================================

# ① 额外伤害 = #be_dmg × 0.8(×100 口径: ×80 再 ÷100)
scoreboard players set #be_x zx.meta 0
execute store result score #be_x zx.meta run scoreboard players get #be_dmg zx.meta
scoreboard players operation #be_x zx.meta *= #80 zx.meta
scoreboard players operation #be_x zx.meta /= #100 zx.meta

# ② 打真实伤害(带射手归属)
data modify storage zx:work a set value {target:"@s",damage:0.0,num:0.0,type:"sweetdream:true_damage",u0:0,u1:0,u2:0,u3:0}
execute store result storage zx:work a.damage double 0.01 run scoreboard players get #be_x zx.meta
data modify storage zx:work a.num set from storage zx:work a.damage
function sweetdream:lib/num/plain
data modify storage zx:work a.u0 set from storage zx:work be.snap.u0
data modify storage zx:work a.u1 set from storage zx:work be.snap.u1
data modify storage zx:work a.u2 set from storage zx:work be.snap.u2
data modify storage zx:work a.u3 set from storage zx:work be.snap.u3
function sweetdream:internal/damage/with_from with storage zx:work a

# ③ 表现(原地再爆一圈骨刺, 比主伤那下小而利)
particle minecraft:item{item:"minecraft:bone"} ~ ~1 ~ 0.5 0.4 0.5 0.04 12 normal
playsound minecraft:entity.skeleton.hurt player @a ~ ~ ~ 0.5 1.6
