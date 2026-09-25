# ============================================================
# api/stats/import —— 批量导入属性
# ------------------------------------------------------------
# 【调用模板】
#   data modify storage manacore:in arg set value {uuid:"<UUID>", stats:{max_mana:300.0, base_attack:12.5}}
#   function manacore:api/stats/import
# 【语义】只覆盖你给出的字段, 其他属性原样保留(merge 语义)。
# 【用途】读档恢复、外部系统(职业表/装备表)一次性写入整套面板。
# 【配套】api/stats/export 先导出、改完再导入, 是最稳的修改姿势。
# ============================================================
data modify storage manacore:work a set value {uuid:"",stats:{}}
data modify storage manacore:work a merge from storage manacore:in arg
function manacore:internal/stats/import with storage manacore:work a
