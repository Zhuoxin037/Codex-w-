# ============================================================
# manacore:internal/slot/rebuild —— 按 index 实际占用重建槽位回收池
# ------------------------------------------------------------
# 【为什么需要它(2026-10-10 修: 整包静默失效)】
#   core/boot 原来用 `data merge storage manacore:free_slots {list:[]}` 来"保证回收池存在",
#   但 NBT merge 对**列表是整体替换**(不是保留、也不是追加) ⇒ **每 reload 清空一次**。
#   而 #next_slot 只增不减 ⇒ 槽位只出不进 ⇒ 迟早撑满 #max_slots(默认 64)。
#   撑满之后 slot/new 按 F04 的规则"拒绝分配并把 @s 槽位清 0" ⇒ reissue 跳过
#   register ⇒ index 恒空 ⇒ session/verify 永远判"没注册" ⇒ 每秒重走一次 join
#   ⇒ **整个数据包静默失效**(不报错, 但技能/观测镜/提示全死)。
#   事故现场: #next_slot=64=#max_slots、#slot_full=1、#slot_overflow=52、index 空。
#   修法两条: ① boot 不再清空池子(见 core/boot); ② 池子内容可以从 index 反推(本文件)。
# 【不变量】占用 ⇔ index."<槽位>" 存在
#   - leave/body     : 先删 index 条目, 再把槽位还给池子(顺序固定, 两边的写都成对)
#   - slot/from_free : 从池子取走一个, 随后 register 立刻写入该槽的 index 条目
#   - slot/new       : 分出 #next_slot,   随后 register 立刻写入该槽的 index 条目
#   ⇒ "空闲槽 = 1..#max_slots 里**没有**索引条目的那些" 恒成立, 所以能反推。
# 【为什么敢整份重建】重建出来的集合, 与"正常回收一点点累积"出来的集合**完全相同**;
#   所以它同时也是**自愈**: 哪怕历史数据已经把池子漏光、#slot_full 卡在 1,
#   reload 一次就能还原, 不用手动去改计分板。
# 【为什么不在 slot/new 里就地补】补一格只能救一次; 这里是"整体对账", 一次性把
#   所有因异常(崩服/强制退出/旧版 bug)丢失的槽位全找回来。
# 【成本】只在 boot 跑一次, 最多 #max_slots(默认 64)轮递归 —— 与既有的
#   index/loop、index/find_uuid_loop 同量级, 实测没问题。
# 【元素类型】先用 [0] 占位把列表定型成 int 列表, 再逐格 append, 最后把占位删掉。
#   ★ 不要写成"先 `set value []` 再 append": 空列表没有元素类型, append 的结果
#     无法离线验证; 有 [0] 占位则类型确定, 行为确定。
# ============================================================
data modify storage manacore:free_slots list set value [0]
data modify storage manacore:work s set value {i:0,n:0}
scoreboard players set #i manacore.meta 1
function manacore:internal/slot/rebuild_go
data remove storage manacore:free_slots list[0]
scoreboard players set #i manacore.meta 1
