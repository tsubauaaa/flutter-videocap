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

サービス名を入力する
未承認を許可しないように設定する

```
$ sudo gcloud run deploy --image asia.gcr.io/<プロジェクトID>/openface:latest --platform managed --region asia-northeast1

Allow unauthenticated invocations to [openface] (y/N)?  N
```

#### メモリ上限の設定と更新

```
$ sudo gcloud run services update <サービス名> --memory 2G
```

#### リスト

```
$ sudo gcloud beta run services list --platform managed --region asia-northeast1
```

#### デリート

```
$ sudo gcloud beta run services delete openface --platform managed --region asia-northeast1
```

### Pub/Sub との連携

#### プロジェクトにサービスアカウントトークン作成者権限を付与する

メンバーは service-<プロジェクト番号>@gcp-sa-pubsub.iam.gserviceaccount.com という内部的なサービスアカウントにする

```
$ sudo gcloud projects add-iam-policy-binding <プロジェクトID> --member=serviceAccount:service-<プロジェクト番号>@gcp-sa-pubsub.iam.gserviceaccount.com --role=roles/iam.serviceAccountTokenCreator
```

#### Cloud Run を Pub/Sub 連携で実行するサービスアカウントを作成する

```
sudo gcloud iam service-accounts create cloud-run-pubsub-invoker --display-name "Cloud Run Pub/Sub Invoker"
```

#### cloud-run-pubsub-invoker サービスアカウントに Cloud Run サービスの実行権限を付与する

```
sudo gcloud run services add-iam-policy-binding <Cloud Runサービス名> --member=serviceAccount:cloud-run-pubsub-invoker@<プロジェクトID>.iam.gserviceaccount.com --role=roles/run.invoker
```

#### Pub/Sub トピックの作成

```
$ sudo gcloud pubsub topics create <トピック名>
```

#### Pub/Sub トピックを購読して Cloud Run を実行する Pub/Sub サブスクリプションを作成する

```
$ sudo gcloud pubsub subscriptions create <サブスクリプション名> --topic <トピック名> --push-endpoint=<Cloud RunサービスURL> --push-auth-service-account=cloud-run-pubsub-invoker@<プロジェクトID>.iam.gserviceaccount.com --message-retention-duration=10m --ack-deadline=600
```

#### Pub/Sub トピックにパブリッシュして動作確認

```
$ sudo gcloud pubsub topics publish <トピック名> --message "Runner"
```
