# ============================================================
# sweetdream:overlimit/def/load —— 超限定义表(由 core/load 调用)
# ------------------------------------------------------------
# 【存在哪】zx:config oldef."<武器id>" = {dmg:.., mana:.., cd:.., note:".."}
#   dmg  = 超限后整把武器伤害乘区加算(0.25 = +25%)
#   mana = 魔力消耗乘区加算(正数=更耗蓝; 想更容易放就写负数)
#   cd   = 冷却乘区加算(正数=冷却更长)
# 【每个武器一条】只有"和武器 id 对应的超限石"才敲得上(见 overlimit/api/fit)。
#   武器独有的那部分效果写在武器自己的超限钩子里(见文档)。
# ============================================================

data modify storage zx:config oldef."liaoyuan" set value {dmg:0.25,mana:0.30,cd:0.25,note:"灼烧更强, 但更耗蓝、冷却更长"}
data modify storage zx:config oldef."wind_ontheground" set value {dmg:0.20,mana:0.20,cd:0.20,note:"风声相关效果增强"}