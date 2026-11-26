"""Stage and deploy the verified room-flow and combat changes."""

import argparse
from pathlib import Path

import forest_balance
import forest_exploration
import forest_flow
import forest_revision_release as release

release.BASE = release.ZIP
release.ZIP = release.RELEASES / "坠梦_密林战斗与通路修正版.zip"
release.WORK = release.ROOT / ".workbuddy/rogue_forest_flow_20261124"


def stage(folder):
    release.unpack(release.BASE, folder)
    forest_flow.stage(folder)
    forest_balance.stage(folder)
    forest_exploration.stage(folder)


if __name__ == "__main__":
    args = argparse.ArgumentParser()
    args.add_argument("action", choices=("stage","publish","install"))
    args.add_argument("folder",type=Path)
    options=args.parse_args()
    stage(options.folder) if options.action=="stage" else getattr(release,options.action)(options.folder)
