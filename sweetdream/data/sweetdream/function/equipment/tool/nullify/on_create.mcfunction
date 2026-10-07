# ============================================================
# sweetdream:equipment/tool/nullify/on_create —— 术阵创建成功时记一个标记
# ------------------------------------------------------------
# 【谁调用它】挂在前置包事件 #manacore:event/formation_create 上
#   (manacore/internal/formation/create_write 写盘成功后抛; 抛出前已写好
#    manacore:ctx = {id, uuid, reason:"create"})。
# 【为什么拆两层】tag 文件只是一串函数名, **没法给被调函数绑宏参数** ——
#   所以本函数(非宏)先把 ctx.uuid 抄进自己的节点, 再交给宏函数去拼路径。
# 【它只做一件事】按"术阵归属玩家"的 uuid 记一个 1b 标记(df form_mark)。
#   真正的判定(副手拿没拿「无效」)与兑现(+20% 下一次最大魔力技能)在
#   tool/nullify/second —— 只有那边才有玩家实体(@s)可以判副手。
# ============================================================

# 【★ 存储名和路径之间必须有空格 ★】`data storage manacore:ctx uuid` 才是
#   "存储 manacore:ctx 的 uuid 键"; 写成 `manacore:ctx.uuid` 会被当成**一个存储名**
#   (资源位置允许 `.`), 于是后面没有路径、直接撞上 run -> 整个函数解析失败(静默)。
#   2026-10-06 就是这么让「无效」彻底没生效的: 函数没加载 -> 事件 tag 里那条引用
#   断掉 -> 连 formation_create 事件一起失效。改完必看 latest.log 的
#   "Failed to load function"(check.py 抓不到命令语法! 已补规则见 RULES 坑 64)。
execute unless data storage manacore:ctx uuid run return 0
data modify storage zx:work nf.uu set from storage manacore:ctx uuid
function sweetdream:equipment/tool/nullify/on_create_go with storage zx:work nf
