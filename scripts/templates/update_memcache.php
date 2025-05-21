<?php
header('Content-Type: application/json');
$cid_file = __DIR__ . '/../latest.cid';
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    if (isset($input['cid'])) {
        file_put_contents($cid_file, $input['cid']);
        echo json_encode(["status" => "updated", "cid" => $input['cid']]);
    } else {
        echo json_encode(["error" => "No CID provided"]);
    }
} else {
    echo json_encode(["error" => "POST required"]);
} 