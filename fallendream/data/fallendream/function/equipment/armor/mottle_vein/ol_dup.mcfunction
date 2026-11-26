# ============================================================
# fallendream:equipment/armor/mottle_vein/ol_dup —— 超限·杂纹: 叠加第二次时的"重复触发"
# ------------------------------------------------------------
# 【谁调用它】consume ②.5（条件已判: 超限 + 这一种已经记过一次 + 还没记过第二次）
# 【执行者】消耗者玩家
# 【宏参数】zx:work mc.mark = 这一次被消费掉的标签名
# 【文案(lore 逐字)】"同一种类只计一次，但可以叠加 2 次。叠加的标签会重复触发对应效果。"
# 【★ 五种各自"重复触发"成什么样 ★】
#   流火  -> 再回 30 魔力 + 1%（直接复用 b_liuhuo, 它自己会按档取值）
#   噬心  -> 再回 25% 最大生命（b_shixin 同款）
#   渊海  -> 再在 6 格内退 2 格（b_yuanhai 同款）
#   夜火  -> 给 zx.mv_ny2：下一次技能伤害再来一份 +25%（hook_calc 两条都读）
#   白昼梦 -> 给 zx.mv_ts2：下一次平A 再时停一次（hit/victim_body 两条都读）
#   ★ 夜火/白昼梦本来就是"下一次"的一次性开关, 叠第二次只能再多挂一个开关,
#     不会立刻发生任何事 —— 所以这里只打第二个标签, 不调 reward。
# ============================================================

execute if data storage zx:work mc{mark:"liuhuo"} run function fallendream:equipment/armor/mottle_vein/b_liuhuo
execute if data storage zx:work mc{mark:"shixin"} run function fallendream:equipment/armor/mottle_vein/b_shixin
execute if data storage zx:work mc{mark:"yuanhai"} run function fallendream:equipment/armor/mottle_vein/b_yuanhai
execute if data storage zx:work mc{mark:"yehuo"} run tag @s add zx.mv_ny2
execute if data storage zx:work mc{mark:"dream"} run tag @s add zx.mv_ts2
