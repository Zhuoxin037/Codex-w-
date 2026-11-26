"""Stage, package and install the verified Forest boss revision."""

import importlib.util
from io import BytesIO
import json
import os
from pathlib import Path
import sys
from zipfile import ZIP_DEFLATED, ZipFile

from forest_revision_release import unpack
from forest_stag import stage
from forest_runtime_fixes import stage as runtime_fixes
from stag_visual import build
from world import ROOT

WORK = ROOT/".workbuddy/rogue_stag_20261124"
NATIVE = WORK/"native"
WORLD = NATIVE/"world"
RELEASES = ROOT/"outputs/01a1f2ce-e657-7782-ac13-28be248b8f29"
BASE = RELEASES/"坠梦_密林新怪与事件版.zip"
OUTPUT = RELEASES/"坠梦_密林层主朽冠鹿版.zip"
RP = ROOT/"fallendream_rp_完整版"


def stage_world():
    WORK.mkdir(parents=True,exist_ok=True)
    if not (WORLD/"level.dat").is_file():
        unpack(BASE,WORLD)
    report = stage(WORLD)
    runtime_fixes(WORLD)
    with ZipFile(BASE) as archive:
        with (WORK/"base_resources.zip").open("wb") as stream:
            stream.write(archive.read("坠梦/resources.zip"))
    _,new_art,_ = build()
    temporary = WORK/"resources.zip"
    with ZipFile(WORK/"base_resources.zip") as source, ZipFile(temporary,"w",ZIP_DEFLATED,compresslevel=4) as target:
        for item in source.infolist():
            if item.filename not in new_art:
                target.writestr(item,source.read(item))
        for name, raw in new_art.items():
            target.writestr(name,raw)
    with ZipFile(temporary) as archive:
        assert archive.testzip() is None
        assert all(archive.read(k)==v for k,v in new_art.items())
    os.replace(temporary,WORLD/"resources.zip")
    (WORK/"export.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf-8")
    print("Export and stage complete",flush=True)


def release_tool():
    helper = ROOT/".workbuddy/rogue_mob_floor_20261124/publish.py"
    spec = importlib.util.spec_from_file_location("forest_release",helper)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    module.WORK, module.CHECKED, module.ZIP, module.OUTPUT = WORK, WORLD, BASE, OUTPUT
    return module


def release(action):
    helper=release_tool()
    delta=helper.changes()
    assert any("/stag/visual/" in name for name in delta)
    with ZipFile(BASE) as old:
        packed_before=old.read("坠梦/resources.zip")
    packed_after=(WORLD/"resources.zip").read_bytes()
    if action=="publish":
        delta["resources.zip"]=(packed_before,packed_after)
        helper.publish(delta)
    else:
        installed=(helper.LIVE/"resources.zip").read_bytes()
        if installed not in (packed_before,packed_after):
            # The launcher may have repacked the same assets. Check actual
            # archive contents before accepting it as an installation base.
            with ZipFile(BytesIO(installed)) as live, ZipFile(BytesIO(packed_before)) as base:
                if set(live.namelist())!=set(base.namelist()) or any(live.read(k)!=base.read(k) for k in live.namelist()):
                    raise RuntimeError("The installed resources contain different assets")
            packed_before=installed
        delta["resources.zip"]=(packed_before,packed_after)
        helper.install(delta)


def record_assets():
    _, assets, _ = build()
    for name, raw in assets.items():
        path = RP/name
        if path.exists() and path.read_bytes()!=raw:
            raise RuntimeError(f"Separate resource change: {path}")
    for name, raw in assets.items():
        path = RP/name
        path.parent.mkdir(parents=True,exist_ok=True)
        if not path.exists():
            path.write_bytes(raw)


if __name__=="__main__":
    action=sys.argv[1]
    if action=="stage":
        stage_world()
    elif action=="assets":
        record_assets()
    else:
        release(action)
