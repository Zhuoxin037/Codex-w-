# ============================================================
# sweetdream:equipment/staff/burst_bank/wet_drop —— 决堤超限：在当前脚下留一个水流点
# ------------------------------------------------------------
# 【谁调用】step（每个突进的子步，每 4 个子步 = 2 格放一个点）
# 【宏参数】zx:work bb（uuid / ol / pd / ld / u0..u3 …，施法时拍的快照）
# 【★ marker 只带 tag、不带 NBT ★】它是"这里曾经有水"的锚点，参数每次从施法者身上现取
#   （见 wet_own）。给 marker 写 NBT 会让所在 chunk 每刻标脏（卡顿第 1 类）。
# ============================================================
$execute at @s run summon minecraft:marker ~ ~ ~ {Tags:["zx.bb_wet","zx.bb_wet_$(uuid)"]}
