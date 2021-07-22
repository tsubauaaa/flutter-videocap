import os
import shutil
import subprocess
import sys
import base64
from flask import Flask, request
from google.cloud import storage
import tempfile

app = Flask(__name__)

BUCKET_NAME = "flutter-videocap.appspot.com"
PROCESSED_DIR = "/app/processed"
client = storage.Client()


def download_video(file_name):
    blob = client.bucket(BUCKET_NAME).get_blob("videos/" + file_name)
    _, temp_local_filename = tempfile.mkstemp()
    blob.download_to_filename(temp_local_filename)
    print(f"Image {file_name} was downloaded to {temp_local_filename}.")
    return temp_local_filename


@app.route("/openface", methods=["POST"])
def openface():
    envelope = request.get_json()
    print(f'recieved request: {envelope}')

    if not envelope:
        msg = "no Pub/Sub message received"
        print(f"error: {msg}")
        return f"Bad Request: {msg}", 400

    if not isinstance(envelope, dict) or "message" not in envelope:
        msg = "invalid Pub/Sub message format"
        print(f"error: {msg}")
        return f"Bad Request: {msg}", 400

    pubsub_message = envelope["message"]

    if isinstance(pubsub_message, dict) and "data" in pubsub_message:
        file_name = base64.b64decode(
            pubsub_message["data"]).decode("utf-8").strip()
    else:
        msg = "invalid Pub/Sub message format"
        print(f"error: {msg}")
        return f"Bad Request: {msg}", 400

    print(f"file name is {file_name}")

    # if remove_dir exsists then remove
    if os.path.isdir(PROCESSED_DIR):
        shutil.rmtree(PROCESSED_DIR)
        print(f"removed {PROCESSED_DIR}")

    video_saved_path = download_video(file_name)

    cp = subprocess.run(
        ["/app/OpenFace/build/bin/FeatureExtraction", "-f", video_saved_path])
    if cp.returncode != 0:
        print("FeatureExtraction failed.", file=sys.stderr)
        # TODO: return 500

    print("FeatureExtraction done.")

    os.remove(video_saved_path)

    return ("", 204)


if __name__ == "__main__":
    PORT = int(os.getenv("PORT")) if os.getenv("PORT") else 8080
    app.run(host="127.0.0.1", port=PORT, debug=True)
