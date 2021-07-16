import os
import shutil
import subprocess
import sys

from flask import Flask, request

app = Flask(__name__)

PROCESSED_DIR = "/app/processed"


@app.route("/openface", methods=["POST"])
def index():
    envelope = request.get_json()
    print(f'Recieved {envelope["message"]}.')

    # if remove_dir exsists then remove
    if os.path.isdir(PROCESSED_DIR):
        shutil.rmtree(PROCESSED_DIR)
        print(f"removed {PROCESSED_DIR}")

    cp = subprocess.run(["/app/OpenFace/build/bin/FeatureExtraction", "-f", "/app/face.mp4"])
    if cp.returncode != 0:
        print("FeatureExtraction failed.", file=sys.stderr)


if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))
