# ============================================================
# sweetdream:upgrade/api/ser_mark —— 把副手身上一条升级的"系列名"记进 seen 键集
# ------------------------------------------------------------
# 【宏参数】zx:work fs {id} = 副手 up 列表里的一条石头 id(fit 逐槽抄进来)
# 【为什么两层】"id 的系列名"要从定义表查(路径带宏), 而"按系列名写动态键"
#   又是一次宏 —— 所以拆两层: 这里查名, ser_put 写键。
# 【调用方】upgrade/api/fit 的 ③ 槽位判定
# ============================================================

$data modify storage zx:work fs.ser set from storage zx:config updef."$(id)".series
function sweetdream:upgrade/api/ser_put with storage zx:work fs
