# ============================================================
# sweetdream:equipment/staff/other_shore/roll_shixin —— 25% 概率给「只有渊海」者补「噬心」
# ------------------------------------------------------------
# 【执行者】只有「渊海」的那只生物   【位置】它自己
# 【技能原文】"若其只附有其中一种，则有 25% 的概率使其附加另一种。"
# 【★ 为什么用 lib/rnd 而不是 tick/坐标 ★】包内统一口径: LCG 自走序列, 与攻击节奏
#   和站位脱钩(lib/rnd 头注释里记着旧随机源导致"要么一直中要么一直不中"的事故)。
# 【★ 25% = 取模 4 等于 0 ★】#rnd 已经在 0..32767 拉平过, 直接 `%=` 4 即可。
# 【★ 宏调用为什么可以直接写 {target:"@s",mark:"..."} ★】包内现役写法
#   (lib/mark_take 里就是 `function sweetdream:tag/unmark {target:"$(target)",…}`)。
# ============================================================

function sweetdream:lib/rnd
scoreboard players operation #os_r zx.meta = #rnd zx.meta
scoreboard players operation #os_r zx.meta %= #4 zx.meta
execute if score #os_r zx.meta matches 0 run function sweetdream:tag/mark {target:"@s",mark:"shixin"}
