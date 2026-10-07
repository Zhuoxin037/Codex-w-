# ============================================================
# sweetdream:upgrade/item/uncolor —— 「无色石」的 give
# ------------------------------------------------------------
# 【无色石是什么】特殊石头(不走 α/β/Ω 链, 定义表里没有条目): 对副手装备使用,
#   消除**最近敲入**的一个升级, 并返还**该系列的全部升级石**(消 Ω 还 α+β+Ω,
#   因为敲 Ω 的前提是先敲过 α/β)。超限(ol)不受影响。
# 【编号】CMD 22 —— 三处对齐(由 _chk_stone_icons.py 守着):
#   ① 本文件 floats:[22.0f]  ② _gen_stone_icons.py CMD 表 + recovery_compass
#   的 entries  ③ 模型/贴图文件(stone/uncolor.*)真实存在
# 【谁还调它】upgrade/apply/uncolor 的失败分支(无色石还回来) +
#   upgrade/api/uncolor_give(返还被消的升级石走的是各自 item/<id>, 不是这里)
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"无色石",bold:true,color:"white"},custom_model_data={floats:[22.0f]},lore=[{"text":"✦ 特殊石头","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"对副手装备使用","color":"yellow"}]},{"text":" ","italic":false},{"text":"消除装备上最近敲入的一个升级，并返还","color":"gray","italic":false},{"text":"同系列的全部升级石。对超限无效。","color":"gray","italic":false}],custom_data={zx:["up_uncolor"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
