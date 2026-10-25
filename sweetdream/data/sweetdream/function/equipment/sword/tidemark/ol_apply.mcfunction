# ============================================================
# sweetdream:equipment/sword/tidemark/ol_apply —— 超限·潮痕: 给受击者「渊海」(已有则延到 30 秒)
# ------------------------------------------------------------
# 【谁调用它】tidemark/overlimit ⑦(逐只), 执行者 = 受击的那只
# 【原文】"之后使受到伤害的生物附加「渊海」，若其已有「渊海」则使其「渊海」的
#   持续时间提升至 30 秒。"
# 【渊海的时长存在哪】zx.tt.yuanhai, **单位是秒**(tag/mark_one 贴的时候给满 20,
#   由 tag/ttl_tick 每秒 -1)。所以"提升至 30 秒" = 把这条分数写成 30;
#   ★ 只许往长里调(`unless ... matches 30..`), 不然会把已经更长的状态**截短**。
# 【为什么不用 tag/mark 直接刷】tag/mark 只会 set 回满值 20 —— 那是"刷新", 不是 30 秒。
# 【贴标签的那一下仍走 tag/mark】附加时的 2 秒缓慢Ⅱ、护甲/图标等副作用都写在
#   tag/mark_one 里, 绕过去就会缺表现。
# ============================================================
execute unless entity @s[tag=zx.status.yuanhai] run function sweetdream:tag/mark {target:"@s",mark:"yuanhai"}
execute if entity @s[tag=zx.status.yuanhai] unless score @s zx.tt.yuanhai matches 30.. run scoreboard players set @s zx.tt.yuanhai 30
