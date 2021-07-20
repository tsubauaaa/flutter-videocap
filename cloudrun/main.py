import os
import shutil
import subprocess
import sys

from flask import Flask, request
from google.cloud import storage

app = Flask(__name__)

WORK_DIR = "/app/"
PROCESSED_DIR = "/app/processed"


def download_video(envelope):
    client = storage.Client()
    bucket = client.bucket("videos")
    blob = bucket.blob(envelope["message"])
    with open(WORK_DIR + envelope, "wb") as video:
        blob.download_to_file(video)


@app.route("/openface", methods=["POST"])
def main():
    envelope = request.get_json()
    print(f'Recieved {envelope["message"]}.')

    # if remove_dir exsists then remove
    if os.path.isdir(PROCESSED_DIR):
        shutil.rmtree(PROCESSED_DIR)
        print(f"removed {PROCESSED_DIR}")

    download_video(envelope)

    cp = subprocess.run(["/app/OpenFace/build/bin/FeatureExtraction", "-f", WORK_DIR + envelope])
    if cp.returncode != 0:
        print("FeatureExtraction failed.", file=sys.stderr)


if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))

