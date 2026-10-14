# ============================================================
# manacore:debug/registry_add —— 手动把一条历史记录补进"终身清单"(A03/Q03 运维入口)
# ------------------------------------------------------------
# 【用法】/function manacore:debug/registry_add {uuid:"<键>"}
#   ★ 传的必须是 **manacore:players 里实际那个键** = **32 位纯十六进制**
#     (小写, 无连字符) —— 见 internal/uuid/build: 键直接就是 a.hex, 不拼连字符。
#     · 传"8-4-4-4-12 带连字符的 UUID" ⇒ 匹配不到任何记录(键不是那个形态);
#     · 传"8 位短键" ⇒ 也匹配不到 —— 短键是 **旧版遗留键**, 只作 migrate 的**输入**。
#     两者都会走到下面的"记录不存在"分支: 不报错, 但也不会有任何改动。
#   ★ 拿不到键时: 翻存档备份里 `manacore:players` 的键, 或在服务器日志里找玩家 UUID
#     再去掉连字符、转小写。
# ------------------------------------------------------------
# 【作用】
#   ① 把 uuid append 进 manacore:players_all.list(终身清单);
#   ② 给记录打 reg = 1b。
#   记录不存在 ⇒ 什么都不做(绝不建空记录)。
# ------------------------------------------------------------
# 【★★ Q03(2026-10-11 四审): 为什么现在是"强制"补登记 ★★】
#   A03(三审)修好了 migrate 的"双键漏登记", 但**没能修已经产生的坏状态**:
#   更早的版本可能给一条记录打过 `reg=1b`, 而它其实**从来没进过清单**
#   (旧第 ③ 步在"两键都在"时无条件设 reg, 而登记条件在那种情况下恒假)。
#   对这种记录, 旧版 registry_add 还带着 `unless reg` 这道门 ⇒ 人工口也救不回来。
#   ⇒ 现在**不看 reg**, 一律补登记。理由:
#     · 查重做不到 —— 清单元素是**裸字符串**, 没有任何"列表里含不含某个字符串"的语法;
#     · **重复项无害** —— purge_registry 逐项 `data remove` 时, 第二条会因为
#       `if data storage manacore:players "$(uuid)"` 不成立而被挡掉(见 purge_registry_go);
#       一致性只看"清单里有这个键", 重复只是多遍历一次。
#   ⇒ 拿"可能多一条重复"换可用性: 宁可多一条冗余, 也不能让坏记录永远清不掉。
#   ★ 自动路径(migrate / existing)仍保留 `unless reg` —— 那两条每次上线都跑,
#     无条件 append 会让清单无限增长; 本入口是**人工**的, 跑几次加几条, 可控。
# ------------------------------------------------------------
# 【为什么需要"手动"这一条】
#   纯命令**枚举不出未知的存储键** —— `/data get storage manacore:players` 能整份读出来,
#   但没有任何逐键遍历的语法。所以"补丁前就离线、此后一直没上线、又不在终身清单里"
#   的历史记录(报告 A03 的第二半)没法自动找出来。
#   运维从存档备份 / 服务器日志里拿到键后, 用本命令逐个补登记; 补完再跑
#   debug/reset_all 就能把它们一起清掉。
#   ★ 正常路径(上线 / 迁移)会自动补登记, 本入口只兜"永不上线"的边角。
# ------------------------------------------------------------
# 【宏参数】{uuid} —— 写进 uuid 字段。缺失会整段作废(宏缺失变量是运行期错误)。
# ============================================================

# ① 补登记 + 打标(**强制**: 不看 reg; 记录不存在时两句都不成立 = 不建空记录)
$execute if data storage manacore:players "$(uuid)" run data modify storage manacore:players_all list append value "$(uuid)"
$execute if data storage manacore:players "$(uuid)" run data modify storage manacore:players "$(uuid)".reg set value 1b

# ② 明确回报这次到底做了什么。
#    ★ 旧文案"记录或 reg 不存在时未改动"是**错的** —— 记录存在而 reg 不存在时
#      恰恰**会**改动, 那正是本入口最常见的用法。现在分两种结果如实报。
$execute unless data storage manacore:players "$(uuid)" run tellraw @s [{"text":"[registry_add] ","color":"gold"},{"text":"$(uuid)","color":"white"},{"text":" 在 manacore:players 里没有这条记录 —— 未做任何改动。请核对键: 必须是 32 位纯十六进制(见 internal/uuid/build), 既不是带连字符的 UUID, 也不是 8 位短键。","color":"red"}]
$execute if data storage manacore:players "$(uuid)" run tellraw @s [{"text":"[registry_add] ","color":"gold"},{"text":"$(uuid)","color":"white"},{"text":" 已补登记进终身清单(players_all.list) 且置 reg=1b。★ 若它本来就在清单里, 这次会多出一条重复项 —— 无害(purge 逐删时第二条被 `if data` 挡掉)。","color":"green"}]
