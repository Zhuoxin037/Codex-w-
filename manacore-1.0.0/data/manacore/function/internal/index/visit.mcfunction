# ------------------------------------------------------------
# internal/index/visit —— 索引条目的分派器
# 【宏参数】manacore:index."<槽位>" 的条目 {uuid,u0,u1,u2,u3,slot}
# 【流程】先把条目整份复制进 manacore:work.a(统一参数节点),
#         再按 manacore:ctrl.mode 选择要执行的子流程。
# 【各模式做什么】
#   sweep                -> 该玩家是否还在线? 不在线就做离线清理
#   reset_session        -> 把 session 标记清零, 使其在下一次秒检查时重新注册
#   formation_remove_all -> 从该玩家身上删掉 ctrl.arg 指定的术阵
#   formation_find       -> 在该玩家的术阵里找 ctrl.arg, 找到就写 out
#   dump / validate      -> 调试输出 / 数据自检
# 【扩展方式】想加新的"全服遍历"功能, 只需在 ctrl.mode 加一个分支,
#         然后在 foreach 前设置好 mode(和 arg)即可, 不用改遍历逻辑。
# ------------------------------------------------------------
data modify storage manacore:work a set value {uuid:"",u0:0,u1:0,u2:0,u3:0,slot:0,i:0}
$data modify storage manacore:work a.uuid set value "$(uuid)"
$data modify storage manacore:work a.slot set from storage manacore:index "$(slot)".slot
execute if score #mode manacore.meta matches 1 run function manacore:internal/sweep/one with storage manacore:work a
execute if score #mode manacore.meta matches 2 run function manacore:internal/session/reset_one with storage manacore:work a
execute if score #mode manacore.meta matches 3 run function manacore:internal/formation/remove_all_one with storage manacore:work a
execute if score #mode manacore.meta matches 4 run function manacore:internal/formation/find_one with storage manacore:work a
execute if score #mode manacore.meta matches 5 run function manacore:internal/debug/dump_one with storage manacore:work a
execute if score #mode manacore.meta matches 6 run function manacore:internal/debug/validate_one with storage manacore:work a
execute if score #mode manacore.meta matches 7 run function manacore:internal/debug/purge_one with storage manacore:work a
execute if score #mode manacore.meta matches 8 run function manacore:internal/debug/export_one with storage manacore:work a
