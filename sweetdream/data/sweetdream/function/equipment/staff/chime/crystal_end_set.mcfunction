# ============================================================
# sweetdream:equipment/staff/chime/crystal_end_set —— 共鸣水晶·自毁: 反查释放者(宏)
# ------------------------------------------------------------
# 【谁调用它】chime/crystal_end(`with storage zx:work che`)
# 【宏参数】u0..u3 = 释放者 UUID 的四个 int; ol = 这颗水晶是不是超限召唤的
# 【它做什么】只有**超限**水晶才在自毁时打那一下"当前魔力 ×0.2"; 原版只表现 + kill。
# 【为什么反查释放者】"自身当前魔力值"的"自身" = 释放者 —— 只能切到他身上去算
#   (同 crystal_set 的手法; 释放者离线则整段静默跳过, 可接受)。
# 【位置】调用链只 `as` 不 `at`, 坐标仍是水晶处 —— 但 crystal_end_go 不许用坐标
#   (check 规则 asnoat), 所以目标靠 crystal_end 已经圈好的标签 zx.ch_e。
# ============================================================

$execute if data storage zx:work che{ol:1} as @a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},limit=1] run function sweetdream:equipment/staff/chime/crystal_end_go
