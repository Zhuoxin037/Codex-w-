# ============================================================
# sweetdream:equipment/armor/dusk_dawn/find_dead —— 找回"刚刚被我打死的那只"
# ------------------------------------------------------------
# 【宏参数】zx:work v {u0,u1,u2,u3} = 玩家 UUID 四个整数
# 【产出】给那只挂标签 zx.dd_d(只挂一只, 取最近); 找不到就不挂(调用方有兜底)
# 【为什么需要它】超限版要算"X = 死者身上有几个通用效果", 而
#   player_killed_entity 进度的奖励函数**只能过滤、不能把实体传进来**
#   (和 attack 类进度同一个限制, 见 lib/victim 顶部的说明)。
#   于是回到原版自己留的线索上:
#     · last_hurt_by_player —— "最近打我的玩家"(UUID 四 int, 5 秒后清)
#     · Health:0.0f         —— 血条归零 = 正在死亡动画里(实体此时还在, 约 20 tick)
#   两个一起用就把"这个玩家 5 秒内打过的所有怪"收窄成"刚被打死的那只"。
# 【★ 为什么不用 DeathTime ★】死亡当刻它还是 0s, 而**活体也是 0s** ——
#   写 {DeathTime:0s} 会把旁边的活怪也选进来。Health:0.0f 才是可靠的判据
#   (tag/mark 里就是用 `unless data entity @s {Health:0.0f}` 排除死者的)。
# 【★ 兜底放在调用方 ★】找不到时调用方按 X=1 处理 —— 宁可少给, 不能给错。
# ============================================================

tag @e[tag=zx.dd_d] remove zx.dd_d
$execute as @e[type=!#sweetdream:no_damage,distance=..16,nbt={Health:0.0f,last_hurt_by_player:[I;$(u0),$(u1),$(u2),$(u3)]},sort=nearest,limit=1] run tag @s add zx.dd_d
