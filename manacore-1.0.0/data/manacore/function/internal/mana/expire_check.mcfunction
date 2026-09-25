# ------------------------------------------------------------
# internal/mana/expire_check —— 临时修正到期判定
# 【宏参数】manacore:work.entry {uuid,i,e}   e = 该修正的结束时刻
# 【逻辑】end <= #now  -> mod_clear(清掉这个槽位, 不再加成)
#         end >  #now  -> mod_sum (还没到期, 正常加成)
# 【#now】框架自己的游戏刻时钟, 由 core/tick 维护。
# ------------------------------------------------------------
execute store result score #mend manacore.math run data get storage manacore:work entry.e
execute if score #mend manacore.math <= #now manacore.meta run function manacore:internal/mana/mod_clear with storage manacore:work entry
execute if score #mend manacore.math > #now manacore.meta run function manacore:internal/mana/mod_sum with storage manacore:work entry
