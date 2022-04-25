# rank eval request generator
https://www.elastic.co/guide/en/elasticsearch/reference/current/search-rank-eval.html  
のリクエストボディを生成

## データの準備
```bash
# 必要に応じてcueをインストール: 
# brew install cue

# indexにbulk insertするためのリクエスト用shell scriptを作成
$ cue -t filename="./assets/example.txt" -t index="test-index" generateBulkRequest
```

リクエスト(`bulk_request.ndjson`)
```json
{"index":{"_index":"hoge-index","_id":"hoge"}}
{"title":"hoge"}
{"index":{"_index":"hoge-index","_id":"fuga"}}
{"title":"fuga"}
```
リクエスト用スクリプト(`bulk_request.ndjson`)
```basenameh
curl -s -w %{http_code} -H 'Content-Type: application/x-ndjson' \
    -XPOST http://localhost:9200/_bulk \
    --data-binary @./dist/bulk_request.ndjson \
    -o /dev/null
```


## 評価用のshellscriptの生成
```bash
$ cue -t filename="./assets/example.txt" -t index="test-index" -t k=1 -t host="http://localhost:9200"
 generateEvalRequest
```

リクエストボディ (`dist/evall_request.json`)
```json
{"requests":[{"id":"コロンビア","request":{"query":{"match":{"title":"コロンビア"}}},"ratings":[{"_index":"test-ind
ex","_id":"コロンビア","rating":1}]},{"id":"ケニア","request":{"query":{"match":{"title":"ケニア"}}},"ratings":[{"_
index":"test-index","_id":"ケニア","rating":1}]},{"id":"エチオピア","request":{"query":{"match":{"title":"エチオピ
ア"}}},"ratings":[{"_index":"test-index","_id":"エチオピア","rating":1}]},{"id":"ブラジル","request":{"query":{"mat
ch":{"title":"ブラジル"}}},"ratings":[{"_index":"test-index","_id":"ブラジル","rating":1}]}],"metric":{"recall":{"k
":1,"relevant_rating_threshold":1}}}
```

リクエスト用スクリプト(`evaluation.sh`)
```bash
curl -s -H 'Content-Type: application/json' -X POST \
    'http://localhost:9200/test-index/_rank_eval' \
    --data-binary @./dist/eval_request.json
```
