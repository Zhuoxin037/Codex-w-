# ------------------------------------------------------------
# internal/damage/mk_from —— 拼出"按 UUID 定位玩家"的选择器
# 【宏参数】玩家记录 {u0,u1,u2,u3}
# 【产出】work.a.from = @a[nbt={UUID:[I;u0,u1,u2,u3]},limit=1]
# 【注意】limit=1 保证只选中一个实体。
# ------------------------------------------------------------
$data modify storage manacore:work a.from set value "@a[tag=manacore.u$(uuid),limit=1]"
