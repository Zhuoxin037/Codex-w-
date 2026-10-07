# ============================================================
# sweetdream:equipment/sword/hush/back_step —— 归位的每刻驱动(约 0.2 秒)
# ------------------------------------------------------------
# 【谁调用它】sweetdream:core/tick:
#   execute as @a[tag=zx.hs_back] at @s run function ...
# 【怎么归位】每刻朝原点 marker 迈 2 格; 距离 <= 2 格就吸附并收尾。
#   突击全程最多 8 格 -> 8/2 = 4 刻 = 0.2 秒, 正好是"极速闪回"。
#   ★ 方向用 `facing entity <marker> feet` 现算, 所以玩家中途转视角也不影响。
# 【★ 为什么每刻要"重写一次共享节点 zx:work hs"】core/tick 是"每人依次调用":
#   每个人进来时先把自己的 uuid 写进节点、当场调宏函数(参数在调用那一刻就被
#   展开), 下一个人才覆盖 —— 所以多人同时归位也不会串味(宏参数不是"稍后读")。
# 【安全网】zx.hush_bk 每刻 -1, 归零则强制收尾(marker 万一丢了也不会卡死)。
#   【顺序】先减倒计时再判 —— 设 10 就最多闪 10 刻, 正常 3~4 刻就收尾了。
# ============================================================

# ① 先减倒计时(不管后面走哪条分支, 这一步都算)
scoreboard players remove @s zx.hush_bk 1

# ② 拿 uuid: 写进共享节点, 供下面的宏函数当场展开
function sweetdream:lib/uuid
data modify storage zx:work hs.uuid set from storage zx:data self.uuid

# ③ 到点(倒计时耗尽) -> 强制收尾
execute if data storage zx:data self{ok:1b} if score @s zx.hush_bk matches ..0 run function sweetdream:equipment/sword/hush/back_finish with storage zx:work hs

# ④ 正常推进: 朝 marker 迈步 / 到点收尾(见 back_move)
execute if data storage zx:data self{ok:1b} if entity @s[tag=zx.hs_back] run function sweetdream:equipment/sword/hush/back_move with storage zx:work hs

# ⑤ 兜底: uuid 拿不到(理论上不会发生) -> 放弃归位, 直接清状态, 别卡住玩家
execute unless data storage zx:data self{ok:1b} run tag @s remove zx.hs_back
execute unless data storage zx:data self{ok:1b} run scoreboard players reset @s zx.hush_bk
