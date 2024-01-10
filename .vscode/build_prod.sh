#!/bin/sh
SOURCE="dist/apps/student/prod"
TARGET="s3://student.kyons.vn"
npx nx run student:build
echo "Start delete $TARGET"
AWS_PROFILE=kyons-importer aws s3 rm --recursive $TARGET
echo "Deleted"
echo "Start copy $SOURCE to $TARGET"
AWS_PROFILE=kyons-importer aws s3 cp --recursive $SOURCE $TARGET
echo "Done copy"
echo "Done deploy"
