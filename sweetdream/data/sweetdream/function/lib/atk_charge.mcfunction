# ============================================================
# sweetdream:lib/atk_charge —— 「本次平A的蓄力」通用判定工具(2026-10-10)
# ------------------------------------------------------------
# 【执行者】玩家。必须在"这次平A命中生物"的调用链里跑
#   (现行接点: upgrade/api/on_hit + 全包各武器的平A被动入口)。
# 【出参】(全部是 zx.meta 上的假玩家, 每次调用都重算)
#   #atk_full  = 1 / 0       是否**蓄满**(1 = 满蓄力平A)
#   #atk_pct   = 0..100      蓄力百分比(整数, 封顶 100)
#   #atk_gap   = tick        距上一次**命中**的刻数(封顶 1000)
#   #atk_as100 = 攻击速度×100 (剑 = 160 = 1.6)
#   @s zx.atk_ok = 1 / 0     本刻结论的**玩家级拷贝** —— ★ 全包闸门一律读它, 别读 #atk_full(见下)
#   ★ 常量 #atk_k2000 = 2000 / #atk_k20 = 20 由 core/load 设, 本文件不设。
# 【★★ 同一刻只算一次(2026-10-10 加) ★★】
#   用 `@s zx.atk_gt` 记"本刻已算过"; 同一刻的第二次调用**直接返回**, `@s zx.atk_ok` 保持第一次的结论。
#   为什么必须这样: 一记平A同刻可能同时触发**多个**入口(武器被动 + 护甲被动 + upgrade/on_hit),
#   若每个入口都重算, 第二个入口读到的是被第一个入口写过的 `zx.atk_lt` ⇒ gap = 0 ⇒ 误判"未蓄满"
#   ⇒ 被动全灭。加了缓存后"一记平A无论命中几只、经过几个入口, 只算一次"。
#   ★ 也正因为它, `#atk_full` 这种**全局假玩家**出参不能跨入口复用(同刻别的玩家会覆盖它)
#     ⇒ 闸门一律读玩家级的 `@s zx.atk_ok`(在算完那一刻就拷好了)。
# 【口径】原版蓄力 = min(1, 距上次**挥砍**的刻数 ÷ 冷却刻数), 冷却刻数 = 20 ÷ 攻击速度。
#   ★★ 数据包**观测不到"挥砍"**(原版没有"挥空"事件), 只能观测"命中" ⇒ 本工具量的是
#     "距上次**命中**"。挥空不计入 ⇒ "先空挥几下再打中"会被**高估**成满蓄力 —— 已知取舍,
#     真实玩法里连点打怪时两者基本一致(打中就必然是一次挥砍)。
#   ★ 判据写成**乘法**避免取整: 满蓄力 ⟺ gap × (攻速×100) ≥ 2000 (= 20 刻 × 100)。
#     例: 攻速 1.6(160) ⇒ 需 gap ≥ 12.5 ⇒ 13 刻; 攻速 2.0(200) ⇒ 10 刻。
#     ★ 攻速是**每发现读**的 ⇒ 吃得上任何攻速加成(陨星熔星形态的 attack_speed modifier 也一样:
#       攻速 4.0 → 12.0 时要求间隔从 5 刻缩到 2 刻, 工具自动跟上)。
#   ★ 蓄力是**玩家属性**、不分武器(换手不清零) ⇒ 全包共用一份记录 `zx.atk_lt`,
#     不按武器分家; 攻速读的当然是"这次A时手里那把"的值。
# 【怎么用】各武器自己的 hit / 平A被动入口最前面:
#     function sweetdream:lib/atk_charge
#     execute unless score @s zx.atk_ok matches 1 run return 0   # 只要满蓄力才继续
#   想放宽成"半蓄力以上": 把 ⑤ 的判据换成 `#atk_v >= 1000`(= 50%) 即可,
#   闸门照旧读 `@s zx.atk_ok`(不用动)。
# 【自测】`/tag @s add zx.dbg_atk` 之后每次平A会在聊天栏打出本发的蓄力值;
#   `/tag @s remove zx.dbg_atk` 关闭。
# ============================================================

# ⓪ 同一刻只算一次(见文件头 ★★)
#   首次调用没有记录 -> 补 -1(与 #now 必不相等, 于是继续往下算)
execute unless score @s zx.atk_gt = @s zx.atk_gt run scoreboard players set @s zx.atk_gt -1
execute if score @s zx.atk_gt = #now manacore.meta run return 0
scoreboard players operation @s zx.atk_gt = #now manacore.meta

# ① 距上次命中的刻数
#   ★ 首次调用(没有记录)**直接按"蓄满"放行** —— 别写成"把 atk_lt 补 0":
#     那样结果 = #now, 新世界刚开(#now < 13)的头几刻会被误判成"没蓄满"。
scoreboard players set #atk_gap zx.meta 1000
execute if score @s zx.atk_lt = @s zx.atk_lt run scoreboard players operation #atk_gap zx.meta = #now manacore.meta
execute if score @s zx.atk_lt = @s zx.atk_lt run scoreboard players operation #atk_gap zx.meta -= @s zx.atk_lt
#   ≥1000 一律算"久到蓄满"(也防 #now 很大时后面乘法溢出); ≤0 按蓄满放行
#   (理论上只可能出现在时钟被重置时; 同刻不会打两下, 所以 0 不可能是"真·同刻")。
execute if score #atk_gap zx.meta matches 1000.. run scoreboard players set #atk_gap zx.meta 1000
execute if score #atk_gap zx.meta matches ..0 run scoreboard players set #atk_gap zx.meta 1000

# ② 攻击速度 ×100(读失败兜底 1.6 = 160)
scoreboard players set #atk_as100 zx.meta 0
execute store result score #atk_as100 zx.meta run attribute @s minecraft:attack_speed get 100
execute if score #atk_as100 zx.meta matches ..0 run scoreboard players set #atk_as100 zx.meta 160

# ③ gap × 攻速×100(百分比与判据都从它算)
scoreboard players operation #atk_v zx.meta = #atk_gap zx.meta
scoreboard players operation #atk_v zx.meta *= #atk_as100 zx.meta

# ④ 蓄力百分比 = #atk_v ÷ 20, 封顶 100
scoreboard players operation #atk_pct zx.meta = #atk_v zx.meta
scoreboard players operation #atk_pct zx.meta /= #atk_k20 zx.meta
execute if score #atk_pct zx.meta matches 101.. run scoreboard players set #atk_pct zx.meta 100

# ⑤ 满蓄力? (#atk_v >= 2000)
scoreboard players set #atk_full zx.meta 0
execute if score #atk_v zx.meta >= #atk_k2000 zx.meta run scoreboard players set #atk_full zx.meta 1

# ⑥ 玩家级拷贝(闸门读它 —— 见文件头【同一刻只算一次】)
scoreboard players operation @s zx.atk_ok = #atk_full zx.meta

# ⑦ 自测输出(默认关闭, 见文件头【自测】)
execute if entity @s[tag=zx.dbg_atk] run tellraw @s [{"text":"[蓄力] ","color":"gray","italic":false},{"text":"本发 ","color":"gray","italic":false},{"score":{"name":"#atk_pct","objective":"zx.meta"},"color":"yellow"},{"text":"%   间隔 ","color":"gray","italic":false},{"score":{"name":"#atk_gap","objective":"zx.meta"},"color":"aqua"},{"text":" 刻   攻速 ","color":"gray","italic":false},{"score":{"name":"#atk_as100","objective":"zx.meta"},"color":"aqua"},{"text":"   满蓄力 = ","color":"gray","italic":false},{"score":{"name":"#atk_full","objective":"zx.meta"},"color":"green"}]

# ⑧ 记录本次命中刻 —— **必须最后写**(否则 ③ 算完就被自己清零)
scoreboard players operation @s zx.atk_lt = #now manacore.meta
