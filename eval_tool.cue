package main

import (
	"tool/file"
	"tool/cli"
	"encoding/json"
	"strings"
    "list"

	"com.github.hytssk.rankeval/eval:eval_request"
)

command: generateEvalRequest: {
	// 入力ファイルの読み込み
	task: read: file.Read & {
		filename: string | *"./assets/example.txt" @tag(filename)
		contents: string
	}
    _array: strings.Split(task.read.contents, "\n")

	// データの変換
	data: eval_request.#Convert & {
		input: {
			queryWords: list.Slice(_array, 0, len(_array)-1)
			fieldName:  "title"
			index:      string | *"test-index" @tag(index)
			k:          >=1 | *1               @tag(k,type=int)
		}
	}

	// 出力
	_outputDir: "./dist"
	task: mkdir: file.Mkdir & {
		path: _outputDir
	}
	task: generateRequestJson: file.Create & {
		_deps:    task.mkdir
		filename: "\(_outputDir)/eval_request.json"
		contents: json.Marshal(data.output)
	}

	elasticsearchHost: *"http://localhost:9200" | string @tag(host)
	task: generateScript: file.Create & {
		_deps:    task.generateRequestJson
		filename: "\(_outputDir)/evaluation.sh"
		contents: #"""
                curl -s -H 'Content-Type: application/json' -X POST \
                    '\#(elasticsearchHost)/\#(data.input.index)/_rank_eval' \
                    --data-binary @\#(task.generateRequestJson.filename)
                """#
	}

	task: display: cli.Print & {
		_deps: task.generateRequestJson
		text:  "Script has been created: \(task.generateScript.filename)"
	}
}
