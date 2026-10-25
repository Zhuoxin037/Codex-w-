# ============================================================
# sweetdream:equipment/sword/tidemark/ol_strike —— 超限·潮痕: 一次"前方 4 长 × 5 宽"打击
# ------------------------------------------------------------
# 【谁调用它】tidemark/overlimit ⑥, 宏 {dmg} = 本次伤害
# 【怎么框出"前方 4 格长 × 5 格宽"】9 个采样球:
#   纵向(沿朝向) 1.0 / 2.0 / 3.0, 横向 ±1.5 / 0, 半径 1.05 —— 合起来
#     纵向 -0.05 ~ 4.05(≈4 格), 横向 -2.55 ~ 2.55(≈5 格)。
#   原版是"2 个球半径 1.0" = 4 长 × 2 宽; 超限只是把球从 2 个铺成 3×3 的方阵。
# 【横向怎么偏】先 `rotated ~ 0` 把俯仰归零, 再 `positioned ^ ^ ^1.0` 走到纵向位置,
#   然后 `rotated ~90 0` 把朝向转 90°、再用 `positioned ^ ^ ^±1.5` 就是**横向偏移**。
#   （`positioned ^ ^ ^` 用的是"当前执行朝向", rotated 会改它 —— 所以顺序不能反。）
# 【本轮内去重】同一只可能落进好几个球 -> zx.tm_hit 保证本轮只挨一次;
#   标记**不清**(overlimit ⑦ 要拿它挑"全部受击者"), 由 overlimit 末尾统一清。
# ============================================================

# 清上一轮(或别人残留)的本轮标记
tag @e[tag=zx.tm_hit,distance=0..] remove zx.tm_hit

execute rotated ~ 0 positioned ^ ^ ^1.0 run function sweetdream:equipment/sword/tidemark/ol_area with storage zx:work tm
execute rotated ~ 0 positioned ^ ^ ^2.0 run function sweetdream:equipment/sword/tidemark/ol_area with storage zx:work tm
execute rotated ~ 0 positioned ^ ^ ^3.0 run function sweetdream:equipment/sword/tidemark/ol_area with storage zx:work tm

execute rotated ~ 0 positioned ^ ^ ^1.0 rotated ~90 0 positioned ^ ^ ^1.5 run function sweetdream:equipment/sword/tidemark/ol_area with storage zx:work tm
execute rotated ~ 0 positioned ^ ^ ^2.0 rotated ~90 0 positioned ^ ^ ^1.5 run function sweetdream:equipment/sword/tidemark/ol_area with storage zx:work tm
execute rotated ~ 0 positioned ^ ^ ^3.0 rotated ~90 0 positioned ^ ^ ^1.5 run function sweetdream:equipment/sword/tidemark/ol_area with storage zx:work tm

execute rotated ~ 0 positioned ^ ^ ^1.0 rotated ~90 0 positioned ^ ^ ^-1.5 run function sweetdream:equipment/sword/tidemark/ol_area with storage zx:work tm
execute rotated ~ 0 positioned ^ ^ ^2.0 rotated ~90 0 positioned ^ ^ ^-1.5 run function sweetdream:equipment/sword/tidemark/ol_area with storage zx:work tm
execute rotated ~ 0 positioned ^ ^ ^3.0 rotated ~90 0 positioned ^ ^ ^-1.5 run function sweetdream:equipment/sword/tidemark/ol_area with storage zx:work tm
