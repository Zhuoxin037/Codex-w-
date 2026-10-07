# ============================================================
# sweetdream:equipment/armor/blaze_armor/pig_calm —— 焱·「视为金甲」(宏)
# ------------------------------------------------------------
# 【宏参数】zx:work ba = {u0,u1,u2,u3} = 玩家 UUID 四个 int
# 【做什么】把 16 格内"正对你发怒"的猪灵的怒气记忆清掉 => 它不再把你当敌人。
# 【★ 为什么用 UUID 精确匹配, 而不是"范围内猪灵一律清怒气" ★】
#   后者会把"正在追别人"的猪灵也一起劝好 —— 那不是"视为金甲", 那是"和平光环"。
#   精确匹配只动跟你有关的那一份怒气。
# 【★ 为什么是 AngryAt ★】猪灵的敌对目标走 NeutralMob 的 AngryAt 字段
#   (持久化的 NBT 键就叫 AngryAt)。原版猪灵还有一份 Brain 记忆
#   minecraft:angry_at, 两份都清才不会"下一刻又想起来"。
# 【兜底】猪灵蛮兵(piglin_brute)天生敌对、不吃这套, 原版也是这样, 不管。
# ============================================================

$execute as @e[type=minecraft:piglin,distance=..16,nbt={AngryAt:[I;$(u0),$(u1),$(u2),$(u3)]}] run function sweetdream:equipment/armor/blaze_armor/pig_calm_one

# 【第二条: 只有 Brain 记忆、AngryAt 还没落盘的那半秒】猪灵被激怒的瞬间是
#   先写 angry_at 记忆、再由 NeutralMob 同步到 AngryAt 字段的 —— 中间那几刻
#   NBT 里只有记忆。补一条同款匹配把它也捞进来。
#   ★ 写法如果和当前版本的 NBT 结构不符(有的版本直接存 [I;…] 而不是
#     {uuid:[I;…]}), 这条就是**静默不匹配**, 不会报错也不会误伤 —— 安全。
$execute as @e[type=minecraft:piglin,distance=..16,nbt={Brain:{memories:{"minecraft:angry_at":{uuid:[I;$(u0),$(u1),$(u2),$(u3)]}}}}] run function sweetdream:equipment/armor/blaze_armor/pig_calm_one
