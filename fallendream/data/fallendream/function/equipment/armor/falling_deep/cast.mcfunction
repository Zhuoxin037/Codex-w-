# ============================================================
# fallendream:equipment/armor/falling_deep/cast —— 落溟：节流 + 术阵 + 领域
# ------------------------------------------------------------
# 【谁调用它】falling_deep/tick ②（本刻有一次成功付费技能且穿着落溟）
# 【执行者】玩家
# 【做什么】① 12 秒节流 → ② 登记 1 个术阵位 → ③ 自身位置生成半径 3 格 / 5 秒领域
# ============================================================

# ① 12 秒节流（zx.fd_cd = 下次可触发刻；240 刻 = 12 秒）
#   ★ 先判后记账：判据被自己改掉就等于没有节流
scoreboard players add @s zx.fd_cd 0
execute if score @s zx.fd_cd > #now manacore.meta run return 0
scoreboard players operation @s zx.fd_cd = #now manacore.meta
scoreboard players add @s zx.fd_cd 240

# ② 登记 1 个术阵位（duration_seconds:5.0 → 5 秒自动到期释放）
#   ★ 不看返回值：领域判定只看 marker，术阵位满时技能照常生效
#     （同 condensed_shell/on_hurt 的口径）；也不额外清别人的术阵。
function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",id:"fallendream:falling_deep",type:"falling_deep",duration_seconds:5.0,data:{radius:3.0}}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/formation/create

# ③ 自身位置生成领域 marker
function fallendream:equipment/armor/falling_deep/spawn
