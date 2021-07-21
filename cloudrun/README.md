## Pub/Sub -> Cloud Run 利用手順

### Google Cloud 設定

```
$ sudo gcloud auth login
$ sudo sudo gcloud config set project <プロジェクトID>
$ sudo gcloud config list
$ sudo gcloud auth configure-docker
```

### Cloud Run ラン

#### ビルド

```
$ sudo docker build -t asia.gcr.io/<プロジェクトID>/openface .
```

#### プッシュ

```
$ sudo docker push asia.gcr.io/<プロジェクトID>/openface:latest
```

#### ビルド&プッシュ

```
$ sudo gcloud builds submit --tag asia.gcr.io/<プロジェクトID>/openface:latest .
```

#### デプロイ

```
$ sudo gcloud run deploy --image asia.gcr.io/<プロジェクトID>/openface:latest --platform managed --region asia-northeast1
```

#### リスト

```
$ sudo gcloud beta run services list --platform managed --region asia-northeast1
```

#### デリート

```
$ sudo gcloud beta run services delete openface --platform managed --region asia-northeast1
```

### Pub/Sub との統合
