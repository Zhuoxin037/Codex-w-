# ============================================================
# sweetdream:upgrade/api/bonus_one —— 把**一条**升级的数值并进总账(宏 {id})
# ------------------------------------------------------------
# 【两类字段, 两套规则】
#   dmg / mana / cd  : 乘区, 一律**累加**(0.1 = +10%), 单位 0.01 存在计分板上
#   mm / mr / mh/mhp : 分级链条, 交给 bonus_take 按"同系取最高 tier"处理
# 【为什么每次都先 set 0】data get 读不到(键不存在)时 store 不会执行,
#   分数会**留着上一次的值** —— 不先归零就会把别人的数值算进来(踩过)。
# ============================================================

# ---- 老三样: 累加 ----
scoreboard players set #up_t zx.meta 0
$execute store result score #up_t zx.meta run data get storage zx:config updef."$(id)".dmg 100
scoreboard players operation #up_dmg zx.meta += #up_t zx.meta
scoreboard players set #up_t zx.meta 0
$execute store result score #up_t zx.meta run data get storage zx:config updef."$(id)".mana 100
scoreboard players operation #up_mana zx.meta += #up_t zx.meta
scoreboard players set #up_t zx.meta 0
$execute store result score #up_t zx.meta run data get storage zx:config updef."$(id)".cd 100
scoreboard players operation #up_cd zx.meta += #up_t zx.meta

# ---- 分级链条: 取 series 和 tier, 交给下一层宏 ----
scoreboard players set #up_tier zx.meta 0
$execute store result score #up_tier zx.meta run data get storage zx:config updef."$(id)".tier
$data modify storage zx:work up.series set from storage zx:config updef."$(id)".series
function sweetdream:upgrade/api/bonus_take with storage zx:work up
