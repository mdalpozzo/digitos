#!/bin/bash

echo "Setting environment variables for Codemagic"

# Write the NHOST_GRAPHQL_ENDPOINT to the .env file, overwriting existing content
echo "NHOST_GRAPHQL_ENDPOINT=$NHOST_GRAPHQL_ENDPOINT" >> $FCI_BUILD_DIR/.env

# Append other vars to the .env file
echo "NHOST_GRAPHQL_ADMIN_SECRET=$NHOST_GRAPHQL_ADMIN_SECRET" > $FCI_BUILD_DIR/.env

echo "FIREBASE_WEB_API_KEY=$FIREBASE_WEB_API_KEY" > $FCI_BUILD_DIR/.env
echo "FIREBASE_WEB_APP_ID=$FIREBASE_WEB_APP_ID" > $FCI_BUILD_DIR/.env
echo "FIREBASE_WEB_MESSAGING_SENDER_ID=$FIREBASE_WEB_MESSAGING_SENDER_ID" > $FCI_BUILD_DIR/.env
echo "FIREBASE_WEB_PROJECT_ID=$FIREBASE_WEB_PROJECT_ID" > $FCI_BUILD_DIR/.env
echo "FIREBASE_WEB_AUTH_DOMAIN=$FIREBASE_WEB_AUTH_DOMAIN" > $FCI_BUILD_DIR/.env
echo "FIREBASE_WEB_DATABASE_URL=$FIREBASE_WEB_DATABASE_URL" > $FCI_BUILD_DIR/.env
echo "FIREBASE_WEB_STORAGE_BUCKET=$FIREBASE_WEB_STORAGE_BUCKET" > $FCI_BUILD_DIR/.env
echo "FIREBASE_WEB_MEASUREMENT_ID=$FIREBASE_WEB_MEASUREMENT_ID" > $FCI_BUILD_DIR/.env

echo "FIREBASE_ANDROID_API_KEY=$FIREBASE_ANDROID_API_KEY" > $FCI_BUILD_DIR/.env
echo "FIREBASE_ANDROID_APP_ID=$FIREBASE_ANDROID_APP_ID" > $FCI_BUILD_DIR/.env
echo "FIREBASE_ANDROID_MESSAGING_SENDER_ID=$FIREBASE_ANDROID_MESSAGING_SENDER_ID" > $FCI_BUILD_DIR/.env
echo "FIREBASE_ANDROID_PROJECT_ID=$FIREBASE_ANDROID_PROJECT_ID" > $FCI_BUILD_DIR/.env
echo "FIREBASE_ANDROID_DATABASE_URL=$FIREBASE_ANDROID_DATABASE_URL" > $FCI_BUILD_DIR/.env
echo "FIREBASE_ANDROID_STORAGE_BUCKET=$FIREBASE_ANDROID_STORAGE_BUCKET" > $FCI_BUILD_DIR/.env

echo "FIREBASE_IOS_API_KEY=$FIREBASE_IOS_API_KEY" > $FCI_BUILD_DIR/.env
echo "FIREBASE_IOS_APP_ID=$FIREBASE_IOS_APP_ID" > $FCI_BUILD_DIR/.env
echo "FIREBASE_IOS_MESSAGING_SENDER_ID=$FIREBASE_IOS_MESSAGING_SENDER_ID" > $FCI_BUILD_DIR/.env
echo "FIREBASE_IOS_PROJECT_ID=$FIREBASE_IOS_PROJECT_ID" > $FCI_BUILD_DIR/.env
echo "FIREBASE_IOS_DATABASE_URL=$FIREBASE_IOS_DATABASE_URL" > $FCI_BUILD_DIR/.env
echo "FIREBASE_IOS_STORAGE_BUCKET=$FIREBASE_IOS_STORAGE_BUCKET" > $FCI_BUILD_DIR/.env
echo "FIREBASE_IOS_CLIENT_ID=$FIREBASE_IOS_CLIENT_ID" > $FCI_BUILD_DIR/.env
echo "FIREBASE_IOS_BUNDLE_ID=$FIREBASE_IOS_BUNDLE_ID" > $FCI_BUILD_DIR/.env

echo "FIREBASE_MACOS_API_KEY=$FIREBASE_MACOS_API_KEY" > $FCI_BUILD_DIR/.env
echo "FIREBASE_MACOS_APP_ID=$FIREBASE_MACOS_APP_ID" > $FCI_BUILD_DIR/.env
echo "FIREBASE_MACOS_MESSAGING_SENDER_ID=$FIREBASE_MACOS_MESSAGING_SENDER_ID" > $FCI_BUILD_DIR/.env
echo "FIREBASE_MACOS_PROJECT_ID=$FIREBASE_MACOS_PROJECT_ID" > $FCI_BUILD_DIR/.env
echo "FIREBASE_MACOS_DATABASE_URL=$FIREBASE_MACOS_DATABASE_URL" > $FCI_BUILD_DIR/.env
echo "FIREBASE_MACOS_STORAGE_BUCKET=$FIREBASE_MACOS_STORAGE_BUCKET" > $FCI_BUILD_DIR/.env
echo "FIREBASE_MACOS_IOS_BUNDLE_ID=$FIREBASE_MACOS_IOS_BUNDLE_ID" > $FCI_BUILD_DIR/.env