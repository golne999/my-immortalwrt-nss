#!/bin/bash
set -e

# 项目根目录
ROOT_DIR=$(pwd)
WORK_BRANCH="main"
PATCH_BRANCH="nss-patch"

# 设置 remote
git remote add upstream https://github.com/immortalwrt/immortalwrt || true
git fetch upstream

# 1. 更新主线
git checkout $WORK_BRANCH
git pull
git merge upstream/openwrt-24.10

# 2. Cherry-pick NSS commit（如有多个，换行添加）
COMMITS=(
  a2888a4
)

for COMMIT in "${COMMITS[@]}"; do
  echo "Cherry-picking $COMMIT..."
  git cherry-pick $COMMIT || {
    echo "❌ Cherry-pick $COMMIT failed. Resolve conflicts manually."
    exit 1
  }
done

# 3. 更新 feeds
./scripts/feeds clean
./scripts/feeds update -a
./scripts/feeds install -a
