# ============================================================
# fallendream:equipment/bow/burst_dawn/shade_model —— 「魂灵之影」外观载体每秒兜底
# ------------------------------------------------------------
# 【谁调用它】lib/second 三维度各一行(`as @e[type=item_display,tag=zx.bd_model] at @s`)
# 【执行者】item_display(魂灵之影的外观载体)
# 【★ 2026-11-02 起它只做"寿命兜底", 定位交给 shade_follow ★】
#   以前这里每秒跑一次贴地自校准(shade_fit_one), 是为了弥补**骑乘**带来的
#   挂载高度误差。现在载体不骑乘了、每刻由 shade_follow 贴到载具脚底,
#   translation 固定 +0.5 与载具无关 ⇒ 不需要校准, 那一秒的"先错后对"也没了。
# 【为什么还需要它】
#   载体不会跟着铁傀儡一起消失(它不是乘客了, 就是个独立实体)。铁傀儡有三种
#   死法: ① 寿命到期(自己 kill @s) ② 被怪打死 ③ 被当弹药 kill。三种都由
#   shade_follow 每刻的"附近 2 格内没有 zx.bd_shade ⇒ 收尸"覆盖; 这里再按
#   **载体自己的寿命账**(zx.bd_mft)补一道, 防的是"影还在、但载体卡在别处"
#   这种没人管的漏网状态。
# 【21 秒的来由】影本身 20 秒; 载体多留 1 秒当收尸窗口(见 shade_make)。
#   ★ 这个计分项是**载体自己的账**, 不读 zx.bd_ft(=铁傀儡的):
#     铁傀儡一死, 它身上的计分项就查不到了。
# ============================================================

scoreboard players remove @s zx.bd_mft 1
execute if score @s zx.bd_mft matches ..0 run return run function fallendream:equipment/bow/burst_dawn/shade_model_die
# 载具还在 ⇒ 继续活着(定位由 shade_follow 每刻负责)。找不到才收尸。
execute if entity @e[tag=zx.bd_shade,distance=..2,limit=1] run return 0
function fallendream:equipment/bow/burst_dawn/shade_model_die
