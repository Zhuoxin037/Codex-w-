# ============================================================
# sweetdream:equipment/armor/tide_fold/spend —— 「消耗了 150 魔力值」的兑现口
# ------------------------------------------------------------
# 【执行者】玩家(@s)（由 core/tick 每刻筛 zx.tf_sum ≥ 150000 的人）
# 【★ 文案(逐字)】"自身在消耗「渊海」或消耗了 150 魔力值后在自身位置生成一面…水墙"
# 【★ 满了不扣账 ★】先试着立墙, **成功(#tf_ok=1)才扣 150 魔力** —— 设计稿 §六:
#   "4 个上限: 满了不再生成（也不消耗掉触发它的那次消费）"。
#   ⇒ 不能先减后判: 那样玩家在墙满了的时候会白白蒸发 150 点消耗记录。
# ============================================================

function sweetdream:equipment/armor/tide_fold/new
execute unless score #tf_ok zx.meta matches 1 run return 0

# 扣掉 150 魔力（zx.tf_sum 的单位是 魔力×1000 ⇒ 150 × 1000）
scoreboard players operation #tf_c zx.meta = #150 zx.meta
scoreboard players operation #tf_c zx.meta *= #1000 zx.meta
scoreboard players operation @s zx.tf_sum -= #tf_c zx.meta
