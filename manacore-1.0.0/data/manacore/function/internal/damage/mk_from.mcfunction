# ------------------------------------------------------------
# internal/damage/mk_from —— 拼出"按 UUID 定位玩家"的选择器
# 【宏参数】玩家记录 {u0,u1,u2,u3}
# 【产出】work.a.from = @a[nbt={UUID:[I;u0,u1,u2,u3]},limit=1]
# 【注意】limit=1 保证只选中一个实体。
# ------------------------------------------------------------
# 用玩家记录里的 u0..u3 反向定位玩家实体。
# 【为什么不用 tag=manacore.u$(uuid)】全包没有任何地方设置过那个标签,
#   选不到人 -> /damage 的 by 指向空选择器 -> 整条命令失败 -> 一点伤害都没有。
# 【为什么用 UUID 的 4 个整数】UUID 文本没法直接写进选择器, 这 4 个整数可以。
$data modify storage manacore:work a.from set value "@a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},limit=1]"

# 选不到实体(记录还没采集、或人不在线)就把 from 清掉,
# 让 from_auto 退化成 @s —— 宁可归属差一点, 也不能让命令失败。
$execute unless entity @a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},limit=1] run data remove storage manacore:work a.from
