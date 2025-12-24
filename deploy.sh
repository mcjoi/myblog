#!/bin/bash
set -e

# =========================
# 기본 경로 설정
# =========================
PROJECT_ROOT="$(pwd)"
WEB_DIR="$PROJECT_ROOT/website/web"
POSTS_DIR="$PROJECT_ROOT/website/posts"
BASE_URL="https://mcjoi.github.io"

echo "Deploy Starting..."
echo "=============================="

# =========================
# 1/4 Flutter Web 결과물 복사
# =========================
echo "1/4 Copy build/web → website/web (overwrite only)"

# ❗ 기존 파일 삭제 ❌
# rm -rf "$WEB_DIR"/*

# ✅ 기존 파일 유지 + 동일 파일만 덮어쓰기
cp -R build/web/. "$WEB_DIR/"

echo "Web files copied safely."
echo "------------------------------"

# =========================
# 2/4 posts/index.json 생성
# =========================
echo "2/4 Generate posts/index.json"
dart ./tools/generate_index.dart
echo "index.json generated."
echo "------------------------------"

# =========================
# 3/4 sitemap.xml / robots.txt 생성
# =========================
echo "3/4 Generate sitemap.xml"
dart ./tools/generate_sitemap.dart "$BASE_URL"
echo "sitemap.xml generated."
echo "------------------------------"

# =========================
# 4/4 website/web GitHub 업로드
# =========================
echo "4/4 Upload website/web"
cd "$WEB_DIR"

git status
git add .
git commit -m "Deploy web ($(date '+%Y-%m-%d %H:%M'))" \
  || echo "No web changes to commit."

git push origin master
echo "website/web upload completed."
echo "------------------------------"

# =========================
# website/posts GitHub 업로드
# =========================
echo "Upload website/posts"
cd "$POSTS_DIR"

git status
git add .
git commit -m "Update posts ($(date '+%Y-%m-%d %H:%M'))" \
  || echo "No post changes to commit."

git push origin master
echo "website/posts upload completed."
echo "=============================="
echo "Deploy Finished Successfully 🎉"