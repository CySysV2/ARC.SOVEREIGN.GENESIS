<?php
header('Content-Type: application/json');
$cidFile = __DIR__ . '/../latest.cid';
$cid = false;
if (file_exists($cidFile)) {
    $cid = trim(file_get_contents($cidFile));
}
echo json_encode([
    'cid' => $cid,
    'epoch' => false,
    'synced' => false
]);
?> 