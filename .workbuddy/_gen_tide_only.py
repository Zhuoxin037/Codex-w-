# -*- coding: utf-8 -*-
"""
只重生成「暗潮」那两张贴图 —— 不碰枯木贴图/模型。
【为什么单独写一个】_gen_wood_tide.py 的 main() 会连枯木一起重刷; 只想改暗潮时
用本脚本按函数调用, 减少"顺手覆盖了不该动的东西"的风险。幂等。
"""
import importlib.util
import pathlib

HERE = pathlib.Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('gt', HERE / '_gen_wood_tide.py')
gt = importlib.util.module_from_spec(spec)
spec.loader.exec_module(gt)          # 顶层只有常量/函数定义, main() 有 __main__ 守卫

(gt.TEX / 'tide_deep.png').write_bytes(gt.gen_tide_deep())
(gt.TEX / 'tide_ripple.png').write_bytes(gt.gen_tide_ripple())
for f in ('tide_deep.png', 'tide_ripple.png'):
    print('  %8d  %s' % ((gt.TEX / f).stat().st_size, f))
