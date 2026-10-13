# ============================================================
# sweetdream:equipment/bow/cloudtrail/field_make —— 生成「云迹」领域(宏 {uu})
# ------------------------------------------------------------
# 【宏参数】zx:work ctf {uu} = 射手 uuid 文本
# 【执行者】那支刚落地的箭; 位置 = 箭停留处(summon ~ ~ ~ 就落在那里)
# 【领域是什么】一个 marker 实体, 带标签 zx.ct_field, NBT 里存:
#   data.zx.uu = 射手 uuid 文本 —— 用来判"这个领域是不是**我**的"
#     (文案"当**自身**射击在领域内的生物时": 别人的领域不触发)。
#   计时用计分项 zx.ct_ft(= 5 秒), 由 lib/second 每秒 -1, 归零 kill 自己。
# 【半径 3】写在 fire 的判定箱里(-3.0..+3.0), 这里只是实体本身。
# ============================================================

$summon minecraft:marker ~ ~ ~ {Tags:["zx.ct_field","zx.ct_new"],data:{zx:{uu:"$(uu)"}}}
execute as @e[tag=zx.ct_new,distance=..2,limit=1] run scoreboard players set @s zx.ct_ft 5
tag @e[tag=zx.ct_new,distance=..2] remove zx.ct_new
