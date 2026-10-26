# ============================================================
# sweetdream:event/player_prepare_new —— 新建记录前清理本包旧属性(S02)
# 【调用方】manacore:internal/join/new, 分配槽位成功后、读取实际攻击力前。
# 【执行者】玩家本人(@s), 此时尚未登记; 不调用 lib/uuid 或 manacore API。
# 仅摘本包修饰符与配套状态标签, 保留分数和返还队列。
# zx.ret_pend / zx.ret_slot 是旧版欠款迁移的判据, 必须留到 player_join 迁移完;
# 逐项清账仍由随后 player_first_join -> player_reset 执行。
# 普通重连走 join/existing, 不触发本事件。被标签直接调用, 必须保持无宏。
# ============================================================
function sweetdream:internal/attr/cleanup

tag @s add zx.j_new_record
