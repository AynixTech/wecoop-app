#!/usr/bin/env python3
"""Submit the latest WeCoop iOS build to App Store review (production)."""

from __future__ import annotations

import argparse
import json
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path

import jwt

APP_ID = "6766248437"
KEY_ID = "P44NUU72Z4"
ISSUER_ID = "146dbad1-a9b7-47cd-91fb-f8af2ff38ec9"
P8_CANDIDATES = [
    Path.home() / ".appstoreconnect/private_keys/AuthKey_P44NUU72Z4.p8",
    Path.home() / "Downloads/AuthKey_P44NUU72Z4.p8",
]
API = "https://api.appstoreconnect.apple.com"
IN_FLIGHT = {
    "WAITING_FOR_REVIEW",
    "IN_REVIEW",
    "PENDING_DEVELOPER_RELEASE",
    "PENDING_APPLE_RELEASE",
    "PROCESSING_FOR_APP_STORE",
}


def resolve_p8() -> Path:
    for p in P8_CANDIDATES:
        if p.is_file():
            return p
    raise SystemExit("AuthKey .p8 missing. Expected:\n  " + "\n  ".join(str(p) for p in P8_CANDIDATES))


def token() -> str:
    now = int(time.time())
    return jwt.encode(
        {"iss": ISSUER_ID, "iat": now, "exp": now + 19 * 60, "aud": "appstoreconnect-v1"},
        resolve_p8().read_text(),
        algorithm="ES256",
        headers={"kid": KEY_ID, "typ": "JWT"},
    )


def request(method: str, path: str, body: dict | None = None, retries: int = 4):
    data = None if body is None else json.dumps(body).encode()
    last_err: Exception | None = None
    for attempt in range(1, retries + 1):
        req = urllib.request.Request(
            API + path,
            data=data,
            method=method,
            headers={
                "Authorization": f"Bearer {token()}",
                "Content-Type": "application/json",
                "Accept": "application/json",
            },
        )
        try:
            with urllib.request.urlopen(req, timeout=90) as r:
                raw = r.read()
                return json.loads(raw) if raw else {}
        except urllib.error.HTTPError as e:
            err = e.read().decode("utf-8", errors="replace")[:4000]
            raise SystemExit(f"HTTP {e.code} {method} {path}\n{err}") from e
        except Exception as e:  # noqa: BLE001 — retry flaky ASC timeouts
            last_err = e
            print(f"WARN {method} {path} attempt {attempt}/{retries}: {e}", file=sys.stderr)
            time.sleep(min(10 * attempt, 30))
    raise SystemExit(f"Failed {method} {path} after {retries} retries: {last_err}")


def latest_build(version_code: str | None) -> dict:
    payload = request(
        "GET",
        f"/v1/builds?filter[app]={APP_ID}&limit=15&sort=-uploadedDate",
    )
    builds = payload.get("data") or []
    if version_code:
        for b in builds:
            if str(b.get("attributes", {}).get("version")) == str(version_code):
                return b
        raise SystemExit(f"Build {version_code} not found in App Store Connect yet")
    if not builds:
        raise SystemExit("No iOS builds found")
    return builds[0]


def wait_valid(build: dict, timeout_s: int = 900) -> dict:
    bid = build["id"]
    deadline = time.time() + timeout_s
    while time.time() < deadline:
        state = (build.get("attributes") or {}).get("processingState")
        print(f"build={bid} processingState={state}")
        if state == "VALID":
            return build
        if state in {"FAILED", "INVALID"}:
            raise SystemExit(f"Build {bid} is {state}")
        time.sleep(20)
        build = request("GET", f"/v1/builds/{bid}")["data"]
    raise SystemExit(f"Timed out waiting for build {bid} VALID")


def latest_ios_version() -> dict | None:
    payload = request(
        "GET",
        f"/v1/apps/{APP_ID}/appStoreVersions?limit=5&filter[platform]=IOS",
    )
    data = payload.get("data") or []
    return data[0] if data else None


def create_version(version_string: str) -> dict:
    return request(
        "POST",
        "/v1/appStoreVersions",
        {
            "data": {
                "type": "appStoreVersions",
                "attributes": {
                    "platform": "IOS",
                    "versionString": version_string,
                    "releaseType": "AFTER_APPROVAL",
                },
                "relationships": {
                    "app": {"data": {"type": "apps", "id": APP_ID}},
                },
            }
        },
    )["data"]


def attach_build(version_id: str, build_id: str) -> None:
    request(
        "PATCH",
        f"/v1/appStoreVersions/{version_id}/relationships/build",
        {"data": {"type": "builds", "id": build_id}},
    )


def set_whats_new(version_id: str, notes: str) -> None:
    locs = request(
        "GET",
        f"/v1/appStoreVersions/{version_id}/appStoreVersionLocalizations",
    ).get("data") or []
    if not locs:
        print("WARN: no App Store localizations to patch what's new", file=sys.stderr)
        return
    preferred = [l for l in locs if l.get("attributes", {}).get("locale") in {"it", "it-IT"}]
    targets = preferred or locs[:1]
    for loc in targets:
        request(
            "PATCH",
            f"/v1/appStoreVersionLocalizations/{loc['id']}",
            {
                "data": {
                    "type": "appStoreVersionLocalizations",
                    "id": loc["id"],
                    "attributes": {"whatsNew": notes},
                }
            },
        )


def submit(version_id: str) -> dict:
    # Apple deprecated POST /v1/appStoreVersionSubmissions (CREATE forbidden).
    # Use reviewSubmissions + reviewSubmissionItems instead.
    existing = request(
        "GET",
        f"/v1/apps/{APP_ID}/reviewSubmissions?filter[platform]=IOS&filter[state]=READY_FOR_REVIEW,UNRESOLVED_ISSUES,WAITING_FOR_REVIEW",
    ).get("data") or []
    if existing:
        submission = existing[0]
        print(f"reusing reviewSubmission={submission['id']} state={submission.get('attributes', {}).get('state')}")
    else:
        submission = request(
            "POST",
            "/v1/reviewSubmissions",
            {
                "data": {
                    "type": "reviewSubmissions",
                    "attributes": {"platform": "IOS"},
                    "relationships": {
                        "app": {"data": {"type": "apps", "id": APP_ID}},
                    },
                }
            },
        )["data"]
        print(f"created reviewSubmission={submission['id']}")

    sid = submission["id"]
    items = request(
        "GET",
        f"/v1/reviewSubmissions/{sid}/items",
    ).get("data") or []
    has_version = any(
        (it.get("relationships") or {}).get("appStoreVersion", {}).get("data", {}).get("id") == version_id
        for it in items
    )
    if not has_version:
        request(
            "POST",
            "/v1/reviewSubmissionItems",
            {
                "data": {
                    "type": "reviewSubmissionItems",
                    "relationships": {
                        "reviewSubmission": {
                            "data": {"type": "reviewSubmissions", "id": sid}
                        },
                        "appStoreVersion": {
                            "data": {"type": "appStoreVersions", "id": version_id}
                        },
                    },
                }
            },
        )

    state = (submission.get("attributes") or {}).get("state")
    if state in {"WAITING_FOR_REVIEW", "IN_REVIEW"}:
        return submission

    return request(
        "PATCH",
        f"/v1/reviewSubmissions/{sid}",
        {
            "data": {
                "type": "reviewSubmissions",
                "id": sid,
                "attributes": {"submitted": True},
            }
        },
    )


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--version", required=True, help="Marketing version, e.g. 1.6.18")
    parser.add_argument("--build", default=None, help="iOS build number, e.g. 54 (default: latest)")
    parser.add_argument(
        "--notes",
        default="Correzioni e miglioramenti di stabilità.",
        help="What's New (it-IT)",
    )
    args = parser.parse_args()

    build = wait_valid(latest_build(args.build))
    build_n = build["attributes"]["version"]
    current = latest_ios_version()
    state = (current or {}).get("attributes", {}).get("appStoreState")
    current_ver = (current or {}).get("attributes", {}).get("versionString")

    if current and state in IN_FLIGHT:
        print(
            f"ALREADY_IN_FLIGHT version={current_ver} state={state} "
            f"id={current['id']} build={build_n}"
        )
        return 0

    if current and current_ver == args.version and state in {
        "PREPARE_FOR_SUBMISSION",
        "DEVELOPER_REJECTED",
        "REJECTED",
        "METADATA_REJECTED",
    }:
        version = current
    elif current and current_ver == args.version and state == "READY_FOR_REVIEW":
        version = current
    else:
        version = create_version(args.version)

    vid = version["id"]
    attach_build(vid, build["id"])
    set_whats_new(vid, args.notes)
    submit(vid)
    print("SUCCESS")
    print(f"app={APP_ID}")
    print(f"version={args.version}")
    print(f"build={build_n}")
    print(f"appStoreVersion={vid}")
    print("state=WAITING_FOR_REVIEW (expected after submit)")
    print("releaseType=AFTER_APPROVAL")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
