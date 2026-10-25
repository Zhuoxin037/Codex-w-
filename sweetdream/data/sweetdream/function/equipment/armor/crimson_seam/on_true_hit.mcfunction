# ============================================================
# sweetdream:equipment/armor/crimson_seam/on_true_hit —— 绯缝: 真伤命中带噬心的目标 -> 回血
# ------------------------------------------------------------
# 【宏参数】zx:work ob {u0..u3}(施法者 UUID 四段)
# 【执行者】被打的那一只（@s = 目标）
# 【文案(lore 逐字)】自身魔力值上限 +120，最大生命值 +4。自身真实伤害命中了附有
#   「噬心」的生物后，为自身回复最大生命值 5% 的生命。该效果 6 秒内最多触发一次。
# 【★ 与殓丝的分工 ★】殓丝是同条件下"换「殓结」"(还要额外消耗噬心)，本件是**直接回血**。
#   两件可以同时生效(它们不是同一件装备)。
# 【★ 排在 deal **之后** ★】"命中了…后"; 且回血不该回头影响这一击。
#   判据由 internal/damage/one 给出(真伤 + 非敌方 + 目标带噬心), 这里只管施法者侧。
# ============================================================

# ① 施法者还在线吗
$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function sweetdream:lib/u_by
execute unless entity @a[tag=zx.ub,limit=1] run return 0

# ② 交给玩家上下文里的叶子件（穿着判定 / 节流 / 算 5% / 治疗 都在那边做）
$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function sweetdream:lib/u_by
execute as @a[tag=zx.ub,limit=1] run function sweetdream:equipment/armor/crimson_seam/heal_go
