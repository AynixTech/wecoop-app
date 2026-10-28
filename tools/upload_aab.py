#!/usr/bin/env python3
"""Upload WeCoop AAB via Google Play Android Publisher API."""

from __future__ import annotations

import argparse
import os
import sys
from pathlib import Path

from google.oauth2 import service_account
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError
from googleapiclient.http import MediaFileUpload

PACKAGE = "org.wecoop.app"
DEFAULT_AAB = (
    "/Users/aynix/Documents/GitHub/wecoop/wecoop-app/"
    "build/app/outputs/bundle/release/app-release.aab"
)
DEFAULT_SA_CANDIDATES = [
    Path.home() / ".wecoop" / "play-publisher.json",
    Path.home() / "Downloads" / "wecoop-app-08edf0467e34.json",
]
SCOPES = ["https://www.googleapis.com/auth/androidpublisher"]


def resolve_sa(explicit: str | None) -> Path:
    if explicit:
        p = Path(explicit).expanduser()
        if not p.is_file():
            raise SystemExit(f"Service account JSON not found: {p}")
        return p
    for p in DEFAULT_SA_CANDIDATES:
        if p.is_file():
            return p
    raise SystemExit(
        "Service account JSON missing. Expected one of:\n  "
        + "\n  ".join(str(p) for p in DEFAULT_SA_CANDIDATES)
    )


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--aab", default=DEFAULT_AAB, help="Path to app-release.aab")
    parser.add_argument(
        "--sa",
        default=None,
        help="Path to play-publisher JSON (default: ~/.wecoop/play-publisher.json)",
    )
    parser.add_argument(
        "--track",
        default="production",
        choices=["internal", "alpha", "beta", "production"],
    )
    parser.add_argument(
        "--status",
        default="completed",
        choices=["draft", "completed", "inProgress", "halted"],
    )
    parser.add_argument(
        "--user-fraction",
        type=float,
        default=None,
        help="Required for production staged rollout with status=inProgress (0–1)",
    )
    parser.add_argument("--name", default=None, help="Release name override")
    parser.add_argument(
        "--notes",
        default="Rilascio via Android Publisher API (WeCoop).",
        help="it-IT release notes",
    )
    args = parser.parse_args()

    aab = Path(args.aab).expanduser()
    if not aab.is_file():
        raise SystemExit(f"AAB not found: {aab}")

    if args.track == "production" and args.status == "completed":
        print("INFO: Play production 100% (default WeCoop store policy)", file=sys.stderr)

    if args.status == "inProgress" and args.user_fraction is None:
        raise SystemExit("--user-fraction required when --status inProgress")

    sa = resolve_sa(args.sa)
    print(f"SA={sa.name} package={PACKAGE} track={args.track} status={args.status}")
    print(f"AAB={aab} ({aab.stat().st_size // (1024 * 1024)}MB)")

    creds = service_account.Credentials.from_service_account_file(
        str(sa), scopes=SCOPES
    )
    service = build(
        "androidpublisher", "v3", credentials=creds, cache_discovery=False
    )

    try:
        edit = service.edits().insert(packageName=PACKAGE, body={}).execute()
        edit_id = edit["id"]
        print(f"edit_id={edit_id}")

        media = MediaFileUpload(
            str(aab), mimetype="application/octet-stream", resumable=True
        )
        bundle = (
            service.edits()
            .bundles()
            .upload(packageName=PACKAGE, editId=edit_id, media_body=media)
            .execute()
        )
        version_code = bundle["versionCode"]
        print(f"uploaded versionCode={version_code}")

        release: dict = {
            "name": args.name or f"WeCoop ({version_code})",
            "versionCodes": [str(version_code)],
            "status": args.status,
            "releaseNotes": [{"language": "it-IT", "text": args.notes}],
        }
        if args.user_fraction is not None:
            release["userFraction"] = args.user_fraction

        service.edits().tracks().update(
            packageName=PACKAGE,
            editId=edit_id,
            track=args.track,
            body={"track": args.track, "releases": [release]},
        ).execute()

        service.edits().commit(packageName=PACKAGE, editId=edit_id).execute()
        print("SUCCESS")
        print(f"package={PACKAGE}")
        print(f"track={args.track}")
        print(f"versionCode={version_code}")
        print(f"status={args.status}")
        print("console=https://play.google.com/console")
        return 0
    except HttpError as e:
        body = e.content.decode("utf-8", errors="replace")[:2000]
        print(f"HTTP_ERROR {e.resp.status}", file=sys.stderr)
        print(body, file=sys.stderr)
        if "already been used" in body:
            print(
                "HINT: bump pubspec.yaml version +BUILD, rebuild AAB, retry",
                file=sys.stderr,
            )
        return 1


if __name__ == "__main__":
    # Avoid leaking env noise; keep cwd irrelevant.
    os.environ.setdefault("PYTHONUNBUFFERED", "1")
    raise SystemExit(main())
