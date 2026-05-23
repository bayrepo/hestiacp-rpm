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
    HESTIA_CMD . "v-ext-modules state update_module json",
    $output,
    $return_var,
);
$check_update_enabled = json_decode(implode("", $output), true);
if (
    $return_var != 0 ||
    empty($check_update_enabled) ||
    $check_update_enabled[0]["STATE"] != "enabled"
) {
    header("Location: /list/extmodules/");
    exit();
}
unset($output);

$error_message = "";

if (isset($_GET["action"]) && $_GET["action"] === "update") {
    exec(
        HESTIA_CMD . "v-ext-modules-run update_module synctemplates",
        $output,
        $return_var,
    );
    if ($return_var != 0) {
        $error_message = $output;
    }
    unset($output);
}

// Data
exec(
    HESTIA_CMD . "v-ext-modules-run update_module listsynctemplates json",
    $output,
    $return_var,
);
$synctemplates_list = [];
if ($return_var == 0) {
    $synctemplates_list = json_decode(implode("", $output), true);
} else {
    $error_message = implode("<br/>\n", $output);
}

unset($output);

// Render page
render_page($user, $TAB, "extmodules/extmodules_update_module");

// Back uri
$_SESSION["back"] = $_SERVER["REQUEST_URI"];
