# -*- coding: utf-8 -*-
"""把拆分好的 markdown 分块插入 editor_sdk 的 docx。
每块插入前先插一个空段落，避免插入点落在上一个表格的单元格内。"""
import json, subprocess, sys

PY = r"C:/Users/qq303/.workbuddy/binaries/python/versions/3.13.12/python.exe"
ED = r"C:/Users/qq303/AppData/Local/Programs/WorkBuddy/resources/app.asar.unpacked/resources/plugins/workbuddy-builtin/skills/workbuddy-local-office-edit/edsdk.py"
FID = sys.argv[1]
N = int(sys.argv[2]) if len(sys.argv) > 2 else 7
TMP = r"D:/数据包/.workbuddy/_tmp_args.json"


def call(tool, args):
    open(TMP, "w", encoding="utf-8").write(json.dumps(args, ensure_ascii=False))
    r = subprocess.run([PY, ED, "call", tool, "--json-file", TMP],
                       capture_output=True, text=True, encoding="utf-8")
    s = r.stdout.strip()
    try:
        j = json.loads(s)
    except Exception:
        raise RuntimeError(f"{tool} bad resp: {s[:300]}")
    if "error" in j or j.get("ok") is False:
        raise RuntimeError(f"{tool} failed: {s[:300]}")
    return j


for i in range(N):
    md = open(f"D:/数据包/.workbuddy/_eq_part{i}.md", encoding="utf-8").read()
    pos = call("doc_get_last_operable_pos", {"file_id": FID})["position"]
    j = call("doc_insert_paragraph_with_text",
             {"file_id": FID, "idx": int(pos), "text": "", "type": 0})
    nxt = j.get("next_index") or j.get("last_edit_index") or int(pos)
    j2 = call("doc_insert_markdown", {"file_id": FID, "idx": int(nxt), "markdown": md})
    print(f"part {i} ok  pos={pos} -> para_idx={nxt} -> md_end={j2.get('last_edit_index')} ({len(md)} chars)")

print("DONE")
