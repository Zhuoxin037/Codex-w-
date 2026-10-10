# -*- coding: utf-8 -*-
"""渲染验证转换出来的 Java 物品模型（用 mc-model-preview 的软渲染器）
用法: python .workbuddy/_render_item.py <model.json> <rp_root> <ns> [out_prefix]
输出: 若干视角的 PNG
"""
import io
import os
import sys

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
sys.path.insert(0, r'C:\Users\qq303\.workbuddy\skills\mc-model-preview\scripts')
import render3d as R  # noqa


def main():
    if len(sys.argv) < 4:
        print(__doc__)
        return
    model_path, rp_root, ns = sys.argv[1], sys.argv[2], sys.argv[3]
    out = sys.argv[4] if len(sys.argv) > 4 else 'preview'

    repo = R.Repo(rp_root)
    model = R.load_model(model_path)
    faces = R.bake(model, repo, ns_hint=ns)
    print('模型: %s' % os.path.basename(model_path))
    print('可渲染面数: %d' % len(faces))
    if not faces:
        print('!! 一个面都没有 —— 贴图或 UV 有问题')
        return

    VIEWS = [
        ('34view', 30.0, 12.0),
        ('front', 0.0, 0.0),
        ('side', 90.0, 0.0),
        ('top', 0.0, 78.0),
        ('iso', 210.0, 20.0),
    ]
    W = H = 640
    fit = R.fit_all([[(faces, 1.0)]], W, H, yaw=VIEWS[0][1], pitch=VIEWS[0][2])
    for name, yaw, pitch in VIEWS:
        # ★ render 返回 (rows, fit) 二元组 —— 别当单一返回值用
        rows, _ = R.render([(faces, 1.0)], W, H, yaw=yaw, pitch=pitch, fit=fit)
        p = '%s_%s.png' % (out, name)
        with open(p, 'wb') as f:
            f.write(R.encode_png(W, H, rows))
        print('  -> %s' % p)


if __name__ == '__main__':
    main()
