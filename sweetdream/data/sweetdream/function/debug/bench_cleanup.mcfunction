# ============================================================
# sweetdream:debug/bench_cleanup —— 清掉**旧版强化台**在世界里留下的箱子
# ------------------------------------------------------------
# 【用法】/function sweetdream:debug/bench_cleanup
# 【什么时候用】2026-10-08 之前, 敲升级石 / 超限石要在主世界 0,-59,2 现场
#   setblock 一个箱子当"改物品 NBT 的跳板"。那是上古版本"用箱子做强化台"的
#   残留: 后来操作方式改成"装备副手 + 石头主手右键", 箱子却一直在世界里。
#   现在整条链已经换成**临时盔甲架**(见 station/api/apply_go), 不会再产生新箱子,
#   但**已经躺在世界里的那几个**不会自己消失 —— 用这个函数清一次即可。
#
# 【★ 只清"空箱子" ★】
#   `if block ... minecraft:chest{Items:[]}` 是安全阀: 万一你自己在那儿放过东西,
#   箱子不会被清掉(setblock air 会把里面的东西一并销毁)。
#   ★ 你自己上古版本搭的那个箱子(比如 0,-59,0 那种)不在这份名单里 ——
#     那些是你放的, 直接手动敲掉就行, 我不猜坐标去动你的世界。
#
# 【清完要不要再看一眼】跑完会 tellraw 报"清了几个"; 报 0 说明那几个位置本来
#   就没有空箱子(或者早就被你拆了)。
# ============================================================

scoreboard players set #bc_n zx.meta 0

# ① 旧强化台: 0,-59,2
#    【store success 才是"到底清没清"】不能用"现在是不是 air"来计数 ——
#     那个位置本来就是空气的话会被算成"清掉了", 数字就没有参考价值了。
execute in minecraft:overworld store success score #bc_a zx.meta if block 0 -59 2 minecraft:chest{Items:[]} run setblock 0 -59 2 minecraft:air replace
execute if score #bc_a zx.meta matches 1 run scoreboard players add #bc_n zx.meta 1

# ② give_all 的暂存箱: 0,-60,2(正常流程结束时会自己清, 中途被打断才可能留下)
execute in minecraft:overworld store success score #bc_a zx.meta if block 0 -60 2 minecraft:chest{Items:[]} run setblock 0 -60 2 minecraft:air replace
execute if score #bc_a zx.meta matches 1 run scoreboard players add #bc_n zx.meta 1

tellraw @s [{"text":"[调试] 旧强化台箱子清理完成，清掉 ","color":"green"},{"score":{"name":"#bc_n","objective":"zx.meta"},"color":"white"},{"text":" 个（只清空箱子；你自己放东西的箱子不会动）","color":"green"}]
