<?php
header('Content-Type: application/json');
$cid_file = __DIR__ . '/../latest.cid';
if (file_exists($cid_file)) {
    $cid = trim(file_get_contents($cid_file));
    echo json_encode(["cid" => $cid]);
} else {
    echo json_encode(["error" => "CID not found"]);
} 