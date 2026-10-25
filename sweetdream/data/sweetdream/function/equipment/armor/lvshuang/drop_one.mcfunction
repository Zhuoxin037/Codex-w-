# ============================================================
# sweetdream:equipment/armor/lvshuang/drop_one —— 超 6 片时收掉一片
# ------------------------------------------------------------
# 【为什么不用宏挑最旧】marker 数量极小（<=7），随便收一片与"收最旧"在体感上
#   没有区别；给每片排序号要多一个计分项 + 一次遍历取最小，不划算。
# ============================================================
execute as @e[type=marker,tag=zx.lsh_frost,limit=1] at @s run function sweetdream:equipment/armor/lvshuang/frost_end
