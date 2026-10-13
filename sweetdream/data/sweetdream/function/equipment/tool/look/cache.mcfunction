# ============================================================
# sweetdream:equipment/tool/look/cache —— 面板重数据的每秒缓存(以玩家身份执行)
# ------------------------------------------------------------
# 【谁调用它】lib/second: execute as @a[tag=test_look_on] run function ...(每秒)
#           toggle: 开启面板的那一刻也立即调一次(见 N07 修)
# 【O02 为什么要有它(2026-10-11, spark 剖析结论)】
#   任何 `data ... entity` —— 读也好、if data 也好 —— 都会把整个玩家
#   (54 格背包 + 全部物品组件 + lore)完整序列化成 NBT(NbtPredicate.entityToNbt)。
#   老面板每刻做: 1×Health + 1×SelectedItem.skill + 6×equip_scan(每条都是
#   if data entity / data modify from entity) ⇒ 开着面板 = **每刻最多 14 次全量
#   序列化**。spark 里那条 8~10 秒/分钟的热点主要就是它。
# 【重新分工】装备在身名单(eq)和手持武器 skill 字段改成**每秒缓存**进
#   zx:look cache; render_go(每刻)只读计分板/命令存储 —— 免序列化。
#   面板的显示粒度本来就是秒(v_cd 后缀 s), 观感不变; 换装最多滞后 1 秒。
# 【★★ N07 修(2026-10-11): 缓存按 UUID 分片 ★★】
#   原来 cache.eq / cache.skill 是**全服共用一格**: 调用点是
#   `execute as @a[tag=test_look_on]`(每人跑一遍), 每跑一遍都把同一格覆盖掉
#   ⇒ 每个人 render_go 时读到的都是"**最后那个人**"的装备/手持技能:
#     · 装备专属段(调色盘/炉心)会串到别人身上;
#     · 冷却读的是"别人的技能 id + 自己的 uuid" ⇒ 显示无关技能或恒 0;
#     · 最后那个人手里没武器时, 还会把别人要用的那格**删掉**。
#   现在路径 = zx:look cache."<uuid>".eq / .skill: 各人只写自己那格、只读自己那格。
# 【为什么要拆两层】uuid 只能靠宏变量拼进 storage 路径, 而宏变量必须 "with storage"
#   传 —— 本文件只做"普通事"(取 uuid / 判空), 宏部分全在 cache_go。
# ============================================================

# ① 取自己的 uuid(拿不到就收工, 免得按 cache."" 这种野键写)
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 转交宏叶子(执行者仍是玩家本人 —— equip_scan 要靠 @s 读身上的物品)
data modify storage zx:work a.uuid set from storage zx:data self.uuid
function sweetdream:equipment/tool/look/cache_go with storage zx:work a
