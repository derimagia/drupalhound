#!/usr/bin/env php
<?php

# Download XML file.
echo shell_exec('curl https://updates.drupal.org/release-history/project-list/all/projects.xml -o projects.xml');

# Parse Projects to get name and type (distro, module, theme).
$projects = array();
$project_type_map = array(
  'project_module' => 'module',
  'project_theme' => 'theme',
  'project_distribution' => 'distribution',
);

if (file_exists('projects.xml')) {
  $xml = simplexml_load_file('projects.xml');
  foreach ($xml as $project) {
    $machine_name = (string) $project->short_name;
    $project_type = (string) $project->type;
    if ($project->project_status == 'published'
      && !is_numeric($machine_name)
      && isset($project_type_map[$project_type])) {
      $projects[$project_type_map[$project_type]][] = $machine_name;
    }
  }
}
else {
  exit('Failed to open projects.xml.');
}

# Rewrite all[distro|module|theme]s.txt with latest.
if ($projects) {
  foreach ($projects as $project_type => $projects) {
    file_put_contents('all' . $project_type . 's.txt', implode("\n", $projects));
  }
}

# Cleanup (Optionally) remove modules that are no longer in the txt files.

