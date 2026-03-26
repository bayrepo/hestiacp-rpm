<?php
$TAB = "DB";

// Main include
include $_SERVER["DOCUMENT_ROOT"] . "/inc/main.php";

//Update data before $output
exec(HESTIA_CMD . "v-update-databases-disk $user", $output, $return_var);
unset($output);

// Data
exec(HESTIA_CMD . "v-list-databases $user json", $output, $return_var);
$data = json_decode(implode("", $output), true);
if ($_SESSION["userSortOrder"] == "name") {
    ksort($data);
} else {
    $data = array_reverse($data, true);
}
unset($output);

// Render page
render_page($user, $TAB, "list_db");

// Back uri
$_SESSION["back"] = $_SERVER["REQUEST_URI"];
