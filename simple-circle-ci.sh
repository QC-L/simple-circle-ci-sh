#!/bin/sh
mkdir .circleci && cd .circleci
check_email=`git config user.email`
echo $check_email
ssh-keygen -t rsa -b 4096 -C $check_email <<EOF
deploy_key
\n
\n
EOF
touch config.yml
(
cat <<EOF
version: 2
jobs:
  build:
    docker:
      - image: circleci/node:8.10.0
    working_directory: ~/repo
    steps:
      - add_ssh_keys:
          fingerprints:
            - "enter your key"
      - checkout
      - restore_cache:
          keys:
          - v1-dependencies-{{ checksum "package.json" }}
          - v1-dependencies-
      - run: yarn
      - save_cache:
          paths:
            - node_modules
          key: v1-dependencies-{{ checksum "package.json" }}
      - run:
          name: Yarn build site
          command: yarn build 
      - run:
          name: Run deploy scripts
          command: bash ./.script/deploy.sh                   
EOF
) >config.yml

cd ..
(
cat <<EOF
.circleci/deploy_key
.circleci/deploy_key.pub
simple-circle-ci.sh
EOF
)>> .gitignore
yarn add gh-pages
mkdir .scripts/ && cd .scripts/
touch deploy.sh

(
cat <<EOF
git config --global --replace-all user.name "QC.L"
git config --global --replace-all user.email "github@liqichang.com"
git remote set-url origin "`git config remote.origin.url`"
chmod -R 777 node_modules/gh-pages/
yarn deploy
EOF
) >deploy.sh