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
# 【★★ 为什么要打 zx.em_burn —— 修“余烬有时不触发”的关键 ★★】
#   余烬的流火/夜火是“燃烧结束”的边沿检测: 它扫一次, 只认
#   自己上一次打过 zx.em_burn 标记、这一次 Fire 归 0 的目标。
#   （扫描周期: 2026-10-12 前是每秒 20 tick; 之后用户嫌“灭了不能及时上标记”,
#     由 core/tick **每 5 刻**调 ember/scan_one —— 见那里的头注。）
#   而焚舟这一把火只有 10 tick(0.5 秒) —— 比余烬的采样周期还短。
#   于是“扫到没扫到”全看相位: 采样点落进这 10 tick 里就触发, 落在外面
#   这次点燃就凭空消失了。更糟的是焚舟的衰减也是 20 tick 一次(烈空
#   180/160/…/0), 和余烬同频 —— 相位一旦错开, 一整轮 10 次点火全废,
#   表现就是“有时整轮都触发, 有时整轮都不触发”。
#   现在点火当场把 zx.em_burn 打上, 余烬下一秒一定接得到, 与相位无关。
# ============================================================

execute unless entity @e[type=!#sweetdream:no_damage,distance=..5] run return 0
tag @e[tag=zx.im_ray] remove zx.im_ray
tag @e[type=!#sweetdream:no_damage,distance=..5] add zx.im_ray
tag @e[tag=zx.im_ray_pick] remove zx.im_ray_pick
execute as @e[tag=zx.im_ray,sort=random,limit=1] run tag @s add zx.im_ray_pick

# 点燃 0.5 秒(10 tick, 只延长不缩短) + 火焰粒子 + 打余烬边沿标记
execute as @e[tag=zx.im_ray_pick,limit=1] at @s run function sweetdream:equipment/armor/immolate/ignite
scoreboard players add @s zx.im_ignite 1

tag @e[tag=zx.im_ray_pick] remove zx.im_ray_pick
tag @e[tag=zx.im_ray] remove zx.im_ray
