import os
import subprocess
import sys
from concurrent.futures import TimeoutError

from google.cloud import pubsub_v1

project_id = "flutter-videocap"
subscription_id = "videocap"
timeout = 300.0

os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = "./flutter-videocap-1252d31ef4eb.json"

subscriber = pubsub_v1.SubscriberClient()
subscription_path = subscriber.subscription_path(project_id, subscription_id)


def callback(message):
    print(f"Recieved {message}.")
    cp = subprocess.run(["/home/ubuntu/OpenFace/build/bin/FeatureExtraction", "-f", "/home/ubuntu/ts-hirota-face.mp4"])
    if cp.returncode != 0:
        print("FeatureExtraction failed.", file=sys.stderr)
        sys.exit()
    message.ack()

streaming_pull_future = subscriber.subscribe(subscription_path, callback=callback)
print(f"Listening for messages on {subscription_path}..\n")

with subscriber:
    try:
        streaming_pull_future.result(timeout=timeout)
    except TimeoutError:
        streaming_pull_future.cancel()
        streaming_pull_future.result()
