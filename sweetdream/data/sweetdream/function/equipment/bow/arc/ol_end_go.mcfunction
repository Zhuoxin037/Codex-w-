# ============================================================
# sweetdream:equipment/bow/arc/ol_end_go —— 超限·电弧: 放电收尾(宏)
# ------------------------------------------------------------
# 【谁调用它】ol_tick_go: 计时归零 => function .../ol_end_go with storage zx:work aw
# 【执行者/位置】放电锚(marker)自己
# 【宏参数】a0..a3 / b0..b3 = 配对两端 UUID 四个整数(锚的 data.zx 里是**独立键**,
#   不是列表 —— 见 ol_spawn 头部: 宏参数只能取键, 写成列表整段静默作废)
# 【收尾三件事(文案: "之后移除「电刺」")】
#   ① 移除两端身上的「电刺」(zx.status.dianci)
#   ② 摘掉两端的放电窗口标记 + 把窗口计时归零(锚万一被提前 kill 也能自愈)
#   ③ kill 锚自己
# 【★ 为什么按 UUID 回查而不是带标签】这 3 秒里两端可能走动/被打死; UUID 是唯一
#   稳的锚点(同 ol_tick_go 的存在性检查)。查不到就自然一条也不匹配, 不报错。
# 【★ 窗口计时为什么必须归零】ol_sweep 每秒也会 -1 → 两条路都会收, 谁先到都行;
#   留一个 >0 的残留分数会让"这一对"在窗口期内拒绝再起放电(ol_begin ⓪ 会 return)。
# ============================================================

# ① 移除双方的「电刺」
$tag @e[nbt={UUID:[I;$(a0),$(a1),$(a2),$(a3)]}] remove zx.status.dianci
$tag @e[nbt={UUID:[I;$(b0),$(b1),$(b2),$(b3)]}] remove zx.status.dianci

# ② 摘窗口标记 + 窗口计时归零
$tag @e[nbt={UUID:[I;$(a0),$(a1),$(a2),$(a3)]}] remove zx.arc_dis
$tag @e[nbt={UUID:[I;$(b0),$(b1),$(b2),$(b3)]}] remove zx.arc_dis
$scoreboard players set @e[nbt={UUID:[I;$(a0),$(a1),$(a2),$(a3)]}] zx.arc_dt 0
$scoreboard players set @e[nbt={UUID:[I;$(b0),$(b1),$(b2),$(b3)]}] zx.arc_dt 0

# ③ 锚自毁
kill @s
