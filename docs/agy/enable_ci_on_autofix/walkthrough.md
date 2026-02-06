# 変更確認: 自動修正コミットでの CI トリガー有効化 (Ver 2)

## 概要

`.github/workflows/lint-markdown.yml` を再修正し、より確実に CI をトリガーする方法に変更しました。
以前の方法 (`ad-m/github-push-action`) では CI がトリガーされなかったため、`actions/checkout` でトークン認証を行い、標準的な `git push` を使用する方式に切り替えました。

## 変更されたファイル

- [.github/workflows/lint-markdown.yml](../../../.github/workflows/lint-markdown.yml)

## 検証結果

### コード変更の確認

#### 1. Checkout ステップの認証

チェックアウト時に PAT を使用するように変更しました。これにより、以降の git 操作（プッシュ含む）でこのトークンが使用されます。

```yaml
      - name: Checkout
        uses: actions/checkout@v6
        with:
          fetch-depth: 0
          token: ${{ secrets.PUSH_AND_RUN_WORKFLOW_TOKEN || secrets.GITHUB_TOKEN }}
```

#### 2. 直接 push の実行

外部アクションの使用をやめ、シンプルに現在の HEAD をプッシュするように変更しました。

```yaml
      - name: Push changes (PR only)
        # ... (条件省略)
        run: git push origin HEAD:${{ github.head_ref }}
```

## 次のアクション

1. **変更をプッシュ**: この変更をリモートブランチにプッシュしてください。
2. **動作確認**: 次回以降、自動修正（auto-fix）が発生した際、新しいコミットに対して yamllint や shellcheck などの CI が自動的に開始されることを確認してください。
