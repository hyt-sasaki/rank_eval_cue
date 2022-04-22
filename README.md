# rank eval request generator
https://www.elastic.co/guide/en/elasticsearch/reference/current/search-rank-eval.html  
のリクエストボディを生成

```bash
# 必要に応じてcueをインストール: 
# brew install cue

# indexにbulk insertするためのリクエストボディを生成
$ cue export bulk_insert/bulk.cue -t index="hoge-index" -t field="title"| jq -c '.[]'
```

```json
{"index":{"_index":"hoge-index","_id":"hoge"}}
{"title":"hoge"}
{"index":{"_index":"hoge-index","_id":"fuga"}}
{"title":"fuga"}
```

```bash
# indexとfieldを指定
# match queryに渡されるクエリは rank_eval.cue の _queries配列で定義している
$ cue export -t index="hoge-index" -t field="title"
```

```json
{
    "requests": [
        {
            "id": "hoge",
            "request": {
                "query": {
                    "match": {
                        "title": {
                            "query": "hoge"
                        }
                    }
                }
            },
            "ratings": [
                {
                    "_id": "hoge",
                    "_index": "hoge-index",
                    "rating": 1
                }
            ]
        },
        {
            "id": "fuga",
            "request": {
                "query": {
                    "match": {
                        "title": {
                            "query": "fuga"
                        }
                    }
                }
            },
            "ratings": [
                {
                    "_id": "fuga",
                    "_index": "hoge-index",
                    "rating": 1
                }
            ]
        }
    ],
    "metric": {
        "recall": {
            "k": 5,
            "rerevant_rating_threashold": 1
        }
    }
}

```
