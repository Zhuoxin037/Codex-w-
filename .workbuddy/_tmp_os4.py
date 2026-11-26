import io, sys, os

BASE = r'D:/数据包/fallendream/data/fallendream/function/equipment/staff/other_shore'

def write(name, text):
    io.open(os.path.join(BASE, name), 'w', encoding='utf-8', newline='\n').write(text)
    print('ok', name)

write('roll_shixin.mcfunction', '''# ============================================================
# fallendream:equipment/staff/other_shore/roll_shixin —— 给「只有渊海」者补「噬心」
# ------------------------------------------------------------
# 【执行者】只有「渊海」的那只生物   【位置】它自己
# 【技能原文】"若其只附有其中一种，则有 25% 的概率使其附加另一种。"（超限：40%）
# 【★ 为什么用 lib/rnd 而不是 tick/坐标 ★】包内统一口径: LCG 自走序列, 与攻击节奏
#   和站位脱钩(lib/rnd 头注释里记着旧随机源导致"要么一直中要么一直不中"的事故)。
# 【★ 百分比怎么写 ★】#rnd 在 0..32767 上拉平过，先 %100 取 0..99，
#   再跟阈值比（原版 25 / 超限 40）。这样两档共用一个随机数、不用各抽一次，
#   也不用为 40% 特地凑一个"取模几"的数。
# 【档位从哪来】#os_ol —— ball_hit 从球的 data.ol 拍的（命中刻玩家可能已换手）。
# ============================================================

function fallendream:lib/rnd
scoreboard players operation #os_r zx.meta = #rnd zx.meta
scoreboard players operation #os_r zx.meta %= #100 zx.meta
scoreboard players set #os_t zx.meta 25
execute if score #os_ol zx.meta matches 1 run scoreboard players set #os_t zx.meta 40
execute if score #os_r zx.meta < #os_t zx.meta run function fallendream:tag/mark {target:"@s",mark:"shixin"}
''')

write('roll_yuanhai.mcfunction', '''# ============================================================
# fallendream:equipment/staff/other_shore/roll_yuanhai —— 给「只有噬心」者补「渊海」
# ------------------------------------------------------------
# 【执行者】只有「噬心」的那只生物   【位置】它自己
# 【技能原文】"若其只附有其中一种，则有 25% 的概率使其附加另一种。"（超限：40%）
# 【★ 与 roll_shixin 是一对 ★】两份分开写而不是做成一个宏, 是为了避免
#   "宏参数里塞中文/状态名"带来的可读性问题 —— 两个文件一眼能对上文案。
# 【百分比口径与档位同 roll_shixin】%100 + 阈值（25 / 40），档位读 #os_ol。
# ============================================================

function fallendream:lib/rnd
scoreboard players operation #os_r zx.meta = #rnd zx.meta
scoreboard players operation #os_r zx.meta %= #100 zx.meta
scoreboard players set #os_t zx.meta 25
execute if score #os_ol zx.meta matches 1 run scoreboard players set #os_t zx.meta 40
execute if score #os_r zx.meta < #os_t zx.meta run function fallendream:tag/mark {target:"@s",mark:"yuanhai"}
''')
