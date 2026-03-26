<?php
$TAB = "WEB";

// Main include
include $_SERVER["DOCUMENT_ROOT"] . "/inc/main.php";

//Update data before output
exec(HESTIA_CMD . "v-update-web-domains-disk " . $user, $output, $return_var);
unset($output);
exec(HESTIA_CMD . "v-update-web-domains-stat " . $user, $output, $return_var);
unset($output);
exec(HESTIA_CMD . "v-update-web-domains-traff " . $user, $output, $return_var);
unset($output);

// Data
exec(
    HESTIA_CMD . "v-list-web-domains " . $user . " 'json'",
    $output,
    $return_var,
);
$data = json_decode(implode("", $output), true);
if ($_SESSION["userSortOrder"] == "name") {
    ksort($data);
} else {
    $data = array_reverse($data, true);
}
$ips = json_decode(shell_exec(HESTIA_CMD . "v-list-sys-ips json"), true);

// Render page
render_page($user, $TAB, "list_web");

// Back uri
$_SESSION["back"] = $_SERVER["REQUEST_URI"];
