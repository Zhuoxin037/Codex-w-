# ============================================================
# sweetdream:equipment/tool/look/cooldown_get —— 查"主手那把武器"的剩余冷却
# ------------------------------------------------------------
# 【宏参数】sweetdream:work a {uuid, skill}
#   由 look/render_go 从"主手物品的 custom_data.skill"读出来再传进来。
# 【为什么要单独一个宏函数】冷却的路径是动态的:
#     players."<uuid>".cooldowns."<技能id>".end
#   而宏变量在"调用那一刻"就固定了。所以必须等读到技能 id 之后,
#   再调一次带宏的函数, 才能把技能 id 拼进路径里。
# 【出参】#v_cd zx.meta = 剩余秒数(向上取整); 没在冷却就是 0
# ============================================================

# 没在冷却时这条路径不存在, data get 会失败 -> 计分项保留旧值。
# 所以先手动归零, 再尝试覆盖。
scoreboard players set #v_end zx.meta 0
$execute store result score #v_end zx.meta run data get storage manacore:players "$(uuid)".cooldowns."$(skill)".end

# 剩余 tick = 结束刻 - 当前刻, 负数当 0
scoreboard players operation #v_cd zx.meta = #v_end zx.meta
scoreboard players operation #v_cd zx.meta -= #now manacore.meta
execute if score #v_cd zx.meta matches ..0 run scoreboard players set #v_cd zx.meta 0

# tick -> 秒, 向上取整: (n + 19) / 20
# 用自己包的 #tps(=20), 不用前置包的 #interval —— 那个是"回魔间隔",
# 数值碰巧一样, 改了回魔间隔会把这里的秒数带歪。
scoreboard players add #v_cd zx.meta 19
scoreboard players operation #v_cd zx.meta /= #tps zx.meta
