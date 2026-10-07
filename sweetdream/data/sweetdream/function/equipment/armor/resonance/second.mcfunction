# ============================================================
# sweetdream:equipment/armor/resonance/second —— 共振的每秒入口
# ------------------------------------------------------------
# 【谁调用它】挂在 #manacore:event/second 上(前置包每秒抛一次, 全局身份)
# 【为什么是"每秒"】装备的魔力上限只在换装那一下需要改, 秒级足够 ——
#   每刻跑是 20 倍开销换同样的结果。
# 【为什么先 execute as @a】事件是服务器身份、没有 @s, 后面每步都要玩家身份。
# 【自己注册自己】这个文件是谁的一部分, 就由谁在事件标签里登记一行 ——
#   以后加新的装备, 在标签的 values 里多加一条自己的 second 就行,
#   不用改任何别的装备的代码。
# 【技伤加成不在这里】那一条是施法瞬间的术阵数, 挂在 damage_calc 事件上,
#   见 equipment/armor/resonance/hook_calc。
# ============================================================

# 【备份公共输入口】理由见 lib/in_bak(这套每秒逻辑要读写魔力面板)
function sweetdream:lib/in_bak

execute as @a run function sweetdream:equipment/armor/resonance/passive

function sweetdream:lib/in_restore
