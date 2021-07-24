import os
import shutil
import subprocess
import sys
import base64
from flask import Flask, request
from google.cloud import storage
import tempfile
import json
app = Flask(__name__)

PROCESSED_DIR = "/app/processed"
client = storage.Client()


def upload_csv(processed_csv_file_name, file_name, bucket_name):
    blob = client.bucket(bucket_name).blob("csvs/" + file_name)
    blob.upload_from_filename(PROCESSED_DIR + "/" + processed_csv_file_name)
    print(f"OpenFace csv uploaded to: gs://{bucket_name}/csvs/{file_name}")


def download_video(file_name, bucket_name):
    blob = client.bucket(bucket_name).get_blob("videos/" + file_name)
    _, temp_local_filename = tempfile.mkstemp()
    blob.download_to_filename(temp_local_filename)
    print(f"Video {file_name} was downloaded to {temp_local_filename}.")
    return temp_local_filename


@app.route("/openface", methods=["POST"])
def openface():
    envelope = request.get_json()
    print(f'recieved request: {envelope}')

    # if remove_dir exsists then remove
    if os.path.isdir(PROCESSED_DIR):
        shutil.rmtree(PROCESSED_DIR)
        print(f"removed {PROCESSED_DIR}")

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
        try:
            data = json.loads(
                base64.b64decode(
                    pubsub_message["data"]).decode())
            print(f"data: {data}")
        except Exception as e:
            msg = (
                "Invalid Pub/Sub message: "
                "data property is not valid base64 encoded JSON"
            )
            print(f"error: {e}")
            return f"Bad Request: {msg}", 400

        # Validate the message is a Cloud Storage event.
        if not data["name"] or not data["bucket"]:
            msg = (
                "Invalid Cloud Storage notification: "
                "expected name and bucket properties"
            )
            print(f"error: {msg}")
            return f"Bad Request: {msg}", 400

        # Validate the message is a videocap event.
        if data["name"][:6] != "videos":
            msg = (
                "Invalid Cloud Storage file: "
                "expected file properties"
            )
            print(f"error: {msg}")
            return f"Bad Request: {msg}", 400

        try:
            file_name = data["name"].split("/")[-1]
            bucket_name = data["bucket"]
            print(f"file name is {file_name}")

            video_saved_path = download_video(file_name, bucket_name)

            cp = subprocess.run(
                ["/app/OpenFace/build/bin/FeatureExtraction", "-f", video_saved_path])
            if cp.returncode != 0:
                print("FeatureExtraction failed.", file=sys.stderr)
                return ("", 500)

            print("FeatureExtraction done.")

            upload_csv(video_saved_path.split("/")
                       [-1] + ".csv", file_name[: -3] + "csv", bucket_name)

            os.remove(video_saved_path)

            return ("", 204)

        except Exception as e:
            print(f"error: {e}")
            return ("", 500)


if __name__ == "__main__":
    PORT = int(os.getenv("PORT")) if os.getenv("PORT") else 8080
    app.run(host="127.0.0.1", port=PORT, debug=True)
