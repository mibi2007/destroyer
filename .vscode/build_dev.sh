#!/bin/sh
SOURCE="dist/apps/student/dev"
TARGET="s3://dev.kyons.vn"
npx nx run student:build --configuration=dev
echo "Start delete $TARGET"
AWS_PROFILE=kyons-importer aws s3 rm --recursive $TARGET
echo "Deleted"
echo "Start copy $SOURCE to $TARGET"
AWS_PROFILE=kyons-importer aws s3 cp --recursive $SOURCE $TARGET
echo "Done copy"
echo "Done deploy"
