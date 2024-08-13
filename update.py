import hashlib
import json
import subprocess
import urllib.request

proc = subprocess.run(
    ["gh", "release", "--repo=DeCarabas/fwd", "view", "--json=assets"],
    check=True,
    capture_output=True,
    encoding="utf-8",
)
response = json.loads(proc.stdout)
for asset in response["assets"]:
    url = asset["url"]
    with urllib.request.urlopen(url) as response:
        digest = hashlib.file_digest(response, "sha256")
        print(f'url "{url}"')
        print(f'sha256 "{digest.hexdigest()}"')
        print()
