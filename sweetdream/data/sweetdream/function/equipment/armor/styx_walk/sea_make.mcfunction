# ============================================================
# sweetdream:equipment/armor/styx_walk/sea_make —— 召唤一片「暗海」(item_display)
# ------------------------------------------------------------
# 【宏来源】storage zx:work sea_mk {model, scale}
#   · model = sweetdream:sea_a / sea_b / sea_c(由 sea_pick_model 随机写入)
#   · scale = "0.6f"(主片 ⇒ 直径 6 格) / "0.4f"(次级片 ⇒ 直径 4 格)
# 【为什么宏化】summon 的 NBT 里有"物品模型名"和"scale"两处变量, 三形态 × 两尺寸
#   写死要 6 条几乎一样的 summon —— 宏一次搞定, 以后加形态只改 sea_pick_model。
# 【留下什么】实体带 zx.sea_new 标签, 调用方接着写归属/寿命/动画(见 sea_spawn)。
# 【坐标】执行位置 = 暗海中心(平图以实体位置为中心铺开, 见 _gen_sea.py 的尺寸约定)。
# ★ 行首 $ 必须真的含 $(变量), 否则整个函数作废(RULES 坑 3); 本行两个都有。
# ★ 必须带 with 绑定(RULES 坑 41 nowith): 宏函数缺绑定 = 一条都不跑, 且常零日志。
# ============================================================

$summon minecraft:item_display ~ ~ ~ {Tags:["zx.sea","zx.sea_new"],item:{id:"minecraft:stick",count:1,components:{"minecraft:item_model":"$(model)"}},brightness:{sky:6,block:6},interpolation_duration:0,transformation:{translation:[0.0f,0.02f,0.0f],scale:[$(scale),1.0f,$(scale)],left_rotation:[0.0f,0.0f,0.0f,1.0f],right_rotation:[0.0f,0.0f,0.0f,1.0f]}}
