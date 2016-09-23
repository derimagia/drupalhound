#!/usr/bin/env bash
DRUPAL_VERSION=7

PROJECTS_PATH="https://www.drupal.org/api-d$DRUPAL_VERSION/node.json?type=project_module&limit=999999"

# MS_BETWEEN_POLL is 604800 seconds, or 1 week
JQ_FILTER='
{
	"dbpath": "data",
	"max-concurrent-indexers": 6,
	"repos":
		[.list[] |  {
			"key" : .title,
			"value" : {
				"url": "git://git.drupal.org/project/\(.field_project_machine_name).git",
				"ms-between-poll": 604800
			}
		}] | from_entries
}'

mkdir -p data

# Convert the drupal projects into a config for drupalhound
config=$(curl -s "$PROJECTS_PATH" | jq -r "$JQ_FILTER")

echo $config

for remote in $(echo $config | jq -r '.repos[] .url'); do
	branch=$(git ls-remote -h "$remote" | cut -f2 | fgrep "refs/heads/$DRUPAL_VERSION.x" | sed 's|refs/heads/||' | sort -r)
    echo "${branch:-master}"
done