# ============================================================
# sweetdream:equipment/armor/armor_mana/has_mana —— 该玩家记录里到底有没有 current_mana
# ------------------------------------------------------------
# 【宏参数】zx:work am {uuid}   ★ 不能直接传 zx:data self(宏函数会一条命令都不跑, 见 check 规则 selfmacro)
# 【出参】#mhas zx.meta = 1(在) / 0(不在)   【执行者】玩家
# 【为什么需要它】manacore:internal/mana/get 的 out r.value 是"恒存在的 0.0"
#   (取不到字段时也写 0.0), 不能拿它判"读到了没有" —— 见 apply_mana 的说明。
#   这里直接查玩家记录里的字段, 才是真正的"读到了"。
# ============================================================
$execute if data storage manacore:players "$(uuid)".stats.current_mana run scoreboard players set #mhas zx.meta 1
