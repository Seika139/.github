# 変更確認: 自動修正コミットでの CI トリガー有効化

## 概要

`.github/workflows/lint-markdown.yml` を修正し、自動修正コミットのプッシュ時に `PUSH_AND_RUN_WORKFLOW_TOKEN` (PAT) を使用するように変更しました。これにより、PAT が設定されている場合、自動修正コミットが後続の CI ワークフローをトリガーするようになります。

## 変更されたファイル

- [.github/workflows/lint-markdown.yml](../../../.github/workflows/lint-markdown.yml)

## 検証結果

### コード変更の確認

以下の通り、`github_token` の設定が変更されていることを確認しました。

```yaml
        uses: ad-m/github-push-action@v0.8.0
        with:
          github_token: ${{ secrets.PUSH_AND_RUN_WORKFLOW_TOKEN || secrets.GITHUB_TOKEN }}
          branch: ${{ github.head_ref }}
```

この変更により：

1. `secrets.PUSH_AND_RUN_WORKFLOW_TOKEN` が存在する場合、それが優先的に使用されます。PAT によるプッシュとなるため、CI がトリガーされます。
2. 存在しない場合、`secrets.GITHUB_TOKEN` が使用されます（従来の挙動）。

## 次のアクション

この変更を含む PR をマージし、実際のプルリクエストで自動修正が発生した際に CI が正しく再実行されるかを確認してください。
