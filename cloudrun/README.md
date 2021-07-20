## Pub/Sub -> Cloud Run 利用手順

### Cloud Run ラン

#### ビルド

```
$ docker build -t asia.gcr.io/<プロジェクトID>/openface .
```

#### プッシュ

```
$ docker push asia.gcr.io/<プロジェクトID>/openface:latest
```

#### ビルド&プッシュ

```
$ gcloud builds submit --tag asia.gcr.io/<プロジェクトID>/openface:latest .
```

#### デプロイ

```
gcloud run deploy --image asia.gcr.io/<プロジェクトID>/openface:latest --platform managed --region asia-northeast1
```

#### リスト

```
$ gcloud beta run services list --platform managed --region asia-northeast1
```

#### デリート

```
$ gcloud beta run services delete openface --platform managed --region asia-northeast1
```

### Pub/Sub との統合

