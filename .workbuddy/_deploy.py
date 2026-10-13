# -*- coding: utf-8 -*-
"""
_deploy.py —— 把 manacore-1.0.0 / sweetdream / sweetdream_rp_完整版 镜像到存档
--------------------------------------------------------------------------
为什么不用 deploy.ps1 / robocopy:
  · deploy.ps1 结尾有 Read-Host, 非交互会话会挂住;
  · robocopy 在 Git-Bash 里对含中文的路径会返回 16(异常退出码)。
  所以用 Python 走一条等价于 robocopy /MIR 的镜像: 内容不同就覆盖, 目标里
  多出来的文件就删除(这样源里删过的函数不会在目标里残留)。

★ 2026-10-10(F20 修): 资源包改镜像"游戏实际加载的那一份" = `sweetdream_rp_完整版`
  (options.txt 里 resourcePacks 一直是它)。原来这里镜像的是老包 `sweetdream_rp`
  —— 那份根本没被加载 ⇒ 改老包再一键部署, 游戏外观毫无变化。
★ 2026-10-13: 老包 / 覆盖层已删除, `sweetdream_rp_完整版` 升为**唯一真源**
  (不再有"合并产物"和 build 这一步)。改模型/贴图直接改它, 再一键部署 + F3+T。

用法:
  python .workbuddy/_deploy.py            # 试运行(只报告要做什么)
  python .workbuddy/_deploy.py --apply    # 真写
可选 --save "<存档文件夹>" 覆盖默认存档。
"""
import filecmp
import io
import os
import shutil
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DEFAULT_SAVE = ('D:\\PCL 正式版 2.10.0\\.minecraft\\versions\\'
                '1.21.5-Fabric 0.16.10\\saves\\测试包体')


def mirror(src, dst, apply):
    copied = []      # (rel, '新增'|'覆盖')
    deleted = []     # rel
    same = 0
    if not os.path.isdir(dst):
        os.makedirs(dst)
    # 目标里所有相对路径
    dst_rel = set()
    for r, ds, fs in os.walk(dst):
        for f in fs:
            dst_rel.add(os.path.relpath(os.path.join(r, f), dst))
    for r, ds, fs in os.walk(src):
        for f in fs:
            sp = os.path.join(r, f)
            rel = os.path.relpath(sp, src)
            dp = os.path.join(dst, rel)
            dst_rel.discard(rel)
            if not os.path.exists(dp):
                copied.append((rel, '新增'))
            elif os.path.getsize(sp) != os.path.getsize(dp) \
                    or not filecmp.cmp(sp, dp, shallow=False):
                copied.append((rel, '覆盖'))
            else:
                same += 1
                continue
            if apply:
                os.makedirs(os.path.dirname(dp), exist_ok=True)
                shutil.copy2(sp, dp)
    for rel in sorted(dst_rel):
        deleted.append(rel)
        if apply:
            os.remove(os.path.join(dst, rel))
    # 清掉空目录
    if apply:
        for r, ds, fs in os.walk(dst, topdown=False):
            if r != dst and not os.listdir(r):
                os.rmdir(r)
    return copied, deleted, same


# ---- 改动分类: 哪些改动 /reload 吃不到, 必须"退世界重进"或"F3+T" ----
# 数据包 registry(1.21.5 实测: /reload **不会**重新读取 datapack registry) ——
#   必须【退出世界再进】才生效。真实事故 2026-10-07: 新加的 enchantment/arc.json
#   一直只做 /reload ⇒ 附魔没注册 ⇒ bow/arc/give 里的
#   `enchantments={"sweetdream:arc":1}` 每次 reload 都报
#   "Failed to get element sweetdream:arc", 玩家看到的是"天芒给不出来"。
REGISTRY_DIRS = {
    'enchantment', 'enchantment_provider', 'damage_type', 'jukebox_song',
    'painting_variant', 'wolf_variant', 'wolf_sound_variant', 'cat_variant',
    'cat_sound_variant', 'chicken_variant', 'chicken_sound_variant',
    'cow_variant', 'cow_sound_variant', 'frog_variant', 'pig_variant',
    'pig_sound_variant', 'banner_pattern', 'instrument', 'trim_pattern',
    'trim_material', 'dimension_type', 'dimension', 'worldgen', 'dialog',
    'test_environment', 'test_instance',
}


def registry_hits(rels):
    """从相对路径里挑出"改了 datapack registry"的那些(data/<ns>/<registry>/...)."""
    out = []
    for rel in rels:
        parts = rel.replace('\\', '/').split('/')
        if len(parts) >= 3 and parts[0] == 'data' and parts[2] in REGISTRY_DIRS:
            out.append(rel)
    return out


def main():
    apply = '--apply' in sys.argv
    save = DEFAULT_SAVE
    if '--save' in sys.argv:
        save = sys.argv[sys.argv.index('--save') + 1]
    save = save.rstrip('\\/')

    pairs = [
        ('manacore-1.0.0', os.path.join(ROOT, 'manacore-1.0.0'),
         os.path.join(save, 'datapacks', 'manacore-1.0.0')),
        ('sweetdream', os.path.join(ROOT, 'sweetdream'),
         os.path.join(save, 'datapacks', 'sweetdream')),
    ]
    # 资源包镜像到"版本目录\resourcepacks"(版本隔离: 从存档往上两层是版本目录)
    # ★ F20 修: 目标 = 游戏 options.txt 里真正加载的那一份 = sweetdream_rp_完整版
    gamedir = os.path.dirname(os.path.dirname(save))
    rp_name = 'sweetdream_rp_完整版'
    rp_src = os.path.join(ROOT, rp_name)
    if os.path.isdir(rp_src):
        pairs.append((rp_name, rp_src,
                      os.path.join(gamedir, 'resourcepacks', rp_name)))

    print('模式: %s' % ('APPLY' if apply else 'DRY-RUN'))
    print('存档: %s' % save)
    print()
    reg_changed = []     # 改了 datapack registry(必须退世界重进)
    rp_changed = []      # 改了资源包(必须 F3+T)
    for name, src, dst in pairs:
        if not os.path.isdir(src):
            print('[跳过] 源不存在: %s' % src)
            continue
        copied, deleted, same = mirror(src, dst, apply)
        print('== %s ==  相同 %d / 改写 %d / 删除 %d'
              % (name, same, len(copied), len(deleted)))
        for rel, how in copied[:400]:
            print('   %s  %s' % (how, rel))
        if len(copied) > 400:
            print('   … 还有 %d 个' % (len(copied) - 400))
        for rel in deleted[:200]:
            print('   删除  %s' % rel)
        if len(deleted) > 200:
            print('   … 还有 %d 个删除' % (len(deleted) - 200))
        print()
        if name == rp_name:
            if copied or deleted:
                rp_changed.append((name, [r for r, _ in copied][:20]))
        else:
            reg_changed += [(name, rel) for rel in
                            registry_hits([r for r, _ in copied])]
    if not apply:
        print('(试运行; 加 --apply 真正写入)')
    # ---- 部署后必读: 这两类改动 /reload 吃不到 ----
    if reg_changed:
        print()
        print('!' * 74)
        print('⚠️  本次改动含**数据包注册表**(datapack registry) —— /reload 不会重新读取它们:')
        seen = set()
        for name, rel in reg_changed:
            if rel in seen:
                continue
            seen.add(rel)
            print('     [%s]  %s' % (name, rel))
        print('     ⇒ 必须【退出世界再进】才生效。只按 /reload 的话, 游戏里会表现为')
        print('        "Failed to get element <id>"(引用它的函数整个加载失败 = 装备没反应)。')
        print('!' * 74)
    if rp_changed:
        print()
        print('!' * 74)
        print('⚠️  本次改动含**资源包**文件(两份已同步: 源 + 版本隔离目录):')
        for name, rels in rp_changed:
            for rel in rels:
                print('     [%s]  %s' % (name, rel))
        print('     ⇒ 游戏里必须按【F3+T】重载资源包(/reload 不重载资源包)。')
        print('!' * 74)


if __name__ == '__main__':
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8',
                                 errors='replace')
    main()
