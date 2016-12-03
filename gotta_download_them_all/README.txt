This project provides tools to help make it easy for you to create a git clone
of all 6.x, 7.x, and 8.x modules, themes, and distributions that have releases.

Note: This requires the master version of Drush

How to use it:

0. cd /path/to/gotta_download_them_all
1. chmod u+x *.sh
2. ./download.sh allmodules.txt
3. ./download.sh allthemes.txt
4. ./download.sh alldistributions.txt

Then periodically to update those directories:

./freshen.sh

### To update through the drupal.org release history:

./refresh-lists.sh

* A backup copy of the previous lists will be stored in /backups/YYYY-MM-DD/

Note: This script will exclude sandbox projects.

### For the project maintainer who has access to drupal.org:

* Update list of modules:
drush @do_prod sql-query "SELECT distinct pp.uri FROM project_projects pp INNER JOIN project_release_nodes prn ON prn.pid = pp.nid INNER JOIN node n ON pp.nid = n.nid WHERE n.type = 'project_module' AND (left(prn.version, 3) = '8.x' OR left(prn.version, 3) = '7.x' OR left(prn.version, 3) = '6.x') AND n.status = 1 ORDER BY pp.uri" > allmodules.txt

* Update the list of themes:
drush @do_prod sql-query "SELECT distinct pp.uri FROM project_projects pp INNER JOIN project_release_nodes prn ON prn.pid = pp.nid INNER JOIN node n ON pp.nid = n.nid WHERE n.type = 'project_theme' AND (left(prn.version, 3) = '8.x' OR left(prn.version, 3) = '7.x' OR left(prn.version, 3) = '6.x') AND n.status = 1 ORDER BY pp.uri" > allthemes.txt

* Update the list of distributions:
drush @do_prod sql-query "SELECT distinct pp.uri FROM project_projects pp INNER JOIN project_release_nodes prn ON prn.pid = pp.nid INNER JOIN node n ON pp.nid = n.nid WHERE n.type = 'project_distribution' AND (left(prn.version, 3) = '8.x' OR left(prn.version, 3) = '7.x' OR left(prn.version, 3) = '6.x') AND n.status = 1 ORDER BY pp.uri" > alldistributions.txt

* clean up the lists:
sed -i '' 's/^[ \t]*//;s/[ \t]*$//' all*.txt
sed -i '' '/^$/d' all*.txt

then git commit and push.

