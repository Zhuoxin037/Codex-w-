# ============================================================
# sweetdream:event/player_first_join —— 新玩家 / reset_all 后首次上线
# ------------------------------------------------------------
# 【谁抛它】manacore:internal/join/new(在 register 之后抛一次);
#   标签在 manacore:event/player_first_join(sweetdream 侧往里追加本函数)。
# 【与 player_join 的区别(★ 本事件存在的理由)】
#   · player_join    : **每次注册都抛** —— 含老玩家重连。
#   · player_first_join: **只在 join/new 这条路**上抛 —— 新玩家首次注册, 或
#     debug/reset_all 删掉记录之后的首次上线(老玩家正常重连走 join/existing, 不抛)。
# 【做什么(N05 修, 2026-10-11)】debug/reset_all 只能对 @a(在线玩家)抛 player_reset,
#   **离线玩家**的 zx.* 账本那一次清不到 —— 他下次上线走的就是 join/new。在这里
#   复用 player_reset 那份"逐项清单"补一次清账; 之后各装备被动按**新面板**重算,
#   不会再"少一截加成"(差额恒 0)。
# 【新玩家】本来就没有账本, 清一遍无害。
# ============================================================
function sweetdream:event/player_reset
