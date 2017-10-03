<?php

$url = parse_url($_SERVER['REQUEST_URI']);
if (file_exists('.' . $url['path'])) {
  // Serve the requested resource as-is.
  return false;
}

// The use of a router-script means that a number of $_SERVER variables has to
// be updated to point to the index-file.
$index_file_relative = DIRECTORY_SEPARATOR . 'index.php';
$index_file_absolute = $_SERVER['DOCUMENT_ROOT'] . $index_file_relative;

// SCRIPT_NAME and PHP_SELF will either point to /index.php or contain the full
// virtual path being requested depending on the url being requested. They
// should always point to index.php relative to document root.
$_SERVER['PHP_SELF'] = $_SERVER['SCRIPT_NAME'] = $index_file_relative;

// SCRIPT_FILENAME will point to the router-script itself, it should point to
// the full path to index.php.
// Require the main index-file and let core take over.
require $_SERVER['SCRIPT_FILENAME'] = $index_file_absolute;