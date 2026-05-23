<?php
use function Hestiacp\quoteshellarg\quoteshellarg;

$TAB = "EXTMODULES";

// Main include
include $_SERVER["DOCUMENT_ROOT"] . "/inc/main.php";

// Check user
if ($_SESSION["userContext"] != "admin") {
    header("Location: /list/user");
    exit();
}

exec(
    HESTIA_CMD . "v-ext-modules state bunkerweb_module json",
    $output,
    $return_var,
);
$check_bunkerweb_enabled = json_decode(implode("", $output), true);
if (
    $return_var != 0 ||
    empty($check_bunkerweb_enabled) ||
    $check_bunkerweb_enabled[0]["STATE"] != "enabled"
) {
    header("Location: /list/extmodules/");
    exit();
}
unset($output);

$error_message = "";

// Data
exec(
    HESTIA_CMD . "v-ext-modules-run bunkerweb_module list json",
    $output,
    $return_var,
);
$bunkerweb_list = [];
if ($return_var == 0) {
    $bunkerweb_list = json_decode(implode("", $output), true);
} else {
    $error_message = implode("<br/>\n", $output);
}

unset($output);

//Get current ip
exec(HESTIA_CMD . "v-list-sys-ips json", $output, $return_var);
$server_ip = "127.0.0.1";
if ($return_var == 0) {
    $server_ip_list = json_decode(implode("", $output), true);
    if (!empty($server_ip_list)) {
        $server_ip = array_key_first($server_ip_list);
    }
}

unset($output);

//Get UI and  API passw
// Data
exec(
    HESTIA_CMD . "v-ext-modules-run bunkerweb_module passwd json",
    $output,
    $return_var,
);

$pass = [];
if ($return_var == 0) {
    $pass = json_decode(implode("", $output), true);
} else {
    $error_message .= implode("<br/>\n", $output);
}

// Render page
render_page($user, $TAB, "extmodules/extmodules_bunkerweb_module");

// Back uri
$_SESSION["back"] = $_SERVER["REQUEST_URI"];
