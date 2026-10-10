# ============================================================
# sweetdream:tg/api/ids —— 标签 -> 装备 id 列表(反查索引)
# ------------------------------------------------------------
# 【入参】storage zx:work q{tag:"<标签>"}      (单个标签)
# 【出参】storage zx:out ids = ["装备id",…]    (该标签的全部装备; 没有则为空表)
# 【用法(肉鸽地图查"哪些装备是位移类")】
#     data modify storage zx:work q set value {tag:"dash"}
#     function sweetdream:tg/api/ids with storage zx:work q
#     data get storage zx:out ids
# 【any / all / at_least:N 怎么拼】
#   本接口只做**单标签**。调用方对每个标签各跑一次, 再自己并集 / 计数:
#     any        -> N 次结果取并集
#     at_least:N -> 累加每个 id 的出现次数, 取 >= N
#   (词表固定 27 个, 调用方最多跑 27 次; 反查表由 tg/def/load 建)
# ============================================================
data modify storage zx:out ids set value []
$execute if data storage zx:config tgidx."$(tag)" run data modify storage zx:out ids set from storage zx:config tgidx."$(tag)"
