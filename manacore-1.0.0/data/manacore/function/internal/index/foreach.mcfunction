# ------------------------------------------------------------
# internal/index/foreach —— 遍历所有"已登记槽位"
# 【为什么需要遍历】玩家的 UUID 是任意字符串, 无法凭空枚举出来,
#         所以框架额外维护 manacore:index(槽位号 -> UUID)。
#         遍历 1..#next_slot 就等于遍历所有"曾经注册过"的玩家。
# 【为什么用递归】宏函数无法写循环。这里让 index/loop 自己调用自己,
#         每次把 i 加 1 存进 manacore:work.a.i, 再以该节点为参数递归。
#         深度最多 = #max_slots(默认 64), 远低于命令链上限。
# 【行为由谁决定】计分板 #mode(manacore.meta):
#         1=sweep(离线检测) 2=reset_session(重载后重置会话)
#         3=formation_remove_all(全局按 id 删术阵) 4=formation_find(查归属)
#         5=dump(全量打印) 6=validate(数据自检)
#         7=reset_all(清空全部玩家) 8=export_all(导出全部玩家)
# 【为什么用计分板而不是存储里的字符串】存储根路径无法参与比较,
#         计分板比较既简单又不会产生"路径缺失"的写法错误。
# 【前提】调用前必须把 #mode 设好; 需要附加参数(例如术阵 id)时
#         写 storage manacore:ctrl arg。
# 【i 会不会被覆盖】会。index/loop 每轮都会重新把 i 写回 work.a.i, 所以
#         被 visit 改掉也没关系。
# ------------------------------------------------------------
scoreboard players set #idx manacore.meta 1
execute store result storage manacore:work a.i int 1 run scoreboard players get #idx manacore.meta
execute if score #idx manacore.meta <= #next_slot manacore.meta run function manacore:internal/index/loop with storage manacore:work a
