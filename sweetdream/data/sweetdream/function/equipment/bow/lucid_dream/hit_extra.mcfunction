# ============================================================
# sweetdream:equipment/bow/lucid_dream/hit_extra —— 被标记生物的"受击额外真伤"(每刻)
# ------------------------------------------------------------
# 【谁调它】core/tick: 对所有带 zx.ld_mark 的生物每刻跑一次(执行者 = 那只生物)。
# 【文案】"召唤术阵后该生物每次受到攻击都会使自身 2 格内的全部生物额外受到一次
#   相当于自身最大魔力值 ×0.0X 的真实伤害, 持续 X 秒。若持续时间内该生物被附加了
#   「白昼梦」效果, 则消耗「白昼梦」效果且技能持续时间延长 X 秒。(X 为「梦回」层数)"
# 【怎么判"受到攻击"】用 HurtTime:10s 检测(HurtTime 刚被设为 10 = 这一 tick 挨了打;
#   刚挨打完是一段 10..1 的倒计时, 只有 ==10 是"这一 tick")。
# 【怎么判"到点"】ld_end <= #now -> 结束(摘标签、清计分)。
# 【★ 白昼梦: 消耗 + 延长 X 秒 ★】(2026-10-05 改)
#   原文案是"延长至白昼梦结束", 现在是"**消耗**白昼梦 + 延长 X 秒":
#     · 一旦本 tick 发现该生物带 zx.status.dream -> 用 tag/unmark 摘掉它(= 消耗)
#     · 并把 ld_end 往后推 X 秒(X = 触发时的梦回层数, 存在 @s zx.ld_x)
#   每次延长只在"又新挂上白昼梦"时发生一次(摘了就没有了, 不会每刻都续)。
# 【伤害归属】用 zx.ld_u0..u3 反查施法者, 读其 max_mana。
# 【漫彩特效】只要标记还在, 每刻冒一点彩色粒子(见 ④)。
# ============================================================

# ① 到点: 结束
execute if score @s zx.ld_end <= #now manacore.meta run function sweetdream:equipment/bow/lucid_dream/hit_extra_end
execute unless entity @s[tag=zx.ld_mark] run return 0

# ② 漫彩期间被挂了「白昼梦」-> 消耗它 + 持续时间延长 X 秒
#    X = @s zx.ld_x(触发时存下的梦回层数); 延长 = X*20 tick
execute if entity @s[tag=zx.status.dream] run function sweetdream:equipment/bow/lucid_dream/hit_extra_dream

# ③ 这一 tick 挨打了吗(HurtTime == 10)
execute if entity @s[nbt={HurtTime:10s}] run function sweetdream:equipment/bow/lucid_dream/hit_extra_dmg

# ④ 漫彩特效: 标记还在就冒彩色粒子(每刻少量, 不刷屏)
particle minecraft:entity_effect{color:[0.60,0.85,1.00,1.0]} ~ ~1 ~ 0.5 0.7 0.5 0.02 2 normal
particle minecraft:end_rod ~ ~1.1 ~ 0.4 0.6 0.4 0.02 1 normal
