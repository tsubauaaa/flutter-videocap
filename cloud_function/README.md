## Storage -> Cloud Function 利用手順

### Google Cloud 設定
```
$  gcloud auth login
$  gcloud config set project <プロジェクトID>
$  gcloud config list
```

### Cloud Function デプロイ
更新時もこのコマンドでOK  
```
$ gcloud functions deploy analyze_action_unit --runtime python39 --trigger-resource <バケット名> --region asia-northeast1 --trigger-event google.storage.object.finalize
```