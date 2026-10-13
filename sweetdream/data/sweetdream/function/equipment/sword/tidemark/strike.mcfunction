# ============================================================
# sweetdream:equipment/sword/tidemark/strike —— 一次"前方 4 长 × 2 宽"打击(宏 {dmg})
# ------------------------------------------------------------
# 【谁调用它】tidemark/cast: `function .../strike with storage zx:work tm`
# 【执行者】施法者(玩家); 【位置】他所在处
# 【怎么框出"前方 4 格长 × 2 格宽"】2 个采样点(前向 1.0 / 3.0, 各半径 1.0):
#   球 1 覆盖 0~2, 球 2 覆盖 2~4 -> 合起来 0~4 格长、横向 ±1 格 = 2 格宽。
# 【本轮内去重】一只生物可能落进两个球 -> 用 zx.tm_hit 保证本轮只挨一次(选择器判 tag)。
#   ★ 标记**不清** —— cast ⑧ 要拿它挑"随机一个受击者"附加「渊海」, cast 末尾才统一清。
# ============================================================

# 清上一轮(或别人残留)的本轮标记
tag @e[tag=zx.tm_hit,distance=0..] remove zx.tm_hit

# 2 个采样点(沿朝向, 俯仰归零避免打到脚前)
execute rotated ~ 0 positioned ^ ^ ^1.0 run function sweetdream:equipment/sword/tidemark/area with storage zx:work tm
execute rotated ~ 0 positioned ^ ^ ^3.0 run function sweetdream:equipment/sword/tidemark/area with storage zx:work tm
