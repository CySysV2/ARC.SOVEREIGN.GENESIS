<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
$mem = new Memcached();
$mem->addServer("127.0.0.1", 11249);
echo json_encode([
  "cid" => $mem->get("latest_cid"),
  "epoch" => $mem->get("epoch_status"),
  "synced" => $mem->get("last_sync_time")
]);
?> 