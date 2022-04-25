package main

import (
	"tool/exec"
	"tool/file"
	"tool/cli"
	"encoding/json"
	"strings"

	"com.github.hytssk.rankeval/bulk:bulk_request"
)

command: generateBulkRequest: {
	// 入力ファイルの読み込み
	_sampling: bool | *false                    @tag(sampling,type=bool)
	_filename: string | *"./assets/example.txt" @tag(filename)

	_array: [...string]
	_n:                    uint | *1000 @tag(N,type=int) // サンプリングの場合にのみ使用
	_dist:                 "./dist"
	_sampledArrayFileName: string | *"\(_dist)/sampledArray.txt"
	if _sampling {
		task: shuffle: exec.Run & {
			cmd: ["shuf", "-n", "\(_n)", _filename]
			stdout: string
		}
		_array: strings.Split(task.shuffle.stdout, "\n")

		task: generateSampledArrayFile: file.Create & {
			filename: _sampledArrayFileName
			contents: task.shuffle.stdout
		}
	}
	if !_sampling {
		task: read: file.Read & {
			filename: _filename
			contents: string
		}
		_array: strings.Split(task.read.contents, "\n")
	}

	// データの変換
	data: bulk_request.#Convert & {
		input: {
			array:     _array
			index:     string | *"test-index" @tag(index)
			fieldName: "title"
		}
	}
	task: out: exec.Run & {
		cmd: ["jq", "-c", ".[]"]
		stdin:  json.Marshal(data.output)
		stdout: string
	}

	// 出力
	task: mkdir: file.Mkdir & {
		path: _dist
	}
	task: generateRequestJson: file.Create & {
		filename: "\(task.mkdir.path)/bulk_request.ndjson"
		contents: task.out.stdout
	}

	elasticsearchHost: *"http://localhost:9200" | string @tag(host)
	task: generateScript: file.Create & {
		filename: "\(task.mkdir.path)/bulk_insert.sh"
		contents: #"""
			curl -s -w %{http_code} -H 'Content-Type: application/x-ndjson' \
			    -XPOST \#(elasticsearchHost)/_bulk \
			    --data-binary @\#(task.generateRequestJson.filename) \
			    -o /dev/null
			"""#
	}

	task: display: cli.Print & {
		_deps: task.generateScript
		text:  "Script has been created: \(task.generateScript.filename)"
	}

}
