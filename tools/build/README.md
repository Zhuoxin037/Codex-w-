# 构建与发布流程（可复现）

> 审查报告 **O09**：发布产物不能取决于"本机恰好有 `.workbuddy` 里某个可选脚本"。
> 从 2026-10-10 起，**工具链脚本本身已纳入版本控制**（`.gitignore` 对 `.workbuddy/`
> 下的 `*.py` / `*.ps1` 做了白名单），所以 clone 下来就能重建。

本目录只放**流程说明**；真正的工具脚本在 `.workbuddy/`。分四类：

| 阶段 | 干什么 | 入口 | 什么时候跑 |
| --- | --- | --- | --- |
| **① 生成** | 由"单一真源"重新生成数据包/资源包里那些**不能手改**的文件（give 行、超限定义、回收图标、注册表展开…） | `.workbuddy/_gen_*.py` · `build_vanilla_pack.py` · `build_full_pack.py` · `draw_*.py` | 改了对应的真源之后 |
| **② 检查** | 静态自检 + 各专项回归 | `.workbuddy/check.py`（**必须 0 问题**）+ `_chk_*.py` | 每次改完、**发布前必跑** |
| **③ 打包** | 合并资源包、出 zip | `python .workbuddy/build_vanilla_pack.py`（覆盖层）→ `python .workbuddy/build_full_pack.py --zip`（完整版） | 发布前 |
| **④ 部署** | 镜像到存档/资源包目录 | `部署到存档.bat` → `deploy.ps1`；资源包另见 `build_full_pack.py --deploy` | 每次要进游戏测之前 |

## 解释器（唯一坑）

本机只有 `.workbuddy` 目录下的 venv 装了 `PIL`，**所有 `build_*` / `_gen_*` / `draw_*`
脚本都必须用它**：

```
C:\Users\qq303\.workbuddy\binaries\python\envs\default\Scripts\python.exe
```

`check.py` 与 `_chk_*.py` 不依赖 PIL，用哪个 python 都行（但用上面这个最稳）。

## 最小发布流程

```bash
PY="C:/Users/qq303/.workbuddy/binaries/python/envs/default/Scripts/python.exe"

# 1) 生成（仅当改过真源）
"$PY" .workbuddy/build_vanilla_pack.py          # 重建覆盖层 sweetdream_rp_原版风/
"$PY" .workbuddy/build_full_pack.py --deploy --zip   # 合并成完整版 + 部署 + 出 zip

# 2) 检查
"$PY" .workbuddy/check.py                        # 合计问题必须 = 0

# 3) 部署数据包
#    双击 部署到存档.bat（或跑 deploy.ps1 <存档文件夹>）
#    ★ deploy.ps1 里的显示同步脚本是**必需**的：缺一个就报错停止，
#      不会"有就跑、没有就当没这回事"(O09)。
```

## 发布前还要确认（审查报告 C01 / C02）

- **C01**：`/scoreboard players set #dev zx.meta 0` —— 收窄调试管理入口给 `zx.admin`。
- **C02**：按需用 `发布可选配置/bypasses_cooldown.no_player_attack.json` 覆盖
  `sweetdream/data/minecraft/tags/damage_type/bypasses_cooldown.json`。
- **兼容范围**：以 `pack.mcmeta` 为准 —— 数据包格式 **71**、资源格式 **55**、**仅 1.21.5**。

## 进游戏后的最后两道

1. `/reload`，看日志有没有 `Failed to load function`（有 = 某个函数整份没加载）。
2. 改过资源包 ⇒ `F3+T` 重载；改过 `damage_type` / `enchantment` / 数据包注册表 ⇒ **退世界重进**。
