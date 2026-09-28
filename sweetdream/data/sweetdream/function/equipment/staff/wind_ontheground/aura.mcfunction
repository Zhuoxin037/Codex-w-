# ============================================================
# sweetdream:equipment/staff/wind_ontheground/aura —— 起"风声回响"(20 秒)
# ------------------------------------------------------------
# 【宏参数】zx:work wg {uuid}   【执行者】施法者
# 【文案】之后每 1 点「风声」使最大魔力提升 风声 ×10, 并对自身 5 格内的生物
#         造成 5 次 最大魔力 ×0.04 的伤害, 持续 20 秒; 结束后清空「风声」。
# 【"持续 20 秒"怎么理解】把 5 次伤害**摊在 20 秒里**: 每 4 秒打一次, 正好 5 次
#   (aura_tick 负责)。这样既满足"5 次"也满足"持续 20 秒", 而且两次之间隔得远,
#   不会撞上生物的受伤无敌帧。
# 【加的最大魔力要还】加完立刻把"加了多少"记在 zx.wg_mana 上,
#   end 的时候按这个数减回去 —— 不然会和静脉泵/套装的加成串味。
# ============================================================

# ① 最大魔力 + (风声 × 10)
scoreboard players operation #bonus zx.meta = @s zx.wg_sound
scoreboard players operation #bonus zx.meta *= #10 manacore.meta
data modify storage manacore:in arg set value {uuid:"",key:"max_mana",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 1 run scoreboard players get #bonus zx.meta
function manacore:api/stats/add
scoreboard players operation @s zx.wg_mana = #bonus zx.meta

# ② 倒计时 20 秒(由每秒入口 aura_tick 扣)
scoreboard players set @s zx.wg_aura 20

# ③ 表现
#   【只给音效和粒子, 不播报聊天文字】
#   这里原来有一句 tellraw("风声回响 —— 20 秒内最大魔力提升, 风会每隔一阵撕一次"),
#   已经按你的要求删掉了: 回响开始时间正好和"风声攒够了 +N%"那条挤在一起, 看着很乱。
#   回响的存在感靠 gust 粒子 + wind_burst 音效就够了, 不要再加回来。
execute at @s run particle minecraft:gust ~ ~1 ~ 3.0 1.0 3.0 0.05 40 normal
execute at @s run playsound minecraft:entity.breeze.wind_burst player @a ~ ~ ~ 1.0 1.0
