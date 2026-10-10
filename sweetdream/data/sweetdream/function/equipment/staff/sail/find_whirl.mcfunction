# ============================================================
# sweetdream:equipment/staff/sail/find_whirl —— 找出"自己放的那个旋风"
# ------------------------------------------------------------
# 【谁调用它】sail/recall 第 ① 步
# 【宏参数】zx:work slu {uuid}   【执行者】施法玩家(位置无所谓)
# 【出参】那个旋风 marker 被打上 zx.sl_mine 标签(找不到就没有)。
# 【★ 按"释放者 uuid"找, 不按"被记录生物的 UUID" ★】
#   marker 的 data.zx.sl 里存着两样:
#     · uuid = **释放者**的 uuid 字符串(whirl_spawn 从 zx:work sl.uuid 抄, 来源 zx:data self.uuid)
#     · u0..u3 = **被记录生物**的 UUID 四个 int(从玩家计分项 zx.sl_u0..u3 抄)
#   用后者也能"大体"定位, 但两个人若记录了同一只生物(同一只僵尸), 两个旋风的 u0..u3
#   就一模一样 -> recall 的 limit=1 可能挪走别人的旋风。用 uuid 字符串则严格唯一:
#   "自己的旋风" = 自己放的那个(用户口径: "传送的是旋风")。
#   ★ 写法与 sword/hush 的 org_clear、final_revelation/beam_go 同款(嵌套 nbt= 已被验证可用)。
# 【★ 先清全场 ★】免得上一次调用留下的标签被当成这一次的目标。
# ============================================================

tag @e[tag=zx.sl_mine,distance=0..] remove zx.sl_mine
$tag @e[tag=zx.sl_vtx,nbt={data:{zx:{sl:{uuid:"$(uuid)"}}}}] add zx.sl_mine
