# ============================================================
# sweetdream:equipment/sword/flame_brokenbody/night —— 处理「夜火」
# ------------------------------------------------------------
# 【执行者】施法者   【目标】zx.fb_night(cast 挑出来的、带夜火的那几只)
# 【文案】若攻击到的生物附有「夜火」则: 该技能冷却时间立即结束,
#         且每有一个「夜火」就吸收并为自身积攒一点「熔浆」。
# 【怎么数】execute if entity 的返回值就是匹配数量, 直接 store 到计分项。
# 【"吸收"是什么】把那几只身上的「夜火」摘掉(走通用标签接口) ——
#   它们头顶的夜火图标也会跟着收掉。
# ============================================================

# ① 数一数有几只
execute store result score #n zx.meta run execute if entity @e[tag=zx.fb_night]

# ② 冷却立即结束(不是"减 3 秒", 是直接归零)
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:flame_brokenbody"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/reset

# ③ 吸收: 每只 +1 熔浆, 并把「夜火」摘掉
scoreboard players operation @s zx.fb_lava += #n zx.meta
#   ★ 统一走 lib/mark_consume: 摘夜火的同时, 穿「余烬」的人会拿到
#      “消耗夜火 -> 回100魔力 + 力量5”的被动。以后别的武器消耗流火/夜火,
#      也只需要照这三行写, 不要在武器里直接 tag/unmark。
data modify storage zx:work a set value {target:"@e[tag=zx.fb_night]",mark:"yehuo"}
function sweetdream:lib/mark_consume

# ④ 表现: 火被吸走的感觉
execute at @e[tag=zx.fb_night] run particle minecraft:soul_fire_flame ~ ~1 ~ 0.4 0.6 0.4 0.03 20 normal
execute at @s run playsound minecraft:block.fire.extinguish player @a ~ ~ ~ 0.8 0.8
execute at @s run playsound minecraft:block.lava.pop player @a ~ ~ ~ 0.8 1.1

tag @e[tag=zx.fb_night] remove zx.fb_night
