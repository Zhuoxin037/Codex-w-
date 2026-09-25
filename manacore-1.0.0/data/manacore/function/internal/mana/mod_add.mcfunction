# ============================================================
# internal/mana/mod_add —— 添加一条魔力恢复修正
# ------------------------------------------------------------
# 【宏参数】manacore:work.a {uuid,id,type,value,duration|duration_seconds}
# 【使用场景】装备加成 / 被动技能 / 临时药剂 —— 三者只是 type 不同。
# 【流程】
#   ① mod_find_driver 找一个空槽位 -> #free(找不到为 -1)
#   ② #free = -1 -> mod_full(报错: 槽位满, out.success=0b)
#   ③ 否则 mod_prep 把 #free 写进 work.a.i, 再交给 mod_write 落库
# 【id 的作用】同一个 id 重复添加会占用多个槽位; 用 modifier/remove 按 id
#         删除可以一次清掉所有同名修正(换装/卸装场景常用)。
# 【为什么用固定槽位而不是动态键】见 regen_driver 的注释。
# ============================================================
$data modify storage manacore:work entry set value {uuid:"$(uuid)",i:0}
function manacore:internal/mana/mod_find_driver with storage manacore:work entry
execute if score #free manacore.math matches -1 run function manacore:internal/mana/mod_full
execute if score #free manacore.math matches 0.. run function manacore:internal/mana/mod_prep with storage manacore:work a
