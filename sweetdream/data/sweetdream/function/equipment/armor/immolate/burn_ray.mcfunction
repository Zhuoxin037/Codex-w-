# ============================================================
# sweetdream:equipment/armor/immolate/burn_ray —— 烈空每减 20 点触发一次
# ------------------------------------------------------------
# 【文案】「烈空」每减少 20 点, 则使自身 5 格内的随机 1 个生物燃烧 0.5 秒。
# 【★ 已删除“受到最大魔力 ×0.02 伤害” ★】
#   原因: 这段伤害是由玩家打出的, 会再次触发“玩家攻击生物”的回调,
#   配合余烬的“燃烧结束 → 流火/夜火”很容易形成左脚踩右脚的正反馈。
#   所以现在只点燃, 不造成伤害。
# 【同一只目标】先随机挑一只打上 zx.im_ray_pick, 再对它点火/粒子;
#   不这样做的话, 两次 sort=random 会各自随机, 火和粒子可能落在不同生物身上。
# ============================================================

execute unless entity @e[type=!#sweetdream:no_damage,distance=..5] run return 0
tag @e[tag=zx.im_ray] remove zx.im_ray
tag @e[type=!#sweetdream:no_damage,distance=..5] add zx.im_ray
tag @e[tag=zx.im_ray_pick] remove zx.im_ray_pick
execute as @e[tag=zx.im_ray,sort=random,limit=1] run tag @s add zx.im_ray_pick

# 只点燃 0.5 秒(10 tick) + 火焰粒子
execute as @e[tag=zx.im_ray_pick,limit=1] run data merge entity @s {Fire:10s}
execute as @e[tag=zx.im_ray_pick,limit=1] at @s run particle minecraft:flame ~ ~1 ~ 0.3 0.4 0.3 0.02 10 normal

tag @e[tag=zx.im_ray_pick] remove zx.im_ray_pick
tag @e[tag=zx.im_ray] remove zx.im_ray
