# ============================================================
# sweetdream:equipment/sword/gousi/ol_step —— 超限·钩丝 拉一只走一步(宏)
# ------------------------------------------------------------
# 【执行者】被拉的那只生物；位置已在它脚下
# 【宏参数】zx:work gs3 {own}
# 【三步】
#   ① 朝施法者方向 0.8 格的那个方块不可替换 -> 撞墙, **按"拉到位置"结算**
#      (文案: "在抵达身前 2 格或撞上不可替换的方块时停下。拉到位置后, 使其获得
#       5 秒缓慢Ⅱ, 并对其造成…" —— 撞墙停下也算"拉到位置", 不是 miss)
#   ② 没被结算(tag 还在)才真的 tp 这一步
#      ★ 用"标签还在不在"当门, 而不是再判一次方块: ① 结算时会摘掉 tag,
#        ② 自然就不成立; 两处各写一遍条件迟早写歪。
#   ③ 拉动的这一步给缓慢Ⅰ(1 秒, 每 0.25 秒续一次 = 全程覆盖)
# 【★ tp 之前必须 `facing entity <施法者> feet` ★】生物自己的朝向是乱的,
#   只用 `positioned ^ ^ ^0.8` 会朝着它自己看的方向走 —— 那是"推"不是"拉"。
# ============================================================

# ① 没有施法者标签(技能被中途打断) -> 这一步什么也不做
execute unless entity @e[tag=zx.gs3_src,limit=1] run return 0

# ② 撞墙 -> 停下并按到位结算
execute facing entity @e[tag=zx.gs3_src,limit=1] feet positioned ^ ^ ^0.8 unless block ~ ~ ~ #minecraft:replaceable run function sweetdream:equipment/sword/gousi/ol_land with storage zx:work gs3

# ③ 没被结算才真的拉 0.8 格
$execute if entity @s[tag=zx.gs3_$(own)] facing entity @e[tag=zx.gs3_src,limit=1] feet positioned ^ ^ ^0.8 run tp @s ~ ~ ~

# ④ 拉动期间: 常态缓慢Ⅰ + 拖尾
$execute if entity @s[tag=zx.gs3_$(own)] run effect give @s minecraft:slowness 1 0 true
execute at @s run particle minecraft:end_rod ~ ~0.6 ~ 0.15 0.25 0.15 0.01 4 normal
