# ============================================================
# sweetdream:tag/mark —— 给生物贴一个"通用标签"并显示图标
# ------------------------------------------------------------
# 【宏参数】zx:work ic {target, mark}
#   target : 选择器字符串(可以是范围选择器, 会逐个处理)
#   mark   : 标签名 —— 目前约定这 5 个:
#              yuanhai  渊海    liuhuo   流火    yehuo  夜火
#              shixin   噬心    dream    白昼梦
# 【存哪】写在生物身上: data.zx.status."<mark>" = 1b
#   —— 沿用深海回响已经在用的结构, 所以老数据不用迁移。
# 【为什么要逐个处理】每个生物要拿一个**自己的**图标编号; 一次性给一堆生物
#   写同一个编号的话, 图标就会跟错人。
# 【用法】
#   data modify storage zx:work ic set value {target:"@e[tag=xxx]",mark:"yuanhai"}
#   function sweetdream:tag/mark with storage zx:work ic
# ============================================================

$execute as $(target) run function sweetdream:tag/mark_one with storage zx:work ic
